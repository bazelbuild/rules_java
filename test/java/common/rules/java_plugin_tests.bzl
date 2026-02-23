"""Tests for the java_plugin rule"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "subjects")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_library.bzl", "java_library")
load("//java:java_plugin.bzl", "java_plugin")
load("//java/common:java_plugin_info.bzl", "JavaPluginInfo")
load("//java/common:proguard_spec_info.bzl", "ProguardSpecInfo")
load("//test/java/testutil:java_info_subject.bzl", "java_plugin_info_subject")

def _test_exposes_plugins_to_starlark(name):
    target_name = name + "/plugin"
    util.helper_target(
        java_library,
        name = target_name + "/plugin_dep",
        srcs = ["ProcessorDep.java"],
        data = ["depfile.dat"],
    )
    util.helper_target(
        java_plugin,
        name = target_name,
        srcs = ["AnnotationProcessor.java"],
        data = ["pluginfile.dat"],
        processor_class = "com.google.process.stuff",
        deps = [target_name + "/plugin_dep"],
    )

    analysis_test(
        name = name,
        impl = _test_exposes_plugins_to_starlark_impl,
        target = target_name,
    )

def _test_exposes_plugins_to_starlark_impl(env, target):
    assert_plugin_data = java_plugin_info_subject.from_target(env, target).plugins()
    assert_plugin_data.processor_classes().contains_exactly(["com.google.process.stuff"])
    assert_plugin_data.processor_jars().contains_exactly([
        "{package}/lib{name}.jar",
        "{package}/lib{name}/plugin_dep.jar",
    ])
    assert_plugin_data.processor_data().contains_exactly(["{package}/pluginfile.dat"])

    java_plugin_info_subject.from_target(env, target).api_generating_plugins().is_empty()

def _test_exposes_api_generating_plugins_to_starlark(name):
    target_name = name + "/plugin"
    util.helper_target(
        java_library,
        name = target_name + "/plugin_dep",
        srcs = ["ProcessorDep.java"],
        data = ["depfile.dat"],
    )
    util.helper_target(
        java_plugin,
        name = target_name,
        srcs = ["AnnotationProcessor.java"],
        data = ["pluginfile.dat"],
        processor_class = "com.google.process.stuff",
        deps = [target_name + "/plugin_dep"],
        generates_api = True,
    )

    analysis_test(
        name = name,
        impl = _test_exposes_api_generating_plugins_to_starlark_impl,
        target = target_name,
    )

def _test_exposes_api_generating_plugins_to_starlark_impl(env, target):
    assert_api_plugin_data = java_plugin_info_subject.from_target(env, target).api_generating_plugins()
    assert_api_plugin_data.processor_classes().contains_exactly(["com.google.process.stuff"])
    assert_api_plugin_data.processor_jars().contains_exactly([
        "{package}/lib{name}.jar",
        "{package}/lib{name}/plugin_dep.jar",
    ])
    assert_api_plugin_data.processor_data().contains_exactly(["{package}/pluginfile.dat"])
    assert_api_plugin_data.equals(target[JavaPluginInfo].plugins)

def _test_not_empty_processor_class(name):
    util.helper_target(
        java_library,
        name = name + "/deps",
        srcs = ["Deps.java"],
    )
    util.helper_target(
        java_plugin,
        name = name + "/processor",
        srcs = ["Processor.java"],
        processor_class = "com.google.test.Processor",
        deps = [name + "/deps"],
    )

    analysis_test(
        name = name,
        impl = _test_not_empty_processor_class_impl,
        target = name + "/processor",
    )

def _test_not_empty_processor_class_impl(env, target):
    plugin_info = java_plugin_info_subject.from_target(env, target)
    plugin_info.plugins().processor_classes().contains_exactly(["com.google.test.Processor"])

    plugin_info.plugins().processor_jars().contains_exactly([
        "{package}/lib{name}.jar",
        "{package}/lib{test_name}/deps.jar",
    ])

def _test_empty_processor_class(name):
    util.helper_target(
        java_library,
        name = name + "/deps",
        srcs = ["Deps.java"],
    )
    util.helper_target(
        java_plugin,
        name = name + "/bugchecker",
        srcs = ["BugChecker.java"],
        deps = [":" + name + "/deps"],
    )

    analysis_test(
        name = name,
        impl = _test_empty_processor_class_impl,
        target = name + "/bugchecker",
    )

def _test_empty_processor_class_impl(env, target):
    plugin_info = java_plugin_info_subject.from_target(env, target)
    plugin_info.plugins().processor_classes().contains_exactly([])
    plugin_info.plugins().processor_jars().contains_exactly([
        "{package}/lib{name}.jar",
        "{package}/lib{test_name}/deps.jar",
    ])

def _test_empty_processor_class_target(name):
    util.helper_target(
        java_library,
        name = name + "/deps",
        srcs = ["Deps.java"],
    )
    util.helper_target(
        java_plugin,
        name = name + "/bugchecker",
        srcs = ["BugChecker.java"],
        deps = [":" + name + "/deps"],
    )
    util.helper_target(
        java_library,
        name = name + "/empty",
        plugins = [":" + name + "/bugchecker"],
    )

    analysis_test(
        name = name,
        impl = _test_empty_processor_class_target_impl,
        target = name + "/empty",
    )

def _test_empty_processor_class_target_impl(env, target):
    env.expect.that_target(target).action_generating("{package}/lib{name}.jar").inputs().contains_at_least([
        "{package}/lib{test_name}/bugchecker.jar",
        "{package}/lib{test_name}/deps.jar",
    ])

def _new_proguard_info_subject(info, meta):
    return struct(
        specs = lambda: subjects.depset_file(info.specs, meta.derive("specs")),
    )

def _test_java_plugin_exports_transitive_proguard_specs(name):
    util.helper_target(
        java_plugin,
        name = name + "/plugin",
        srcs = ["Plugin.java"],
        proguard_specs = ["plugin.pro"],
    )
    util.helper_target(
        java_library,
        name = name + "/dep",
        srcs = ["Dep.java"],
        proguard_specs = ["dep.pro"],
    )
    util.helper_target(
        java_plugin,
        name = name + "/top",
        srcs = ["Top.java"],
        plugins = [":" + name + "/plugin"],
        proguard_specs = ["top.pro"],
        deps = [":" + name + "/dep"],
    )

    analysis_test(
        name = name,
        impl = _test_java_plugin_exports_transitive_proguard_specs_impl,
        target = name + "/top",
        # Before Bazel 8, native rules use the native ProguardSpecProvider
        attr_values = {"tags": ["min_bazel_8"]},
        provider_subject_factories = [struct(
            type = ProguardSpecInfo,
            name = "ProguardInfo",
            factory = _new_proguard_info_subject,
        )],
    )

def _test_java_plugin_exports_transitive_proguard_specs_impl(env, target):
    env.expect.that_target(target).provider(ProguardSpecInfo).specs().contains_exactly(
        [
            "{package}/validated_proguard/{test_name}/top/{package}/top.pro_valid",
            "{package}/validated_proguard/{test_name}/dep/{package}/dep.pro_valid",
        ],
    )

def _test_java_plugin_validates_proguard_specs(name):
    util.helper_target(
        java_plugin,
        name = name + "/plugin",
        srcs = ["Plugin.java"],
        proguard_specs = ["plugin.pro"],
    )

    analysis_test(
        name = name,
        impl = _test_java_plugin_validates_proguard_specs_impl,
        target = name + "/plugin",
    )

def _test_java_plugin_validates_proguard_specs_impl(env, target):
    output_file = None
    for f in target.output_groups["_hidden_top_level_INTERNAL_"].to_list():
        if f.basename == "plugin.pro_valid":
            output_file = f
            break
    env.expect.that_target(target).action_generating(
        output_file.short_path,
    ).inputs().contains_at_least(
        ["{package}/plugin.pro"],
    )

def _test_java_plugin_validates_transitive_proguard_specs(name):
    util.helper_target(
        java_library,
        name = name + "/transitive",
        srcs = ["Transitive.java"],
        proguard_specs = ["transitive.pro"],
    )
    util.helper_target(
        java_plugin,
        name = name + "/plugin",
        srcs = ["Plugin.java"],
        deps = [":" + name + "/transitive"],
    )

    analysis_test(
        name = name,
        impl = _test_java_plugin_validates_transitive_proguard_specs_impl,
        targets = {
            "transitive": name + "/transitive",
            "plugin": name + "/plugin",
        },
    )

def _test_java_plugin_validates_transitive_proguard_specs_impl(env, targets):
    output_file = None
    for f in targets.plugin.output_groups["_hidden_top_level_INTERNAL_"].to_list():
        if f.basename == "transitive.pro_valid":
            output_file = f
            break

    env.expect.that_target(targets.transitive).action_generating(
        output_file.short_path,
    ).inputs().contains_at_least(["{package}/transitive.pro"])

def _test_generates_api(name):
    util.helper_target(
        java_plugin,
        name = name + "/api_generating",
        srcs = ["ApiGeneratingPlugin.java"],
        generates_api = True,
        processor_class = "ApiGeneratingPlugin",
    )

    analysis_test(
        name = name,
        impl = _test_generates_api_impl,
        target = name + "/api_generating",
    )

def _test_generates_api_impl(env, target):
    plugin_info = java_plugin_info_subject.from_target(env, target)
    plugin_info.plugins().processor_classes().contains_exactly(["ApiGeneratingPlugin"])
    plugin_info.api_generating_plugins().processor_classes().contains_exactly(["ApiGeneratingPlugin"])
    plugin_info.plugins().processor_jars().contains_exactly([
        "{package}/lib{name}.jar",
    ])
    plugin_info.api_generating_plugins().processor_jars().contains_exactly([
        "{package}/lib{name}.jar",
    ])

def _test_generates_implementation(name):
    util.helper_target(
        java_plugin,
        name = name + "/impl_generating",
        srcs = ["ImplGeneratingPlugin.java"],
        generates_api = False,
        processor_class = "ImplGeneratingPlugin",
    )

    analysis_test(
        name = name,
        impl = _test_generates_implementation_impl,
        target = name + "/impl_generating",
    )

def _test_generates_implementation_impl(env, target):
    plugin_info = java_plugin_info_subject.from_target(env, target)
    plugin_info.plugins().processor_classes().contains_exactly(["ImplGeneratingPlugin"])
    plugin_info.api_generating_plugins().processor_classes().contains_exactly([])
    plugin_info.plugins().processor_jars().contains_exactly([
        "{package}/lib{test_name}/impl_generating.jar",
    ])
    plugin_info.api_generating_plugins().processor_jars().contains_exactly([])

def _test_plugin_data_in_provider(name):
    util.helper_target(
        java_plugin,
        name = name + "/impl_generating",
        srcs = ["ImplGeneratingPlugin.java"],
        data = ["data.txt"],
        generates_api = False,
        processor_class = "ImplGeneratingPlugin",
    )

    analysis_test(
        name = name,
        impl = _test_plugin_data_in_provider_impl,
        target = name + "/impl_generating",
    )

def _test_plugin_data_in_provider_impl(env, target):
    plugin_info = java_plugin_info_subject.from_target(env, target)
    plugin_info.plugins().processor_data().contains_exactly([
        "{package}/data.txt",
    ])

def _test_plugin_data_in_action_inputs(name):
    util.helper_target(
        java_plugin,
        name = name + "/impl_generating_lib",
        srcs = ["ImplGeneratingPlugin.java"],
        data = ["data.txt"],
        generates_api = False,
        processor_class = "ImplGeneratingPlugin",
    )
    util.helper_target(
        java_library,
        name = name + "/lib",
        plugins = [":" + name + "/impl_generating_lib"],
    )

    analysis_test(
        name = name,
        impl = _test_plugin_data_in_action_inputs_impl,
        target = name + "/lib",
    )

def _test_plugin_data_in_action_inputs_impl(env, target):
    env.expect.that_target(target).action_generating("{package}/lib{name}.jar").inputs().contains_at_least([
        "{package}/data.txt",
    ])

def java_plugin_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_exposes_plugins_to_starlark,
            _test_exposes_api_generating_plugins_to_starlark,
            _test_not_empty_processor_class,
            _test_empty_processor_class,
            _test_empty_processor_class_target,
            _test_generates_api,
            _test_plugin_data_in_provider,
            _test_plugin_data_in_action_inputs,
            _test_java_plugin_exports_transitive_proguard_specs,
            _test_java_plugin_validates_proguard_specs,
            _test_java_plugin_validates_transitive_proguard_specs,
            _test_generates_implementation,
        ],
    )
