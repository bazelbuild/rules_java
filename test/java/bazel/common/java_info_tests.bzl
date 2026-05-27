"""Tests for Bazel JavaInfo."""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_library.bzl", "java_library")
load("//test/java/testutil:java_info_subject.bzl", "java_info_subject")
load("//test/java/testutil:rules/custom_java_info_rule.bzl", "custom_java_info_rule")

# We can't transition on a Starlark-semantics affecting flag, so this relies on
# --incompatible_java_info_merge_runtime_module_flags set in .bazelrc
def _test_create_java_info_with_module_flags_merge_runtime(name):
    util.helper_target(
        custom_java_info_rule,
        name = name + "/my_starlark_rule",
        output_jar = name + "/doesnotmatter.jar",
        dep = [name + "/dep"],
        dep_runtime = [name + "/runtime"],
        dep_exports = [name + "/export"],
        add_exports = ["java.base/java.lang.invoke"],
    )
    util.helper_target(
        java_library,
        name = name + "/dep",
        srcs = ["java/A.java"],
        add_exports = ["java.base/java.lang"],
        add_opens = ["java.base/java.lang"],
    )

    util.helper_target(
        java_library,
        name = name + "/runtime",
        srcs = ["java/A.java"],
        add_opens = ["java.base/java.util"],
    )

    util.helper_target(
        java_library,
        name = name + "/export",
        srcs = ["java/A.java"],
        add_opens = ["java.base/java.math"],
    )

    analysis_test(
        name = name,
        impl = _test_create_java_info_with_module_flags_merge_runtime_impl,
        target = name + "/my_starlark_rule",
    )

def _test_create_java_info_with_module_flags_merge_runtime_impl(env, target):
    assert_module_info = java_info_subject.from_target(env, target).module_flags()
    assert_module_info.add_exports().contains_exactly([
        "java.base/java.lang",
        "java.base/java.lang.invoke",
    ]).in_order()
    assert_module_info.add_opens().contains_exactly([
        "java.base/java.util",
        "java.base/java.math",
        "java.base/java.lang",
    ]).in_order()

def java_info_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_create_java_info_with_module_flags_merge_runtime,
        ],
    )
