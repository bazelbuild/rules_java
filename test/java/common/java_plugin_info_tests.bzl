"""Tests for the JavaPluginInfo provider"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_library.bzl", "java_library")
load("//java:java_plugin.bzl", "java_plugin")
load("//java/common:java_plugin_info.bzl", "JavaPluginInfo")
load("//test/java/testutil:java_info_subject.bzl", "java_plugin_info_subject")
load("//test/java/testutil:rules/custom_plugin.bzl", "custom_plugin")

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

def _test_provider_contstructor(name):
    target_name = name + "/plugin"
    util.helper_target(
        java_library,
        name = target_name + "/plugin_dep1",
        srcs = ["A.java"],
        data = ["depfile1.dat"],
    )
    util.helper_target(
        custom_plugin,
        name = target_name,
        data = ["pluginfile1.dat"],
        processor_class = "com.google.process.stuff",
        deps = [target_name + "/plugin_dep1"],
    )

    analysis_test(
        name = name,
        impl = _test_provider_contstructor_impl,
        target = target_name,
    )

def _test_provider_contstructor_impl(env, target):
    assert_plugin_data = java_plugin_info_subject.from_target(env, target).plugins()
    assert_plugin_data.processor_classes().contains_exactly(["com.google.process.stuff"])
    assert_plugin_data.processor_jars().contains_exactly([
        "{package}/{name}/lib.jar",
        "{package}/lib{name}/plugin_dep1.jar",
    ])
    assert_plugin_data.processor_data().contains_exactly(["{package}/pluginfile1.dat"])

    assert_api_plugin_data = java_plugin_info_subject.from_target(env, target).api_generating_plugins()
    assert_api_plugin_data.processor_classes().contains_exactly([])
    assert_api_plugin_data.processor_jars().contains_exactly([])
    assert_api_plugin_data.processor_data().contains_exactly([])

def _test_api_generating_provider_constructor(name):
    target_name = name + "/plugin"
    util.helper_target(
        java_library,
        name = target_name + "/plugin_dep1",
        srcs = ["A.java"],
        data = ["depfile1.dat"],
    )
    util.helper_target(
        custom_plugin,
        name = target_name,
        data = ["pluginfile1.dat"],
        processor_class = "com.google.process.stuff",
        deps = [target_name + "/plugin_dep1"],
        generates_api = True,
    )

    analysis_test(
        name = name,
        impl = _test_api_generating_provider_constructor_impl,
        target = target_name,
    )

def _test_api_generating_provider_constructor_impl(env, target):
    assert_api_plugin_data = java_plugin_info_subject.from_target(env, target).api_generating_plugins()
    assert_api_plugin_data.processor_classes().contains_exactly(["com.google.process.stuff"])
    assert_api_plugin_data.processor_jars().contains_exactly([
        "{package}/{name}/lib.jar",
        "{package}/lib{name}/plugin_dep1.jar",
    ])
    assert_api_plugin_data.processor_data().contains_exactly(["{package}/pluginfile1.dat"])
    assert_api_plugin_data.equals(target[JavaPluginInfo].plugins)

def _test_without_processor_class(name):
    target_name = name + "/plugin"
    util.helper_target(
        java_library,
        name = target_name + "/plugin_dep1",
        srcs = ["A.java"],
        data = ["depfile1.dat"],
    )
    util.helper_target(
        custom_plugin,
        name = target_name,
        processor_class = None,
        data = ["pluginfile1.dat"],
        deps = [target_name + "/plugin_dep1"],
    )
    analysis_test(
        name = name,
        impl = _test_without_processor_class_impl,
        target = target_name,
    )

def _test_without_processor_class_impl(env, target):
    assert_plugin_data = java_plugin_info_subject.from_target(env, target).plugins()
    assert_plugin_data.processor_classes().contains_exactly([])
    assert_plugin_data.processor_jars().contains_exactly([
        "{package}/{name}/lib.jar",
        "{package}/lib{name}/plugin_dep1.jar",
    ])
    assert_plugin_data.processor_data().contains_exactly(["{package}/pluginfile1.dat"])

    assert_api_plugin_data = java_plugin_info_subject.from_target(env, target).api_generating_plugins()
    assert_api_plugin_data.processor_classes().contains_exactly([])
    assert_api_plugin_data.processor_jars().contains_exactly([])
    assert_api_plugin_data.processor_data().contains_exactly([])

def _test_constructor_with_data_depset(name):
    target_name = name + "/plugin"
    util.helper_target(
        java_library,
        name = target_name + "/plugin_dep1",
        srcs = ["A.java"],
        data = ["depfile1.dat"],
    )
    util.helper_target(
        custom_plugin,
        name = target_name,
        processor_class = "com.google.process.stuff",
        data = ["pluginfile1.dat"],
        deps = [target_name + "/plugin_dep1"],
        data_as_depset = True,
    )

    analysis_test(
        name = name,
        impl = _test_constructor_with_data_depset_impl,
        target = target_name,
    )

def _test_constructor_with_data_depset_impl(env, target):
    assert_plugin_data = java_plugin_info_subject.from_target(env, target).plugins()
    assert_plugin_data.processor_classes().contains_exactly(["com.google.process.stuff"])
    assert_plugin_data.processor_jars().contains_exactly([
        "{package}/{name}/lib.jar",
        "{package}/lib{name}/plugin_dep1.jar",
    ])
    assert_plugin_data.processor_data().contains_exactly(["{package}/pluginfile1.dat"])

    assert_api_plugin_data = java_plugin_info_subject.from_target(env, target).api_generating_plugins()
    assert_api_plugin_data.processor_classes().contains_exactly([])
    assert_api_plugin_data.processor_jars().contains_exactly([])
    assert_api_plugin_data.processor_data().contains_exactly([])

def java_plugin_info_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_exposes_java_outputs,
            _test_provider_contstructor,
            _test_api_generating_provider_constructor,
            _test_without_processor_class,
            _test_constructor_with_data_depset,
        ],
    )
