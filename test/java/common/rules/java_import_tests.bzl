"""Tests for the java_import rule"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_import.bzl", "java_import")
load("//java:java_library.bzl", "java_library")
load("//test/java/testutil:java_info_subject.bzl", "java_info_subject")
load("//test/java/testutil:rules/forward_java_info.bzl", "java_info_forwarding_rule")

def _test_java_import_attributes(name):
    target_name = name + "/import"
    util.helper_target(
        java_library,
        name = target_name + "/jl_bottom_for_deps",
        srcs = ["java/A.java"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/jl_bottom_for_runtime_deps",
        srcs = ["java/A2.java"],
    )
    util.helper_target(
        java_info_forwarding_rule,
        name = target_name + "/mya",
        dep = target_name + "/jl_bottom_for_deps",
    )
    util.helper_target(
        java_info_forwarding_rule,
        name = target_name + "/myb",
        dep = target_name + "/jl_bottom_for_runtime_deps",
    )
    util.helper_target(
        java_import,
        name = target_name,
        jars = ["B.jar"],
        runtime_deps = [target_name + "/myb"],
        deps = [target_name + "/mya"],
    )

    analysis_test(
        name = name,
        impl = _test_java_import_attributes_impl,
        target = target_name,
    )

def _test_java_import_attributes_impl(env, target):
    assert_runtime_jars = java_info_subject.from_target(env, target).compilation_args().transitive_runtime_jars()

    # Test that all bottom jars are on the runtime classpath.
    assert_runtime_jars.contains_at_least_predicates([
        matching.file_basename_equals("jl_bottom_for_deps.jar"),
        matching.file_basename_equals("jl_bottom_for_runtime_deps.jar"),
    ])

def _test_simple(name):
    target_name = name + "/libraryjar"
    util.helper_target(
        java_import,
        name = target_name,
        jars = ["library.jar"],
    )

    analysis_test(
        name = name,
        impl = _test_simple_impl,
        target = target_name,
    )

def _test_simple_impl(env, target):
    env.expect.that_target(target).default_outputs().contains_exactly([
        "{package}/library.jar",
    ])

def java_import_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_java_import_attributes,
            _test_simple,
        ],
    )
