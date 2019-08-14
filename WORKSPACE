workspace(name = "rules_java")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "bazel_federation",
    url = "https://github.com/bazelbuild/bazel-federation/archive/01dc3f937696174c9764e23978f9d2e7105fd855.zip",
    sha256 = "64229f859bb0465fcdb654b31b3e547bbd5462005beaebbc09eb0ec735044cdd",
    strip_prefix = "bazel-federation-01dc3f937696174c9764e23978f9d2e7105fd855",
    type = "zip",
)

# Load the dependencies
load("@bazel_federation//:repositories.bzl", "bazel_skylib")
bazel_skylib()

load("@rules_java//java:repositories.bzl", "rules_java_dependencies", "rules_java_toolchains")
rules_java_dependencies()
rules_java_toolchains()

# Set up the toolchains we need
# TODO(aiuto): Define a standard annotation scheme so that the federation
# maintainers can easily extract this to find create rules_java_setup()
load("@rules_java//java:repositories.bzl", "rules_java_toolchains")
rules_java_toolchains()

#
# Dependencies for development of rules_java itself.
#
load("//:internal_deps.bzl", "rules_java_internal_deps")
rules_java_internal_deps()

load("//:internal_setup.bzl", "rules_java_internal_setup")
rules_java_internal_setup()
