"""Tests for the java_library rule"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_library.bzl", "java_library")
load("//java:java_plugin.bzl", "java_plugin")
load("//java/common:java_info.bzl", "JavaInfo")
load("//java/test/testutil:java_info_subject.bzl", "java_info_subject")
load("//java/test/testutil:rules/forward_java_info.bzl", "java_info_forwarding_rule")
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

def _test_java_info_propagation(name):
    util.helper_target(
        java_library,
        name = name + "/jl",
        srcs = ["java/A.java"],
    )
    util.helper_target(
        java_info_forwarding_rule,
        name = name + "/r",
        dep = name + "/jl",
    )
    util.helper_target(
        java_library,
        name = name + "/jl_top",
        srcs = ["java/C.java"],
        deps = [name + "/r"],
    )

    analysis_test(
        name = name,
        impl = _test_java_info_propagation_impl,
        targets = {
            "r": name + "/r",
            "jl": name + "/jl",
            "jl_top": name + "/jl_top",
        },
    )

def _test_java_info_propagation_impl(env, targets):
    env.expect.that_bool(targets.r[JavaInfo] == targets.jl[JavaInfo]).equals(True)
    _assert_depsets_have_the_same_parent(
        env,
        targets.jl[JavaInfo].transitive_compile_time_jars,
        targets.jl_top[JavaInfo].transitive_compile_time_jars,
    )
    _assert_depsets_have_the_same_parent(
        env,
        targets.jl[JavaInfo].transitive_runtime_jars,
        targets.jl_top[JavaInfo].transitive_runtime_jars,
    )

def _assert_depsets_have_the_same_parent(env, depset1, depset2):
    elements = depset1.to_list()
    other_elements = depset2.to_list()

    for e, other_e in zip(elements, other_elements):
        env.expect.that_str(e.dirname).equals(other_e.dirname)

def java_library_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_exposes_plugins,
            _test_exposes_java_info,
            _test_java_info_propagation,
        ],
    )
