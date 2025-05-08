"""Tests for the java_import rule"""

load("@bazel_features//:features.bzl", "bazel_features")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_import.bzl", "java_import")
load("//java:java_library.bzl", "java_library")
load("//java/common:java_info.bzl", "JavaInfo")
load("//test/java/testutil:helper.bzl", "always_passes")
load("//test/java/testutil:java_info_subject.bzl", "java_info_subject")
load("//test/java/testutil:javac_action_subject.bzl", "javac_action_subject")
load("//test/java/testutil:rules/forward_java_info.bzl", "java_info_forwarding_rule")

def _test_java_import_attributes(name):
    target_name = name + "/import"
    util.helper_target(
        java_library,
        name = target_name + "/jl_bottom_for_deps",
        srcs = ["java/A.java"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/jl_bottom_for_runtime_deps",
        srcs = ["java/A2.java"],
    )
    util.helper_target(
        java_info_forwarding_rule,
        name = target_name + "/mya",
        dep = target_name + "/jl_bottom_for_deps",
    )
    util.helper_target(
        java_info_forwarding_rule,
        name = target_name + "/myb",
        dep = target_name + "/jl_bottom_for_runtime_deps",
    )
    util.helper_target(
        java_import,
        name = target_name,
        jars = ["B.jar"],
        runtime_deps = [target_name + "/myb"],
        deps = [target_name + "/mya"],
    )

    analysis_test(
        name = name,
        impl = _test_java_import_attributes_impl,
        target = target_name,
    )

def _test_java_import_attributes_impl(env, target):
    assert_runtime_jars = java_info_subject.from_target(env, target).compilation_args().transitive_runtime_jars()

    # Test that all bottom jars are on the runtime classpath.
    assert_runtime_jars.contains_at_least_predicates([
        matching.file_basename_equals("jl_bottom_for_deps.jar"),
        matching.file_basename_equals("jl_bottom_for_runtime_deps.jar"),
    ])

def _test_simple(name):
    target_name = name + "/libraryjar"
    util.helper_target(
        java_import,
        name = target_name,
        jars = ["library.jar"],
    )

    analysis_test(
        name = name,
        impl = _test_simple_impl,
        target = target_name,
    )

def _test_simple_impl(env, target):
    env.expect.that_target(target).default_outputs().contains_exactly([
        "{package}/library.jar",
    ])

def _test_with_java_library(name):
    target_name = name + "/javalib"
    util.helper_target(
        java_library,
        name = target_name,
        srcs = ["Other.java"],
        deps = [target_name + "/libraryjar"],
    )
    util.helper_target(
        java_import,
        name = target_name + "/libraryjar",
        jars = ["library.jar"],
    )

    analysis_test(
        name = name,
        impl = _test_with_java_library_impl,
        target = target_name,
    )

def _test_with_java_library_impl(env, target):
    assert_compliation_info = java_info_subject.from_target(env, target).compilation_info()

    assert_compliation_info.compilation_classpath().contains_exactly([
        "{package}/_ijar/{name}/libraryjar/{package}/library-ijar.jar",
    ])
    assert_compliation_info.runtime_classpath().contains_exactly([
        "{package}/lib{name}.jar",
        "{package}/library.jar",
    ])

def _test_deps(name):
    util.helper_target(
        java_library,
        name = name + "/lib",
        srcs = ["Main.java"],
        deps = [name + "/import-jar"],
    )
    util.helper_target(
        java_import,
        name = name + "/import-jar",
        jars = ["import.jar"],
        exports = [name + "/exportjar"],
        deps = [name + "/depjar"],
    )
    util.helper_target(
        java_import,
        name = name + "/depjar",
        jars = ["depjar.jar"],
    )
    util.helper_target(
        java_import,
        name = name + "/exportjar",
        jars = ["exportjar.jar"],
    )

    analysis_test(
        name = name,
        impl = _test_deps_impl,
        targets = {
            "importjar": name + "/import-jar",
            "lib": name + "/lib",
        },
    )

def _test_deps_impl(env, targets):
    env.expect.that_target(targets.importjar).default_outputs().contains_exactly([
        "{package}/import.jar",
    ])

    assert_import_compilation_args = java_info_subject.from_target(env, targets.importjar).compilation_args()
    assert_import_compilation_args.transitive_compile_time_jars().contains_exactly([
        "{package}/_ijar/test_deps/import-jar/{package}/import-ijar.jar",
        "{package}/_ijar/test_deps/exportjar/{package}/exportjar-ijar.jar",
        "{package}/_ijar/test_deps/depjar/{package}/depjar-ijar.jar",
    ])
    assert_import_compilation_args.transitive_runtime_jars().contains_exactly([
        "{package}/import.jar",
        "{package}/exportjar.jar",
        "{package}/depjar.jar",
    ])
    assert_import_compilation_args.compile_jars().contains_exactly([
        "{package}/_ijar/test_deps/import-jar/{package}/import-ijar.jar",
        "{package}/_ijar/test_deps/exportjar/{package}/exportjar-ijar.jar",
    ])

    assert_lib_compilation_info = java_info_subject.from_target(env, targets.lib).compilation_info()
    assert_lib_compilation_info.compilation_classpath().contains_exactly([
        "{package}/_ijar/test_deps/import-jar/{package}/import-ijar.jar",
        "{package}/_ijar/test_deps/exportjar/{package}/exportjar-ijar.jar",
        "{package}/_ijar/test_deps/depjar/{package}/depjar-ijar.jar",
    ])
    assert_lib_compilation_info.runtime_classpath().contains_exactly([
        "{package}/lib{name}.jar",
        "{package}/import.jar",
        "{package}/exportjar.jar",
        "{package}/depjar.jar",
    ])

# Regression test for b/262751943.
def _test_commandline_contains_target_label(name):
    util.helper_target(
        java_import,
        name = name + "/java_imp",
        jars = ["import.jar"],
    )

    analysis_test(
        name = name,
        impl = _test_commandline_contains_target_label_impl,
        target = name + "/java_imp",
    )

def _test_commandline_contains_target_label_impl(env, target):
    compiled_artifact = target[JavaInfo].compile_jars.to_list()[0].short_path
    assert_action = env.expect.that_target(target).action_generating(compiled_artifact)

    assert_action.contains_flag_values([
        ("--target_label", "//{package}:{name}"),
    ])

# Regression test for b/5868388.
def _test_java_library_allows_import_in_deps(name):
    util.helper_target(
        java_import,
        name = name + "/libraryjar",
        jars = ["library.jar"],
    )
    util.helper_target(
        java_library,
        name = name + "/javalib",
        srcs = ["Other.java"],
        exports = [name + "/libraryjar"],
    )

    analysis_test(
        name = name,
        impl = _test_java_library_allows_import_in_deps_impl,
        target = name + "/javalib",
    )

def _test_java_library_allows_import_in_deps_impl(_env, _target):
    pass  # no errors

def _test_module_flags(name):
    if not bazel_features.java.java_info_constructor_module_flags:
        # exit early because this test case would be a loading phase error otherwise
        always_passes(name)
        return

    util.helper_target(
        java_library,
        name = name + "/lib",
        srcs = ["Main.java"],
        deps = [name + "/import-jar"],
    )
    util.helper_target(
        java_import,
        name = name + "/import-jar",
        jars = ["import.jar"],
        exports = [name + "/exportjar"],
        deps = [name + "/depjar"],
    )
    util.helper_target(
        java_import,
        name = name + "/depjar",
        add_exports = ["java.base/java.lang"],
        jars = ["depjar.jar"],
    )
    util.helper_target(
        java_import,
        name = name + "/exportjar",
        add_opens = ["java.base/java.util"],
        jars = ["exportjar.jar"],
    )

    analysis_test(
        name = name,
        impl = _test_module_flags_impl,
        targets = {
            "importjar": name + "/import-jar",
            "lib": name + "/lib",
        },
    )

def _test_module_flags_impl(env, targets):
    assert_import_module_flags = java_info_subject.from_target(env, targets.importjar).module_flags()
    assert_import_module_flags.add_exports().contains_exactly(["java.base/java.lang"])
    assert_import_module_flags.add_opens().contains_exactly(["java.base/java.util"])

    assert_lib_module_flags = java_info_subject.from_target(env, targets.lib).module_flags()
    assert_lib_module_flags.add_exports().contains_exactly(["java.base/java.lang"])
    assert_lib_module_flags.add_opens().contains_exactly(["java.base/java.util"])

def _test_src_jars(name):
    util.helper_target(
        java_import,
        name = name + "/libraryjar_with_srcjar",
        jars = ["import.jar"],
        srcjar = "library.srcjar",
    )

    analysis_test(
        name = name,
        impl = _test_src_jars_impl,
        target = name + "/libraryjar_with_srcjar",
    )

def _test_src_jars_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)
    assert_java_info.outputs().source_output_jars().contains_exactly([
        "{package}/library.srcjar",
    ])

