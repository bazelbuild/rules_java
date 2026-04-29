"""Parameterized tests for java_library with --java_launcher"""

load("@bazel_features//:features.bzl", "bazel_features")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_import.bzl", "java_import")
load("//java:java_library.bzl", "java_library")
load("//java:java_plugin.bzl", "java_plugin")
load("//java/toolchains:java_runtime.bzl", "java_runtime")
load("//java/toolchains:java_toolchain.bzl", "java_toolchain")
load("//test/java/testutil:helper.bzl", "always_passes")
load("//test/java/testutil:java_info_subject.bzl", "java_info_subject")
load("//test/java/testutil:javac_action_subject.bzl", "javac_action_subject")
load("//test/java/testutil:rules/custom_library_with_bootclasspath.bzl", "custom_bootclasspath")

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

def _test_java_library_annotation_processing_using_javacopt(name):
    util.helper_target(
        java_library,
        name = name + "/to_be_processed",
        srcs = ["ToBeProcessed.java"],
        javacopts = ["-processor com.google.process.Processor"],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_annotation_processing_using_javacopt_impl,
        target = name + "/to_be_processed",
    )

def _test_java_library_annotation_processing_using_javacopt_impl(env, target):
    javac_action = javac_action_subject.of(env, target, "{package}/lib{name}.jar")
    javac_action.argv().contains("--generated_sources_output")
    javac_action.generated_sources_output().contains("{bin_path}/{package}/lib{name}-gensrc.jar")
    javac_action.javacopts().contains("-processor")
    javac_action.javacopts().contains("com.google.process.Processor")

    # The compile action should have a gensrc jar output
    javac_action.outputs().contains("{package}/lib{name}-gensrc.jar")

    # The gensrc jar should be an input to the source jar action
    src_jar_action = env.expect.that_target(target).action_generating("{package}/lib{name}-src.jar")
    src_jar_action.inputs().contains("{package}/lib{name}-gensrc.jar")

def _test_java_library_javacopts_with_location_expansion(name):
    util.helper_target(
        java_library,
        name = name + "/patch",
        srcs = ["A.java"],
    )
    util.helper_target(
        java_library,
        name = name + "/lib",
        srcs = ["ToBeProcessed.java"],
        javacopts = ["--patch $(execpath " + name + "/patch)"],
        deps = [name + "/patch"],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_javacopts_with_location_expansion_impl,
        target = name + "/lib",
    )

def _test_java_library_javacopts_with_location_expansion_impl(env, target):
    javac_action = javac_action_subject.of(env, target, "{package}/lib{name}.jar")
    javac_action.javacopts().contains_at_least([
        "--patch",
        "{bin_path}/{package}/lib{test_name}/patch.jar",
    ])

def _test_java_library_invalid_plugin(name):
    util.helper_target(
        java_library,
        name = name + "/not_a_plugin",
        srcs = ["NotAPlugin.java"],
    )
    util.helper_target(
        java_library,
        name = name + "/lib",
        srcs = ["Lib.java"],
        plugins = [name + "/not_a_plugin"],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_invalid_plugin_impl,
        target = name + "/lib",
        expect_failure = True,
    )

def _test_java_library_invalid_plugin_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.contains("does not have mandatory providers: 'JavaPluginInfo'"),
    )

def _test_java_library_plugin_with_runtime_deps(name):
    util.helper_target(
        java_library,
        name = name + "/runtime_lib",
        srcs = ["Runtime.java"],
    )
    util.helper_target(
        java_library,
        name = name + "/lib",
        srcs = ["Lib.java"],
        runtime_deps = [name + "/runtime_lib"],
    )
    util.helper_target(
        java_plugin,
        name = name + "/plugin",
        srcs = ["Plugin.java"],
        processor_class = "com.google.process.stuff",
        deps = [name + "/lib"],
    )
    util.helper_target(
        java_library,
        name = name + "/leaf_lib",
        srcs = ["LeafLib.java"],
        plugins = [name + "/plugin"],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_plugin_with_runtime_deps_impl,
        target = name + "/leaf_lib",
    )

def _test_java_library_plugin_with_runtime_deps_impl(env, target):
    javac_action = javac_action_subject.of(env, target, "{package}/lib{name}.jar")
    javac_action.processorpath().contains_exactly_predicates([
        matching.str_matches("*/plugin.jar"),
        matching.str_matches("*/lib.jar"),
        matching.str_matches("*/runtime_lib.jar"),
    ])

