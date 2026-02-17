#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

RELEASE_VERSION=${1}

# update MODULE.bazel with the version number
sed -i "3s/version = \"0.0.0\"/version = \"${RELEASE_VERSION}\"/" MODULE.bazel

# create release artifacts
bazel build //distro:relnotes //distro:rules_java-${RELEASE_VERSION}.tar.gz

# revert change to MODULE.bazel
git checkout -- MODULE.bazel

# print the release notes for release.yaml
cat bazel-bin/distro/relnotes.txt
