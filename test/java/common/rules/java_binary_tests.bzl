"""Tests for the java_binary rule"""

load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching", "subjects")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_binary.bzl", "java_binary")
load("//java:java_library.bzl", "java_library")
load("//java/test/testutil:java_info_subject.bzl", "java_info_subject")
load("//test/java/testutil:rules/custom_java_info_rule.bzl", "custom_java_info_rule")
load("//test/java/testutil:rules/forward_java_info.bzl", "java_info_forwarding_rule")

def _test_java_binary_provides_binary_java_info(name):
    util.helper_target(java_binary, name = "bin", srcs = ["Main.java"])

    analysis_test(
        name = name,
        impl = _test_java_binary_provides_binary_java_info_impl,
        target = Label(":bin"),
        attr_values = {"tags": ["min_bazel_7"]},
    )

def _test_java_binary_provides_binary_java_info_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.compilation_args().equals(None)
    assert_java_info.is_binary().equals(True)

def _test_stamp_conversion_does_not_override_int(name):
    util.helper_target(
        java_binary,
        name = name + "/bin",
        srcs = ["Main.java"],
        stamp = -1,
    )

    analysis_test(
        name = name,
        impl = _test_stamp_conversion_does_not_override_int_impl,
        target = name + "/bin",
        config_settings = {
            "//command_line_option:stamp": False,
        },
        # deploy jars are in a separate rule in Bazel 7, Bazel 6 generated build-info differently
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _test_stamp_conversion_does_not_override_int_impl(env, target):
    assert_deploy_jar_action = env.expect.that_target(target).action_generating(
        "{package}/{name}_deploy.jar",
    )

    assert_deploy_jar_action.inputs().not_contains_predicate(
        matching.file_basename_equals("non_volatile_file.properties"),
    )
    assert_deploy_jar_action.inputs().contains_predicate(
        matching.file_basename_equals("redacted_file.properties"),
    )

def _test_java_binary_attributes(name):
    util.helper_target(
        java_library,
        name = name + "/jl_bottom_for_deps",
        srcs = ["java/A.java"],
    )
    util.helper_target(
        java_library,
        name = name + "/jl_bottom_for_runtime_deps",
        srcs = ["java/A2.java"],
    )
    util.helper_target(
        java_info_forwarding_rule,
        name = name + "/mya",
        dep = name + "/jl_bottom_for_deps",
    )
    util.helper_target(
        java_info_forwarding_rule,
        name = name + "/myb",
        dep = name + "/jl_bottom_for_runtime_deps",
    )
    util.helper_target(
        java_binary,
        name = name + "/binary",
        srcs = ["java/B.java"],
        main_class = "foo.A",
        deps = [name + "/mya"],
        runtime_deps = [name + "/myb"],
    )

    analysis_test(
        name = name,
        impl = _test_java_binary_attributes_impl,
        target = name + "/binary",
    )

def _test_java_binary_attributes_impl(env, target):
    assert_runtime_classpath = java_info_subject.from_target(env, target).compilation_info().runtime_classpath()

    # Test that all bottom jars are on the runtime classpath.
    assert_runtime_classpath.contains_at_least_predicates([
        matching.file_basename_equals("jl_bottom_for_deps.jar"),
        matching.file_basename_equals("jl_bottom_for_runtime_deps.jar"),
    ])

def _test_java_binary_propagates_direct_native_libraries(name):
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
        java_binary,
        name = name + "/binary",
        srcs = ["java/C.java"],
        deps = [name + "/r"],
        main_class = "C",
    )

    analysis_test(
        name = name,
        impl = _test_java_binary_propagates_direct_native_libraries_impl,
        target = name + "/binary",
        # in Bazel 6, the windows stub was created by a bespoke, native and
        # opaque-to-Starlark LauncherFileWriteAction
        attr_values = {"tags": ["min_bazel_7"]},
    )

def _test_java_binary_propagates_direct_native_libraries_impl(env, target):
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
        matching.str_matches("-Djava.library.path=${JAVA_RUNFILES}/*/test_java_binary_propagates_direct_native_libraries"),
    )

def java_binary_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_java_binary_provides_binary_java_info,
            _test_stamp_conversion_does_not_override_int,
            _test_java_binary_attributes,
            _test_java_binary_propagates_direct_native_libraries,
        ],
    )
