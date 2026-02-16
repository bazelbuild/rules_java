"""Tests for the java_runtime rule"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java/common:java_semantics.bzl", "semantics")
load("//java/toolchains:java_runtime.bzl", "java_runtime")
load("//test/java/testutil:java_runtime_info_subject.bzl", "java_runtime_info_subject")
load("//test/java/testutil:rules/forward_java_runtime_info.bzl", "java_runtime_info_forwarding_rule")
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
    )

def _test_with_absolute_java_home_impl(env, target):
    assert_info = java_runtime_info_subject.from_target(env, target)

    assert_info.java_home().equals("/foo/bar")
    assert_info.java_home_runfiles_path().equals("/foo/bar")
    assert_info.java_executable_exec_path().starts_with("/foo/bar/bin/java")
    assert_info.java_executable_runfiles_path().starts_with("/foo/bar/bin/java")

def _test_with_hermetic_java_home(name):
    util.helper_target(
        java_runtime,
        name = name + "/jvm",
        srcs = [],
        java_home = "foo/bar",
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
        impl = _test_with_hermetic_java_home_impl,
        target = name + "/r",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/java_runtime_toolchain")],
        },
    )

def _test_with_hermetic_java_home_impl(env, target):
    assert_info = java_runtime_info_subject.from_target(env, target)

    assert_info.java_home().equals("{package}/foo/bar")
    assert_info.java_home_runfiles_path().equals("{package}/foo/bar")
    assert_info.java_executable_exec_path().starts_with("{package}/foo/bar/bin/java")
    assert_info.java_executable_runfiles_path().starts_with("{package}/foo/bar/bin/java")

def _test_with_generated_java_executable(name):
    util.helper_target(
        native.genrule,
        name = name + "/gen",
        cmd = "",
        outs = ["foo/bar/bin/java"],
        output_to_bindir = True,
    )
    util.helper_target(
        java_runtime,
        name = name + "/jvm",
        srcs = [],
        java = "foo/bar/bin/java",
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
        impl = _test_with_generated_java_executable_impl,
        target = name + "/r",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/java_runtime_toolchain")],
        },
    )

def _test_with_generated_java_executable_impl(env, target):
    assert_info = java_runtime_info_subject.from_target(env, target)

    assert_info.java_home().equals("{bindir}/{package}/foo/bar")
    assert_info.java_home_runfiles_path().equals("{package}/foo/bar")
    assert_info.java_executable_exec_path().starts_with("{bindir}/{package}/foo/bar/bin/java")
    assert_info.java_executable_runfiles_path().starts_with("{package}/foo/bar/bin/java")

def _test_runtime_alias(name):
    util.helper_target(
        java_runtime_alias,
        name = name + "/alias",
    )

    analysis_test(
        name = name,
        impl = _test_runtime_alias_impl,
        target = name + "/alias",
    )

def _test_runtime_alias_impl(env, target):
    env.expect.that_target(target).has_provider(platform_common.ToolchainInfo)
    env.expect.that_target(target).has_provider(platform_common.TemplateVariableInfo)

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

def _test_bin_java_path_name(name):
    util.helper_target(
        java_runtime,
        name = name + "/jvm",
        java = "java",
    )

    analysis_test(
        name = name,
        impl = _test_bin_java_path_name_impl,
        target = name + "/jvm",
        expect_failure = True,
    )

def _test_bin_java_path_name_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("the path to 'java' must end in 'bin/java'."),
    )

def _test_absolute_java_home(name):
    util.helper_target(
        java_runtime,
        name = name + "/jvm",
        java_home = "/absolute/path",
    )

    analysis_test(
        name = name,
        impl = _test_absolute_java_home_impl,
        target = name + "/jvm",
    )

def _test_absolute_java_home_impl(env, target):
    java_runtime_info_subject.from_target(env, target).java_home().equals("/absolute/path")

def _test_relative_java_home(name):
    util.helper_target(
        java_runtime,
        name = name + "/jvm",
        java_home = "b/c",
    )

    analysis_test(
        name = name,
        impl = _test_relative_java_home_impl,
        target = name + "/jvm",
    )

def _test_relative_java_home_impl(env, target):
    java_runtime_info_subject.from_target(env, target).java_home().equals("{package}/b/c")

def _test_java_home_with_invalid_make_variables(name):
    util.helper_target(
        java_runtime,
        name = name + "/jvm",
        java_home = "/opt/$(WTF)",
    )

    analysis_test(
        name = name,
        impl = _test_java_home_with_invalid_make_variables_impl,
        target = name + "/jvm",
        expect_failure = True,
    )

def _test_java_home_with_invalid_make_variables_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("$(WTF) not defined"),
    )

def java_runtime_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_with_absolute_java_home,
            _test_with_hermetic_java_home,
            _test_with_generated_java_executable,
            _test_runtime_alias,
            _test_java_runtime_simple,
            _test_absolute_java_home_with_srcs,
            _test_absolute_java_home_with_java,
            _test_bin_java_path_name,
            _test_absolute_java_home,
            _test_relative_java_home,
            _test_java_home_with_invalid_make_variables,
        ],
    )
