"""Tests for the JavaInfo provider"""

load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_library.bzl", "java_library")
load("//java:java_plugin.bzl", "java_plugin")
load("//java/common:java_info.bzl", "JavaInfo")
load("//test/java/testutil:java_info_subject.bzl", "java_info_subject")
load("//test/java/testutil:rules/bad_java_info_rules.bzl", "bad_deps", "bad_exports", "bad_libs", "bad_runtime_deps", "compile_jar_not_set", "compile_jar_set_to_none")
load("//test/java/testutil:rules/custom_java_info_rule.bzl", "custom_java_info_rule")
load("//test/java/testutil:rules/custom_library.bzl", "custom_library")
load("//test/java/testutil:rules/forward_java_info.bzl", "java_info_forwarding_rule")
load("//test/java/testutil:rules/java_info_merge.bzl", "java_info_merge_rule")

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
    )

def _with_native_libraries_test_impl(env, target):
    assert_native_libs = java_info_subject.from_target(env, target).transitive_native_libraries()

    assert_native_libs.static_libraries().contains_exactly_predicates([matching.str_matches("*my_cc_lib_direct*")])

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

def _with_generated_jars_annotation_processing_test(name):
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
        impl = _with_generated_jars_annotation_processing_test_impl,
        target = target_name,
    )

def _with_generated_jars_annotation_processing_test_impl(env, target):
    assert_annotation_processing = java_info_subject.from_target(env, target).annotation_processing()

    assert_annotation_processing.class_jar().short_path_equals("{package}/generated_class.jar")
    assert_annotation_processing.source_jar().short_path_equals("{package}/generated_srcs.jar")

def _with_compile_jdeps_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        compile_jdeps = "compile.deps",
        output_jar = target_name + "/my_starlark_rule_lib.jar",
    )

    analysis_test(
        name = name,
        impl = _with_compile_jdeps_test_impl,
        target = target_name,
    )

def _with_compile_jdeps_test_impl(env, target):
    java_info_subject.from_target(env, target).outputs().compile_jdeps().contains_exactly([
        "{package}/compile.deps",
    ])

def _with_native_headers_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        native_headers_jar = "native_headers.jar",
        output_jar = target_name + "/my_starlark_rule_lib.jar",
    )

    analysis_test(
        name = name,
        impl = _with_native_headers_test_impl,
        target = target_name,
    )

def _with_native_headers_test_impl(env, target):
    java_info_subject.from_target(env, target).outputs().native_headers().contains_exactly([
        "{package}/native_headers.jar",
    ])

def _with_manifest_proto_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        manifest_proto = "manifest.proto",
        output_jar = target_name + "/my_starlark_rule_lib.jar",
    )

    analysis_test(
        name = name,
        impl = _with_manifest_proto_test_impl,
        target = target_name,
    )

def _with_manifest_proto_test_impl(env, target):
    java_info_subject.from_target(env, target).outputs().manifest_protos().contains_exactly([
        "{package}/manifest.proto",
    ])

def _sequence_parameters_are_type_checked_test(name):
    util.helper_target(bad_deps, name = name + "/bad_deps")
    util.helper_target(bad_runtime_deps, name = name + "/bad_runtime_deps")
    util.helper_target(bad_exports, name = name + "/bad_exports")
    util.helper_target(bad_libs, name = name + "/bad_libs")

    analysis_test(
        name = name,
        impl = _sequence_parameters_are_type_checked_test_impl,
        targets = {
            "deps": name + "/bad_deps",
            "runtime_deps": name + "/bad_runtime_deps",
            "exports": name + "/bad_exports",
            "libs": name + "/bad_libs",
        },
        expect_failure = True,
    )

def _sequence_parameters_are_type_checked_test_impl(env, targets):
    env.expect.that_target(targets.deps).failures().contains_predicate(
        matching.str_matches("at index 0 of deps, got element of type File, want JavaInfo"),
    )
    env.expect.that_target(targets.runtime_deps).failures().contains_predicate(
        matching.str_matches("at index 0 of runtime_deps, got element of type File, want JavaInfo"),
    )
    env.expect.that_target(targets.exports).failures().contains_predicate(
        matching.str_matches("at index 0 of exports, got element of type File, want JavaInfo"),
    )
    env.expect.that_target(targets.libs).failures().contains_predicate(
        matching.str_matches("at index 0 of native_libraries, got element of type File, want CcInfo"),
    )

def _with_compile_jar_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        output_jar = target_name + "/output.jar",
        compile_jar = "compile.jar",
    )

    analysis_test(
        name = name,
        impl = _with_compile_jar_test_impl,
        target = target_name,
    )

