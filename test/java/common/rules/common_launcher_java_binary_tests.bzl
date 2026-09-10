"""Parameterized tests for java_binary with --java_launcher"""

load("@bazel_features//:features.bzl", "bazel_features")
load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "subjects")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_binary.bzl", "java_binary")
load("//java:java_library.bzl", "java_library")
load("//java:java_test.bzl", "java_test")
load("//java/common/rules:java_helper.bzl", "helper")
load("//test/java/testutil:artifact_closure.bzl", "artifact_closure")
load("//test/java/testutil:binary_executable_subject.bzl", "expect_that_executable")
load("//test/java/testutil:helper.bzl", "always_passes")
load("//test/java/testutil:javac_action_subject.bzl", "javac_action_subject")
load("//test/java/testutil:mock_java_toolchain.bzl", "mock_java_toolchain")

def _test_java_binary_non_executable_rule_outputs(name):
    util.helper_target(
        java_binary,
        name = name + "/test_app_noexec",
        srcs = ["InputFile.java"],
        create_executable = 0,
    )

    analysis_test(
        name = name,
        impl = _test_java_binary_non_executable_rule_outputs_impl,
        target = name + "/test_app_noexec",
    )

def _test_java_binary_non_executable_rule_outputs_impl(env, target):
    env.expect.that_target(target).default_outputs().contains_exactly([
        "{package}/{name}.jar",
    ])

def _test_java_binary_resources_only(name):
    util.helper_target(
        java_binary,
        name = name + "/bin",
        main_class = "doesnotmatter",
        resources = [
            "someFile.xml",
            "someOtherFile.xml",
        ],
        runtime_deps = [name + "/lib"],
    )
    util.helper_target(
        java_library,
        name = name + "/lib",
        srcs = ["Xml.java"],
    )
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
    )

    analysis_test(
        name = name,
        attr_values = {"tags": ["min_bazel_8"]},  # the deploy jar was created by a separate rule in Bazel 7
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
        extra_target_under_test_aspects = [artifact_closure.aspect],
        impl = _test_java_binary_resources_only_impl,
        target = name + "/bin",
    )

def _test_java_binary_resources_only_impl(env, target):
    deploy_jar = env.expect.that_target(target).action_named("JavaDeployJar").actual.outputs.to_list()[0]
    env.expect.that_file(deploy_jar).basename().equals("bin_deploy.jar")

    # check that we do have a jar file build for bin, although
    # it does not contain any source files
    artifact_closure.of_target(env, target, extensions = ["jar"], initial = deploy_jar).contains_exactly([
        "{package}/JavaBuilder_deploy.jar",
        "{package}/lib{test_name}/lib.jar",
        "{package}/{test_name}/bin-class.jar",
        "{package}/{test_name}/bin.jar",
        "{package}/{test_name}/bin_deploy.jar",
    ])
    artifact_closure.of_target(env, target, extensions = ["xml"], initial = deploy_jar).contains_exactly([
        "{package}/someFile.xml",
        "{package}/someOtherFile.xml",
    ])

def _test_java_binary_deploy_jar_coverage_setup(name):
    util.helper_target(
        java_binary,
        name = name + "/app",
        main_class = "com.google.app",
    )

    analysis_test(
        name = name,
        attr_values = {"tags": ["min_bazel_8"]},  # the deploy jar was created by a separate rule in Bazel 7
        config_settings = {
            "//command_line_option:collect_code_coverage": True,
        },
        impl = _test_java_binary_deploy_jar_coverage_setup_impl,
        target = name + "/app",
    )

def _test_java_binary_deploy_jar_coverage_setup_impl(env, target):
    assert_that_action = env.expect.that_target(target).action_generating("{package}/{name}_deploy.jar")
    assert_that_action.argv().contains("Coverage-Main-Class: com.google.app")

def _test_java_binary_transitive_dependency_from_java_library(name):
    util.helper_target(
        java_binary,
        name = name + "/Binary",
        srcs = ["Binary.java"],
        deps = [name + "/somedep"],
    )
    util.helper_target(
        java_library,
        name = name + "/somedep",
        srcs = ["Dependency.java"],
        deps = [name + "/otherdep"],
    )
    util.helper_target(
        java_library,
        name = name + "/otherdep",
        srcs = ["OtherDependency.java"],
    )

    analysis_test(
        name = name,
        extra_target_under_test_aspects = [artifact_closure.aspect],
        impl = _test_java_binary_transitive_dependency_from_java_library_impl,
        target = name + "/Binary",
    )