def _test_from_genrule(name):
    target_name = name + "/library-jar"
    util.helper_target(
        native.genrule,
        name = target_name + "/generated_jar",
        outs = [target_name + "/generated.jar"],
        cmd = "",
    )
    util.helper_target(
        native.genrule,
        name = target_name + "/generated_src_jar",
        outs = [target_name + "/generated.srcjar"],
        cmd = "",
    )
    util.helper_target(
        java_import,
        name = target_name + "/libraryjar",
        jars = ["library.jar"],
    )
    util.helper_target(
        java_import,
        name = target_name,
        jars = [target_name + "/generated_jar"],
        srcjar = target_name + "/generated.srcjar",
        exports = [target_name + "/libraryjar"],
    )

    analysis_test(
        name = name,
        impl = _test_from_genrule_impl,
        targets = {
            "lib": target_name,
            "gen": target_name + "/generated_jar",
        },
    )

def _test_from_genrule_impl(env, targets):
    assert_compilation_args = java_info_subject.from_target(env, targets.lib).compilation_args()
    assert_compilation_args.transitive_compile_time_jars().contains_exactly([
        "{package}/_ijar/{name}/{package}/{name}/generated-ijar.jar",
        "{package}/_ijar/{name}/libraryjar/{package}/library-ijar.jar",
    ])
    assert_compilation_args.transitive_runtime_jars().contains_exactly([
        "{package}/library.jar",
        "{package}/{name}/generated.jar",
    ])

    jar = targets.lib[JavaInfo].transitive_runtime_jars.to_list()[0].short_path
    env.expect.that_target(targets.gen).action_generating(jar).mnemonic().equals("Genrule")