def _test_java_library_source_jar_without_annotation_processing(name):
    util.helper_target(
        java_library,
        name = name + "/foo",
        srcs = ["Foo.java"],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_source_jar_without_annotation_processing_impl,
        target = name + "/foo",
    )

def _test_java_library_source_jar_without_annotation_processing_impl(env, target):
    javac_action = javac_action_subject.of(env, target, "{package}/lib{name}.jar")
    javac_action.argv().not_contains("--generated_sources_output")
    javac_action.outputs().contains_exactly([
        "{package}/lib{name}.jar",
        "{package}/lib{name}.jdeps",
        "{package}/lib{name}-native-header.jar",
        "{package}/lib{name}.jar_manifest_proto",
    ])

    src_jar_action = javac_action_subject.of(env, target, "{package}/lib{name}-src.jar")
    src_jar_action.outputs().contains_exactly([
        "{package}/lib{name}-src.jar",
    ])

def _test_java_library_source_jars_with_source_jars(name):
    util.helper_target(
        java_library,
        name = name + "/beatit",
        srcs = [
            "Plugin.java",
            "Some.srcjar",
        ],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_source_jars_with_source_jars_impl,
        target = name + "/beatit",
    )

def _test_java_library_source_jars_with_source_jars_impl(env, target):
    src_jar_action = javac_action_subject.of(env, target, "{package}/lib{name}-src.jar")
    src_jar_action.inputs().contains_at_least([
        "{package}/Plugin.java",
        "{package}/Some.srcjar",
    ])
    src_jar_action.sources().contains_exactly([
        "{package}/Some.srcjar",
    ])
    src_jar_action.resources().contains_predicate(
        matching.str_matches("*/Plugin.java:*rules/Plugin.java"),
    )

def _test_java_library_should_set_bootclasspath(name):
    boot_jar = util.empty_file(name + "/boot.jar")
    util.helper_target(
        custom_bootclasspath,
        name = name + "/mock_bootclasspath",
        bootclasspath = [boot_jar],
    )

    util.helper_target(
        java_runtime,
        name = name + "/runtime",
    )

    util.helper_target(
        java_toolchain,
        name = name + "/mock_toolchain_impl",
        bootclasspath = [name + "/mock_bootclasspath"],
        genclass = name + "/genclass",
        header_compiler = name + "/header_compiler",
        header_compiler_direct = name + "/header_compiler_direct",
        ijar = name + "/ijar",
        java_runtime = name + "/runtime",
        javabuilder = name + "/javabuilder",
        singlejar = name + "/singlejar",
    )
    util.helper_target(
        native.toolchain,
        name = name + "/toolchain",
        toolchain = name + "/mock_toolchain_impl",
        toolchain_type = "@bazel_tools//tools/jdk:toolchain_type",
    )
    util.helper_target(
        java_library,
        name = name + "/test_lib",
        srcs = ["A.java"],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_should_set_bootclasspath_impl,
        config_settings = {
            "//command_line_option:extra_toolchains": [
                native.package_relative_label(name + "/toolchain"),
            ],
        },
        target = name + "/test_lib",
    )

def _test_java_library_should_set_bootclasspath_impl(env, target):
    javac_action = javac_action_subject.of(env, target, "{package}/lib{name}.jar")

    javac_action.bootclasspath().contains_exactly([
        "{bin_path}/{package}/test_java_library_should_set_bootclasspath/boot.jar",
    ])

def _test_java_library_command_line_contains_target_label_and_rule_kind(name):
    util.helper_target(
        java_library,
        name = name + "/test_lib",
        srcs = ["A.java"],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_command_line_contains_target_label_and_rule_kind_impl,
        target = name + "/test_lib",
    )

def _test_java_library_command_line_contains_target_label_and_rule_kind_impl(env, target):
    javac_action = javac_action_subject.of(env, target, "{package}/lib{name}.jar")
    javac_action.target_label().contains_exactly(["//{package}:{name}"])

