"""Parameterized tests for java_library with --java_launcher"""

load("@bazel_features//:features.bzl", "bazel_features")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_import.bzl", "java_import")
load("//java:java_library.bzl", "java_library")
load("//test/java/testutil:helper.bzl", "always_passes")
load("//test/java/testutil:java_info_subject.bzl", "java_info_subject")
load("//test/java/testutil:javac_action_subject.bzl", "javac_action_subject")

def _test_java_library_rule_outputs(name):
    util.helper_target(
        java_library,
        name = name + "/test_lib",
        srcs = ["A.java"],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_rule_outputs_impl,
        target = name + "/test_lib",
    )

def _test_java_library_rule_outputs_impl(env, target):
    env.expect.that_target(target).default_outputs().contains_exactly([
        "{package}/lib{name}.jar",
    ])

def _test_java_library_action_graph(name):
    util.helper_target(
        java_library,
        name = name + "/test_lib",
        srcs = [
            "Util.java",
            "Util2.java",
        ],
        javacopts = [
            "-g",
            "-encoding",
            "utf8",
        ],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_action_graph_impl,
        target = name + "/test_lib",
    )

def _test_java_library_action_graph_impl(env, target):
    javac_action = javac_action_subject.of(env, target, "{package}/lib{name}.jar")
    javac_action.inputs().contains_at_least([
        "{package}/Util.java",
        "{package}/Util2.java",
    ])
    javac_action.javacopts().contains_at_least([
        "-g",
        "-encoding",
        "utf8",
    ])

def _test_java_library_deps_of_genrule_are_not_on_classpath(name):
    util.helper_target(
        java_library,
        name = name + "/root_dep",
        srcs = ["test.java"],
    )
    util.helper_target(
        native.genrule,
        name = name + "/has_java_dep",
        outs = ["foo.jar"],
        cmd = "echo NOT EXECUTED",
        tools = [name + "/root_dep"],
    )
    util.helper_target(
        java_import,
        name = name + "/has_java_dep_import",
        jars = [name + "/has_java_dep"],
    )
    util.helper_target(
        java_library,
        name = name + "/library",
        srcs = ["dummy.java"],
        deps = [name + "/has_java_dep_import"],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_deps_of_genrule_are_not_on_classpath_impl,
        target = name + "/library",
    )

def _test_java_library_deps_of_genrule_are_not_on_classpath_impl(env, target):
    expected_classpath = "{bin_path}/{package}/_ijar/{test_name}/has_java_dep_import/{package}/foo-ijar.jar"
    javac_action_subject.of(env, target, "{package}/lib{name}.jar").classpath().contains_exactly([expected_classpath])

def _test_java_library_compile_and_run_time_paths(name):
    util.helper_target(
        java_library,
        name = name + "/base",
        srcs = ["Base.java"],
    )
    util.helper_target(
        java_library,
        name = name + "/specialization",
        srcs = ["Specialization.java"],
        deps = [name + "/base"],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_compile_and_run_time_paths_impl,
        targets = {
            "base": name + "/base",
            "specialization": name + "/specialization",
        },
    )

def _test_java_library_compile_and_run_time_paths_impl(env, targets):
    base_info = java_info_subject.from_target(env, targets.base)
    base_info.compilation_args().transitive_runtime_jars().contains_exactly(["{package}/lib{name}.jar"])
    base_info.compilation_args().transitive_compile_time_jars().contains_exactly(["{package}/lib{name}-hjar.jar"])
    base_info.compilation_args().compile_jars().contains_exactly(["{package}/lib{name}-hjar.jar"])

    base_jar = "{package}/lib{test_name}/base.jar"
    base_hjar = "{package}/lib{test_name}/base-hjar.jar"

    specialization_info = java_info_subject.from_target(env, targets.specialization)
    specialization_info.compilation_args().transitive_runtime_jars().contains_exactly([
        base_jar,
        "{package}/lib{name}.jar",
    ])
    specialization_info.compilation_args().transitive_compile_time_jars().contains_exactly([
        base_hjar,
        "{package}/lib{name}-hjar.jar",
    ])
    specialization_info.compilation_args().compile_jars().contains_exactly(["{package}/lib{name}-hjar.jar"])

