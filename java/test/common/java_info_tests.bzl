"""Tests for the JavaInfo provider"""

load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_library.bzl", "java_library")
load("//java:java_plugin.bzl", "java_plugin")
load("//java/test/testutil:java_info_subject.bzl", "java_info_subject")
load("//java/test/testutil:rules/custom_java_info_rule.bzl", "custom_java_info_rule")

def _with_output_jar_only_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        output_jar = target_name + "/my_starlark_rule_lib.jar",
        source_jars = ["my_starlark_rule_src.jar"],
    )

    analysis_test(
        name = name,
        impl = _with_output_jar_only_test_impl,
        target = target_name,
    )

def _with_output_jar_only_test_impl(env, target):
    assert_compilation_args = java_info_subject.from_target(env, target).compilation_args()

    assert_compilation_args.compile_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib.jar"])
    assert_compilation_args.full_compile_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib.jar"])
    assert_compilation_args.transitive_runtime_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib.jar"])
    assert_compilation_args.transitive_compile_time_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib.jar"])

def _with_output_jar_and_use_ijar_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        output_jar = target_name + "/my_starlark_rule_lib.jar",
        source_jars = ["my_starlark_rule_src.jar"],
        use_ijar = True,
    )

    analysis_test(
        name = name,
        impl = _with_output_jar_and_use_ijar_test_impl,
        target = target_name,
    )

def _with_output_jar_and_use_ijar_test_impl(env, target):
    assert_compilation_args = java_info_subject.from_target(env, target).compilation_args()

    assert_compilation_args.compile_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib-ijar.jar"])
    assert_compilation_args.full_compile_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib.jar"])
    assert_compilation_args.transitive_runtime_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib.jar"])
    assert_compilation_args.transitive_compile_time_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib-ijar.jar"])

def _with_output_jar_and_use_ijar_outputs_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        output_jar = target_name + "/my_starlark_rule_lib.jar",
        source_jars = ["my_starlark_rule_src.jar"],
        use_ijar = True,
    )

    analysis_test(
        name = name,
        impl = _with_output_jar_and_use_ijar_outputs_test_impl,
        target = target_name,
    )

def _with_output_jar_and_use_ijar_outputs_test_impl(env, target):
    assert_outputs = java_info_subject.from_target(env, target).outputs()

    assert_outputs.source_output_jars().contains_exactly(["{package}/my_starlark_rule_src.jar"])
    assert_outputs.class_output_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib.jar"])
    assert_outputs.jars().singleton().compile_jar().short_path_equals("{package}/{name}/my_starlark_rule_lib-ijar.jar")

def _with_deps_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_direct",
        srcs = ["java/A.java"],
    )
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        dep = [target_name + "/my_java_lib_direct"],
        output_jar = target_name + "/my_starlark_rule_lib.jar",
        source_jars = ["my_starlark_rule_src.jar"],
    )

    analysis_test(
        name = name,
        impl = _with_deps_test_impl,
        target = target_name,
    )

def _with_deps_test_impl(env, target):
    assert_compilation_args = java_info_subject.from_target(env, target).compilation_args()

    assert_compilation_args.compile_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib.jar"])
    assert_compilation_args.full_compile_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib.jar"])
    assert_compilation_args.transitive_runtime_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib.jar",
        "{package}/lib{name}/my_java_lib_direct.jar",
    ])
    assert_compilation_args.transitive_compile_time_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib.jar",
        "{package}/lib{name}/my_java_lib_direct-hjar.jar",
    ])

def _with_runtime_deps_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_direct",
        srcs = ["java/A.java"],
    )
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        dep_runtime = [target_name + "/my_java_lib_direct"],
        output_jar = target_name + "/my_starlark_rule_lib.jar",
        source_jars = ["my_starlark_rule_src.jar"],
    )

    analysis_test(
        name = name,
        impl = _with_runtime_deps_test_impl,
        target = target_name,
    )

def _with_runtime_deps_test_impl(env, target):
    assert_compilation_args = java_info_subject.from_target(env, target).compilation_args()

    assert_compilation_args.compile_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib.jar"])
    assert_compilation_args.full_compile_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib.jar"])
    assert_compilation_args.transitive_runtime_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib.jar",
        "{package}/lib{name}/my_java_lib_direct.jar",
    ])
    assert_compilation_args.transitive_compile_time_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib.jar"])

