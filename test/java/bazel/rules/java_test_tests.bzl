"""Tests for the Bazel java_test rule"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching", "subjects")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_test.bzl", "java_test")

def _test_deduced_test_class(name):
    util.helper_target(
        java_test,
        name = name + "/foo",
        srcs = [name + "/Foo.java"],
    )

    analysis_test(
        name = name,
        impl = _test_deduced_test_class_impl,
        target = name + "/foo",
    )

def _test_deduced_test_class_impl(env, target):
    executable = target[DefaultInfo].files_to_run.executable.short_path
    assert_action = env.expect.that_target(target).action_generating(executable)

    if assert_action.actual.substitutions:
        # TemplateExpansion action on linux/mac
        assert_jvm_flags = assert_action.substitutions().get(
            "%jvm_flags%",
            factory = lambda v, meta: subjects.collection([v], meta),
        )
    else:
        # Windows
        assert_jvm_flags = assert_action.argv()
    assert_jvm_flags.contains_predicate(
        matching.str_matches("-Dbazel.test_suite=bazel.rules.test_deduced_test_class.foo"),
    )

# regression test for https://github.com/bazelbuild/bazel/issues/20378
def _test_invalid_test_class_at_repo_root(name):
    analysis_test(
        name = name,
        impl = _test_invalid_test_class_at_repo_root_impl,
        target = "//:invalid_test_at_repo_root",
        expect_failure = True,
    )

def _test_invalid_test_class_at_repo_root_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("cannot determine test class."),
    )

def java_test_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_deduced_test_class,
            _test_invalid_test_class_at_repo_root,
        ],
    )
