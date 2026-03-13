"""Tests for the "launcher" attribute and "--java_launcher" flag."""

load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_binary.bzl", "java_binary")

def _test_overridden_incompatible_launcher(name):
    # Check analysis succeeds even though --java_launcher refers to an incompatible target
    # when the "use_launcher" attribute is set to False.
    util.helper_target(
        rule = cc_binary,
        name = name + "/launcher",
        srcs = select({
            "@platforms//cpu:ppc": [name + "/launcher.cc"],
        }),
    )

    util.helper_target(
        rule = java_binary,
        name = name + "/bin",
        srcs = [name + "/Bin.java"],
        use_launcher = False,
    )

    analysis_test(
        name = name,
        impl = lambda env, target: True,
        target = name + "/bin",
        config_settings = {
            "//command_line_option:java_launcher": Label(name + "/launcher"),
            "//command_line_option:cpu": "k8",
        },
    )

def _test_launcher_with_create_executable_false_fails(name):
    util.helper_target(
        rule = cc_binary,
        name = name + "/launcher",
        srcs = [name + "/launcher.cc"],
    )

    util.helper_target(
        rule = java_binary,
        name = name + "/bin",
        srcs = [name + "/Bin.java"],
        launcher = name + "/launcher",
        create_executable = False,
    )

    analysis_test(
        name = name,
        impl = _test_launcher_with_create_executable_false_fails_impl,
        target = name + "/bin",
        expect_failure = True,
    )

def _test_launcher_with_create_executable_false_fails_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("launcher specified but create_executable is false"),
    )

def java_launcher_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_overridden_incompatible_launcher,
            _test_launcher_with_create_executable_false_fails,
        ],
    )
