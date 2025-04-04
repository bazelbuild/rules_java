"""Tests for the java_test rule"""

load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching", "subjects")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_library.bzl", "java_library")
load("//java:java_test.bzl", "java_test")
load("//test/java/testutil:rules/custom_java_info_rule.bzl", "custom_java_info_rule")

def _test_java_test_propagates_direct_native_libraries(name):
    util.helper_target(
        cc_library,
        name = name + "/cclib",
        srcs = ["z.cc"],
    )
    util.helper_target(
        cc_binary,
        name = name + "/native",
        srcs = ["cc/x.cc"],
        deps = [name + "/cclib"],
        linkshared = 1,
        linkstatic = 1,
    )
    util.helper_target(
        java_library,
        name = name + "/jl",
        srcs = ["java/A.java"],
        deps = [name + "/native"],
    )
    util.helper_target(
        cc_binary,
        name = name + "/ccl",
        srcs = ["cc/x.cc"],
        deps = [name + "/cclib"],
        linkshared = 1,
        linkstatic = 1,
    )
    util.helper_target(
        custom_java_info_rule,
        name = name + "/r",
        output_jar = name + "-out.jar",
        cc_dep = [name + "/ccl"],
        dep = [name + "/jl"],
    )
    util.helper_target(
        java_test,
        name = name + "/binary",
        srcs = ["java/C.java"],
        deps = [name + "/r"],
        main_class = "C",
    )

    analysis_test(
        name = name,
        impl = _test_java_test_propagates_direct_native_libraries_impl,
        target = name + "/binary",
        # in Bazel 6, the windows stub was created by a bespoke, native and
        # opaque-to-Starlark LauncherFileWriteAction
        attr_values = {"tags": ["min_bazel_7"]},
    )

def _test_java_test_propagates_direct_native_libraries_impl(env, target):
    executable = target[DefaultInfo].files_to_run.executable.short_path
    assert_action = env.expect.that_target(target).action_generating(executable)
    if assert_action.actual.substitutions:
        # TemplateExpansion action on linux/mac
        assert_jvm_flags = assert_action.substitutions().get(
            "%jvm_flags%",
            factory = lambda v, meta: subjects.collection([v], meta),
        )
    else:
        # windows
        assert_jvm_flags = assert_action.argv()
    assert_jvm_flags.contains_predicate(
        matching.str_matches("-Djava.library.path=${JAVA_RUNFILES}/*/test_java_test_propagates_direct_native_libraries"),
    )

def java_test_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_java_test_propagates_direct_native_libraries,
        ],
    )
