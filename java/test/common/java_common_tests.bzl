"""Tests for java_common APIs"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_library.bzl", "java_library")
load("//java:java_plugin.bzl", "java_plugin")
load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_info.bzl", "JavaInfo")
load("//java/common:java_plugin_info.bzl", "JavaPluginInfo")
load("//java/test/testutil:java_info_subject.bzl", "java_info_subject")
load("//java/test/testutil:rules/custom_library.bzl", "custom_library")
load("//java/test/testutil:rules/custom_library_extended_compile_jdeps.bzl", "CompileJdepsInfo", "custom_library_extended_jdeps")
load("//java/test/testutil:rules/custom_library_with_bootclasspath.bzl", "custom_bootclasspath", "custom_library_with_bootclasspath")
load("//java/test/testutil:rules/custom_library_with_exports.bzl", "custom_library_with_exports")
load("//java/test/testutil:rules/custom_library_with_sourcepaths.bzl", "custom_library_with_sourcepaths")
load("//java/test/testutil:rules/custom_library_with_wrong_plugins_type.bzl", "custom_library_with_wrong_plugins_type")

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
    files = [
        "custom-system/lib/jrt-fs.jar",
        "custom-system/lib/modules",
        "custom-system/release",
    ]
    util.helper_target(
        custom_bootclasspath,
        name = name + "/bootclasspath",
        bootclasspath = files,
        system = files,
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

def _test_compile_override_with_empty_bootclasspath(name):
    util.helper_target(
        custom_bootclasspath,
        name = name + "/bootclasspath",
        bootclasspath = [],
        system = [
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
    )

    analysis_test(
        name = name,
        impl = _test_compile_override_with_empty_bootclasspath_impl,
        target = name + "/custom",
        attr_values = {"tags": ["min_bazel_7"]},
    )

def _test_compile_override_with_empty_bootclasspath_impl(env, target):
    assert_that_javac = env.expect.that_target(target).action_named("Javac")

    assert_that_javac.contains_flag_values([(
        "--system",
        "{}/custom-system".format(target.label.package),
    )])

def _test_exposes_java_info_as_provider(name):
    util.helper_target(
        java_library,
        name = name + "/dep",
        srcs = ["Dep.java"],
    )
    analysis_test(
        name = name,
        impl = _test_exposes_java_info_as_provider_impl,
        target = name + "/dep",
    )

def _test_exposes_java_info_as_provider_impl(env, target):
    java_info = target[java_common.provider]
    assert_java_info = java_info_subject.new(
        java_info,
        env.expect.meta.derive(
            format_str_kwargs = {
                "name": target.label.name,
                "package": target.label.package,
            },
        ),
    )

    assert_java_info.compilation_args().transitive_runtime_jars().contains_exactly([
        "{package}/lib{name}.jar",
    ])
    assert_java_info.compilation_args().transitive_compile_time_jars().contains_exactly([
        "{package}/lib{name}-hjar.jar",
    ])
    assert_java_info.compilation_args().full_compile_jars().contains_exactly([
        "{package}/lib{name}.jar",
    ])
    assert_java_info.source_jars().contains_exactly_predicates([
        matching.file_basename_equals("dep-src.jar"),
    ])

    assert_output = assert_java_info.outputs().jars().singleton()
    assert_output.class_jar().short_path_equals("{package}/lib{name}.jar")
    assert_output.compile_jar().short_path_equals("{package}/lib{name}-hjar.jar")
    assert_output.source_jars().contains_exactly(["{package}/lib{name}-src.jar"])
    assert_output.jdeps().short_path_equals("{package}/lib{name}.jdeps")
    assert_output.compile_jdeps().short_path_equals("{package}/lib{name}-hjar.jdeps")

def _test_compile_exposes_outputs_provider(name):
    util.helper_target(
        custom_library,
        name = name + "/dep",
        srcs = ["Main.java"],
    )

    analysis_test(
        name = name,
        impl = _test_compile_exposes_outputs_provider_impl,
        target = name + "/dep",
    )

def _test_compile_exposes_outputs_provider_impl(env, target):
    assert_output = java_info_subject.from_target(env, target).outputs().jars().singleton()

    assert_output.class_jar().short_path_equals("{package}/lib{name}.jar")
    assert_output.compile_jar().short_path_equals("{package}/lib{name}-hjar.jar")
    assert_output.source_jars().contains_exactly(["{package}/lib{name}-src.jar"])
    assert_output.jdeps().short_path_equals("{package}/lib{name}.jdeps")
    assert_output.native_headers_jar().short_path_equals("{package}/lib{name}-native-header.jar")
    assert_output.compile_jdeps().short_path_equals("{package}/lib{name}-hjar.jdeps")

def _test_compile_sets_runtime_deps(name):
    target_name = name + "/custom"
    util.helper_target(
        custom_library,
        name = target_name,
        srcs = ["Main.java"],
        runtime_deps = [target_name + "/runtime"],
        deps = [target_name + "/dep"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/dep",
        srcs = ["Dep.java"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/runtime",
        srcs = ["Runtime.java"],
    )

    analysis_test(
        name = name,
        impl = _test_compile_sets_runtime_deps_impl,
        target = target_name,
    )

def _test_compile_sets_runtime_deps_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.compilation_args().transitive_runtime_jars_list().contains_exactly_predicates([
        matching.file_basename_equals("custom.jar"),
        matching.file_basename_equals("dep.jar"),
        matching.file_basename_equals("runtime.jar"),
    ]).in_order()
    assert_java_info.runtime_output_jars().contains_exactly(["{package}/lib{name}.jar"])
    assert_java_info.compilation_info().compilation_classpath().contains_exactly([
        "{package}/lib{name}/dep-hjar.jar",
    ])
    assert_java_info.compilation_info().runtime_classpath_list().contains_exactly_predicates([
        matching.file_basename_equals("custom.jar"),
        matching.file_basename_equals("runtime.jar"),
        matching.file_basename_equals("dep.jar"),
    ]).in_order()
    assert_java_info.transitive_source_jars_list().contains_exactly_predicates([
        matching.file_basename_equals("runtime-src.jar"),
        matching.file_basename_equals("dep-src.jar"),
        matching.file_basename_equals("custom-src.jar"),
    ]).in_order()

def _test_compile_exposes_annotation_processing_info(name):
    _test_annotation_processing_info_is_starlark_accessible(name, custom_library)

def _test_java_library_exposes_annotation_processing_info(name):
    _test_annotation_processing_info_is_starlark_accessible(name, java_library)

def _test_annotation_processing_info_is_starlark_accessible(name, to_be_processed_rule_class):
    target_name = name + "/to_be_processed"
    util.helper_target(
        to_be_processed_rule_class,
        name = target_name,
        plugins = [target_name + "/plugin"],
        srcs = ["ToBeProcessed.java"],
        deps = [target_name + "/dep"],
        exports = [target_name + "/export"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/plugin_dep",
        srcs = ["Processordep.java"],
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
        name = target_name + "/dep",
        srcs = ["Dep.java"],
        plugins = [target_name + "/plugin"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/export",
        srcs = ["Export.java"],
        plugins = [target_name + "/plugin"],
    )

    analysis_test(
        name = name,
        impl = _test_annotation_processing_info_is_starlark_accessible_impl,
        target = target_name,
    )

def _test_annotation_processing_info_is_starlark_accessible_impl(env, target):
    depj = target[JavaInfo]
    result = struct(
        enabled = depj.annotation_processing.enabled,
        class_jar = depj.outputs.jars[0].generated_class_jar,
        source_jar = depj.outputs.jars[0].generated_source_jar,
        old_class_jar = depj.annotation_processing.class_jar,
        old_source_jar = depj.annotation_processing.source_jar,
        processor_classpath = depj.annotation_processing.processor_classpath,
        processor_classnames = depj.annotation_processing.processor_classnames,
        transitive_class_jars = depj.annotation_processing.transitive_class_jars,
        transitive_source_jars = depj.annotation_processing.transitive_source_jars,
    )

    env.expect.that_bool(result.enabled).equals(True)
    env.expect.that_file(result.class_jar).equals(result.old_class_jar)
    env.expect.that_file(result.source_jar).equals(result.old_source_jar)
    env.expect.that_collection(result.processor_classnames).contains_exactly([
        "com.google.process.stuff",
    ])
    env.expect.that_collection(result.processor_classpath.to_list()).contains_exactly_predicates([
        matching.file_basename_equals("plugin.jar"),
        matching.file_basename_equals("plugin_dep.jar"),
    ])
    env.expect.that_collection(result.transitive_class_jars.to_list()).has_size(3)
    env.expect.that_collection(result.transitive_class_jars.to_list()).contains(result.class_jar)
    env.expect.that_collection(result.transitive_source_jars.to_list()).has_size(3)
    env.expect.that_collection(result.transitive_source_jars.to_list()).contains(result.source_jar)

def _test_compile_requires_java_plugin_info(name):
    target_name = name + "/to_be_processed"
    util.helper_target(
        java_library,
        name = target_name + "/dep",
        srcs = ["ProcessorDep.java"],
    )
    util.helper_target(
        custom_library_with_wrong_plugins_type,
        name = target_name,
        srcs = ["ToBeProcessed.java"],
        deps = [target_name + "/dep"],
    )

    analysis_test(
        name = name,
        impl = _test_compile_requires_java_plugin_info_impl,
        target = target_name,
        expect_failure = True,
    )

def _test_compile_requires_java_plugin_info_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("at index 0 of plugins, got element of type JavaInfo, want JavaPluginInfo"),
    )

def _test_compile_compilation_info(name):
    target_name = name + "/custom"
    util.helper_target(
        custom_library,
        name = target_name,
        srcs = ["Main.java"],
        deps = [target_name + "/dep"],
        javac_opts = ["-XDone -XDtwo"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/dep",
        srcs = ["Dep.java"],
    )

    analysis_test(
        name = name,
        impl = _test_compile_compilation_info_impl,
        target = target_name,
    )

def _test_compile_compilation_info_impl(env, target):
    assert_compilation_info = java_info_subject.from_target(env, target).compilation_info()

    assert_compilation_info.compilation_classpath().contains_exactly([
        "{package}/lib{name}/dep-hjar.jar",
    ])
    assert_compilation_info.runtime_classpath().contains_exactly([
        "{package}/lib{name}/dep.jar",
        "{package}/lib{name}.jar",
    ])
    assert_compilation_info.javac_options().contains("-XDone")

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
            _test_compile_override_with_empty_bootclasspath,
            _test_exposes_java_info_as_provider,
            _test_compile_exposes_outputs_provider,
            _test_compile_sets_runtime_deps,
            _test_compile_exposes_annotation_processing_info,
            _test_java_library_exposes_annotation_processing_info,
            _test_compile_requires_java_plugin_info,
            _test_compile_compilation_info,
        ],
    )
