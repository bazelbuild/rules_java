workspace(name = "rules_java")

load("@rules_java//java:repositories.bzl", "rules_java_dependencies", "rules_java_toolchains")
rules_java_dependencies()
rules_java_toolchains()


#
# Dependencies for development of rules_java itself.
#
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "rules_pkg",
    url = "https://github.com/bazelbuild/rules_pkg/releases/download/0.2.1/rules_pkg-0.2.1.tar.gz",
    sha256 = "04c1eab736f508e94c297455915b6371432cbc4106765b5252b444d1656db051",
)
load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")
rules_pkg_dependencies()