def _with_compile_jar_test_impl(env, target):
    env.expect.that_depset_of_files(target[JavaInfo].compile_jars).contains_predicate(
        matching.file_basename_equals("compile.jar"),
    )

def _compile_jar_not_set_test(name):
    util.helper_target(compile_jar_not_set, name = name + "/only_outputjar")

    analysis_test(
        name = name,
        impl = _compile_jar_not_set_test_impl,
        target = name + "/only_outputjar",
        expect_failure = True,
    )

def _compile_jar_not_set_test_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("missing 1 required positional argument: compile_jar"),
    )

def _compile_jar_set_to_none_test(name):
    util.helper_target(compile_jar_set_to_none, name = name + "/compilejar_none")

    analysis_test(
        name = name,
        impl = _compile_jar_set_to_none_test_impl,
        target = name + "/compilejar_none",
    )

def _compile_jar_set_to_none_test_impl(env, target):
    env.expect.that_depset_of_files(target[JavaInfo].compile_jars).contains_exactly([])

def _sources_jars_exposed_test(name):
    util.helper_target(
        java_library,
        name = name + "/my_java_lib_b",
        srcs = ["java/B.java"],
    )
    util.helper_target(
        java_library,
        name = name + "/my_java_lib_a",
        srcs = ["java/A.java"],
        deps = [name + "/my_java_lib_b"],
    )
    analysis_test(
        name = name,
        impl = _sources_jars_exposed_test_impl,
        target = name + "/my_java_lib_a",
    )

def _sources_jars_exposed_test_impl(env, target):
    source_jars = target[JavaInfo].source_jars
    env.expect.that_collection(source_jars).contains_exactly_predicates([
        matching.file_basename_equals("my_java_lib_a-src.jar"),
    ])

def _transitive_source_jars_test(name):
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
        deps = [target_name + "/my_java_lib_c"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_a",
        srcs = ["java/A.java"],
        deps = [target_name + "/my_java_lib_b"],
    )
    util.helper_target(
        java_info_forwarding_rule,
        name = target_name,
        dep = target_name + "/my_java_lib_a",
    )
    analysis_test(
        name = name,
        impl = _transitive_source_jars_test_impl,
        target = target_name,
    )

def _transitive_source_jars_test_impl(env, target):
    assert_transitive_source_jars = java_info_subject.from_target(env, target).transitive_source_jars()
    assert_transitive_source_jars.contains_exactly([
        "{package}/lib{name}/my_java_lib_a-src.jar",
        "{package}/lib{name}/my_java_lib_b-src.jar",
        "{package}/lib{name}/my_java_lib_c-src.jar",
    ])

def _transitive_compile_time_jars_test(name):
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
        deps = [target_name + "/my_java_lib_c"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_a",
        srcs = ["java/A.java"],
        deps = [target_name + "/my_java_lib_b"],
    )
    util.helper_target(
        java_info_forwarding_rule,
        name = target_name,
        dep = target_name + "/my_java_lib_a",
    )
    analysis_test(
        name = name,
        impl = transitive_compile_time_jars_impl,
        target = target_name,
    )

def transitive_compile_time_jars_impl(env, target):
    assert_transitive_compile_time_jars = java_info_subject.from_target(env, target).compilation_args().transitive_compile_time_jars()
    assert_transitive_compile_time_jars.contains_exactly([
        "{package}/lib{name}/my_java_lib_a-hjar.jar",
        "{package}/lib{name}/my_java_lib_b-hjar.jar",
        "{package}/lib{name}/my_java_lib_c-hjar.jar",
    ])

def _transitive_runtime_jars_test(name):
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
        deps = [target_name + "/my_java_lib_c"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_a",
        srcs = ["java/A.java"],
        deps = [target_name + "/my_java_lib_b"],
    )
    util.helper_target(
        java_info_forwarding_rule,
        name = target_name,
        dep = target_name + "/my_java_lib_a",
    )
    analysis_test(
        name = name,
        impl = transitive_runtime_jars_impl,
        target = target_name,
    )

def transitive_runtime_jars_impl(env, target):
    assert_transitive_runtime_jars = java_info_subject.from_target(env, target).compilation_args().transitive_runtime_jars()
    assert_transitive_runtime_jars.contains_exactly([
        "{package}/lib{name}/my_java_lib_a.jar",
        "{package}/lib{name}/my_java_lib_b.jar",
        "{package}/lib{name}/my_java_lib_c.jar",
    ])

