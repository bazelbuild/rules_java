"""Fake test toolchain for testing arbitrary --platforms"""

load("@bazel_features//:features.bzl", "bazel_features")
load("@rules_testing//lib:util.bzl", "util")
load("//java/common:java_semantics.bzl", "semantics")

def mock_test_toolchains(name, cpu, os):
    """Creates and returns a list of mock test toolchains for the given cpu and os if they're required.

    Args:
        name: The name of the toolchain.
        cpu: The cpu for toolchain should be compatible with.
        os: The os the toolchain should be compatible with.
    Returns:
        A list of toolchain targets.
    """
    if not bazel_features.toolchains.has_default_test_toolchain_type:
        return []
    util.helper_target(
        rule = native.toolchain,
        name = name,
        toolchain_type = Label(semantics.TOOLS_TEST_DEFAULT_TEST_TOOLCHAIN_TYPE),
        toolchain = Label(semantics.TOOLS_TEST_EMPTY_TOOLCHAIN),
        target_compatible_with = [
            "@platforms//os:" + os,
            "@platforms//cpu:" + cpu,
        ],
    )
    return [native.package_relative_label(name)]
