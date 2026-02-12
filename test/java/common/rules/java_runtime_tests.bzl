"""Tests for the java_runtime rule"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java/toolchains:java_runtime.bzl", "java_runtime")
load("//test/java/testutil:java_runtime_info_subject.bzl", "java_runtime_info_subject")

def _test_java_runtime_simple(name):
    util.helper_target(
        java_runtime,
        name = name + "/jvm-foo",
        srcs = [
            "foo/a",
            "foo/b",
        ],
        java_home = "foo",
    )

    analysis_test(
        name = name,
        impl = _test_java_runtime_simple_impl,
        target = name + "/jvm-foo",
    )

def _test_java_runtime_simple_impl(env, target):
    java_runtime_info_subject.from_target(env, target).files().contains_exactly([
        "{package}/foo/a",
        "{package}/foo/b",
    ])
    env.expect.that_target(target).data_runfiles().contains_exactly([
        "{workspace}/{package}/foo/a",
        "{workspace}/{package}/foo/b",
    ])

def _test_absolute_java_home_with_srcs(name):
    util.helper_target(
        java_runtime,
        name = name + "/jvm",
        srcs = ["dummy.txt"],
        java_home = "/absolute/path",
    )

    analysis_test(
        name = name,
        impl = _test_absolute_java_home_with_srcs_impl,
        target = name + "/jvm",
        expect_failure = True,
    )

def _test_absolute_java_home_with_srcs_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("'java_home' with an absolute path requires 'srcs' to be empty."),
    )

def _test_absolute_java_home_with_java(name):
    util.helper_target(
        java_runtime,
        name = name + "/jvm",
        java = "bin/java",
        java_home = "/absolute/path",
    )

    analysis_test(
        name = name,
        impl = _test_absolute_java_home_with_java_impl,
        target = name + "/jvm",
        expect_failure = True,
    )

def _test_absolute_java_home_with_java_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("'java_home' with an absolute path requires 'java' to be empty."),
    )

def java_runtime_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_java_runtime_simple,
            _test_absolute_java_home_with_srcs,
            _test_absolute_java_home_with_java,
        ],
    )
