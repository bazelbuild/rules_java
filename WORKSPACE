workspace(name = "rules_java")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "bazel_federation",
    url = "https://github.com/bazelbuild/bazel-federation/archive/ade5370cb2c8be9e88a2ba6a15037139ae409f9c.zip",
    sha256 = "0239a8af3fe66d17464a3be706109c021df31c461df3c447995f25efb63a1b22",
    strip_prefix = "bazel-federation-ade5370cb2c8be9e88a2ba6a15037139ae409f9c",
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
