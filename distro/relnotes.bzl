"""Release notes generator"""

def print_rel_notes(*, name, version, archive):
    native.genrule(
        name = name,
        outs = [name + ".txt"],
        cmd = """
              last_rel=$$(git describe --tags --abbrev=0)
              changelog=$$(/usr/bin/git log tags/$$last_rel..HEAD --format=oneline --invert-grep --grep 'ignore-relnotes' --)
              sha=$$(/usr/bin/sha256sum $(SRCS) | cut -d ' '  -f1)
              cat > $@ <<EOF
**Changes since $$last_rel**
$$changelog

**MODULE.bazel setup**
~~~
bazel_dep(name = "rules_java", version = "{VERSION}")
~~~

**WORKSPACE setup**

With Bazel 8.0.0 and before 8.3.0, add the following to your `.bazelrc` file:

~~~
# https://github.com/bazelbuild/bazel/pull/26119
common --repositories_without_autoloads=bazel_features_version,bazel_features_globals
~~~

In all cases, add the following to your `WORKSPACE` file:

~~~
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "rules_java",
    urls = [
        "https://github.com/bazelbuild/rules_java/releases/download/{VERSION}/rules_java-{VERSION}.tar.gz",
    ],
    sha256 = "$$sha",
)

load("@rules_java//java:rules_java_deps.bzl", "rules_java_dependencies")
rules_java_dependencies()

load("@bazel_features//:deps.bzl", "bazel_features_deps")
bazel_features_deps()

# note that the following line is what is minimally required from protobuf for the java rules
# consider using the protobuf_deps() public API from @com_google_protobuf//:protobuf_deps.bzl
load("@com_google_protobuf//bazel/private:proto_bazel_features.bzl", "proto_bazel_features")  # buildifier: disable=bzl-visibility
proto_bazel_features(name = "proto_bazel_features")

# register toolchains
load("@rules_java//java:repositories.bzl", "rules_java_toolchains")
rules_java_toolchains()
~~~

**Using the rules**
See [the source](https://github.com/bazelbuild/rules_java/tree/{VERSION}).

EOF
              """.format(ARCHIVE = archive, VERSION = version),
        srcs = [archive],
        tags = ["local", "manual"],
        visibility = ["//test:__pkg__"],
    )