def _with_native_libraries_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        cc_library,
        name = target_name + "/my_cc_lib_direct",
        srcs = ["cc/a.cc"],
    )
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        cc_dep = [target_name + "/my_cc_lib_direct"],
        output_jar = target_name + "/my_starlark_rule_lib.jar",
        source_jars = ["my_starlark_rule_src.jar"],
    )

    analysis_test(
        name = name,
        impl = _with_native_libraries_test_impl,
        target = target_name,
        # LibraryToLink.library_indentifier only available from Bazel 8
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _with_native_libraries_test_impl(env, target):
    assert_native_libs = java_info_subject.from_target(env, target).transitive_native_libraries()

    assert_native_libs.identifiers().contains_exactly_predicates([matching.str_endswith("my_cc_lib_direct")])

def _with_deps_and_neverlink_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_direct",
        srcs = ["java/A.java"],
    )
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        dep = [target_name + "/my_java_lib_direct"],
        output_jar = target_name + "/my_starlark_rule_lib.jar",
        source_jars = ["my_starlark_rule_src.jar"],
        neverlink = True,
    )

    analysis_test(
        name = name,
        impl = _with_deps_and_neverlink_test_impl,
        target = target_name,
    )

def _with_deps_and_neverlink_test_impl(env, target):
    assert_compilation_args = java_info_subject.from_target(env, target).compilation_args()

    assert_compilation_args.compile_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib.jar"])
    assert_compilation_args.full_compile_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib.jar"])
    assert_compilation_args.transitive_runtime_jars().contains_exactly([])
    assert_compilation_args.transitive_compile_time_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib.jar",
        "{package}/lib{name}/my_java_lib_direct-hjar.jar",
    ])

def _with_source_jars_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        output_jar = target_name + "/my_starlark_rule_lib.jar",
        source_jars = ["my_starlark_rule_src.jar"],
    )

    analysis_test(
        name = name,
        impl = _with_source_jars_test_impl,
        target = target_name,
    )

def _with_source_jars_test_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.source_jars().contains_exactly_predicates([
        matching.file_basename_equals("my_starlark_rule_src.jar"),
    ])
    assert_java_info.transitive_source_jars().contains_exactly([
        "{package}/my_starlark_rule_src.jar",
    ])

def _with_packed_sourcejars_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        output_jar = target_name + "/my_starlark_rule_lib.jar",
        source_jars = ["my_starlark_rule_src.jar"],
        pack_sources = True,
    )

    analysis_test(
        name = name,
        impl = _with_packed_sourcejars_test_impl,
        target = target_name,
    )

def _with_packed_sourcejars_test_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.source_jars().contains_exactly_predicates([
        matching.file_basename_equals("my_starlark_rule_lib-src.jar"),
    ])
    assert_java_info.transitive_source_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib-src.jar",
    ])

def _with_packed_sources_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        output_jar = target_name + "/my_starlark_rule_lib.jar",
        sources = ["ClassA.java", "ClassB.java", "ClassC.java", "ClassD.java"],
        pack_sources = True,
    )

    analysis_test(
        name = name,
        impl = _with_packed_sources_test_impl,
        target = target_name,
    )

def _with_packed_sources_test_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.outputs().source_output_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib-src.jar",
    ])
    assert_java_info.source_jars().contains_exactly_predicates([
        matching.file_basename_equals("my_starlark_rule_lib-src.jar"),
    ])
    assert_java_info.transitive_source_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib-src.jar",
    ])

def _with_packed_sources_and_source_jars_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        output_jar = target_name + "/my_starlark_rule_lib.jar",
        source_jars = ["my_starlark_rule_src-A.jar"],
        sources = ["ClassA.java", "ClassB.java", "ClassC.java", "ClassD.java"],
        pack_sources = True,
    )

    analysis_test(
        name = name,
        impl = _with_packed_sources_and_source_jars_test_impl,
        target = target_name,
    )

def _with_packed_sources_and_source_jars_test_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.outputs().source_output_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib-src.jar",
    ])
    assert_java_info.source_jars().contains_exactly_predicates([
        matching.file_basename_equals("my_starlark_rule_lib-src.jar"),
    ])
    assert_java_info.transitive_source_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib-src.jar",
    ])

