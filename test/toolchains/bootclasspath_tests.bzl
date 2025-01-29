"""Tests for the bootclasspath rule."""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "subjects")
load("//java/common:java_common.bzl", "java_common")

def _test_utf_8_environment(name):
    analysis_test(
        name = name,
        impl = _test_utf_8_environment_impl,
        target = Label("//toolchains:platformclasspath"),
    )

def _test_utf_8_environment_impl(env, target):
    for action in target.actions:
        env_subject = env.expect.where(action = action).that_dict(action.env)
        env_subject.keys().contains("LC_CTYPE")
        env_subject.get("LC_CTYPE", factory = subjects.str).contains("UTF-8")

def _test_incompatible_language_version_bootclasspath_disabled(name):
    analysis_test(
        name = name,
        impl = _test_incompatible_language_version_bootclasspath_disabled_impl,
        target = Label("//toolchains:platformclasspath"),
        config_settings = {
            "//command_line_option:java_language_version": "11",
            "//command_line_option:java_runtime_version": "remotejdk_17",
            str(Label("//toolchains:incompatible_language_version_bootclasspath")): False,
        },
    )

def _test_incompatible_language_version_bootclasspath_disabled_impl(env, target):
    system_path = target[java_common.BootClassPathInfo]._system_path
    env.expect.that_str(system_path).contains("remotejdk17_")

def _test_incompatible_language_version_bootclasspath_enabled_versioned(name):
    analysis_test(
        name = name,
        impl = _test_incompatible_language_version_bootclasspath_enabled_versioned_impl,
        target = Label("//toolchains:platformclasspath"),
        config_settings = {
            "//command_line_option:java_language_version": "11",
            "//command_line_option:java_runtime_version": "remotejdk_17",
            str(Label("//toolchains:incompatible_language_version_bootclasspath")): True,
        },
    )

def _test_incompatible_language_version_bootclasspath_enabled_versioned_impl(env, target):
    system_path = target[java_common.BootClassPathInfo]._system_path
    env.expect.that_str(system_path).contains("remotejdk11_")

def _test_incompatible_language_version_bootclasspath_enabled_unversioned(name):
    analysis_test(
        name = name,
        impl = _test_incompatible_language_version_bootclasspath_enabled_unversioned_impl,
        target = Label("//toolchains:platformclasspath"),
        config_settings = {
            "//command_line_option:java_language_version": "11",
            "//command_line_option:java_runtime_version": "local_jdk",
            str(Label("//toolchains:incompatible_language_version_bootclasspath")): True,
        },
    )

def _test_incompatible_language_version_bootclasspath_enabled_unversioned_impl(env, target):
    system_path = target[java_common.BootClassPathInfo]._system_path
    env.expect.that_str(system_path).contains("local_jdk")

def bootclasspath_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_utf_8_environment,
            _test_incompatible_language_version_bootclasspath_disabled,
            _test_incompatible_language_version_bootclasspath_enabled_versioned,
            _test_incompatible_language_version_bootclasspath_enabled_unversioned,
        ],
    )
