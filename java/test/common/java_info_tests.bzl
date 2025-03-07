"""Tests for the JavaInfo provider"""

load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_library.bzl", "java_library")
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
        ],
    )
