"""Tests for DeployArchiveBuilder."""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_binary.bzl", "java_binary")
load("//java/common:java_semantics.bzl", "semantics")
load("//java/toolchains:java_runtime.bzl", "java_runtime")
load("//java/toolchains:java_toolchain.bzl", "java_toolchain")

def _declare_java_toolchain(*, name, **kwargs):
    java_runtime_name = name + "/runtime"
    util.helper_target(
        java_runtime,
        name = java_runtime_name,
    )
    toolchain_attrs = {
        "source_version": "6",
        "target_version": "6",
        "bootclasspath": ["rt.jar"],
        "xlint": ["toto"],
        "javacopts": ["-Xmaxerrs 500"],
        "compatible_javacopts": {
            "android": ["-XDandroidCompatible"],
            "testonly": ["-XDtestOnly"],
            "public_visibility": ["-XDpublicVisibility"],
        },
        "tools": [":javac_canary.jar"],
        "javabuilder": ":JavaBuilder_deploy.jar",
        "header_compiler": ":turbine_canary_deploy.jar",
        "header_compiler_direct": ":turbine_direct",
        "singlejar": "singlejar",
        "ijar": "ijar",
        "genclass": "GenClass_deploy.jar",
        "timezone_data": "tzdata.jar",
        "header_compiler_builtin_processors": ["BuiltinProc1", "BuiltinProc2"],
        "reduced_classpath_incompatible_processors": [
            "IncompatibleProc1",
            "IncompatibleProc2",
        ],
        "java_runtime": java_runtime_name,
    }
    toolchain_attrs.update(kwargs)
    util.helper_target(
        java_toolchain,
        name = name + "/java_toolchain",
        **toolchain_attrs
    )
    util.helper_target(
        native.toolchain,
        name = name + "/toolchain",
        toolchain = name + "/java_toolchain",
        toolchain_type = semantics.JAVA_TOOLCHAIN_TYPE,
    )

def _test_custom_singlejar(name):
    _declare_java_toolchain(name = name)

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

def deploy_archive_builder_test_suite(name):
    """Test suite for java_binary deploy archive."""
    test_suite(
        name = name,
        tests = [
            _test_custom_singlejar,
        ],
    )