def _test_java_library_files_to_compile(name):
    util.helper_target(
        java_library,
        name = name + "/lib",
        srcs = ["Lib.java"],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_files_to_compile_impl,
        target = name + "/lib",
    )

def _test_java_library_files_to_compile_impl(env, target):
    env.expect.that_target(target).output_group("compilation_outputs").contains_exactly(["{package}/lib{name}.jar"])

def _test_java_library_runtime_deps_are_not_on_classpath(name):
    util.helper_target(
        java_library,
        name = name + "/runtime_java_dep",
        srcs = ["test.java"],
    )
    util.helper_target(
        java_library,
        name = name + "/compile_dep",
        srcs = ["compile.java"],
    )
    util.helper_target(
        java_library,
        name = name + "/depends_on_runtimedep",
        srcs = ["dummy.java"],
        runtime_deps = [name + "/runtime_java_dep"],
        deps = [name + "/compile_dep"],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_runtime_deps_are_not_on_classpath_impl,
        target = name + "/depends_on_runtimedep",
    )

def _test_java_library_runtime_deps_are_not_on_classpath_impl(env, target):
    expected_compile = "{bin_path}/{package}/lib{test_name}/compile_dep-hjar.jar"
    javac_action_subject.of(env, target, "{package}/lib{name}.jar").classpath().contains_exactly([expected_compile])

def _test_java_library_runtime_deps_are_not_on_classpath_with_header_compilation(name):
    util.helper_target(
        java_library,
        name = name + "/runtime_java_dep",
        srcs = ["test.java"],
    )
    util.helper_target(
        java_library,
        name = name + "/compile_dep",
        srcs = ["compile.java"],
    )
    util.helper_target(
        java_library,
        name = name + "/depends_on_runtimedep",
        srcs = ["dummy.java"],
        runtime_deps = [name + "/runtime_java_dep"],
        deps = [name + "/compile_dep"],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_runtime_deps_are_not_on_classpath_with_header_compilation_impl,
        config_settings = {
            "//command_line_option:java_header_compilation": True,
        },
        target = name + "/depends_on_runtimedep",
    )

def _test_java_library_runtime_deps_are_not_on_classpath_with_header_compilation_impl(env, target):
    expected_compile = "{bin_path}/{package}/lib{test_name}/compile_dep-hjar.jar"
    javac_action_subject.of(env, target, "{package}/lib{name}.jar").classpath().contains_exactly([expected_compile])

def _test_java_library_fix_deps_tool_written_to_params_file(name):
    if not bazel_features.rules.analysis_tests_can_transition_on_experimental_incompatible_flags:
        # Bazel 7 does not support transition on experimental_* flags.
        # Exit early because this test case would be a loading phase error otherwise.
        always_passes(name)
        return
    util.helper_target(
        java_library,
        name = name + "/base",
        srcs = ["Base.java"],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_fix_deps_tool_written_to_params_file_impl,
        config_settings = {
            "//command_line_option:experimental_fix_deps_tool": "fixer",
        },
        target = name + "/base",
    )

def _test_java_library_fix_deps_tool_written_to_params_file_impl(env, target):
    javac_action_subject.of(env, target, "{package}/lib{name}.jar").argv().contains_at_least([
        "--experimental_fix_deps_tool",
        "fixer",
    ]).in_order()

JAVA_LIBRARY_LAUNCHER_TESTS = [
    _test_java_library_rule_outputs,
    _test_java_library_action_graph,
    _test_java_library_deps_of_genrule_are_not_on_classpath,
    _test_java_library_compile_and_run_time_paths,
    _test_java_library_files_to_compile,
    _test_java_library_runtime_deps_are_not_on_classpath,
    _test_java_library_runtime_deps_are_not_on_classpath_with_header_compilation,
    _test_java_library_fix_deps_tool_written_to_params_file,
]