def _with_deps_source_jars_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_direct",
        srcs = ["java/A.java"],
    )
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        dep = [target_name + "/my_java_lib_direct"],
        output_jar = target_name + "/my_starlark_rule_lib.jar",
        source_jars = ["my_starlark_rule_src.jar"],
    )

    analysis_test(
        name = name,
        impl = _with_deps_source_jars_test_impl,
        target = target_name,
    )

def _with_deps_source_jars_test_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.source_jars().contains_exactly_predicates([
        matching.file_basename_equals("my_starlark_rule_src.jar"),
    ])
    assert_java_info.transitive_source_jars().contains_exactly([
        "{package}/my_starlark_rule_src.jar",
        "{package}/lib{name}/my_java_lib_direct-src.jar",
    ])

def _with_runtime_deps_source_jars_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_direct",
        srcs = ["java/A.java"],
    )
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        dep_runtime = [target_name + "/my_java_lib_direct"],
        output_jar = target_name + "/my_starlark_rule_lib.jar",
        source_jars = ["my_starlark_rule_src.jar"],
    )

    analysis_test(
        name = name,
        impl = _with_runtime_deps_source_jars_test_impl,
        target = target_name,
    )

def _with_runtime_deps_source_jars_test_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.source_jars().contains_exactly_predicates([
        matching.file_basename_equals("my_starlark_rule_src.jar"),
    ])
    assert_java_info.transitive_source_jars().contains_exactly([
        "{package}/my_starlark_rule_src.jar",
        "{package}/lib{name}/my_java_lib_direct-src.jar",
    ])

def _with_transitive_deps_source_jars_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_transitive",
        srcs = ["java/B.java"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_direct",
        srcs = ["java/A.java"],
        deps = [target_name + "/my_java_lib_transitive"],
    )
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        dep_runtime = [target_name + "/my_java_lib_direct"],
        output_jar = target_name + "/my_starlark_rule_lib.jar",
        source_jars = ["my_starlark_rule_src.jar"],
    )

    analysis_test(
        name = name,
        impl = _with_transitive_deps_source_jars_test_impl,
        target = target_name,
    )

def _with_transitive_deps_source_jars_test_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.source_jars().contains_exactly_predicates([
        matching.file_basename_equals("my_starlark_rule_src.jar"),
    ])
    assert_java_info.transitive_source_jars().contains_exactly([
        "{package}/my_starlark_rule_src.jar",
        "{package}/lib{name}/my_java_lib_direct-src.jar",
        "{package}/lib{name}/my_java_lib_transitive-src.jar",
    ])

def _with_transitive_runtime_deps_source_jars_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_transitive",
        srcs = ["java/B.java"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_direct",
        srcs = ["java/A.java"],
        runtime_deps = [target_name + "/my_java_lib_transitive"],
    )
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        dep_runtime = [target_name + "/my_java_lib_direct"],
        output_jar = target_name + "/my_starlark_rule_lib.jar",
        source_jars = ["my_starlark_rule_src.jar"],
    )

    analysis_test(
        name = name,
        impl = _with_transitive_runtime_deps_source_jars_test_impl,
        target = target_name,
    )

def _with_transitive_runtime_deps_source_jars_test_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.source_jars().contains_exactly_predicates([
        matching.file_basename_equals("my_starlark_rule_src.jar"),
    ])
    assert_java_info.transitive_source_jars().contains_exactly([
        "{package}/my_starlark_rule_src.jar",
        "{package}/lib{name}/my_java_lib_direct-src.jar",
        "{package}/lib{name}/my_java_lib_transitive-src.jar",
    ])

def _with_exports_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_exports",
        srcs = ["java/A.java"],
    )
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        dep_exports = [target_name + "/my_java_lib_exports"],
        output_jar = target_name + "/my_starlark_rule_lib.jar",
    )

    analysis_test(
        name = name,
        impl = _with_exports_test_impl,
        target = target_name,
    )

def _with_exports_test_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.source_jars().contains_exactly([])

    assert_compilation_args = assert_java_info.compilation_args()
    assert_compilation_args.compile_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib.jar",
        "{package}/lib{name}/my_java_lib_exports-hjar.jar",
    ])
    assert_compilation_args.full_compile_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib.jar",
        "{package}/lib{name}/my_java_lib_exports.jar",
    ])
    assert_compilation_args.transitive_runtime_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib.jar",
        "{package}/lib{name}/my_java_lib_exports.jar",
    ])
    assert_compilation_args.transitive_compile_time_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib.jar",
        "{package}/lib{name}/my_java_lib_exports-hjar.jar",
    ])

