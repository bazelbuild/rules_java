"""Tests for the java_test rule"""

load("@bazel_features//:features.bzl", "bazel_features")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching", "subjects")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_binary.bzl", "java_binary")
load("//java:java_library.bzl", "java_library")
load("//java:java_test.bzl", "java_test")
load("//java/common:java_semantics.bzl", "semantics")
load("//java/common/rules:java_helper.bzl", "helper")
load("//test/java/testutil:helper.bzl", "always_passes")
load("//test/java/testutil:mock_cc_toolchain.bzl", "mock_cc_toolchain")
load("//test/java/testutil:mock_java_toolchain.bzl", "mock_java_runtime_toolchain", "mock_java_toolchain")
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

def _test_one_version_check_java_test(name):
    if not bazel_features.rules.analysis_tests_can_transition_on_experimental_incompatible_flags:
        # exit early because this test case would be a loading phase error otherwise
        always_passes(name)
        return

    util.helper_target(
        java_library,
        name = name + "/foo",
        srcs = [name + "/foo.java"],
    )
    util.helper_target(
        java_test,
        name = name + "/foo_test",
        srcs = [name + "/foo_test.java"],
        deps = [name + "/foo"],
        use_testrunner = False,
    )
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
        oneversion = "one_version_tool",
        oneversion_allowlist = "one_version_allowlist",
        oneversion_allowlist_for_tests = "one_version_allowlist_for_tests",
    )

    analysis_test(
        name = name,
        impl = _test_one_version_check_java_test_impl,
        target = name + "/foo_test",
        config_settings = {
            "//command_line_option:experimental_one_version_enforcement": "ERROR",
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
        attrs = {
            "_windows_constraints": attr.label_list(
                default = [paths.join(semantics.PLATFORMS_ROOT, "os:windows")],
            ),
        },
    )

def _test_one_version_check_java_test_impl(env, target):
    assert_target = env.expect.that_target(target)
    assert_target.default_outputs().contains_exactly([
        "{package}/{test_name}/foo_test.jar",
        "{package}/{test_name}/foo_test" + (".exe" if helper.is_target_platform_windows(env.ctx) else ""),
    ])
    assert_action = assert_target.action_generating(
        "{package}/{name}-one-version.txt",
    )
    tool = [f for f in assert_action.actual.inputs.to_list() if f.short_path.endswith("one_version_tool")][0]
    assert_action.argv().contains_exactly([
        tool.path,
        "--output",
        "{bindir}/{package}/{name}-one-version.txt",
        "--allowlist",
        "{package}/one_version_allowlist_for_tests",
        "--inputs",
        "{bindir}/{package}/{test_name}/foo_test.jar,//{package}:{test_name}/foo_test",
        "{bindir}/{package}/lib{test_name}/foo.jar,//{package}:{test_name}/foo",
    ]).in_order()

def _test_one_version_check_disabled_for_java_test(name):
    if not bazel_features.rules.analysis_tests_can_transition_on_experimental_incompatible_flags:
        # exit early because this test case would be a loading phase error otherwise
        always_passes(name)
        return

    util.helper_target(
        java_test,
        name = name + "/foo_test",
        srcs = [name + "/foo.java"],
        use_testrunner = False,
    )
    util.helper_target(
        java_binary,
        name = name + "/foo_binary",
        srcs = [name + "/foo.java"],
    )
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
        oneversion = "one_version_tool",
    )

    analysis_test(
        name = name,
        impl = _test_one_version_check_disabled_for_java_test_impl,
        targets = {
            "bin": name + "/foo_binary",
            "test": name + "/foo_test",
        },
        config_settings = {
            "//command_line_option:experimental_one_version_enforcement": "ERROR",
            "//command_line_option:one_version_enforcement_on_java_tests": False,
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
    )

def _test_one_version_check_disabled_for_java_test_impl(env, targets):
    binary_action_mnemonics = [a.mnemonic for a in env.expect.that_target(targets.bin).actual.actions]
    test_action_mnemonics = [a.mnemonic for a in env.expect.that_target(targets.test).actual.actions]
    env.expect.that_collection(binary_action_mnemonics).contains("JavaOneVersion")
    env.expect.that_collection(test_action_mnemonics).not_contains("JavaOneVersion")

def java_test_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_java_test_is_test_only,
            _test_deps_without_srcs_fails,
            _test_java_test_propagates_direct_native_libraries,
            _test_coverage_uses_coverage_runner_for_main,
            _test_stamp_values,
            _test_mac_requires_darwin_for_execution,
            _test_java_test_sets_securiry_manager_property_jdk17,
            _test_one_version_check_java_test,
            _test_one_version_check_disabled_for_java_test,
        ],
    )
