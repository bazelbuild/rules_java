"""Tests for the java_library rule"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_library.bzl", "java_library")
load("//java:java_plugin.bzl", "java_plugin")
load("//java/common:java_info.bzl", "JavaInfo")
load("//java/test/testutil:java_info_subject.bzl", "java_info_subject")
load("//java/test/testutil:rules/wrap_java_info.bzl", "JavaInfoWrappingInfo", "java_info_wrapping_rule")

def _test_exposes_plugins(name):
    target_name = name + "/library"
    util.helper_target(
        java_library,
        name = target_name + "/plugin_dep1",
        srcs = ["A.java"],
        data = ["depfile1.dat"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/plugin_dep2",
        srcs = ["B.java"],
        data = ["depfile2.dat"],
    )
    util.helper_target(
        java_plugin,
        name = target_name + "/plugin",
        srcs = ["AnnotationProcessor1.java"],
        data = ["pluginfile1.dat"],
        processor_class = "com.google.process.stuff",
        deps = [target_name + "/plugin_dep1"],
    )
    util.helper_target(
        java_plugin,
        name = target_name + "/apiplugin",
        srcs = ["AnnotationProcessor2.java"],
        data = ["pluginfile2.dat"],
        generates_api = True,
        processor_class = "com.google.process.apistuff",
        deps = [target_name + "/plugin_dep2"],
    )
    util.helper_target(
        java_library,
        name = target_name,
        exported_plugins = [
            target_name + "/plugin",
            target_name + "/apiplugin",
        ],
    )

    analysis_test(
        name = name,
        impl = _test_exposes_plugins_impl,
        target = target_name,
    )

def _test_exposes_plugins_impl(env, target):
    assert_plugin_data = java_info_subject.from_target(env, target).plugins()
    assert_plugin_data.processor_classes().contains_exactly([
        "com.google.process.stuff",
        "com.google.process.apistuff",
    ])
    assert_plugin_data.processor_jars().contains_exactly([
        "{package}/lib{name}/plugin.jar",
        "{package}/lib{name}/plugin_dep1.jar",
        "{package}/lib{name}/apiplugin.jar",
        "{package}/lib{name}/plugin_dep2.jar",
    ])
    assert_plugin_data.processor_data().contains_exactly([
        "{package}/pluginfile1.dat",
        "{package}/pluginfile2.dat",
    ])

    assert_api_plugin_data = java_info_subject.from_target(env, target).api_generating_plugins()
    assert_api_plugin_data.processor_classes().contains_exactly(["com.google.process.apistuff"])
    assert_api_plugin_data.processor_jars().contains_exactly([
        "{package}/lib{name}/apiplugin.jar",
        "{package}/lib{name}/plugin_dep2.jar",
    ])
    assert_api_plugin_data.processor_data().contains_exactly(["{package}/pluginfile2.dat"])

def _test_exposes_java_info(name):
    util.helper_target(
        java_library,
        name = name + "/jl",
        srcs = ["java/A.java"],
    )
    util.helper_target(
        java_info_wrapping_rule,
        name = name + "/r",
        dep = name + "/jl",
    )
    analysis_test(
        name = name,
        impl = _test_exposes_java_info_impl,
        targets = {
            "r": name + "/r",
            "jl": name + "/jl",
        },
    )

def _test_exposes_java_info_impl(env, targets):
    env.expect.that_bool(
        targets.r[JavaInfoWrappingInfo].p == targets.jl[JavaInfo],
    ).equals(True)

def java_library_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_exposes_plugins,
            _test_exposes_java_info,
        ],
    )
