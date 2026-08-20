"""Tests for DeployArchiveBuilder."""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_binary.bzl", "java_binary")
load("//java/common:java_semantics.bzl", "semantics")
load("//java/common/rules/impl:java_binary_deploy_jar.bzl", "create_deploy_archive")
load("//test/java/testutil:mock_java_toolchain.bzl", "mock_java_toolchain")

def _deploy_archives_impl(ctx):
    outputs = [ctx.outputs.deployjar, ctx.outputs.unstrippeddeployjar]
    for output in outputs:
        create_deploy_archive(
            ctx,
            launcher = None,
            main_class = "com.google.test.main",
            coverage_main_class = "com.google.test.main",
            resources = depset(),
            classpath_resources = depset(),
            runtime_classpath = depset(),
            manifest_lines = [],
            build_info_files = [],
            build_target = str(ctx.label),
            output = output,
            exclude_build_data = True,
        )
    return [DefaultInfo(files = depset(outputs))]

_deploy_archives = rule(
    implementation = _deploy_archives_impl,
    outputs = {
        "deployjar": "%{name}_deploy.jar",
        "unstrippeddeployjar": "%{name}_deploy.jar.unstripped",
    },
    toolchains = [semantics.JAVA_TOOLCHAIN],
)

def _test_custom_singlejar(name):
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
    )
    util.helper_target(
        java_binary,
        name = name + "/binary",
        srcs = [name + "/main.java"],
        main_class = "com.google.test.main",
    )

    analysis_test(
        name = name,
        impl = _test_custom_singlejar_impl,
        target = name + "/binary",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
        # Starlark rules are only used with Bazel 8 onwards.
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _test_custom_singlejar_impl(env, target):
    action = env.expect.that_target(target).action_named("JavaDeployJar")
    action.inputs().contains_at_least_predicates(
        [
            matching.file_path_matches("*/test_custom_singlejar/binary.jar"),
        ],
    )

def _test_exclude_build_data_applies_to_both_deploy_archives(name):
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
    )
    util.helper_target(
        _deploy_archives,
        name = name + "/binary",
    )

    analysis_test(
        name = name,
        impl = _test_exclude_build_data_applies_to_both_deploy_archives_impl,
        target = name + "/binary",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _test_exclude_build_data_applies_to_both_deploy_archives_impl(env, target):
    for output in [
        "{package}/{name}_deploy.jar",
        "{package}/{name}_deploy.jar.unstripped",
    ]:
        action = env.expect.that_target(target).action_generating(output)
        action.argv().contains("--normalize")
        action.argv().contains("--exclude_build_data")
        action.argv().not_contains("--build_info_file")

def deploy_archive_builder_test_suite(name):
    """Test suite for java_binary deploy archive."""
    test_suite(
        name = name,
        tests = [
            _test_custom_singlejar,
            _test_exclude_build_data_applies_to_both_deploy_archives,
        ],
    )
