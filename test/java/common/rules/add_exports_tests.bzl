"""Tests for the add_exports attribute"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//java:defs.bzl", "java_library")
load("//test/java/testutil:java_info_subject.bzl", "java_info_subject")
load("//test/java/testutil:rules/java_info_merge.bzl", "java_info_merge_rule")

def _test_merge_add_exports(name):
    util.helper_target(
        java_info_merge_rule,
        name = name + "/merge",
        deps = [name + "/a"],
    )
    util.helper_target(
        java_library,
        name = name + "/a",
        srcs = ["A.java"],
        add_exports = ["java.base/java.lang"],
    )

    analysis_test(
        name = name,
        impl = _test_merge_add_exports_impl,
        target = name + "/merge",
    )

def _test_merge_add_exports_impl(env, target):
    java_info_subject.from_target(env, target).module_flags().add_exports().contains_exactly(
        ["java.base/java.lang"],
    )

def add_exports_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_merge_add_exports,
        ],
    )
