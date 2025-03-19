"""Tests for the java_runtime rule"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//java/common:java_semantics.bzl", "semantics")
load("//java/test/testutil:java_runtime_info_subject.bzl", "java_runtime_info_subject")
load("//java/test/testutil:rules/forward_java_runtime_info.bzl", "java_runtime_info_forwarding_rule")
load("//java/toolchains:java_runtime.bzl", "java_runtime")
load("//toolchains:java_toolchain_alias.bzl", "java_runtime_alias")

def _test_with_absolute_java_home(name):
    util.helper_target(
        java_runtime,
        name = name + "/jvm",
        srcs = [],
        java_home = "/foo/bar",
    )
    util.helper_target(
        java_runtime_alias,
        name = name + "/alias",
    )
    util.helper_target(
        java_runtime_info_forwarding_rule,
        name = name + "/r",
        java_runtime = name + "/alias",
    )
    util.helper_target(
        native.toolchain,
        name = name + "/java_runtime_toolchain",
        toolchain = name + "/jvm",
        toolchain_type = semantics.JAVA_RUNTIME_TOOLCHAIN_TYPE,
    )

    analysis_test(
        name = name,
        impl = _test_with_absolute_java_home_impl,
        target = name + "/r",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/java_runtime_toolchain")],
        },
        # Bazel 6 doesn't accept Label's for the transition above
        attr_values = {"tags": ["min_bazel_7"]},
    )

def _test_with_absolute_java_home_impl(env, target):
    assert_info = java_runtime_info_subject.from_target(env, target)

    assert_info.java_home().equals("/foo/bar")
    assert_info.java_home_runfiles_path().equals("/foo/bar")
    assert_info.java_executable_exec_path().is_in([
        "/foo/bar/bin/java",
        "/foo/bar/bin/java.exe",
    ])
    assert_info.java_executable_runfiles_path().is_in([
        "/foo/bar/bin/java",
        "/foo/bar/bin/java.exe",
    ])

def java_runtime_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_with_absolute_java_home,
        ],
    )
