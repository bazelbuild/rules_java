"""Tests for the java_plugin rule"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_library.bzl", "java_library")
load("//java:java_plugin.bzl", "java_plugin")
load("//java/test/testutil:java_info_subject.bzl", "java_plugin_info_subject")

def _test_exposes_plugins_to_starlark(name):
    target_name = name + "/plugin"
    util.helper_target(
        java_library,
        name = target_name + "/plugin_dep",
        srcs = ["ProcessorDep.java"],
        data = ["depfile.dat"],
    )
    util.helper_target(
        java_plugin,
        name = target_name,
        srcs = ["AnnotationProcessor.java"],
        data = ["pluginfile.dat"],
        processor_class = "com.google.process.stuff",
        deps = [target_name + "/plugin_dep"],
    )

    analysis_test(
        name = name,
        impl = _test_exposes_plugins_to_starlark_impl,
        target = target_name,
    )

def _test_exposes_plugins_to_starlark_impl(env, target):
    assert_plugin_data = java_plugin_info_subject.from_target(env, target).plugins()
    assert_plugin_data.processor_classes().contains_exactly(["com.google.process.stuff"])
    assert_plugin_data.processor_jars().contains_exactly([
        "{package}/lib{name}.jar",
        "{package}/lib{name}/plugin_dep.jar",
    ])
    assert_plugin_data.processor_data().contains_exactly(["{package}/pluginfile.dat"])

    java_plugin_info_subject.from_target(env, target).api_generating_plugins().is_empty()

def java_plugin_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_exposes_plugins_to_starlark,
        ],
    )