def _test_java_binary_transitive_dependency_from_java_library_impl(env, target):
    artifact_closure.of_target(env, target, extensions = ["java"]).contains_exactly([
        "{package}/Binary.java",
        "{package}/Dependency.java",
        "{package}/OtherDependency.java",
    ])

def _test_java_binary_explicit_main_class(name):
    util.helper_target(
        java_binary,
        name = name + "/bin",
        main_class = "foo.bar.baz",
    )

    analysis_test(
        name = name,
        impl = _test_java_binary_explicit_main_class_impl,
        target = name + "/bin",
    )

def _test_java_binary_explicit_main_class_impl(env, target):
    expect_that_executable.of_target(env, target).java_start_class().equals(
        "foo.bar.baz",
    )

def _test_java_binary_implicit_main_class(name):
    util.helper_target(
        java_binary,
        name = name + "/Binary",
        srcs = ["Binary.java"],
    )

    analysis_test(
        name = name,
        impl = _test_java_binary_implicit_main_class_impl,
        target = name + "/Binary",
    )

def _test_java_binary_implicit_main_class_impl(env, target):
    expect_that_executable.of_target(env, target).java_start_class().equals(
        "common.rules.{test_name}.Binary".format(test_name = env.ctx.label.name),
    )

def _test_java_test_main_class(name):
    util.helper_target(
        java_test,
        name = name + "/Test",
    )

    analysis_test(
        name = name,
        impl = _test_java_test_main_class_impl,
        target = name + "/Test",
    )

def _test_java_test_main_class_impl(env, target):
    expect_that_executable.of_target(env, target).test_suite().equals(
        "common.rules.{test_name}.Test".format(test_name = env.ctx.label.name),
    )

def _test_java_test_main_class_with_dot(name):
    util.helper_target(
        java_test,
        name = name + "/withdot.Test",
    )

    analysis_test(
        name = name,
        impl = _test_java_test_main_class_with_dot_impl,
        target = name + "/withdot.Test",
    )

def _test_java_test_main_class_with_dot_impl(env, target):
    expect_that_executable.of_target(env, target).test_suite().equals(
        "common.rules.{test_name}.withdot.Test".format(test_name = env.ctx.label.name),
    )

def _test_java_test_has_assertions_enabled(name):
    util.helper_target(
        java_test,
        name = name + "/testea",
    )

    analysis_test(
        name = name,
        impl = _test_java_test_has_assertions_enabled_impl,
        target = name + "/testea",
    )

def _test_java_test_has_assertions_enabled_impl(env, target):
    expect_that_executable.of_target(env, target).jvm_flags().contains("-ea")

