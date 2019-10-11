workspace(name = "rules_java")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "bazel_federation",
    url = "https://github.com/bazelbuild/bazel-federation/archive/f0e5eda7f0cbfe67f126ef4dacb18c89039b0506.zip", # 2019-09-30
    sha256 = "33222ab7bcc430f1ff1db8788c2e0118b749319dd572476c4fd02322d7d15792",
    strip_prefix = "bazel-federation-f0e5eda7f0cbfe67f126ef4dacb18c89039b0506",
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
