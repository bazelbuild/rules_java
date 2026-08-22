"""Tests for the Bazel java_import rule"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_import.bzl", "java_import")

def _test_import_deps_checker_checking_mode(name):
    util.helper_target(
        java_import,
        name = name + "/import-jar",
        jars = ["import.jar"],
        deps = [name + "/depjar"],
    )
    util.helper_target(
        java_import,
        name = name + "/depjar",
        jars = ["depjar.jar"],
    )

    analysis_test(
        name = name,
        impl = _test_import_deps_checker_checking_mode_impl,
        target = name + "/import-jar",
        # The rules_java Starlark implementation is used from Bazel 8 on.
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _test_import_deps_checker_checking_mode_impl(env, target):
    # java_import only generates the jdeps proto, it never fails the build on incomplete deps.
    assert_action = env.expect.that_target(target).action_named("ImportDepsChecker")
    assert_action.contains_flag_values([
        ("--checking_mode", "silence"),
        ("--rule_label", "//{package}:{name}"),
    ])

def java_import_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_import_deps_checker_checking_mode,
        ],
    )