def _with_transitive_exports_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_c",
        srcs = ["java/C.java"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_b",
        srcs = ["java/B.java"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_a",
        srcs = ["java/A.java"],
        exports = [target_name + "/my_java_lib_b"],
        deps = [
            target_name + "/my_java_lib_b",
            target_name + "/my_java_lib_c",
        ],
    )
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        dep_exports = [target_name + "/my_java_lib_a"],
        output_jar = target_name + "/my_starlark_rule_lib.jar",
    )

    analysis_test(
        name = name,
        impl = _with_transitive_exports_test_impl,
        target = target_name,
    )

def _with_transitive_exports_test_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_compilation_args = assert_java_info.compilation_args()
    assert_compilation_args.compile_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib.jar",
        "{package}/lib{name}/my_java_lib_a-hjar.jar",
        "{package}/lib{name}/my_java_lib_b-hjar.jar",
    ])
    assert_compilation_args.full_compile_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib.jar",
        "{package}/lib{name}/my_java_lib_a.jar",
        "{package}/lib{name}/my_java_lib_b.jar",
    ])
    assert_compilation_args.transitive_runtime_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib.jar",
        "{package}/lib{name}/my_java_lib_a.jar",
        "{package}/lib{name}/my_java_lib_b.jar",
        "{package}/lib{name}/my_java_lib_c.jar",
    ])
    assert_compilation_args.transitive_compile_time_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib.jar",
        "{package}/lib{name}/my_java_lib_a-hjar.jar",
        "{package}/lib{name}/my_java_lib_b-hjar.jar",
        "{package}/lib{name}/my_java_lib_c-hjar.jar",
    ])

def _with_transitive_deps_and_exports_test(name):
    # Tests case: my_lib
    #               / \
    #              a   c
    #             ||   ||
    #             b    d
    # where single line is normal dependency and double is exports dependency.
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_b",
        srcs = ["java/B.java"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_a",
        srcs = ["java/A.java"],
        exports = [target_name + "/my_java_lib_b"],
        deps = [target_name + "/my_java_lib_b"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_d",
        srcs = ["java/D.java"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_c",
        srcs = ["java/C.java"],
        exports = [target_name + "/my_java_lib_d"],
        deps = [target_name + "/my_java_lib_d"],
    )
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        dep = [
            target_name + "/my_java_lib_a",
            target_name + "/my_java_lib_c",
        ],
        dep_exports = [target_name + "/my_java_lib_a"],
        output_jar = target_name + "/my_starlark_rule_lib.jar",
    )

    analysis_test(
        name = name,
        impl = _with_transitive_deps_and_exports_test_impl,
        target = target_name,
    )

def _with_transitive_deps_and_exports_test_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_compilation_args = assert_java_info.compilation_args()
    assert_compilation_args.compile_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib.jar",
        "{package}/lib{name}/my_java_lib_a-hjar.jar",
        "{package}/lib{name}/my_java_lib_b-hjar.jar",
    ])
    assert_compilation_args.full_compile_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib.jar",
        "{package}/lib{name}/my_java_lib_a.jar",
        "{package}/lib{name}/my_java_lib_b.jar",
    ])
    assert_compilation_args.transitive_runtime_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib.jar",
        "{package}/lib{name}/my_java_lib_a.jar",
        "{package}/lib{name}/my_java_lib_b.jar",
        "{package}/lib{name}/my_java_lib_c.jar",
        "{package}/lib{name}/my_java_lib_d.jar",
    ])
    assert_compilation_args.transitive_compile_time_jars().contains_exactly([
        "{package}/{name}/my_starlark_rule_lib.jar",
        "{package}/lib{name}/my_java_lib_a-hjar.jar",
        "{package}/lib{name}/my_java_lib_b-hjar.jar",
        "{package}/lib{name}/my_java_lib_c-hjar.jar",
        "{package}/lib{name}/my_java_lib_d-hjar.jar",
    ])

