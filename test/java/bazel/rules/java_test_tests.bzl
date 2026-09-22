"""Tests for the Bazel java_test rule"""

load("@bazel_features//private:util.bzl", _bazel_version_ge = "ge")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching", "subjects")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_test.bzl", "java_test")
load("//test/java/testutil:helper.bzl", "always_passes")

def _test_deduced_test_class(name):
    if not _bazel_version_ge("8.0.0"):
        always_passes(name)
        return

    util.helper_target(
        java_test,
        name = name + "/foo",
        srcs = [name + "/Foo.java"],
    )

    analysis_test(
        name = name,
        impl = _test_deduced_test_class_impl,
        target = name + "/foo",
        attr_values = {"tags": ["min_bazel_8"]},
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
        matching.str_matches("-Dbazel.test_suite=bazel.rules.test_deduced_test_class.Foo"),
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

def _test_test_classes(name):
    if not _bazel_version_ge("8.0.0"):
        always_passes(name)
        return

    util.helper_target(
        java_test,
        name = name + "/foo",
        test_classes = ["com.example.FooTest", "com.example.BarTest"],
    )

    analysis_test(
        name = name,
        impl = _test_test_classes_impl,
        target = name + "/foo",
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _test_test_classes_impl(env, target):
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
        matching.str_matches("-Dbazel.test_suite=com.example.FooTest,com.example.BarTest"),
    )

def _test_both_test_class_and_test_classes_fails(name):
    if not _bazel_version_ge("8.0.0"):
        always_passes(name)
        return

    util.helper_target(
        java_test,
        name = name + "/foo",
        test_class = "FooTest",
        test_classes = ["FooTest"],
    )

    analysis_test(
        name = name,
        impl = _test_both_test_class_and_test_classes_fails_impl,
        target = name + "/foo",
        expect_failure = True,
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _test_both_test_class_and_test_classes_fails_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("cannot specify both 'test_class' and 'test_classes'"),
    )

def java_test_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_deduced_test_class,
            _test_invalid_test_class_at_repo_root,
            _test_test_classes,
            _test_both_test_class_and_test_classes_fails,
        ],
    )