def _test_java_library_propagates_native_libraries(name):
    util.helper_target(
        cc_library,
        name = name + "/native_deps1.so",
        srcs = ["a.cc"],
    )
    util.helper_target(
        java_library,
        name = name + "/lib_deps",
        srcs = ["B.java"],
        deps = [name + "/native_deps1.so"],
    )
    util.helper_target(
        cc_library,
        name = name + "/native_deps2.so",
        srcs = ["b.cc"],
    )
    util.helper_target(
        cc_library,
        name = name + "/native_rdeps1.so",
        srcs = ["c.cc"],
    )
    util.helper_target(
        java_library,
        name = name + "/lib_runtime_deps",
        srcs = ["C.java"],
        deps = [name + "/native_rdeps1.so"],
    )
    util.helper_target(
        cc_library,
        name = name + "/native_rdeps2.so",
        srcs = ["d.cc"],
    )
    util.helper_target(
        cc_library,
        name = name + "/native_exports1.so",
        srcs = ["e.cc"],
    )
    util.helper_target(
        java_library,
        name = name + "/lib_exports",
        srcs = ["D.java"],
        deps = [name + "/native_exports1.so"],
    )
    util.helper_target(
        cc_library,
        name = name + "/native_exports2.so",
        srcs = ["f.cc"],
    )
    util.helper_target(
        cc_library,
        name = name + "/native_data1.so",
        srcs = ["g.cc"],
    )
    util.helper_target(
        java_library,
        name = name + "/lib_data",
        srcs = ["E.java"],
        deps = [name + "/native_data1.so"],
    )
    util.helper_target(
        cc_library,
        name = name + "/native_data2.so",
        srcs = ["h.cc"],
    )
    util.helper_target(
        java_library,
        name = name + "/top",
        srcs = ["A.java"],
        data = [
            name + "/lib_data",
            name + "/native_data2.so",
        ],
        exports = [
            name + "/lib_exports",
            name + "/native_exports2.so",
        ],
        runtime_deps = [
            name + "/lib_runtime_deps",
            name + "/native_rdeps2.so",
        ],
        deps = [
            name + "/lib_deps",
            name + "/native_deps2.so",
        ],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_propagates_native_libraries_impl,
        target = name + "/top",
    )

def _test_java_library_propagates_native_libraries_impl(env, target):
    java_info_subject.from_target(env, target).transitive_native_libraries().static_libraries().contains_exactly_predicates([
        # Windows platforms use .lib extension for static libraries.
        matching.is_in(["libnative_rdeps2.so.a", "native_rdeps2.so.lib"]),
        matching.is_in(["libnative_exports2.so.a", "native_exports2.so.lib"]),
        matching.is_in(["libnative_deps2.so.a", "native_deps2.so.lib"]),
        matching.is_in(["libnative_rdeps1.so.a", "native_rdeps1.so.lib"]),
        matching.is_in(["libnative_exports1.so.a", "native_exports1.so.lib"]),
        matching.is_in(["libnative_deps1.so.a", "native_deps1.so.lib"]),
    ])

def _test_java_library_gen_source_no_processor_names(name):
    util.helper_target(
        java_plugin,
        name = name + "/plugin",
        srcs = ["AnnotationProcessor.java"],
    )
    util.helper_target(
        java_library,
        name = name + "/to_be_processed",
        srcs = ["ToBeProcessed.java"],
        plugins = [name + "/plugin"],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_gen_source_no_processor_names_impl,
        target = name + "/to_be_processed",
    )

def _test_java_library_gen_source_no_processor_names_impl(env, target):
    javac_action = javac_action_subject.of(env, target, "{package}/lib{name}.jar")

    # The compile action should not have a gensrc jar output even though it has a plugin,
    # since the plugin doesn't define a processor.
    javac_action.outputs().contains_exactly([
        "{package}/lib{name}.jar",
        "{package}/lib{name}.jdeps",
        "{package}/lib{name}-native-header.jar",
        "{package}/lib{name}.jar_manifest_proto",
    ])

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
    _test_java_library_propagates_native_libraries,
    _test_java_library_gen_source_no_processor_names,
    _test_java_library_annotation_processing_using_javacopt,
    _test_java_library_javacopts_with_location_expansion,
    _test_java_library_invalid_plugin,
    _test_java_library_plugin_with_runtime_deps,
    _test_java_library_source_jar_without_annotation_processing,
    _test_java_library_source_jars_with_source_jars,
    _test_java_library_should_set_bootclasspath,
    _test_java_library_command_line_contains_target_label_and_rule_kind,
]
