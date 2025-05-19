"""Tests for java_common APIs"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_binary.bzl", "java_binary")
load("//java:java_library.bzl", "java_library")
load("//java:java_plugin.bzl", "java_plugin")
load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_info.bzl", "JavaInfo")
load("//java/common:java_plugin_info.bzl", "JavaPluginInfo")
load("//test/java/testutil:artifact_closure.bzl", "artifact_closure")
load("//test/java/testutil:java_info_subject.bzl", "java_info_subject")
load("//test/java/testutil:rules/custom_library.bzl", "custom_library")
load("//test/java/testutil:rules/custom_library_extended_compile_jdeps.bzl", "CompileJdepsInfo", "custom_library_extended_jdeps")
load("//test/java/testutil:rules/custom_library_with_additional_inputs.bzl", "custom_library_with_additional_inputs")
load("//test/java/testutil:rules/custom_library_with_bootclasspath.bzl", "custom_bootclasspath", "custom_library_with_bootclasspath")
load("//test/java/testutil:rules/custom_library_with_custom_output_source_jar.bzl", "custom_library_with_custom_output_source_jar")
load("//test/java/testutil:rules/custom_library_with_exports.bzl", "custom_library_with_exports")
load("//test/java/testutil:rules/custom_library_with_named_outputs.bzl", "custom_library_with_named_outputs")
load("//test/java/testutil:rules/custom_library_with_sourcepaths.bzl", "custom_library_with_sourcepaths")
load("//test/java/testutil:rules/custom_library_with_strict_deps.bzl", "custom_library_with_strict_deps")
load("//test/java/testutil:rules/custom_library_with_wrong_plugins_type.bzl", "custom_library_with_wrong_plugins_type")

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

def _test_compile_exports_with_sources(name):
    target_name = name + "/custom"
    util.helper_target(
        custom_library_with_exports,
        name = target_name,
        srcs = ["Main.java"],
        exports = [target_name + "/dep"],
        output_name = "amazing",
    )
    util.helper_target(
        java_library,
        name = target_name + "/dep",
        srcs = ["Dep.java"],
    )

    analysis_test(
        name = name,
        impl = _test_compile_exports_with_sources_impl,
        target = target_name,
        # Bazel 6 JavaInfo doesn't expose compile_time_java_dependencies
        attr_values = {"tags": ["min_bazel_7"]},
    )

def _test_compile_exports_with_sources_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.transitive_source_jars().contains_exactly([
        "{package}/{name}/amazing-src.jar",
        "{package}/lib{name}/dep-src.jar",
    ])
    assert_java_info.compilation_args().compile_jars().contains_exactly([
        "{package}/{name}/amazing-hjar.jar",
        "{package}/lib{name}/dep-hjar.jar",
    ])
    assert_java_info.compilation_args().compile_time_java_dependencies().contains_exactly([
        "{package}/{name}/amazing-hjar.jdeps",
        "{package}/lib{name}/dep-hjar.jdeps",
    ])

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

def _test_compile_transitive_source_jars(name):
    target_name = name + "/custom"
    util.helper_target(
        custom_library,
        name = target_name,
        srcs = ["Main.java"],
        deps = [target_name + "/dep"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/dep",
        srcs = ["Dep.java"],
    )

    analysis_test(
        name = name,
        impl = _test_compile_transitive_source_jars_impl,
        target = target_name,
    )

def _test_compile_transitive_source_jars_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.source_jars().contains_exactly_predicates([
        matching.file_basename_equals("custom-src.jar"),
    ])
    assert_java_info.transitive_source_jars().contains_exactly([
        "{package}/lib{name}/dep-src.jar",
        "{package}/lib{name}-src.jar",
    ])

def _test_compile_source_jar_name_derived_from_output_jar(name):
    target_name = name + "/custom"
    util.helper_target(
        custom_library_with_named_outputs,
        name = target_name,
        srcs = ["Main.java"],
        deps = [target_name + "/dep"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/dep",
        srcs = ["Dep.java"],
    )

    analysis_test(
        name = name,
        impl = _test_compile_source_jar_name_derived_from_output_jar_impl,
        target = target_name,
    )

def _test_compile_source_jar_name_derived_from_output_jar_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.source_jars().contains_exactly_predicates([
        matching.file_basename_equals("amazing-src.jar"),
        matching.file_basename_equals("wonderful-src.jar"),
    ])
    assert_java_info.transitive_source_jars().contains_exactly([
        "{package}/lib{name}/dep-src.jar",
        "{package}/{name}/amazing-src.jar",
        "{package}/{name}/wonderful-src.jar",
    ])

def _test_compile_with_only_one_source_jar(name):
    util.helper_target(
        custom_library,
        name = name + "/custom",
        source_jars = ["myjar-src.jar"],
    )
    analysis_test(
        name = name,
        impl = _test_compile_with_only_one_source_jar_impl,
        target = name + "/custom",
    )

def _test_compile_with_only_one_source_jar_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.source_jars().contains_exactly_predicates([
        matching.file_basename_equals("custom-src.jar"),
    ])
    assert_output = assert_java_info.java_outputs().singleton()
    assert_output.class_jar().short_path_equals("{package}/lib{name}.jar")
    assert_output.compile_jar().short_path_equals("{package}/lib{name}-hjar.jar")
    assert_output.source_jars().contains_exactly(["{package}/lib{name}-src.jar"])
    assert_output.jdeps().short_path_equals("{package}/lib{name}.jdeps")
    assert_output.compile_jdeps().short_path_equals("{package}/lib{name}-hjar.jdeps")

def _test_compile_no_sources(name):
    util.helper_target(
        custom_library,
        name = name + "/custom",
    )

    analysis_test(
        name = name,
        impl = _test_compile_no_sources_impl,
        target = name + "/custom",
    )

def _test_compile_no_sources_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.source_jars().contains_exactly_predicates([
        matching.file_basename_equals("custom-src.jar"),
    ])
    assert_output = assert_java_info.java_outputs().singleton()
    assert_output.class_jar().short_path_equals("{package}/lib{name}.jar")
    assert_output.source_jars().contains_exactly(["{package}/lib{name}-src.jar"])

def _test_compile_custom_output_source_jar(name):
    util.helper_target(
        custom_library_with_custom_output_source_jar,
        name = name + "/custom",
        srcs = ["myjar-src.jar"],
    )

    analysis_test(
        name = name,
        impl = _test_compile_custom_output_source_jar_impl,
        target = name + "/custom",
    )

def _test_compile_custom_output_source_jar_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)

    assert_java_info.source_jars().contains_exactly_predicates([
        matching.file_basename_equals("custom-mysrc.jar"),
    ])
    assert_output = assert_java_info.java_outputs().singleton()
    assert_output.class_jar().short_path_equals("{package}/lib{name}.jar")
    assert_output.compile_jar().short_path_equals("{package}/lib{name}-hjar.jar")
    assert_output.source_jars().contains_exactly(["{package}/lib{name}-mysrc.jar"])
    assert_output.jdeps().short_path_equals("{package}/lib{name}.jdeps")
    assert_output.compile_jdeps().short_path_equals("{package}/lib{name}-hjar.jdeps")

def _test_compile_additional_inputs_and_outputs(name):
    util.helper_target(
        custom_library_with_additional_inputs,
        name = name + "/custom",
        srcs = ["myjar-src.jar"],
        additional_inputs = ["additional_input.bin"],
    )

    analysis_test(
        name = name,
        impl = _test_compile_additional_inputs_and_outputs_impl,
        target = name + "/custom",
    )

def _test_compile_additional_inputs_and_outputs_impl(env, target):
    assert_java_action = env.expect.that_target(target).action_generating(
        "{package}/lib{name}.jar",
    )

    assert_java_action.inputs().contains_predicate(
        matching.file_basename_equals("additional_input.bin"),
    )
    env.expect.that_depset_of_files(assert_java_action.actual.outputs).contains_predicate(
        matching.file_basename_equals("custom_additional_output"),
    )

def _test_compile_neverlink(name):
    target_name = name + "/plugin"
    util.helper_target(
        java_binary,
        name = target_name,
        srcs = ["Plugin.java"],
        main_class = "plugin.start",
        deps = [target_name + "/somedep"],
    )
    util.helper_target(
        custom_library,
        name = target_name + "/somedep",
        srcs = ["Dependency.java"],
        deps = [target_name + "/eclipse"],
    )
    util.helper_target(
        custom_library,
        name = target_name + "/eclipse",
        srcs = ["EclipseDependency.java"],
        neverlink = 1,
    )
    analysis_test(
        name = name,
        impl = _test_compile_neverlink_impl,
        target = target_name,
        extra_target_under_test_aspects = [artifact_closure.aspect],
    )

def _test_compile_neverlink_impl(env, target):
    java_source_basenames = [
        f.basename
        for f in artifact_closure.of_target(target)
        if f.extension == "java"
    ]
    env.expect.that_collection(java_source_basenames).contains_exactly([
        "Plugin.java",
        "Dependency.java",
        "EclipseDependency.java",
    ])
    jars_in_runfiles = [
        f.basename
        for f in target[DefaultInfo].default_runfiles.files.to_list()
        if f.extension == "jar" and
           f.short_path.startswith(target.label.package)  # exclude toolchain
    ]
    env.expect.that_collection(jars_in_runfiles).contains_exactly([
        "plugin.jar",
        "somedep.jar",
    ]).in_order()

def _test_compile_strict_deps_case_sensitivity(name):
    util.helper_target(
        custom_library_with_strict_deps,
        name = name + "/enabled",
        strict_deps = "error",
    )
    util.helper_target(
        custom_library_with_strict_deps,
        name = name + "/disabled",
        strict_deps = "off",
    )

    analysis_test(
        name = name,
        impl = _test_compile_strict_deps_case_sensitivity_impl,
        targets = {
            "enabled": name + "/enabled",
            "disabled": name + "/disabled",
        },
    )

def _test_compile_strict_deps_case_sensitivity_impl(env, targets):
    env.expect.that_target(targets.enabled).action_named("Javac").contains_flag_values(
        [("--strict_java_deps", "ERROR")],
    )
    env.expect.that_target(targets.disabled).action_named("Javac").not_contains_arg(
        "--strict_java_deps",
    )

def _test_compile_strict_deps_enum(name):
    util.helper_target(
        custom_library_with_strict_deps,
        name = name + "/custom",
        strict_deps = "foo",
    )

    analysis_test(
        name = name,
        impl = _test_compile_strict_deps_enum_impl,
        target = name + "/custom",
        expect_failure = True,
        # This is a crash in earlier Bazel versions (i.e. native rules)
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _test_compile_strict_deps_enum_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("invalid value for strict_deps: FOO"),
    )

def java_common_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_compile_default_values,
            _test_compile_sourcepath,
            _test_compile_exports_no_sources,
            _test_compile_exports_with_sources,
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
            _test_compile_transitive_source_jars,
            _test_compile_source_jar_name_derived_from_output_jar,
            _test_compile_with_only_one_source_jar,
            _test_compile_no_sources,
            _test_compile_custom_output_source_jar,
            _test_compile_additional_inputs_and_outputs,
            _test_compile_neverlink,
            _test_compile_strict_deps_case_sensitivity,
            _test_compile_strict_deps_enum,
        ],
    )
