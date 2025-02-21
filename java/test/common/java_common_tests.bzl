"""Tests for java_common APIs"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_library.bzl", "java_library")
load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_info.bzl", "JavaInfo")
load("//java/common:java_plugin_info.bzl", "JavaPluginInfo")
load("//java/test/testutil:java_info_subject.bzl", "java_info_subject")
load("//java/test/testutil:rules/custom_library.bzl", "custom_library")
load("//java/test/testutil:rules/custom_library_extended_compile_jdeps.bzl", "CompileJdepsInfo", "custom_library_extended_jdeps")
load("//java/test/testutil:rules/custom_library_with_bootclasspath.bzl", "custom_bootclasspath", "custom_library_with_bootclasspath")
load("//java/test/testutil:rules/custom_library_with_exports.bzl", "custom_library_with_exports")
load("//java/test/testutil:rules/custom_library_with_sourcepaths.bzl", "custom_library_with_sourcepaths")

def _test_compile_default_values(name):
    util.helper_target(custom_library, name = name + "/custom", srcs = ["Main.java"])

    analysis_test(name = name, impl = _test_compile_default_values_impl, target = name + "/custom")

def _test_compile_default_values_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.compilation_args().transitive_runtime_jars().contains_exactly([
        "{}/lib{}.jar".format(target.label.package, target.label.name),
    ])

def _test_compile_sourcepath(name):
    util.helper_target(
        custom_library_with_sourcepaths,
        name = "custom",
        srcs = ["Main.java"],
        sourcepath = [":B.jar"],
    )

    analysis_test(
        name = name,
        impl = _test_compile_sourcepath_impl,
        target = ":custom",
    )

def _test_compile_sourcepath_impl(env, target):
    assert_compile_action = env.expect.that_target(target).action_generating("{package}/libcustom.jar")

    assert_compile_action.contains_flag_values([
        ("--sourcepath", "{package}/B.jar".format(package = target.label.package)),
    ])

def _test_compile_exports_no_sources(name):
    util.helper_target(java_library, name = "jl", srcs = ["Main.java"])
    util.helper_target(custom_library_with_exports, name = "custom2", exports = [":jl"])

    analysis_test(
        name = name,
        impl = _test_compile_exports_no_sources_impl,
        target = ":custom2",
    )

def _test_compile_exports_no_sources_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.compilation_args().transitive_runtime_jars().contains_exactly(
        ["{package}/libjl.jar"],
    )

def _test_java_plugin_info(name):
    util.helper_target(native.filegroup, name = name + "/dummy")
    analysis_test(
        name = name,
        impl = _test_java_plugin_info_impl,
        target = name + "/dummy",  # analysis_test always expects a target
    )

def _test_java_plugin_info_impl(env, _target):
    env.expect.that_bool(
        java_common.JavaPluginInfo == JavaPluginInfo,
        "java_common.JavaPluginInfo == JavaPluginInfo",
    ).equals(True)

# Tests that extended 'compile time jdeps' are consistently updated.
def _test_compile_extend_compile_time_jdeps(name):
    util.helper_target(
        custom_library_extended_jdeps,
        name = name + "/foo",
        srcs = ["Foo.java"],
        extra_jdeps = "Foo.jdeps",
    )

    analysis_test(
        name = name,
        impl = _test_compile_extend_compile_time_jdeps_impl,
        target = name + "/foo",
        attr_values = {"tags": ["min_bazel_7"]},
    )

def _test_compile_extend_compile_time_jdeps_impl(env, target):
    before = target[CompileJdepsInfo].before.to_list()
    assert_that_before = env.expect.that_collection(before)
    assert_that_after = env.expect.that_collection(target[CompileJdepsInfo].after.to_list())

    assert_that_before.has_size(1)
    assert_that_after.has_size(2)
    assert_that_after.contains_at_least(before)
    assert_that_after.contains_exactly(target[JavaInfo]._compile_time_java_dependencies)

def _test_compile_extend_compile_time_jdeps_rule_outputs(name):
    util.helper_target(
        custom_library_extended_jdeps,
        name = name + "/foo",
        srcs = ["Foo.java"],
        extra_jdeps = "Foo.jdeps",
    )
    util.helper_target(
        custom_library_extended_jdeps,
        name = name + "/bar",
        srcs = ["Bar.java"],
        extra_jdeps = "Bar.jdeps",
        deps = [name + "/foo"],
    )
    util.helper_target(
        custom_library_extended_jdeps,
        name = name + "/baz",
        srcs = ["Baz.java"],
        extra_jdeps = "Baz.jdeps",
        exports = [name + "/foo"],
    )

    analysis_test(
        name = name,
        impl = _test_compile_extend_compile_time_jdeps_rule_outputs_impl,
        targets = {
            "foo": name + "/foo",
            "bar": name + "/bar",
            "baz": name + "/baz",
        },
        attr_values = {"tags": ["min_bazel_7"]},
    )

def _test_compile_extend_compile_time_jdeps_rule_outputs_impl(env, targets):
    foo = targets.foo
    compile_time_jdeps = foo[JavaInfo]._compile_time_java_dependencies
    env.expect.that_depset_of_files(compile_time_jdeps).contains_exactly([
        "{}/lib{}-hjar.jdeps".format(foo.label.package, foo.label.name),
        "{}/Foo.jdeps".format(foo.label.package),
    ])

    # foo's jdeps shouldn't appear in bar's
    bar = targets.bar
    compile_time_jdeps = bar[JavaInfo]._compile_time_java_dependencies
    env.expect.that_depset_of_files(compile_time_jdeps).contains_exactly([
        "{}/lib{}-hjar.jdeps".format(bar.label.package, bar.label.name),
        "{}/Bar.jdeps".format(bar.label.package),
    ])

    # baz exports foo, so we expect jdeps from both targets
    baz = targets.baz
    compile_time_jdeps = baz[JavaInfo]._compile_time_java_dependencies
    env.expect.that_depset_of_files(compile_time_jdeps).contains_exactly([
        "{}/lib{}-hjar.jdeps".format(foo.label.package, foo.label.name),
        "{}/Foo.jdeps".format(foo.label.package),
        "{}/lib{}-hjar.jdeps".format(baz.label.package, baz.label.name),
        "{}/Baz.jdeps".format(baz.label.package),
    ])

def _test_compile_bootclasspath(name):
    util.helper_target(
        custom_bootclasspath,
        name = name + "/bootclasspath",
        srcs = [
            "custom-system/lib/jrt-fs.jar",
            "custom-system/lib/modules",
            "custom-system/release",
        ],
    )
    util.helper_target(
        custom_library_with_bootclasspath,
        name = name + "/custom",
        srcs = ["Main.java"],
        bootclasspath = name + "/bootclasspath",
        sourcepath = [":B.jar"],
    )

    analysis_test(
        name = name,
        impl = _test_compile_bootclasspath_impl,
        target = name + "/custom",
        attr_values = {"tags": ["min_bazel_7"]},
    )

def _test_compile_bootclasspath_impl(env, target):
    assert_that_javac = env.expect.that_target(target).action_generating(
        target[JavaInfo].java_outputs[0].class_jar.short_path,
    )

    assert_that_javac.contains_flag_values([(
        "--system",
        "{}/custom-system".format(target.label.package),
    )])

def java_common_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_compile_default_values,
            _test_compile_sourcepath,
            _test_compile_exports_no_sources,
            _test_java_plugin_info,
            _test_compile_extend_compile_time_jdeps,
            _test_compile_extend_compile_time_jdeps_rule_outputs,
            _test_compile_bootclasspath,
        ],
    )
