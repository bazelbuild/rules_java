"""Tests for the bootclasspath rule."""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "subjects")

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

def bootclasspath_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_utf_8_environment,
        ],
    )
