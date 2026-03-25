"""Tests for the java_toolchain rule"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching", "subjects")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_binary.bzl", "java_binary")
load("//java:java_library.bzl", "java_library")
load("//java:java_plugin.bzl", "java_plugin")
load("//java/common:java_common.bzl", "java_common")
load("//test/java/testutil:java_info_subject.bzl", "java_info_subject")
load("//test/java/testutil:java_toolchain_info_subject.bzl", "java_toolchain_info_subject")
load("//test/java/testutil:javac_action_subject.bzl", "javac_action_subject")
load("//test/java/testutil:mock_java_toolchain.bzl", "mock_java_toolchain")
load("//toolchains:java_toolchain_alias.bzl", "java_toolchain_alias")

def _test_javac_gets_options(name):
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
        javabuilder = name + "/JavaBuilder_deploy.jar",
        header_compiler_direct = name + "/turbine_direct",
        bootclasspath = [name + "/rt.jar"],
        source_version = "6",
        target_version = "6",
        xlint = ["toto"],
        javacopts = ["-Xmaxerrs 500"],
    )
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
    assert_javac_action.javacopts().contains_at_least([
        "-source",
        "6",
        "-target",
        "6",
        "-Xlint:toto",
        "-Xmaxerrs",
        "500",
    ])
    assert_javac_action.jar().contains_exactly(["{package}/{test_name}/JavaBuilder_deploy.jar"])
    assert_javac_action.inputs().contains("{package}/{test_name}/rt.jar")

    assert_javac_action.javacopts().not_contains("-g")

    assert_header_action = javac_action_subject.of(env, targets.b, "{package}/lib{name}-hjar.jar")
    assert_header_action.argv().contains("{package}/{test_name}/turbine_direct")

def _test_jacocorunner(name):
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
        jacocorunner = "myjacocorunner.jar",
    )
    util.helper_target(
        java_toolchain_alias,
        name = name + "/alias",
    )
    analysis_test(
        name = name,
        impl = _test_jacocorunner_impl,
        target = name + "/alias",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
    )

def _test_jacocorunner_impl(env, target):
    assert_toolchain = java_toolchain_info_subject.from_target(env, target)

    assert_toolchain.jacocorunner().short_path_equals("{package}/myjacocorunner.jar")

def _test_singlejar_get_command_line(name):
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
    )
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
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
        genclass = name + "/GenClass_deploy.jar",
    )
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

    assert_javac_action.jar().contains_exactly(["{package}/{test_name}/GenClass_deploy.jar"])

def _test_timezone_data_is_correct(name):
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
        timezone_data = "tzdata.jar",
    )
    util.helper_target(
        java_toolchain_alias,
        name = name + "/alias",
    )

    analysis_test(
        name = name,
        impl = _test_timezone_data_is_correct_impl,
        target = name + "/alias",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
    )

def _test_timezone_data_is_correct_impl(env, target):
    java_toolchain_info_subject.from_target(env, target).timezone_data().short_path_equals(
        "{package}/tzdata.jar",
    )

def _test_java_binary_uses_timezone_data(name):
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
        timezone_data = name + "/tzdata.jar",
    )
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
    assert_action.sources().contains("{package}/{test_name}/tzdata.jar")
    assert_action.inputs().contains_predicate(matching.file_basename_equals("tzdata.jar"))

def _test_ijar_get_command_line(name):
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
    )
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
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
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
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
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
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
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
        mock_java_toolchain,
        name = name + "/toolchain",
        header_compiler_builtin_processors = ["BuiltinProc1", "BuiltinProc2"],
    )
    util.helper_target(
        java_toolchain_alias,
        name = name + "/alias",
    )

    analysis_test(
        name = name,
        impl = _test_header_compiler_builtin_processors_impl,
        target = name + "/alias",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
    )

def _test_header_compiler_builtin_processors_impl(env, target):
    java_toolchain_info_subject.from_target(env, target).header_compiler_builtin_processors().contains_exactly([
        "BuiltinProc1",
        "BuiltinProc2",
    ])

def _test_reduced_classpath_incompatible_processors(name):
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
        reduced_classpath_incompatible_processors = ["IncompatibleProc1", "IncompatibleProc2"],
    )
    util.helper_target(
        java_toolchain_alias,
        name = name + "/alias",
    )

    analysis_test(
        name = name,
        impl = _test_reduced_classpath_incompatible_processors_impl,
        target = name + "/alias",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
    )

def _test_reduced_classpath_incompatible_processors_impl(env, target):
    java_toolchain_info_subject.from_target(env, target).reduced_classpath_incompatible_processors().contains_exactly([
        "IncompatibleProc1",
        "IncompatibleProc2",
    ])

def _test_location_expansion_in_jvm_opts(name):
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
        tools = [name + "/jsr305.jar", name + "/javac"],
        jvm_opts = [
            "--patch-module=jdk.compiler=$(location " + name + "/javac)",
            "--patch-module=java.xml.ws.annotation=$(location " + name + "/jsr305.jar)",
        ],
        javabuilder_jvm_opts = ["-Xshare:auto"],
    )
    util.helper_target(
        java_library,
        name = name + "/lib",
        srcs = ["a.java"],
    )

    analysis_test(
        name = name,
        impl = _test_location_expansion_in_jvm_opts_impl,
        target = name + "/lib",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
    )

def _test_location_expansion_in_jvm_opts_impl(env, target):
    assert_javac_action = env.expect.that_target(target).action_generating("{package}/lib{name}.jar")
    assert_javac_action.argv().contains("--patch-module=jdk.compiler={package}/{test_name}/javac")
    assert_javac_action.argv().contains("--patch-module=java.xml.ws.annotation={package}/{test_name}/jsr305.jar")
    assert_javac_action.argv().contains("-Xshare:auto")
    assert_javac_action.inputs().contains("{package}/{test_name}/jsr305.jar")

def _test_location_expansion_with_multiple_artifacts_fails(name):
    util.helper_target(
        native.filegroup,
        name = name + "/fg",
        srcs = ["one", "two"],
    )
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
        tools = [name + "/fg"],
        javabuilder_jvm_opts = ["$(location " + name + "/fg)"],
    )

    analysis_test(
        name = name,
        impl = _test_location_expansion_with_multiple_artifacts_fails_impl,
        target = name + "/toolchain_java",  # the underlying java_toolchain
        expect_failure = True,
    )

def _test_location_expansion_with_multiple_artifacts_fails_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.contains("$(location) expression expands to more than one file"),
    )

def _test_timezone_data_with_multiple_artifacts_fails(name):
    util.helper_target(
        native.filegroup,
        name = name + "/fg",
        srcs = ["one", "two"],
    )
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
        timezone_data = name + "/fg",
    )

    analysis_test(
        name = name,
        impl = _test_timezone_data_with_multiple_artifacts_fails_impl,
        target = name + "/toolchain_java",  # the underlying java_toolchain
        expect_failure = True,
    )

def _test_timezone_data_with_multiple_artifacts_fails_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.contains("must produce a single file"),
    )

def _test_java_compile_action_target_gets_javacopts_from_toolchain(name):
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
        source_version = "6",
        target_version = "6",
        xlint = ["toto"],
        javacopts = ["-XDtoolchainJavacFlag"],
    )
    util.helper_target(
        java_library,
        name = name + "/lib",
        srcs = ["a.java"],
    )
    analysis_test(
        name = name,
        impl = _test_java_compile_action_target_gets_javacopts_from_toolchain_impl,
        target = name + "/lib",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
            "//command_line_option:javacopt": ["-XDcommandLineJavacFlag"],
            "//command_line_option:host_javacopt": ["-XDhostCommandLineJavacFlag"],
        },
    )

def _test_java_compile_action_target_gets_javacopts_from_toolchain_impl(env, target):
    assert_javacopts = javac_action_subject.of(env, target, "{package}/lib{name}.jar").javacopts()
    assert_javacopts.contains_exactly([
        "-source",
        "6",
        "-target",
        "6",
        "-Xlint:toto",
        "-XDtoolchainJavacFlag",
        "-XDcommandLineJavacFlag",
    ])

def _test_java_compile_action_exec_gets_javacopts_from_toolchain(name):
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
        source_version = "6",
        target_version = "6",
        xlint = ["toto"],
        javacopts = ["-XDtoolchainJavacFlag"],
    )
    util.helper_target(
        java_library,
        name = name + "/lib",
        srcs = ["a.java"],
    )
    util.helper_target(
        util.force_exec_config,
        name = name + "/exec_lib",
        tools = [name + "/lib"],
    )
    analysis_test(
        name = name,
        impl = _test_java_compile_action_exec_gets_javacopts_from_toolchain_impl,
        target = name + "/exec_lib",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
            "//command_line_option:javacopt": ["-XDcommandLineJavacFlag"],
            "//command_line_option:host_javacopt": ["-XDhostCommandLineJavacFlag"],
        },
    )

def _test_java_compile_action_exec_gets_javacopts_from_toolchain_impl(env, target):
    lib = env.expect.that_target(target).attr("tools", factory = subjects.collection).actual[0]
    assert_javacopts = javac_action_subject.of(env, lib, "{package}/lib{name}.jar").javacopts()
    assert_javacopts.contains_exactly([
        "-source",
        "6",
        "-target",
        "6",
        "-Xlint:toto",
        "-XDtoolchainJavacFlag",
        "-XDhostCommandLineJavacFlag",
    ])

def _test_java_compile_action_uses_tool_specific_jvm_opts(name):
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
        jvm_opts = ["-Xbase"],
        javabuilder_jvm_opts = ["-DjavabuilderFlag=1"],
        turbine_jvm_opts = ["-DturbineFlag=1"],
    )
    util.helper_target(
        java_plugin,
        name = name + "/plugin",
        processor_class = "Proc",
        generates_api = True,
    )
    util.helper_target(
        java_library,
        name = name + "/lib",
        srcs = ["a.java"],
        plugins = [name + "/plugin"],
    )
    analysis_test(
        name = name,
        impl = _test_java_compile_action_uses_tool_specific_jvm_opts_impl,
        target = name + "/lib",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
    )

def _test_java_compile_action_uses_tool_specific_jvm_opts_impl(env, target):
    javac_action = javac_action_subject.of(env, target, "{package}/lib{name}.jar")
    javac_action.argv().contains("-DjavabuilderFlag=1")

    header_action = env.expect.that_target(target).action_generating("{package}/lib{name}-hjar.jar")
    header_action.argv().contains("-DturbineFlag=1")

def _test_javabuilder_location_expansion_with_multiple_artifacts(name):
    util.helper_target(
        native.filegroup,
        name = name + "/fg1",
        srcs = ["a", "b"],
    )
    util.helper_target(
        native.filegroup,
        name = name + "/fg2",
        srcs = ["c", "d"],
    )
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
        javabuilder_data = [name + "/fg1", name + "/fg2"],
        javabuilder_jvm_opts = [
            "$(locations " + name + "/fg1)",
            "$(locations " + name + "/fg2)",
        ],
    )
    util.helper_target(
        java_toolchain_alias,
        name = name + "/alias",
    )

    analysis_test(
        name = name,
        impl = _test_javabuilder_location_expansion_with_multiple_artifacts_impl,
        target = name + "/alias",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
    )

def _test_javabuilder_location_expansion_with_multiple_artifacts_impl(env, target):
    assert_javabuilder = java_toolchain_info_subject.from_target(env, target).javabuilder()
    assert_javabuilder.data().contains_exactly([
        "{package}/a",
        "{package}/b",
        "{package}/c",
        "{package}/d",
    ]).in_order()
    assert_javabuilder.jvm_opts().contains_exactly([
        "{package}/a {package}/b",
        "{package}/c {package}/d",
    ]).in_order()

def _no_toolchain_rule_impl(ctx):
    java_common.pack_sources(
        ctx.actions,
        output_source_jar = "output_source_jar",
        java_toolchain = "java_toolchain",
    )

_no_toolchain_rule = rule(
    implementation = _no_toolchain_rule_impl,
)

def _test_java_common_without_toolchain_type_fails(name):
    util.helper_target(
        _no_toolchain_rule,
        name = name + "/no_toolchain",
    )
    analysis_test(
        name = name,
        impl = _test_java_common_without_toolchain_type_fails_impl,
        target = name + "/no_toolchain",
        expect_failure = True,
    )

def _test_java_common_without_toolchain_type_fails_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("must declare *tools/jdk:toolchain_type' toolchain in order to use java_common"),
    )

def _test_java_toolchain_flag_default(name):
    util.helper_target(
        java_toolchain_alias,
        name = name + "/toolchain_alias",
    )

    analysis_test(
        name = name,
        impl = _test_java_toolchain_flag_default_impl,
        target = name + "/toolchain_alias",
    )

def _test_java_toolchain_flag_default_impl(env, target):
    assert_toolchain = java_toolchain_info_subject.from_target(env, target)
    assert_toolchain.label_str().matches(
        matching.any(
            matching.str_endswith("jdk:remote_toolchain"),
            matching.str_endswith("jdk:toolchain"),
            matching.str_endswith("jdk:toolchain_host"),
            # buildifier: disable=canonical-repository
            matching.str_startswith("@@//toolchains:toolchain_java"),
        ),
    )

def _test_java_toolchain_flag_set(name):
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
    )
    util.helper_target(
        java_toolchain_alias,
        name = name + "/toolchain_alias",
    )

    analysis_test(
        name = name,
        impl = _test_java_toolchain_flag_set_impl,
        targets = {
            "alias": name + "/toolchain_alias",
            "toolchain": name + "/toolchain_java",  # the underlying java_toolchain
        },
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
    )

def _test_java_toolchain_flag_set_impl(env, targets):
    assert_toolchain = java_toolchain_info_subject.from_target(env, targets.alias)
    assert_toolchain.label().equals(targets.toolchain.label)

def _test_default_javac_opts_depset(name):
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
        source_version = "6",
        target_version = "6",
        xlint = ["toto"],
        javacopts = ["-Xmaxerrs 500"],
    )
    util.helper_target(
        java_toolchain_alias,
        name = name + "/alias",
    )

    analysis_test(
        name = name,
        impl = _test_default_javac_opts_depset_impl,
        target = name + "/alias",
        attr_values = {"tags": ["min_bazel_8"]},
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
    )

def _test_default_javac_opts_depset_impl(env, target):
    java_toolchain_info_subject.from_target(env, target).default_javacopts_depset().contains_exactly(
        ["-source 6 -target 6 -Xlint:toto -Xmaxerrs 500"],
    )

def _test_default_javac_opts(name):
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
        source_version = "6",
        target_version = "6",
    )
    util.helper_target(
        java_toolchain_alias,
        name = name + "/alias",
    )

    analysis_test(
        name = name,
        impl = _test_default_javac_opts_impl,
        target = name + "/alias",
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _test_default_javac_opts_impl(env, target):
    java_toolchain_info_subject.from_target(env, target).default_javacopts().contains_at_least([
        "-source",
        "6",
        "-target",
        "6",
    ]).in_order()

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
            _test_location_expansion_in_jvm_opts,
            _test_location_expansion_with_multiple_artifacts_fails,
            _test_timezone_data_with_multiple_artifacts_fails,
            _test_java_compile_action_target_gets_javacopts_from_toolchain,
            _test_java_compile_action_exec_gets_javacopts_from_toolchain,
            _test_java_compile_action_uses_tool_specific_jvm_opts,
            _test_javabuilder_location_expansion_with_multiple_artifacts,
            _test_java_common_without_toolchain_type_fails,
            _test_java_toolchain_flag_default,
            _test_java_toolchain_flag_set,
            _test_default_javac_opts_depset,
            _test_default_javac_opts,
        ],
    )
