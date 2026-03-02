"""Tests for the java_toolchain rule"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_binary.bzl", "java_binary")
load("//java:java_library.bzl", "java_library")
load("//java/common:java_semantics.bzl", "semantics")
load("//java/toolchains:java_runtime.bzl", "java_runtime")
load("//java/toolchains:java_toolchain.bzl", "java_toolchain")
load("//test/java/testutil:java_info_subject.bzl", "java_info_subject")
load("//test/java/testutil:java_toolchain_info_subject.bzl", "java_toolchain_info_subject")
load("//test/java/testutil:javac_action_subject.bzl", "javac_action_subject")

def _declare_java_toolchain(*, name, **kwargs):
    java_runtime_name = name + "/runtime"
    java_runtime(name = java_runtime_name)
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

def _test_javac_gets_options(name):
    _declare_java_toolchain(name = name)
    util.helper_target(
        java_library,
        name = name + "/b",
        srcs = ["b.java"],
    )
    util.helper_target(
        java_library,
        name = name + "/a",
        srcs = ["a.java"],
        deps = [Label(name + "/b")],
    )

    analysis_test(
        name = name,
        impl = _test_javac_gets_options_impl,
        targets = {
            "a": name + "/a",
            "b": name + "/b",
        },
        config_settings = {
            "//command_line_option:java_header_compilation": "true",
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
    )

def _test_javac_gets_options_impl(env, targets):
    assert_javac_action = javac_action_subject.of(env, targets.a, "{package}/lib{name}.jar")
    assert_javac_action.source().contains_exactly(["6"])
    assert_javac_action.target().contains_exactly(["6"])
    assert_javac_action.xmaxerrs().contains_exactly(["500"])
    assert_javac_action.jar().contains_exactly(["{package}/JavaBuilder_deploy.jar"])
    assert_javac_action.inputs().contains("{package}/rt.jar")

    assert_argv = assert_javac_action.argv()
    assert_argv.contains("-Xlint:toto")
    assert_argv.not_contains("-g")

    assert_header_action = javac_action_subject.of(env, targets.b, "{package}/lib{name}-hjar.jar")
    assert_header_action.argv().contains("{package}/turbine_direct")

def _test_jacocorunner(name):
    _declare_java_toolchain(
        name = name,
        jacocorunner = "myjacocorunner.jar",
    )

    analysis_test(
        name = name,
        impl = _test_jacocorunner_impl,
        target = name + "/java_toolchain",
    )

def _test_jacocorunner_impl(env, target):
    assert_toolchain = java_toolchain_info_subject.from_target(env, target)

    assert_toolchain.jacocorunner().short_path_equals("{package}/myjacocorunner.jar")

def _test_singlejar_get_command_line(name):
    _declare_java_toolchain(name = name)
    util.helper_target(
        java_binary,
        name = name + "/a",
        srcs = ["a.java"],
    )

    analysis_test(
        name = name,
        impl = _test_singlejar_get_command_line_impl,
        target = name + "/a",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
        # This crashes in earlier Bazel versions where native rules handled deploy jars differently.
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _test_singlejar_get_command_line_impl(env, target):
    assert_javac_action = javac_action_subject.of(env, target, "{package}/{name}_deploy.jar")
    assert_javac_action.executable_file_name().equals(target.label.package + "/singlejar")

def _test_genclass_get_command_line(name):
    _declare_java_toolchain(name = name)
    util.helper_target(
        java_library,
        name = name + "/a",
        srcs = ["a.java"],
        javacopts = ["-processor NOSUCH"],
    )

    analysis_test(
        name = name,
        impl = _test_genclass_get_command_line_impl,
        target = name + "/a",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
    )

def _test_genclass_get_command_line_impl(env, target):
    assert_javac_action = javac_action_subject.of(env, target, "{package}/lib{name}-gen.jar")

    assert_javac_action.jar().contains_exactly(["{package}/GenClass_deploy.jar"])

def _test_timezone_data_is_correct(name):
    _declare_java_toolchain(name = name)

    analysis_test(
        name = name,
        impl = _test_timezone_data_is_correct_impl,
        target = name + "/java_toolchain",
    )

def _test_timezone_data_is_correct_impl(env, target):
    java_toolchain_info_subject.from_target(env, target).timezone_data().short_path_equals(
        "{package}/tzdata.jar",
    )

def _test_java_binary_uses_timezone_data(name):
    _declare_java_toolchain(name = name)
    util.helper_target(
        java_binary,
        name = name + "/a",
        srcs = ["a.java"],
    )

    analysis_test(
        name = name,
        impl = _test_java_binary_uses_timezone_data_impl,
        target = name + "/a",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
    )

def _test_java_binary_uses_timezone_data_impl(env, target):
    assert_action = javac_action_subject.of(env, target, "{package}/{name}.jar")
    assert_action.sources().contains("{package}/tzdata.jar")
    assert_action.inputs().contains_predicate(matching.file_basename_equals("tzdata.jar"))

def _test_ijar_get_command_line(name):
    _declare_java_toolchain(name = name)
    util.helper_target(
        java_library,
        name = name + "/a",
        srcs = ["a.java"],
    )

    analysis_test(
        name = name,
        impl = _test_ijar_get_command_line_impl,
        target = name + "/a",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
            "//command_line_option:java_header_compilation": "false",
        },
    )

def _test_ijar_get_command_line_impl(env, target):
    compile_jar = java_info_subject.from_target(env, target).java_outputs().singleton().compile_jar().actual
    env.expect.that_target(target).action_generating(compile_jar.short_path).argv().contains(
        "{package}/ijar",
    )

def _test_no_header_compiler_header_compilation_enabled_fails(name):
    _declare_java_toolchain(
        name = name,
        header_compiler = None,
    )
    util.helper_target(
        java_library,
        name = name + "/a",
        srcs = ["a.java"],
    )

    analysis_test(
        name = name,
        impl = _test_no_header_compiler_header_compilation_enabled_fails_impl,
        target = name + "/a",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
            "//command_line_option:java_header_compilation": "true",
        },
        expect_failure = True,
    )

def _test_no_header_compiler_header_compilation_enabled_fails_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.contains("header compilation was requested but it is not supported by the " +
                          "current Java toolchain"),
    )

def _test_no_header_compiler_direct_header_compilation_enabled_fails(name):
    _declare_java_toolchain(
        name = name,
        header_compiler_direct = None,
    )
    util.helper_target(
        java_library,
        name = name + "/a",
        srcs = ["a.java"],
    )

    analysis_test(
        name = name,
        impl = _test_no_header_compiler_direct_header_compilation_enabled_fails_impl,
        target = name + "/a",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
            "//command_line_option:java_header_compilation": "true",
        },
        expect_failure = True,
    )

def _test_no_header_compiler_direct_header_compilation_enabled_fails_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.contains("header compilation was requested but it is not supported by the " +
                          "current Java toolchain"),
    )

def _test_no_header_compiler_header_compilation_disabled_analyzes_successfully(name):
    _declare_java_toolchain(
        name = name,
        header_compiler = None,
    )
    util.helper_target(
        java_library,
        name = name + "/a",
        srcs = ["a.java"],
    )

    analysis_test(
        name = name,
        impl = _test_no_header_compiler_header_compilation_disabled_analyzes_successfully_impl,
        target = name + "/a",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
            "//command_line_option:java_header_compilation": "false",
        },
    )

def _test_no_header_compiler_header_compilation_disabled_analyzes_successfully_impl(
        env,  # @unused
        target):  # @unused
    # Implicitly succeeds.
    pass

def _test_header_compiler_builtin_processors(name):
    util.helper_target(
        java_toolchain,
        name = name + "/java_toolchain",
        header_compiler_builtin_processors = ["BuiltinProc1", "BuiltinProc2"],
        singlejar = "singlejar",
    )

    analysis_test(
        name = name,
        impl = _test_header_compiler_builtin_processors_impl,
        target = name + "/java_toolchain",
    )

def _test_header_compiler_builtin_processors_impl(env, target):
    java_toolchain_info_subject.from_target(env, target).header_compiler_builtin_processors().contains_exactly(["BuiltinProc1", "BuiltinProc2"])

def _test_reduced_classpath_incompatible_processors(name):
    util.helper_target(
        java_toolchain,
        name = name + "/java_toolchain",
        reduced_classpath_incompatible_processors = ["IncompatibleProc1", "IncompatibleProc2"],
        singlejar = "singlejar",
    )

    analysis_test(
        name = name,
        impl = _test_reduced_classpath_incompatible_processors_impl,
        target = name + "/java_toolchain",
    )

def _test_reduced_classpath_incompatible_processors_impl(env, target):
    java_toolchain_info_subject.from_target(env, target).reduced_classpath_incompatible_processors().contains_exactly(["IncompatibleProc1", "IncompatibleProc2"])

def java_toolchain_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_jacocorunner,
            _test_javac_gets_options,
            _test_singlejar_get_command_line,
            _test_genclass_get_command_line,
            _test_timezone_data_is_correct,
            _test_java_binary_uses_timezone_data,
            _test_ijar_get_command_line,
            _test_no_header_compiler_header_compilation_enabled_fails,
            _test_no_header_compiler_direct_header_compilation_enabled_fails,
            _test_no_header_compiler_header_compilation_disabled_analyzes_successfully,
            _test_header_compiler_builtin_processors,
            _test_reduced_classpath_incompatible_processors,
        ],
    )