# Regression test for b/13936397: don't flatten transitive dependencies into direct deps.
def _test_transitive_dependencies(name):
    target_name = name + "/javalib2"
    util.helper_target(
        java_import,
        name = target_name + "/libraryjar",
        jars = ["library.jar"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/lib",
        srcs = ["Lib.java"],
        deps = [target_name + "/libraryjar"],
    )
    util.helper_target(
        java_import,
        name = target_name + "/library2-jar",
        jars = ["library2.jar"],
        exports = [target_name + "/lib"],
    )
    util.helper_target(
        java_library,
        name = target_name,
        srcs = ["Other.java"],
        deps = [target_name + "/library2-jar"],
    )

    analysis_test(
        name = name,
        impl = _test_transitive_dependencies_impl,
        target = target_name,
    )

def _test_transitive_dependencies_impl(env, target):
    assert_javac_action = javac_action_subject.of(env, target, "{package}/lib{name}.jar")

    # Direct jars should NOT include libraryjar-ijar.jar
    assert_javac_action.direct_dependencies().contains_exactly([
        "{bin_path}/{package}/_ijar/{name}/library2-jar/{package}/library2-ijar.jar",
        "{bin_path}/{package}/lib{name}/lib-hjar.jar",
    ])

def _test_exposes_java_provider(name):
    util.helper_target(
        java_import,
        name = name + "/libraryjar",
        jars = ["library.jar"],
    )

    analysis_test(
        name = name,
        impl = _test_exposes_java_provider_impl,
        target = name + "/libraryjar",
    )

def _test_exposes_java_provider_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)
    assert_java_info.compilation_args().transitive_runtime_jars().contains_exactly([
        "{package}/library.jar",
    ])

