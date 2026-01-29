"""Tests for the Bazel java_binary rule"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_plugin.bzl", "java_plugin")
load("//test/java/testutil:rules/template_var_info_rule.bzl", "template_var_info_rule")

def _test_java_plugin_javacopts_make_variable_expansion(name):
    util.helper_target(
        template_var_info_rule,
        name = name + "/vars",
        vars = {
            "MY_CUSTOM_OPT": "MY_OPT_VALUE",
        },
    )
    util.helper_target(
        java_plugin,
        name = name + "/lib",
        srcs = ["java/A.java"],
        javacopts = ["$(MY_CUSTOM_OPT)"],
        toolchains = [name + "/vars"],
    )

    analysis_test(
        name = name,
        impl = _test_java_plugin_javacopts_make_variable_expansion_impl,
        target = name + "/lib",
        # Broken by Starlarkification in the embedded rules in Bazel 7
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _test_java_plugin_javacopts_make_variable_expansion_impl(env, target):
    assert_javac = env.expect.that_target(target).action_named("Javac")
    assert_javac.not_contains_arg("$(MY_CUSTOM_OPT)")
    assert_javac.contains_at_least_args(["MY_OPT_VALUE"])

def java_plugin_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_java_plugin_javacopts_make_variable_expansion,
        ],
    )
