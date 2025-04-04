"""Tests for the java_library rule"""

load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_library.bzl", "java_library")
load("//java:java_plugin.bzl", "java_plugin")
load("//java/common:java_info.bzl", "JavaInfo")
load("//java/test/testutil:java_info_subject.bzl", "java_info_subject")
load("//test/java/testutil:rules/custom_java_info_rule.bzl", "custom_java_info_rule")
load("//test/java/testutil:rules/forward_java_info.bzl", "java_info_forwarding_rule")
load("//test/java/testutil:rules/wrap_java_info.bzl", "JavaInfoWrappingInfo", "java_info_wrapping_rule")

def _test_exposes_plugins(name):
    target_name = name + "/library"
    util.helper_target(
        java_library,
        name = target_name + "/plugin_dep1",
        srcs = ["A.java"],
        data = ["depfile1.dat"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/plugin_dep2",
        srcs = ["B.java"],
        data = ["depfile2.dat"],
    )
    util.helper_target(
        java_plugin,
        name = target_name + "/plugin",
        srcs = ["AnnotationProcessor1.java"],
        data = ["pluginfile1.dat"],
        processor_class = "com.google.process.stuff",
        deps = [target_name + "/plugin_dep1"],
    )
    util.helper_target(
        java_plugin,
        name = target_name + "/apiplugin",
        srcs = ["AnnotationProcessor2.java"],
        data = ["pluginfile2.dat"],
        generates_api = True,
        processor_class = "com.google.process.apistuff",
        deps = [target_name + "/plugin_dep2"],
    )
    util.helper_target(
        java_library,
        name = target_name,
        exported_plugins = [
            target_name + "/plugin",
            target_name + "/apiplugin",
        ],
    )

    analysis_test(
        name = name,
        impl = _test_exposes_plugins_impl,
        target = target_name,
    )

def _test_exposes_plugins_impl(env, target):
    assert_plugin_data = java_info_subject.from_target(env, target).plugins()
    assert_plugin_data.processor_classes().contains_exactly([
        "com.google.process.stuff",
        "com.google.process.apistuff",
    ])
    assert_plugin_data.processor_jars().contains_exactly([
        "{package}/lib{name}/plugin.jar",
        "{package}/lib{name}/plugin_dep1.jar",
        "{package}/lib{name}/apiplugin.jar",
        "{package}/lib{name}/plugin_dep2.jar",
    ])
    assert_plugin_data.processor_data().contains_exactly([
        "{package}/pluginfile1.dat",
        "{package}/pluginfile2.dat",
    ])

    assert_api_plugin_data = java_info_subject.from_target(env, target).api_generating_plugins()
    assert_api_plugin_data.processor_classes().contains_exactly(["com.google.process.apistuff"])
    assert_api_plugin_data.processor_jars().contains_exactly([
        "{package}/lib{name}/apiplugin.jar",
        "{package}/lib{name}/plugin_dep2.jar",
    ])
    assert_api_plugin_data.processor_data().contains_exactly(["{package}/pluginfile2.dat"])

def _test_exposes_java_info(name):
    util.helper_target(
        java_library,
        name = name + "/jl",
        srcs = ["java/A.java"],
    )
    util.helper_target(
        java_info_wrapping_rule,
        name = name + "/r",
        dep = name + "/jl",
    )
    analysis_test(
        name = name,
        impl = _test_exposes_java_info_impl,
        targets = {
            "r": name + "/r",
            "jl": name + "/jl",
        },
    )

def _test_exposes_java_info_impl(env, targets):
    env.expect.that_bool(
        targets.r[JavaInfoWrappingInfo].p == targets.jl[JavaInfo],
    ).equals(True)

def _test_java_info_propagation(name):
    util.helper_target(
        java_library,
        name = name + "/jl",
        srcs = ["java/A.java"],
    )
    util.helper_target(
        java_info_forwarding_rule,
        name = name + "/r",
        dep = name + "/jl",
    )
    util.helper_target(
        java_library,
        name = name + "/jl_top",
        srcs = ["java/C.java"],
        deps = [name + "/r"],
    )

    analysis_test(
        name = name,
        impl = _test_java_info_propagation_impl,
        targets = {
            "r": name + "/r",
            "jl": name + "/jl",
            "jl_top": name + "/jl_top",
        },
    )

def _test_java_info_propagation_impl(env, targets):
    env.expect.that_bool(targets.r[JavaInfo] == targets.jl[JavaInfo]).equals(True)
    _assert_depsets_have_the_same_parent(
        env,
        targets.jl[JavaInfo].transitive_compile_time_jars,
        targets.jl_top[JavaInfo].transitive_compile_time_jars,
    )
    _assert_depsets_have_the_same_parent(
        env,
        targets.jl[JavaInfo].transitive_runtime_jars,
        targets.jl_top[JavaInfo].transitive_runtime_jars,
    )

def _assert_depsets_have_the_same_parent(env, depset1, depset2):
    elements = depset1.to_list()
    other_elements = depset2.to_list()

    for e, other_e in zip(elements, other_elements):
        env.expect.that_str(e.dirname).equals(other_e.dirname)

def _test_java_library_attributes(name):
    util.helper_target(
        java_library,
        name = name + "/jl_bottom_for_deps",
        srcs = ["java/A.java"],
    )
    util.helper_target(
        java_library,
        name = name + "/jl_bottom_for_exports",
        srcs = ["java/A2.java"],
    )
    util.helper_target(
        java_library,
        name = name + "/jl_bottom_for_runtime_deps",
        srcs = ["java/A2.java"],
    )
    util.helper_target(
        java_info_forwarding_rule,
        name = name + "/mya",
        dep = name + "/jl_bottom_for_deps",
    )
    util.helper_target(
        java_info_forwarding_rule,
        name = name + "/myb",
        dep = name + "/jl_bottom_for_exports",
    )
    util.helper_target(
        java_info_forwarding_rule,
        name = name + "/myc",
        dep = name + "/jl_bottom_for_runtime_deps",
    )
    util.helper_target(
        java_library,
        name = name + "/lib_exports",
        srcs = ["java/B.java"],
        exports = [name + "/myb"],
        runtime_deps = [name + "/myc"],
        deps = [name + "/mya"],
    )
    util.helper_target(
        java_library,
        name = name + "/lib_interm",
        srcs = ["java/C.java"],
        deps = [name + "/lib_exports"],
    )
    util.helper_target(
        java_library,
        name = name + "/lib_top",
        srcs = ["java/D.java"],
        deps = [name + "/lib_interm"],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_attributes_impl,
        targets = {
            "exports": name + "/lib_exports",
            "interm": name + "/lib_interm",
        },
    )

def _test_java_library_attributes_impl(env, targets):
    # all bottom jars are on the runtime classpath of lib_exports.
    java_info_subject.from_target(env, targets.exports).compilation_args().transitive_runtime_jars().contains_at_least_predicates([
        matching.file_basename_equals("jl_bottom_for_deps.jar"),
        matching.file_basename_equals("jl_bottom_for_runtime_deps.jar"),
        matching.file_basename_equals("jl_bottom_for_exports.jar"),
    ])

    # jl_bottom_for_exports.jar is in the recursive java compilation args of lib_top.
    java_info_subject.from_target(env, targets.interm).compilation_args().transitive_runtime_jars().contains_predicate(
        matching.file_basename_equals("jl_bottom_for_exports.jar"),
    )

def _test_propagates_direct_native_libraries(name):
    target_name = name + "/jl_top"
    util.helper_target(
        cc_library,
        name = target_name + "/native",
        srcs = ["cc/x.cc"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/jl",
        srcs = ["java/A.java"],
        deps = [target_name + "/native"],
    )
    util.helper_target(
        cc_library,
        name = target_name + "/ccl",
        srcs = ["cc/x.cc"],
    )
    util.helper_target(
        custom_java_info_rule,
        name = target_name + "/r",
        output_jar = target_name + "-out.jar",
        cc_dep = [target_name + "/ccl"],
        dep = [target_name + "/jl"],
    )
    util.helper_target(
        java_library,
        name = target_name,
        srcs = ["java/C.java"],
        deps = [target_name + "/r"],
    )

    analysis_test(
        name = name,
        impl = _test_propagates_direct_native_libraries_impl,
        target = target_name,
        # LibraryToLink.library_indentifier only available from Bazel 8
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _test_propagates_direct_native_libraries_impl(env, target):
    assert_transitive_native_libraries = java_info_subject.from_target(env, target).transitive_native_libraries()
    assert_transitive_native_libraries.identifiers().contains_exactly_predicates([
        matching.str_endswith("native"),
        matching.str_endswith("ccl"),
    ]).in_order()

def _test_exposes_native_library_info(name):
    target_name = name + "/jl"
    util.helper_target(
        cc_library,
        name = target_name + "/mynativedep_lib",
        srcs = ["cc/x.cc"],
    )
    util.helper_target(
        cc_binary,
        name = target_name + "/mynativedep_bin",
        srcs = ["cc/x.cc"],
        linkshared = 1,
    )
    util.helper_target(
        java_library,
        name = target_name,
        srcs = ["java/A.java"],
        deps = select({
            "@platforms//os:windows": [target_name + "/mynativedep_lib"],
            "//conditions:default": [target_name + "/mynativedep_bin"],
        }),
    )
    analysis_test(
        name = name,
        impl = _test_exposes_native_library_info_impl,
        target = target_name,
    )

def _test_exposes_native_library_info_impl(env, target):
    assert_lib = java_info_subject.from_target(env, target).transitive_native_libraries().singleton()

    assert_lib.dynamic_library().basename().contains("mynativedep")

def java_library_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_exposes_plugins,
            _test_exposes_java_info,
            _test_java_info_propagation,
            _test_java_library_attributes,
            _test_propagates_direct_native_libraries,
            _test_exposes_native_library_info,
        ],
    )
