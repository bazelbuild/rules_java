"""Tests for the Bazel java_binary rule"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_binary.bzl", "java_binary")
load("//test/java/testutil:java_info_subject.bzl", "java_info_subject")
load("//test/java/testutil:rules/template_var_info_rule.bzl", "template_var_info_rule")

def _test_java_binary_cross_compilation_to_unix(name):
    # A Unix platform that:
    # - has a JDK
    # - does not require a launcher
    # - is not supported by the default C++ toolchain
    util.helper_target(
        native.platform,
        name = name + "/platform",
        constraint_values = [
            "@platforms//os:linux",
            "@platforms//cpu:s390x",
        ],
    )

    util.helper_target(
        java_binary,
        name = name + "/bin",
        srcs = ["java/C.java"],
        main_class = "C",
    )

    analysis_test(
        name = name,
        impl = _test_java_binary_cross_compilation_to_unix_impl,
        target = name + "/bin",
        config_settings = {
            "//command_line_option:platforms": [Label(name + "/platform")],
        },
        # Requires the launcher_maker toolchain.
        attr_values = {"tags": ["min_bazel_9"]},
    )

def _test_java_binary_cross_compilation_to_unix_impl(env, target):
    # The main assertion is that analysis succeeds, but verify the absence of a
    # binary launcher for good measure. We do this by checking that the output
    # executable is the stub script, and not a bespoke launcher
    executable = target[DefaultInfo].files_to_run.executable.short_path
    assert_action = env.expect.that_target(target).action_generating(executable)
    assert_action.mnemonic().equals("TemplateExpand")
    assert_action.substitutions().keys().contains("%jvm_flags%")
    assert_action.inputs().contains_exactly(["java/bazel/rules/java_stub_template.txt"])

def _test_java_binary_javacopts_make_variable_expansion(name):
    util.helper_target(
        template_var_info_rule,
        name = name + "/vars",
        vars = {
            "MY_CUSTOM_OPT": "MY_OPT_VALUE",
        },
    )
    util.helper_target(
        java_binary,
        name = name + "/bin",
        srcs = ["java/A.java"],
        javacopts = ["$(MY_CUSTOM_OPT)"],
        toolchains = [name + "/vars"],
    )

    analysis_test(
        name = name,
        impl = _test_java_binary_javacopts_make_variable_expansion_impl,
        target = name + "/bin",
        # Broken by Starlarkification in the embedded rules in Bazel 7
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _test_java_binary_javacopts_make_variable_expansion_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)
    assert_java_info.compilation_info().javac_options().not_contains("$(MY_CUSTOM_OPT)")
    assert_java_info.compilation_info().javac_options().contains("MY_OPT_VALUE")

def java_binary_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_java_binary_cross_compilation_to_unix,
            _test_java_binary_javacopts_make_variable_expansion,
        ],
    )