def _transitive_native_libraries_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        cc_library,
        name = target_name + "/my_cc_lib_c.so",
        srcs = ["cc/c.cc"],
    )
    util.helper_target(
        cc_library,
        name = target_name + "/my_cc_lib_b.so",
        srcs = ["cc/b.cc"],
    )
    util.helper_target(
        cc_library,
        name = target_name + "/my_cc_lib_a.so",
        srcs = ["cc/a.cc"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_c",
        srcs = ["java/C.java"],
        deps = [target_name + "/my_cc_lib_c.so"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_b",
        srcs = ["java/B.java"],
        deps = [target_name + "/my_cc_lib_b.so"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/my_java_lib_a",
        srcs = ["java/A.java"],
        deps = [
            target_name + "/my_cc_lib_a.so",
            target_name + "/my_java_lib_b",
            target_name + "/my_java_lib_c",
        ],
    )
    util.helper_target(
        java_info_forwarding_rule,
        name = target_name,
        dep = target_name + "/my_java_lib_a",
    )
    analysis_test(
        name = name,
        impl = _transitive_native_libraries_test_impl,
        target = target_name,
        # LibraryToLink.library_indentifier only available from Bazel 8
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _transitive_native_libraries_test_impl(env, target):
    assert_transitive_native_libraries = java_info_subject.from_target(env, target).transitive_native_libraries()
    assert_transitive_native_libraries.static_libraries().contains_exactly_predicates([
        matching.str_matches("*my_cc_lib_a.so*"),
        matching.str_matches("*my_cc_lib_b.so*"),
        matching.str_matches("*my_cc_lib_c.so*"),
    ])

def _native_libraries_propagation_test(name):
    target_name = name + "/custom"
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        sources = ["A.java"],
        dep_exports = [target_name + "/lib_exports"],
        dep_runtime = [target_name + "/lib_runtime_deps"],
        dep = [target_name + "/lib_deps"],
        output_jar = target_name + ".out",
    )
    util.helper_target(
        java_library,
        name = target_name + "/lib_deps",
        srcs = ["B.java"],
        deps = [target_name + "/native_deps1.so"],
    )
    util.helper_target(
        cc_library,
        name = target_name + "/native_deps1.so",
        srcs = ["a.cc"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/lib_runtime_deps",
        srcs = ["C.java"],
        deps = [target_name + "/native_rdeps1.so"],
    )
    util.helper_target(
        cc_library,
        name = target_name + "/native_rdeps1.so",
        srcs = ["c.cc"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/lib_exports",
        srcs = ["D.java"],
        deps = [target_name + "/native_exports1.so"],
    )
    util.helper_target(
        cc_library,
        name = target_name + "/native_exports1.so",
        srcs = ["e.cc"],
    )

    analysis_test(
        name = name,
        impl = _native_libraries_propagation_test_impl,
        target = target_name,
        # LibraryToLink.library_identifier only available from Bazel 8
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _native_libraries_propagation_test_impl(env, target):
    assert_transitive_native_libraries = java_info_subject.from_target(env, target).transitive_native_libraries()
    assert_transitive_native_libraries.static_libraries().contains_exactly_predicates([
        matching.str_matches("*native_rdeps1.so*"),
        matching.str_matches("*native_exports1.so*"),
        matching.str_matches("*native_deps1.so*"),
    ]).in_order()

def _annotation_processing_test(name):
    target_name = name + "/my_java_lib_a"
    util.helper_target(
        java_library,
        name = target_name,
        srcs = ["java/A.java"],
        javacopts = ["-processor com.google.process.Processor"],
    )

    analysis_test(
        name = name,
        impl = _annotation_processing_test_impl,
        target = target_name,
    )

def _annotation_processing_test_impl(env, target):
    assert_info = java_info_subject.from_target(env, target).annotation_processing()

    assert_info.class_jar().short_path_equals("{package}/lib{name}-gen.jar")
    assert_info.source_jar().short_path_equals("{package}/lib{name}-gensrc.jar")

def _compilation_info_test(name):
    target_name = name + "/my_java_lib_a"
    util.helper_target(
        java_library,
        name = target_name,
        srcs = ["java/A.java"],
        javacopts = ["opt1", "opt2"],
    )
    analysis_test(
        name = name,
        impl = _compilation_info_test_impl,
        target = target_name,
    )

def _compilation_info_test_impl(env, target):
    assert_info = java_info_subject.from_target(env, target).compilation_info()

    assert_info.runtime_classpath().contains_exactly(["{package}/lib{name}.jar"])
    assert_info.javac_options().contains_at_least(["opt1", "opt2"]).in_order()

def _output_source_jars_returns_depset_test(name):
    target_name = name + "/lib"
    util.helper_target(
        java_library,
        name = target_name,
    )

    analysis_test(
        name = name,
        impl = _output_source_jars_returns_depset_test_impl,
        target = target_name,
    )

def _output_source_jars_returns_depset_test_impl(env, target):
    source_jars = target[JavaInfo].java_outputs[0].source_jars
    env.expect.that_str(type(source_jars)).equals(type(depset()))

def _java_info_constructor_with_neverlink_test(name):
    target_name = name + "/my_starlark_rule"
    util.helper_target(
        custom_java_info_rule,
        name = target_name,
        output_jar = target_name + "/my_starlark_rule_lib.jar",
        neverlink = True,
    )

    analysis_test(
        name = name,
        impl = _java_info_constructor_with_neverlink_test_impl,
        target = target_name,
    )

def _java_info_constructor_with_neverlink_test_impl(env, target):
    java_info_subject.from_target(env, target).is_neverlink().equals(True)

def _java_common_merge_with_neverlink_test(name):
    target_name = name + "/merged"
    util.helper_target(
        custom_java_info_rule,
        name = target_name + "/with_neverlink",
        output_jar = target_name + "/with_neverlink.jar",
        neverlink = True,
    )
    util.helper_target(
        custom_java_info_rule,
        name = target_name + "/without_neverlink",
        output_jar = target_name + "/without_neverlink.jar",
        neverlink = False,
    )
    util.helper_target(
        java_info_merge_rule,
        name = target_name,
        deps = [target_name + "/with_neverlink", target_name + "/without_neverlink"],
    )

    analysis_test(
        name = name,
        impl = _java_common_merge_with_neverlink_test_impl,
        target = target_name,
    )

def _java_common_merge_with_neverlink_test_impl(env, target):
    java_info_subject.from_target(env, target).is_neverlink().equals(True)

def _java_common_compile_with_neverlink_test(name):
    target_name = name + "/compiled"
    util.helper_target(
        custom_library,
        name = target_name,
        srcs = ["A.java"],
        neverlink = True,
    )

    analysis_test(
        name = name,
        impl = _java_common_compile_with_neverlink_test_impl,
        target = target_name,
    )

def _java_common_compile_with_neverlink_test_impl(env, target):
    java_info_subject.from_target(env, target).is_neverlink().equals(True)

# Tests that java_common.compile propagates native libraries from deps,
# runtime_deps, and exports.
def _java_common_compile_native_libraries_propagate_test(name):
    target_name = name + "/compiled"

    util.helper_target(
        cc_library,
        name = target_name + "/native_dep",
        srcs = ["a.cc"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/lib_dep",
        srcs = ["B.java"],
        deps = [target_name + "/native_dep"],
    )

    util.helper_target(
        cc_library,
        name = target_name + "/native_rdep",
        srcs = ["c.cc"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/lib_rdep",
        srcs = ["D.java"],
        deps = [target_name + "/native_rdep"],
    )

    util.helper_target(
        cc_library,
        name = target_name + "/native_export",
        srcs = ["e.cc"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/lib_export",
        srcs = ["F.java"],
        deps = [target_name + "/native_export"],
    )

    util.helper_target(
        custom_library,
        name = target_name,
        srcs = ["G.java"],
        deps = [target_name + "/lib_dep"],
        runtime_deps = [target_name + "/lib_rdep"],
        exports = [target_name + "/lib_export"],
    )

    analysis_test(
        name = name,
        impl = _java_common_compile_native_libraries_propagate_test_impl,
        target = target_name,
    )

def _java_common_compile_native_libraries_propagate_test_impl(env, target):
    assert_native_libs = java_info_subject.from_target(env, target).transitive_native_libraries()
    assert_native_libs.static_libraries().contains_exactly_predicates([
        matching.str_matches("*native_rdep*"),
        matching.str_matches("*native_export*"),
        matching.str_matches("*native_dep*"),
    ])

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
            _with_generated_jars_annotation_processing_test,
            _with_compile_jdeps_test,
            _with_native_headers_test,
            _with_manifest_proto_test,
            _with_compile_jar_test,
            _sequence_parameters_are_type_checked_test,
            _compile_jar_not_set_test,
            _compile_jar_set_to_none_test,
            _sources_jars_exposed_test,
            _transitive_source_jars_test,
            _transitive_compile_time_jars_test,
            _transitive_runtime_jars_test,
            _transitive_native_libraries_test,
            _native_libraries_propagation_test,
            _annotation_processing_test,
            _compilation_info_test,
            _output_source_jars_returns_depset_test,
            _java_info_constructor_with_neverlink_test,
            _java_common_merge_with_neverlink_test,
            _java_common_compile_with_neverlink_test,
            _java_common_compile_native_libraries_propagate_test,
        ],
    )
