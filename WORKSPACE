load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

workspace(name = "rules_java")

http_archive(
    name = "bazel_federation",
    url = "https://github.com/bazelbuild/bazel-federation/archive/d0bb2efce669b28b1bf3c6db98cea38704ced82d.zip",
    sha256 = "0c8646a871d25b62a6f2cdd7c21a3dc617a37701adea2a4e678394a084966e8c",
    strip_prefix = "bazel_federation-d0bb2efce669b28b1bf3c6db98cea38704ced82d",
    type = "zip",
)

load("@bazel_federation//:repositories.bzl", "rules_java_deps")
rules_java_deps()

load("@bazel_federation//setup:rules_java.bzl", "rules_java_setup")
rules_java_setup()

#
# Dependencies for development of rules_java itself.
#
load("//:internal_deps.bzl", "rules_java_internal_deps")
rules_java_internal_deps()

load("//:internal_setup.bzl", "rules_java_internal_setup")
rules_java_internal_setup()