def _with_plugins_via_exports_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        java_library,
        name = target_name + "/plugin_dep",
        srcs = ["ProcessorDep.java"],
    )
    util.helper_target(
        java_plugin,
        name = target_name + "/plugin",
        srcs = ["AnnotationProcessor.java"],
        processor_class = "com.google.process.stuff",
        deps = [target_name + "/plugin_dep"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/export",
        exported_plugins = [target_name + "/plugin"],
    )
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        dep_exports = [target_name + "/export"],
        output_jar = target_name + "/my_starlark_rule_lib.jar",
    )

    analysis_test(
        name = name,
        impl = _with_plugins_via_exports_test_impl,
        target = target_name,
    )

def _with_plugins_via_exports_test_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.plugins().processor_classes().contains_exactly(["com.google.process.stuff"])

def _with_plugins_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        java_library,
        name = target_name + "/plugin_dep",
        srcs = ["ProcessorDep.java"],
    )
    util.helper_target(
        java_plugin,
        name = target_name + "/plugin",
        srcs = ["AnnotationProcessor.java"],
        processor_class = "com.google.process.stuff",
        deps = [target_name + "/plugin_dep"],
    )
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        dep_exported_plugins = [target_name + "/plugin"],
        output_jar = target_name + "/my_starlark_rule_lib.jar",
    )

    analysis_test(
        name = name,
        impl = _with_plugins_test_impl,
        target = target_name,
    )

def _with_plugins_test_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.plugins().processor_classes().contains_exactly(["com.google.process.stuff"])

def _with_stamped_jar_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        output_jar = target_name + "/my_starlark_rule_lib.jar",
        source_jars = ["my_starlark_rule_src.jar"],
        stamp_jar = True,
    )

    analysis_test(
        name = name,
        impl = _with_stamped_jar_test_impl,
        target = target_name,
    )

def _with_stamped_jar_test_impl(env, target):
    assert_compilation_args = java_info_subject.from_target(env, target).compilation_args()

    assert_compilation_args.full_compile_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib.jar"])
    assert_compilation_args.compile_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib-stamped.jar"])
    assert_compilation_args.transitive_runtime_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib.jar"])
    assert_compilation_args.transitive_compile_time_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib-stamped.jar"])

def _with_jdeps_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        jdeps = "my_jdeps.pb",
        output_jar = target_name + "/my_starlark_rule_lib.jar",
        source_jars = ["my_starlark_rule_src.jar"],
    )

    analysis_test(
        name = name,
        impl = _with_jdeps_test_impl,
        target = target_name,
    )

def _with_jdeps_test_impl(env, target):
    assert_outputs = java_info_subject.from_target(env, target).outputs()

    assert_outputs.class_output_jars().contains_exactly(["{package}/{name}/my_starlark_rule_lib.jar"])
    assert_outputs.source_output_jars().contains_exactly(["{package}/my_starlark_rule_src.jar"])
    assert_outputs.jdeps().contains_exactly(["{package}/my_jdeps.pb"])

def _with_generated_jars_outputs_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        generated_class_jar = "generated_class.jar",
        generated_source_jar = "generated_srcs.jar",
        output_jar = target_name + "/my_starlark_rule_lib.jar",
    )

    analysis_test(
        name = name,
        impl = _with_generated_jars_outputs_test_impl,
        target = target_name,
    )

def _with_generated_jars_outputs_test_impl(env, target):
    assert_outputs = java_info_subject.from_target(env, target).outputs()

    assert_outputs.generated_class_jars().contains_exactly(["{package}/generated_class.jar"])
    assert_outputs.generated_source_jars().contains_exactly(["{package}/generated_srcs.jar"])

def java_info_tests(name):
    test_suite(
        name = name,
        tests = [
            _with_output_jar_only_test,
            _with_output_jar_and_use_ijar_test,
            _with_output_jar_and_use_ijar_outputs_test,
            _with_deps_test,
            _with_runtime_deps_test,
            _with_native_libraries_test,
            _with_deps_and_neverlink_test,
            _with_source_jars_test,
            _with_packed_sourcejars_test,
            _with_packed_sources_test,
            _with_packed_sources_and_source_jars_test,
            _with_deps_source_jars_test,
            _with_runtime_deps_source_jars_test,
            _with_transitive_deps_source_jars_test,
            _with_transitive_runtime_deps_source_jars_test,
            _with_exports_test,
            _with_transitive_exports_test,
            _with_transitive_deps_and_exports_test,
            _with_plugins_via_exports_test,
            _with_plugins_test,
            _with_stamped_jar_test,
            _with_jdeps_test,
            _with_generated_jars_outputs_test,
        ],
    )
