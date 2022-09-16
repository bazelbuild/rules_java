workspace(name = "rules_java")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_federation",
    sha256 = "0d6893f0d18f417a3324ce7f0ed2e6e5b825d6d5ab42f0f3d7877cb313f36453",
    strip_prefix = "bazel-federation-6ad33bc586701e9836a2bf4432c7aff1235b04d2",
    type = "zip",
    url = "https://github.com/bazelbuild/bazel-federation/archive/6ad33bc586701e9836a2bf4432c7aff1235b04d2.zip",  # 2021-07-12
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
