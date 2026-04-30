"""Tests for the java_test rule"""

load("@bazel_features//:features.bzl", "bazel_features")
load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching", "subjects")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_library.bzl", "java_library")
load("//java:java_test.bzl", "java_test")
load("//java/common:java_info.bzl", "JavaInfo")
load("//java/common:java_semantics.bzl", "semantics")
load("//test/java/testutil:helper.bzl", "always_passes")
load("//test/java/testutil:mock_cc_toolchain.bzl", "mock_cc_toolchain")
load("//test/java/testutil:mock_java_toolchain.bzl", "mock_java_runtime_toolchain")
load("//test/java/testutil:mock_test_toolchain.bzl", "mock_test_toolchains")
load("//test/java/testutil:rules/custom_java_info_rule.bzl", "custom_java_info_rule")

def _test_java_test_is_test_only(name):
    util.helper_target(
        java_test,
        name = name + "/test",
        srcs = [name + "/Test.java"],
    )

    util.helper_target(
        java_library,
        name = name + "/lib",
        srcs = [name + "/Lib.java"],
        deps = [name + "/test"],
    )

    analysis_test(
        name = name,
        impl = _test_java_test_is_test_only_impl,
        target = name + "/lib",
        expect_failure = True,
    )

def _test_java_test_is_test_only_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("non-test target '*/lib' depends on testonly target '*/test'"),
    )

def _test_deps_without_srcs_fails(name):
    util.helper_target(
        rule = java_library,
        name = name + "/lib",
        srcs = [name + "/Lib.java"],
    )

    util.helper_target(
        rule = java_test,
        name = name + "/test",
        deps = [name + "/lib"],
    )

    analysis_test(
        name = name,
        target = name + "/test",
        impl = _test_deps_without_srcs_fails_impl,
        expect_failure = True,
    )

def _test_deps_without_srcs_fails_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.contains("deps not allowed without srcs"),
    )

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

def _test_coverage_uses_coverage_runner_for_main(name):
    util.helper_target(
        rule = java_test,
        name = name + "/test",
        srcs = [name + "/Test.java"],
    )

    analysis_test(
        name = name,
        impl = _test_coverage_uses_coverage_runner_for_main_impl,
        target = name + "/test",
        config_settings = {
            "//command_line_option:collect_code_coverage": True,
        },
    )

def _test_coverage_uses_coverage_runner_for_main_impl(env, target):
    executable = target[DefaultInfo].files_to_run.executable.short_path
    assert_action = env.expect.that_target(target).action_generating(executable)
    if assert_action.actual.substitutions:
        assert_java_start_class = assert_action.substitutions().get(
            "%java_start_class%",
            factory = lambda v, meta: subjects.str(v, meta.derive("java_start_class")),
        )
        assert_java_start_class.contains("com.google.testing.coverage.JacocoCoverageRunner")
    else:
        # Windows
        assert_java_start_class = assert_action.argv()
        assert_java_start_class.contains("java_start_class=com.google.testing.coverage.JacocoCoverageRunner")

def _test_stamp_values(name):
    util.helper_target(
        rule = java_test,
        name = name + "/stamp_true",
        srcs = [name + "/Test.java"],
        stamp = True,
    )

    util.helper_target(
        rule = java_test,
        name = name + "/stamp_false",
        srcs = [name + "/Test.java"],
        stamp = False,
    )

    util.helper_target(
        rule = java_test,
        name = name + "/stamp_auto",
        srcs = [name + "/Test.java"],
        stamp = -1,
    )

    util.helper_target(
        rule = java_test,
        name = name + "/stamp_default",
        srcs = [name + "/Test.java"],
    )

    analysis_test(
        name = name,
        targets = {
            "stamp": name + "/stamp_true",
            "nostamp": name + "/stamp_false",
            "autostamp": name + "/stamp_auto",
            "defaultstamp": name + "/stamp_default",
        },
        impl = _test_stamp_values_impl,
    )

def _test_stamp_values_impl(env, targets):
    env.expect.that_target(targets.stamp).attr("stamp", factory = subjects.int).equals(1)
    env.expect.that_target(targets.nostamp).attr("stamp", factory = subjects.int).equals(0)
    env.expect.that_target(targets.defaultstamp).attr("stamp", factory = subjects.int).equals(0)
    env.expect.that_target(targets.autostamp).attr("stamp", factory = subjects.int).equals(-1)

