"""Tests for the default java toolchain configuration"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_library.bzl", "java_library")

def _test_java_builder_jvm_flags(name):
    util.helper_target(
        java_library,
        name = name + "/lib",
        srcs = ["A.java"],
    )
    analysis_test(
        name = name,
        impl = _test_java_builder_jvm_flags_impl,
        target = name + "/lib",
    )

def _test_java_builder_jvm_flags_impl(env, target):
    env.expect.that_target(target).action_named("Javac").contains_flag_values([
        ("--sun-misc-unsafe-memory-access", "allow"),
    ])

def default_java_toolchain_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_java_builder_jvm_flags,
        ],
    )
