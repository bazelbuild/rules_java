workspace(name = "rules_java")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "bazel_federation",
    url = "https://github.com/bazelbuild/bazel-federation/archive/01dc3f937696174c9764e23978f9d2e7105fd855.zip",
    sha256 = "64229f859bb0465fcdb654b31b3e547bbd5462005beaebbc09eb0ec735044cdd",
    strip_prefix = "bazel-federation-01dc3f937696174c9764e23978f9d2e7105fd855",
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
