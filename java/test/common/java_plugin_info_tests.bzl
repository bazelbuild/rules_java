"""Tests for the JavaPluginInfo provider"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_library.bzl", "java_library")
load("//java:java_plugin.bzl", "java_plugin")
load("//java/test/testutil:java_info_subject.bzl", "java_plugin_info_subject")

def _test_exposes_java_outputs(name):
    util.helper_target(
        java_library,
        name = name + "/lib",
        srcs = ["Lib.java"],
    )
    util.helper_target(
        java_plugin,
        name = name + "/dep",
        srcs = ["Dep.java"],
        deps = [name + "/lib"],
    )

    analysis_test(
        name = name,
        impl = _test_exposes_java_outputs_impl,
        target = name + "/dep",
    )

def _test_exposes_java_outputs_impl(env, target):
    assert_output = java_plugin_info_subject.from_target(env, target).java_outputs().singleton()

    assert_output.class_jar().short_path_equals("{package}/lib{name}.jar")
    assert_output.compile_jar().short_path_equals("{package}/lib{name}-hjar.jar")
    assert_output.source_jars().contains_exactly(["{package}/lib{name}-src.jar"])
    assert_output.jdeps().short_path_equals("{package}/lib{name}.jdeps")
    assert_output.compile_jdeps().short_path_equals("{package}/lib{name}-hjar.jdeps")

def java_plugin_info_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_exposes_java_outputs,
        ],
    )
