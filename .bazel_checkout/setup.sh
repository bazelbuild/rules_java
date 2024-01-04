#!/usr/bin/env bash
set -e
set -x

FAKE_BCR_ROOT=$(mktemp -d --tmpdir fake-bcr.XXX)
FAKE_RULES_JAVA_ROOT=${FAKE_BCR_ROOT}/modules/rules_java
FAKE_MODULE_VERSION=9999
FAKE_MODULE_ROOT=${FAKE_RULES_JAVA_ROOT}/${FAKE_MODULE_VERSION}
FAKE_ARCHIVE=${FAKE_MODULE_ROOT}/rules_java.tar.gz
mkdir -p ${FAKE_MODULE_ROOT}

# relying on the line number is not great, but :shrugs:
sed -e "3 c version = \"${FAKE_MODULE_VERSION}\"," ../MODULE.bazel > ${FAKE_MODULE_ROOT}/MODULE.bazel

tar zcf ${FAKE_ARCHIVE} ../
RULES_JAVA_INTEGRITY_SHA256=`cat ${FAKE_ARCHIVE} | openssl dgst -sha256 -binary | base64`
cat << EOF > ${FAKE_MODULE_ROOT}/source.json
{
    "integrity": "sha256-${RULES_JAVA_INTEGRITY_SHA256}",
    "strip_prefix": "",
    "url": "file://${FAKE_ARCHIVE}"
}
EOF

# fetch and setup bazel sources
git init
git remote add origin https://github.com/bazelbuild/bazel.git
git pull origin master
sed -i.bak -e 's/^# android_sdk_repository/android_sdk_repository/' \
  -e 's/^#  android_ndk_repository/android_ndk_repository/' \
  WORKSPACE.bzlmod
rm -f WORKSPACE.bzlmod.bak
rm -rf $HOME/bazeltest
mkdir $HOME/bazeltest

echo "common --registry=https://bcr.bazel.build" >> .bazelrc
echo "common --registry=file://${FAKE_BCR_ROOT}" >> .bazelrc
echo "add_to_bazelrc \"common --registry=https://bcr.bazel.build\"" >> src/test/shell/testenv.sh.tmpl
echo "add_to_bazelrc \"common --registry=file://${FAKE_BCR_ROOT}\"" >> src/test/shell/testenv.sh.tmpl

SED_CMD="s/bazel_dep(name = \"rules_java\".*/bazel_dep(name = \"rules_java\", version = \"${FAKE_MODULE_VERSION}\")/"
sed -i "${SED_CMD}" MODULE.bazel
sed -i "${SED_CMD}" src/MODULE.tools

BAZEL_QUIET_MODE_ARGS="--ui_event_filters=error,fail"

bazel run ${BAZEL_QUIET_MODE_ARGS} //src/test/tools/bzlmod:update_default_lock_file -- \
  --registry="https://bcr.bazel.build" --registry="file://${FAKE_BCR_ROOT}" ${BAZEL_QUIET_MODE_ARGS}
bazel mod deps --lockfile_mode=update
# populate repo cache so tests don't need to access network
bazel fetch --config=ci-linux --all ${BAZEL_QUIET_MODE_ARGS}
