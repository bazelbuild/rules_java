"""Parameterized tests for java_binary with --java_launcher"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_binary.bzl", "java_binary")

def _test_java_binary_non_executable_rule_outputs(name):
    util.helper_target(
        java_binary,
        name = name + "/test_app_noexec",
        srcs = ["InputFile.java"],
        create_executable = 0,
    )

    analysis_test(
        name = name,
        impl = _test_java_binary_non_executable_rule_outputs_impl,
        target = name + "/test_app_noexec",
    )

def _test_java_binary_non_executable_rule_outputs_impl(env, target):
    env.expect.that_target(target).default_outputs().contains_exactly([
        "{package}/{name}.jar",
    ])

JAVA_BINARY_LAUNCHER_TESTS = [
    _test_java_binary_non_executable_rule_outputs,
]
