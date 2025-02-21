"""Tests for the java_binary rule"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_binary.bzl", "java_binary")
load("//java/test/testutil:java_info_subject.bzl", "java_info_subject")

def _test_java_binary_provides_binary_java_info(name):
    util.helper_target(java_binary, name = "bin", srcs = ["Main.java"])

    analysis_test(
        name = name,
        impl = _test_java_binary_provides_binary_java_info_impl,
        target = Label(":bin"),
        attr_values = {"tags": ["min_bazel_7"]},
    )

def _test_java_binary_provides_binary_java_info_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.compilation_args().equals(None)
    assert_java_info.is_binary().equals(True)

def _test_stamp_conversion_does_not_override_int(name):
    util.helper_target(
        java_binary,
        name = name + "/bin",
        srcs = ["Main.java"],
        stamp = -1,
    )

    analysis_test(
        name = name,
        impl = _test_stamp_conversion_does_not_override_int_impl,
        target = name + "/bin",
        config_settings = {
            "//command_line_option:stamp": False,
        },
        # deploy jars are in a separate rule in Bazel 7, Bazel 6 generated build-info differently
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _test_stamp_conversion_does_not_override_int_impl(env, target):
    assert_deploy_jar_action = env.expect.that_target(target).action_generating(
        "{package}/{name}_deploy.jar",
    )

    assert_deploy_jar_action.inputs().not_contains_predicate(
        matching.file_basename_equals("non_volatile_file.properties"),
    )
    assert_deploy_jar_action.inputs().contains_predicate(
        matching.file_basename_equals("redacted_file.properties"),
    )

def java_binary_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_java_binary_provides_binary_java_info,
            _test_stamp_conversion_does_not_override_int,
        ],
    )