# Tests that the native library path computed from a ".so" cc_binary dependency
# includes the transitive closure of that dependency.
def _test_java_binary_native_library_path_includes_transitive_deps(name):
    util.helper_target(
        java_binary,
        name = name + "/app",
        srcs = ["DoesNotMatter.java"],
        deps = [name + "/jni.so"],
    )
    util.helper_target(
        java_binary,
        name = name + "/runtime_app",
        srcs = ["AlsoDoesNotMatter.java"],
        runtime_deps = [name + "/jni.so"],
    )
    util.helper_target(
        cc_binary,
        name = name + "/jni.so",
        srcs = ["lib1.so"],
        deps = [name + "/helper_lib"],
    )
    util.helper_target(
        cc_library,
        name = name + "/helper_lib",
        srcs = ["lib2.so"],
    )

    analysis_test(
        name = name,
        attrs = {
            "_windows_constraints": attr.label_list(default = ["@platforms//os:windows"]),
            "_cc_toolchain": attr.label(default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")),
        },
        impl = _test_java_binary_native_library_path_includes_transitive_deps_impl,
        target = [
            name + "/app",
            name + "/runtime_app",
        ],
    )

def _test_java_binary_native_library_path_includes_transitive_deps_impl(env, targets):
    for target in targets:
        if helper.is_target_platform_windows(env.ctx):
            expect_that_executable.of_target(env, target).native_library_paths().contains_exactly([
                "${{JAVA_RUNFILES}}/{workspace}/{package}",
            ])
        else:
            expect_that_executable.of_target(env, target).native_library_paths().contains_exactly([
                "${{JAVA_RUNFILES}}/{workspace}/_solib_{cpu}/_//{package}:{test_name}/helper_lib___{package}",
                "${{JAVA_RUNFILES}}/{workspace}/_solib_{cpu}/_//{package}:{test_name}/jni.so___{package}",
            ])

# Regression test for bug 2774317: Problems with inner classes as main class.
def _test_java_binary_inner_class(name):
    util.helper_target(
        java_binary,
        name = name + "/inner",
        srcs = ["Main.java"],
        main_class = "Main$Inner",
    )

    analysis_test(
        name = name,
        attrs = {"_windows_constraints": attr.label_list(default = ["@platforms//os:windows"])},
        impl = _test_java_binary_inner_class_impl,
        target = name + "/inner",
    )

def _test_java_binary_inner_class_impl(env, target):
    if helper.is_target_platform_windows(env.ctx):
        expected = "Main$Inner"  # unquoted on windows
    else:
        expected = "'Main$Inner'"  # shell-quoted
    expect_that_executable.of_target(env, target).java_start_class().equals(expected)

def _test_java_test_inner_class(name):
    util.helper_target(
        java_test,
        name = name + "/inner",
        test_class = "Outer$Inner",
    )

    analysis_test(
        name = name,
        attrs = {"_windows_constraints": attr.label_list(default = ["@platforms//os:windows"])},
        impl = _test_java_test_inner_class_impl,
        target = name + "/inner",
    )

def _test_java_test_inner_class_impl(env, target):
    if helper.is_target_platform_windows(env.ctx):
        expected = "Outer$Inner"  # unquoted on windows
    else:
        expected = "'Outer$Inner'"  # shell-quoted
    expect_that_executable.of_target(env, target).test_suite().equals(expected)

def _test_java_binary_strict_java_deps_flag(name):
    if not bazel_features.rules.analysis_tests_can_transition_on_experimental_incompatible_flags:
        always_passes(name)
        return

    util.helper_target(
        java_binary,
        name = name + "/app",
        srcs = ["App.java"],
        deps = [
            name + "/alpha",
            name + "/bravo",
        ],
    )
    util.helper_target(
        java_library,
        name = name + "/alpha",
        srcs = ["Alpha.java"],
    )
    util.helper_target(
        java_library,
        name = name + "/bravo",
        srcs = ["Bravo.java"],
        exports = [name + "/delta"],
        deps = [name + "/charlie"],
    )
    util.helper_target(
        java_library,
        name = name + "/charlie",
        srcs = ["Charlie.java"],
    )
    util.helper_target(
        java_library,
        name = name + "/delta",
        srcs = ["Delta.java"],
    )

    analysis_test(
        name = name,
        attrs = {
            "off": {"@config_settings": {"//command_line_option:experimental_strict_java_deps": "OFF"}},
            "warn": {"@config_settings": {"//command_line_option:experimental_strict_java_deps": "WARN"}},
            "error": {"@config_settings": {"//command_line_option:experimental_strict_java_deps": "ERROR"}},
            "strict": {"@config_settings": {"//command_line_option:experimental_strict_java_deps": "STRICT"}},
        },
        impl = _test_java_binary_strict_java_deps_flag_impl,
        targets = {
            "off": name + "/app",
            "warn": name + "/app",
            "error": name + "/app",
            "strict": name + "/app",
        },
    )

def _test_java_binary_strict_java_deps_flag_impl(env, targets):
    # off
    assert_that_javac = javac_action_subject.of(env, targets.off, desc = "off")
    assert_that_javac.direct_dependencies().contains_exactly([])
    assert_that_javac.strict_java_deps().equals("OFF")

    for mode, target, expected_flag_value in [
        ("WARN", targets.warn, "WARN"),
        ("ERROR", targets.error, "ERROR"),
        ("STRICT", targets.strict, "ERROR"),
    ]:
        assert_that_javac = javac_action_subject.of(env, target, desc = "mode=" + mode)
        assert_that_javac.strict_java_deps().equals(expected_flag_value)
        assert_that_javac.direct_dependencies().contains_exactly([
            "{bindir}/{package}/lib{test_name}/alpha-hjar.jar",
            "{bindir}/{package}/lib{test_name}/bravo-hjar.jar",
            "{bindir}/{package}/lib{test_name}/delta-hjar.jar",
        ]).in_order()

def _test_java_binary_runtime_deps_transitivity(name):
    util.helper_target(
        java_library,
        name = name + "/l0",
        srcs = ["l0.java"],
    )
    util.helper_target(
        java_library,
        name = name + "/l1",
        srcs = ["l1.java"],
    )
    util.helper_target(
        java_library,
        name = name + "/l2",
        srcs = ["l2.java"],
        runtime_deps = [name + "/l1"],
        deps = [name + "/l0"],
    )
    util.helper_target(
        java_library,
        name = name + "/l3",
        srcs = ["l3.java"],
        deps = [name + "/l2"],
    )
    util.helper_target(
        java_library,
        name = name + "/l4",
        srcs = ["l4.java"],
        deps = [name + "/l1"],
    )
    util.helper_target(
        java_binary,
        name = name + "/b1",
        srcs = ["b1.java"],
        deps = [name + "/l2"],
    )
    util.helper_target(
        java_binary,
        name = name + "/b2",
        srcs = ["b2.java"],
        runtime_deps = [name + "/l3"],
    )

    analysis_test(
        name = name,
        attr_values = {"tags": ["min_bazel_8"]},  # the deploy jar was created by a separate rule in Bazel 7
        impl = _test_java_binary_runtime_deps_transitivity_impl,
        targets = {
            "b1": name + "/b1",
            "b2": name + "/b2",
        },
    )

def _expect_that_deploy_jar_action_inputs(env, target, extension):
    action = env.expect.that_target(target).action_generating("{package}/{name}_deploy.jar")
    return subjects.collection(
        action.actual.inputs.to_list(),
        meta = action.meta,
    ).transform(
        desc = extension + " inputs",
        filter = lambda f: f.extension == extension,
        format = True,
        map_each = lambda f: f.short_path,
    )

def _test_java_binary_runtime_deps_transitivity_impl(env, targets):
    _expect_that_deploy_jar_action_inputs(env, targets.b1, "jar").contains_exactly([
        "{package}/lib{test_name}/l0.jar",
        "{package}/lib{test_name}/l1.jar",
        "{package}/lib{test_name}/l2.jar",
        "{package}/{test_name}/b1.jar",
    ])
    _expect_that_deploy_jar_action_inputs(env, targets.b2, "jar").contains_exactly([
        "{package}/lib{test_name}/l0.jar",
        "{package}/lib{test_name}/l1.jar",
        "{package}/lib{test_name}/l2.jar",
        "{package}/lib{test_name}/l3.jar",
        "{package}/{test_name}/b2.jar",
    ])

def _test_java_binary_runtime_deps_with_transitive_data(name):
    util.helper_target(
        java_binary,
        name = name + "/bin",
        srcs = ["Bin.java"],
        runtime_deps = [name + "/lib"],
    )
    util.helper_target(
        java_library,
        name = name + "/lib",
        srcs = ["Lib.java"],
        deps = [name + "/bundle"],
    )
    util.helper_target(
        java_library,
        name = name + "/bundle",
        data = [name + "/fava"],
        exports = [name + "/bundle2"],
    )
    util.helper_target(
        java_library,
        name = name + "/bundle2",
        data = [name + "/extra"],
    )
    util.helper_target(
        native.filegroup,
        name = name + "/fava",
        srcs = ["some.js"],
    )
    util.helper_target(
        native.filegroup,
        name = name + "/extra",
        srcs = ["some.gss"],
    )

    analysis_test(
        name = name,
        impl = _test_java_binary_runtime_deps_with_transitive_data_impl,
        target = name + "/bin",
    )

def _test_java_binary_runtime_deps_with_transitive_data_impl(env, target):
    env.expect.that_target(target).runfiles().contains_at_least([
        "{workspace}/{package}/some.js",
        "{workspace}/{package}/some.gss",
    ])

def java_binary_launcher_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_java_binary_non_executable_rule_outputs,
            _test_java_binary_resources_only,
            _test_java_binary_deploy_jar_coverage_setup,
            _test_java_binary_transitive_dependency_from_java_library,
            _test_java_binary_explicit_main_class,
            _test_java_binary_implicit_main_class,
            _test_java_test_main_class,
            _test_java_test_main_class_with_dot,
            _test_java_test_has_assertions_enabled,
            _test_java_binary_native_library_path_includes_transitive_deps,
            _test_java_binary_inner_class,
            _test_java_test_inner_class,
            _test_java_binary_strict_java_deps_flag,
            _test_java_binary_runtime_deps_transitivity,
            _test_java_binary_runtime_deps_with_transitive_data,
        ],
    )