def _test_add_test_support_to_compile_time_deps_flag(name):
    if not bazel_features.rules.analysis_tests_can_transition_on_experimental_incompatible_flags:
        always_passes(name)
        return
    util.helper_target(
        rule = java_test,
        name = name + "/test",
        srcs = [name + "/Test.java"],
    )

    analysis_test(
        name = name,
        targets = {
            "add_support": name + "/test",
            "no_add_support": name + "/test",
        },
        attrs = {
            "test_runner": attr.label(default = semantics.JAVA_TEST_RUNNER_LABEL),
            "add_support": {
                "@config_settings": {
                    "//command_line_option:experimental_add_test_support_to_compile_time_deps": True,
                },
            },
            "no_add_support": {
                "@config_settings": {
                    "//command_line_option:experimental_add_test_support_to_compile_time_deps": False,
                },
            },
        },
        impl = _test_add_test_support_to_compile_time_deps_flag_impl,
    )

def _test_add_test_support_to_compile_time_deps_flag_impl(env, targets):
    compile_jars = env.ctx.attr.test_runner[JavaInfo].compile_jars
    env.expect.that_target(targets.add_support).action_named("Javac").inputs().contains_at_least(compile_jars.to_list())
    env.expect.that_target(targets.no_add_support).action_named("Javac").inputs().contains_none_of(compile_jars.to_list())

def _test_mac_requires_darwin_for_execution(name):
    util.helper_target(
        rule = native.platform,
        name = name + "/darwin_x86_64",
        constraint_values = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
    )

    util.helper_target(
        rule = java_test,
        name = name + "/test",
        srcs = [name + "/Test.java"],
        use_launcher = False,
        use_testrunner = 0,
    )

    util.helper_target(
        rule = mock_cc_toolchain,
        name = name + "/cc_toolchain",
        cpu = "x86_64",
        os = "macos",
    )

    toolchains = [Label(name + "/cc_toolchain")] + mock_test_toolchains(
        name = name + "/test_toolchain",
        cpu = "x86_64",
        os = "macos",
    )

    analysis_test(
        name = name,
        target = name + "/test",
        config_settings = {
            "//command_line_option:platforms": [Label(name + "/darwin_x86_64")],
            "//command_line_option:extra_toolchains": toolchains,
        },
        impl = _test_mac_requires_darwin_for_execution_impl,
    )

def _test_mac_requires_darwin_for_execution_impl(env, target):
    env.expect.that_target(target).provider(testing.ExecutionInfo).requirements().contains_at_least(
        {"requires-darwin": ""},
    )

def _test_java_test_sets_securiry_manager_property_jdk17(name):
    util.helper_target(
        java_test,
        name = name + "/test",
        srcs = ["FooTest.java"],
        test_class = "FooTest",
    )
    util.helper_target(
        mock_java_runtime_toolchain,
        name = name + "/toolchain",
        version = 17,
    )

    analysis_test(
        name = name,
        impl = _test_java_test_sets_securiry_manager_property_jdk17_impl,
        target = name + "/test",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
    )

def _test_java_test_sets_securiry_manager_property_jdk17_impl(env, target):
    executable = env.expect.that_target(target).executable().actual.short_path
    assert_action = env.expect.that_target(target).action_generating(executable)
    if assert_action.actual.substitutions:
        # TemplateExpansion action on linux/mac
        assert_action.substitutions().get("%jvm_flags%", factory = subjects.str).contains(
            "-Djava.security.manager=allow",
        )
    else:
        # windows
        assert_action.argv().contains_predicate(
            matching.str_matches("-Djava.security.manager=allow"),
        )

def java_test_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_java_test_is_test_only,
            _test_deps_without_srcs_fails,
            _test_java_test_propagates_direct_native_libraries,
            _test_coverage_uses_coverage_runner_for_main,
            _test_stamp_values,
            _test_add_test_support_to_compile_time_deps_flag,
            _test_mac_requires_darwin_for_execution,
            _test_java_test_sets_securiry_manager_property_jdk17,
        ],
    )