def _test_jars_allowed_in_srcjar(name):
    util.helper_target(
        java_import,
        name = name + "/library",
        jars = ["somelib.jar"],
        srcjar = "somelib-src.jar",
    )

    analysis_test(
        name = name,
        impl = _test_jars_allowed_in_srcjar_impl,
        target = name + "/library",
    )

def _test_jars_allowed_in_srcjar_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)
    assert_java_info.outputs().source_output_jars().contains_exactly([
        "{package}/somelib-src.jar",
    ])

def _test_permits_empty_jars_with_flag(name):
    if not bazel_features.rules.analysis_tests_can_transition_on_experimental_incompatible_flags:
        # exit early because this test case would be a loading phase error otherwise
        always_passes(name)
        return

    util.helper_target(
        java_import,
        name = name + "/rule",
        jars = [],
    )

    analysis_test(
        name = name,
        impl = _test_permits_empty_jars_with_flag_impl,
        target = name + "/rule",
        config_settings = {
            "//command_line_option:incompatible_disallow_java_import_empty_jars": False,
        },
    )

def _test_permits_empty_jars_with_flag_impl(_env, _target):
    pass

def _test_disallows_empty_jars(name):
    if not bazel_features.rules.analysis_tests_can_transition_on_experimental_incompatible_flags:
        # exit early because this test case would be a loading phase error otherwise
        always_passes(name)
        return

    util.helper_target(
        java_import,
        name = name + "/rule",
        jars = [],
    )

    analysis_test(
        name = name,
        impl = _test_disallows_empty_jars_impl,
        target = name + "/rule",
        config_settings = {
            "//command_line_option:incompatible_disallow_java_import_empty_jars": True,
        },
        expect_failure = True,
    )

def _test_disallows_empty_jars_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("empty java_import.jars is no longer supported"),
    )

def _test_disallows_files_in_exports(name):
    util.helper_target(
        java_import,
        name = name + "/rule",
        jars = ["good.jar"],
        # we can't create scratch files, so just use one that we know has a label
        exports = ["BUILD"],
    )

    analysis_test(
        name = name,
        impl = _test_disallows_files_in_exports_impl,
        target = name + "/rule",
        expect_failure = True,
    )

def _test_disallows_files_in_exports_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("source file * is misplaced here (expected no files)"),
    )

def _test_disallows_arbitrary_files(name):
    util.helper_target(
        java_import,
        name = name + "/rule",
        jars = ["not-a-jar.txt"],
    )

    analysis_test(
        name = name,
        impl = _test_disallows_arbitrary_files_impl,
        target = name + "/rule",
        expect_failure = True,
    )

def _test_disallows_arbitrary_files_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("file '*:not-a-jar.txt' is misplaced here (expected .jar)"),
    )

def _test_disallows_arbitrary_files_from_genrule(name):
    util.helper_target(
        native.genrule,
        name = name + "/gen",
        outs = ["not-a-jar.txt"],
        cmd = "",
    )
    util.helper_target(
        java_import,
        name = name + "/rule",
        jars = [name + "/gen"],
    )

    analysis_test(
        name = name,
        impl = _test_disallows_arbitrary_files_from_genrule_impl,
        target = name + "/rule",
        expect_failure = True,
    )

def _test_disallows_arbitrary_files_from_genrule_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("'*/gen' does not produce any java_import jars files (expected .jar)"),
    )

def java_import_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_java_import_attributes,
            _test_simple,
            _test_with_java_library,
            _test_deps,
            _test_commandline_contains_target_label,
            _test_java_library_allows_import_in_deps,
            _test_module_flags,
            _test_src_jars,
            _test_from_genrule,
            _test_transitive_dependencies,
            _test_exposes_java_provider,
            _test_jars_allowed_in_srcjar,
            _test_permits_empty_jars_with_flag,
            _test_disallows_empty_jars,
            _test_disallows_files_in_exports,
            _test_disallows_arbitrary_files,
            _test_disallows_arbitrary_files_from_genrule,
        ],
    )
