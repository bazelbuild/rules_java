"""Parameterized tests for java_library with --java_launcher"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_library.bzl", "java_library")

def _test_java_library_rule_outputs(name):
    util.helper_target(
        java_library,
        name = name + "/test_lib",
        srcs = ["A.java"],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_rule_outputs_impl,
        target = name + "/test_lib",
    )

def _test_java_library_rule_outputs_impl(env, target):
    env.expect.that_target(target).default_outputs().contains_exactly([
        "{package}/lib{name}.jar",
    ])

JAVA_LIBRARY_LAUNCHER_TESTS = [
    _test_java_library_rule_outputs,
]
