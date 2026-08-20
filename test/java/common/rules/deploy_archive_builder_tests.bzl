"""Tests for DeployArchiveBuilder."""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_binary.bzl", "java_binary")
load("//test/java/testutil:mock_java_toolchain.bzl", "mock_java_toolchain")

def _test_custom_singlejar(name):
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
    )
    util.helper_target(
        java_binary,
        name = name + "/binary",
        srcs = [name + "/main.java"],
        main_class = "com.google.test.main",
    )

    analysis_test(
        name = name,
        impl = _test_custom_singlejar_impl,
        target = name + "/binary",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
        # Starlark rules are only used with Bazel 8 onwards.
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _test_custom_singlejar_impl(env, target):
    action = env.expect.that_target(target).action_named("JavaDeployJar")
    action.inputs().contains_at_least_predicates(
        [
            matching.file_path_matches("*/test_custom_singlejar/binary.jar"),
        ],
    )

def deploy_archive_builder_test_suite(name):
    """Test suite for java_binary deploy archive."""
    test_suite(
        name = name,
        tests = [
            _test_custom_singlejar,
        ],
    )
