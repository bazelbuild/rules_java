"""Tests for java_common APIs"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_library.bzl", "java_library")
load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_plugin_info.bzl", "JavaPluginInfo")
load("//java/test/testutil:java_info_subject.bzl", "java_info_subject")
load("//java/test/testutil:rules/custom_library.bzl", "custom_library")
load("//java/test/testutil:rules/custom_library_with_exports.bzl", "custom_library_with_exports")
load("//java/test/testutil:rules/custom_library_with_sourcepaths.bzl", "custom_library_with_sourcepaths")

def _test_compile_default_values(name):
    util.helper_target(custom_library, name = name + "/custom", srcs = ["Main.java"])

    analysis_test(name = name, impl = _test_compile_default_values_impl, target = name + "/custom")

def _test_compile_default_values_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.compilation_args().transitive_runtime_jars().contains_exactly([
        "{}/lib{}.jar".format(target.label.package, target.label.name),
    ])

def _test_compile_sourcepath(name):
    util.helper_target(
        custom_library_with_sourcepaths,
        name = "custom",
        srcs = ["Main.java"],
        sourcepath = [":B.jar"],
    )

    analysis_test(
        name = name,
        impl = _test_compile_sourcepath_impl,
        target = ":custom",
    )

def _test_compile_sourcepath_impl(env, target):
    assert_compile_action = env.expect.that_target(target).action_generating("{package}/libcustom.jar")

    assert_compile_action.contains_flag_values([
        ("--sourcepath", "{package}/B.jar".format(package = target.label.package)),
    ])

def _test_compile_exports_no_sources(name):
    util.helper_target(java_library, name = "jl", srcs = ["Main.java"])
    util.helper_target(custom_library_with_exports, name = "custom2", exports = [":jl"])

    analysis_test(
        name = name,
        impl = _test_compile_exports_no_sources_impl,
        target = ":custom2",
    )

def _test_compile_exports_no_sources_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.compilation_args().transitive_runtime_jars().contains_exactly(
        ["{package}/libjl.jar"],
    )

def _test_java_plugin_info(name):
    util.helper_target(native.filegroup, name = name + "/dummy")
    analysis_test(
        name = name,
        impl = _test_java_plugin_info_impl,
        target = name + "/dummy",  # analysis_test always expects a target
    )

def _test_java_plugin_info_impl(env, _target):
    env.expect.that_bool(
        java_common.JavaPluginInfo == JavaPluginInfo,
        "java_common.JavaPluginInfo == JavaPluginInfo",
    ).equals(True)

def java_common_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_compile_default_values,
            _test_compile_sourcepath,
            _test_compile_exports_no_sources,
            _test_java_plugin_info,
        ],
    )
