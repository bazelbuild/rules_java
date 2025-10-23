"""Tests for the java_import rule"""

load("@bazel_features//:features.bzl", "bazel_features")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_binary.bzl", "java_binary")
load("//java:java_import.bzl", "java_import")
load("//java:java_library.bzl", "java_library")
load("//java/common:java_info.bzl", "JavaInfo")
load("//java/common:proguard_spec_info.bzl", "ProguardSpecInfo")
load("//test/java/testutil:helper.bzl", "always_passes")
load("//test/java/testutil:java_info_subject.bzl", "java_info_subject")
load("//test/java/testutil:javac_action_subject.bzl", "javac_action_subject")
load("//test/java/testutil:rules/custom_library.bzl", "custom_library")
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

def _test_srcjar_added_to_validation_output_group(name):
    util.helper_target(
        java_import,
        name = name + "/libraryjar_with_srcjar",
        jars = ["import.jar"],
        srcjar = "library.srcjar",
    )

    analysis_test(
        name = name,
        impl = _test_srcjar_added_to_validation_output_group_impl,
        target = name + "/libraryjar_with_srcjar",
        # Starlark rules are only used with Bazel 8 onwards.
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _test_srcjar_added_to_validation_output_group_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)
    assert_java_info.outputs().source_output_jars().contains_exactly([
        "{package}/library.srcjar",
    ])

    # Check that the srcjar is in the _validation output group.
    env.expect.that_target(target).output_group("_validation").contains_at_least([
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
        expect_failure = True,
    )

def _test_disallows_empty_jars_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("empty java_import.jars is not supported"),
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

def _test_disallows_java_rules_in_jars(name):
    util.helper_target(
        java_library,
        name = name + "/lib",
        srcs = ["JavaLib.java"],
    )
    util.helper_target(
        java_import,
        name = name + "/rule",
        jars = [name + "/lib"],
    )

    analysis_test(
        name = name,
        impl = _test_disallows_java_rules_in_jars_impl,
        target = name + "/rule",
        expect_failure = True,
    )

def _test_disallows_java_rules_in_jars_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.any(
            matching.str_matches("'jars' attribute cannot contain labels of Java targets"),
            matching.str_matches("should not refer to Java rules"),  # Bazel 6
        ),
    )

def _test_disallows_exports_with_flag(name):
    if not bazel_features.rules.analysis_tests_can_transition_on_experimental_incompatible_flags:
        # exit early because this test case would be a loading phase error otherwise
        always_passes(name)
        return

    util.helper_target(
        java_library,
        name = name + "/dep",
        srcs = ["Dep.java"],
    )
    util.helper_target(
        java_import,
        name = name + "/rule",
        jars = ["dummy.jar"],
        exports = [name + "/dep"],
    )

    analysis_test(
        name = name,
        impl = _test_disallows_exports_with_flag_impl,
        target = name + "/rule",
        expect_failure = True,
        config_settings = {
            "//command_line_option:incompatible_disallow_java_import_exports": True,
        },
    )

def _test_disallows_exports_with_flag_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("java_import.exports is no longer supported; use java_import.deps instead"),
    )

def _test_ijar_can_be_disabled(name):
    util.helper_target(
        java_library,
        name = name + "/a",
        srcs = ["A.java"],
        deps = [name + "/b"],
    )
    util.helper_target(
        java_import,
        name = name + "/b",
        jars = ["b.jar"],
    )

    analysis_test(
        name = name,
        impl = _test_ijar_can_be_disabled_impl,
        target = name + "/a",
        config_settings = {
            "//command_line_option:use_ijars": False,
        },
    )

def _test_ijar_can_be_disabled_impl(env, target):
    assert_jars = java_info_subject.from_target(env, target).compilation_args().transitive_compile_time_jars()
    assert_jars.contains_exactly([
        "{package}/lib{name}-hjar.jar",
        "{package}/b.jar",
    ])

def _test_duplicate_jars_through_filegroup(name):
    util.helper_target(
        native.filegroup,
        name = name + "/jars",
        srcs = ["a.jar"],
    )
    util.helper_target(
        java_import,
        name = name + "/ji-with-dupe-through-fg",
        jars = ["a.jar", name + "/jars"],
    )

    analysis_test(
        name = name,
        impl = _test_duplicate_jars_through_filegroup_impl,
        target = name + "/ji-with-dupe-through-fg",
        expect_failure = True,
    )

def _test_duplicate_jars_through_filegroup_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.any(
            matching.str_matches("in jars attribute of java_import rule */ji-with-dupe-through-fg: a.jar is a duplicate"),
            matching.str_matches("a.jar is a duplicate"),  # Bazel 6
        ),
    )

def _test_runtime_deps_are_not_on_classpath(name):
    target_name = name + "/depends_on_runtimedep"
    util.helper_target(
        java_import,
        name = target_name + "/import_dep",
        jars = ["import_compile.jar"],
        runtime_deps = ["import_runtime.jar"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/library_dep",
        srcs = ["library_compile.java"],
    )
    util.helper_target(
        java_library,
        name = target_name,
        srcs = ["dummy.java"],
        deps = [
            target_name + "/import_dep",
            target_name + "/library_dep",
        ],
    )

    analysis_test(
        name = name,
        impl = _test_runtime_deps_are_not_on_classpath_impl,
        target = name + "/depends_on_runtimedep",
    )

def _test_runtime_deps_are_not_on_classpath_impl(env, target):
    assert_javac = javac_action_subject.of(env, target, "{package}/lib{name}.jar")

    # Direct jars should NOT include import_runtime.jar
    assert_javac.direct_dependencies().contains_exactly([
        "{bin_path}/{package}/_ijar/{name}/import_dep/{package}/import_compile-ijar.jar",
        "{bin_path}/{package}/lib{name}/library_dep-hjar.jar",
    ])

def _test_exports_runfile_collection(name):
    target_name = name + "/tool"
    util.helper_target(
        java_import,
        name = target_name + "/other_lib",
        data = ["foo.txt"],
        jars = ["other.jar"],
    )
    util.helper_target(
        java_import,
        name = target_name + "/lib",
        jars = ["lib.jar"],
        exports = [target_name + "/other_lib"],
    )
    util.helper_target(
        java_binary,
        name = target_name,
        data = [target_name + "/lib"],
        main_class = "com.google.exports.Launcher",
    )

    analysis_test(
        name = name,
        impl = _test_exports_runfile_collection_impl,
        target = target_name,
    )

def _test_exports_runfile_collection_impl(env, target):
    assert_runfiles = env.expect.that_target(target).runfiles()
    assert_runfiles.contains_at_least_predicates([
        matching.str_matches("/lib.jar"),
        matching.str_matches("/other.jar"),
        matching.str_matches("/foo.txt"),
    ])

def _test_transitive_source_jars(name):
    target_name = name + "/a"
    util.helper_target(
        java_import,
        name = target_name,
        jars = ["dummy.jar"],
        srcjar = "dummy-src.jar",
        exports = [target_name + "/b"],
    )
    util.helper_target(
        java_library,
        name = target_name + "/b",
        srcs = ["B.java"],
    )

    analysis_test(
        name = name,
        impl = _test_transitive_source_jars_impl,
        target = target_name,
    )

def _test_transitive_source_jars_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)
    assert_java_info.transitive_source_jars().contains_exactly([
        "{package}/dummy-src.jar",
        "{package}/lib{name}/b-src.jar",
    ])

def _test_neverlink_is_populated(name):
    target_name = name + "/jar"
    util.helper_target(
        java_library,
        name = target_name + "/lib",
    )
    util.helper_target(
        java_import,
        name = target_name,
        jars = ["dummy.jar"],
        neverlink = 1,
        exports = [target_name + "/lib"],
    )

    analysis_test(
        name = name,
        impl = _test_neverlink_is_populated_impl,
        target = target_name,
        # in Bazel 6, JavaInfo._neverlink isn't exposed to Starlark
        attr_values = {"tags": ["min_bazel_7"]},
    )

def _test_neverlink_is_populated_impl(env, target):
    env.expect.that_bool(target[JavaInfo]._neverlink).equals(True)

def _test_transitive_proguard_specs_are_validated(name):
    target_name = name + "/lib"
    util.helper_target(
        java_import,
        name = target_name + "/transitive",
        constraints = ["android"],
        jars = ["Transitive.jar"],
        proguard_specs = ["transitive.pro"],
    )
    util.helper_target(
        java_import,
        name = target_name,
        constraints = ["android"],
        jars = ["Lib.jar"],
        exports = [target_name + "/transitive"],
    )

    analysis_test(
        name = name,
        impl = _test_transitive_proguard_specs_are_validated_impl,
        targets = {
            "lib": target_name,
            "dep": target_name + "/transitive",
        },
    )

def _test_transitive_proguard_specs_are_validated_impl(env, targets):
    proguard_out = "{package}/validated_proguard/{name}/transitive/{package}/transitive.pro_valid"
    env.expect.that_target(targets.lib).output_group(
        "_hidden_top_level_INTERNAL_",
    ).contains(proguard_out)
    env.expect.that_target(targets.dep).action_named("ValidateProguard").inputs().contains(
        "{package}/transitive.pro",
    )

def _test_proguard_specs_are_validated(name):
    target_name = name + "/lib"
    util.helper_target(
        java_import,
        name = target_name,
        constraints = ["android"],
        jars = ["Lib.jar"],
        proguard_specs = ["lib.pro"],
    )

    analysis_test(
        name = name,
        impl = _test_proguard_specs_are_validated_impl,
        target = target_name,
    )

def _test_proguard_specs_are_validated_impl(env, target):
    proguard_out = "{package}/validated_proguard/{name}/{package}/lib.pro_valid"
    env.expect.that_target(target).output_group(
        "_hidden_top_level_INTERNAL_",
    ).contains(proguard_out)
    env.expect.that_target(target).action_named("ValidateProguard").inputs().contains(
        "{package}/lib.pro",
    )

def _test_transitive_proguard_specs_are_exported(name):
    target_name = name + "/lib"
    util.helper_target(
        java_import,
        name = target_name + "/export",
        constraints = ["android"],
        jars = ["Export.jar"],
        proguard_specs = ["export.pro"],
    )
    util.helper_target(
        java_import,
        name = target_name + "/runtime_dep",
        constraints = ["android"],
        jars = ["RuntimeDep.jar"],
        proguard_specs = ["runtime_dep.pro"],
    )
    util.helper_target(
        java_import,
        name = target_name,
        constraints = ["android"],
        jars = ["Lib.jar"],
        proguard_specs = ["lib.pro"],
        exports = [target_name + "/export"],
        runtime_deps = [target_name + "/runtime_dep"],
    )

    analysis_test(
        name = name,
        impl = _test_transitive_proguard_specs_are_exported_impl,
        target = target_name,
        # Before Bazel 8, native rules use the native ProguardSpecProvider
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _test_transitive_proguard_specs_are_exported_impl(env, target):
    spec_basenames = [f.basename for f in target[ProguardSpecInfo].specs.to_list()]
    env.expect.that_collection(spec_basenames).contains_exactly([
        "lib.pro_valid",
        "export.pro_valid",
        "runtime_dep.pro_valid",
    ])

def _test_src_jars_output_groups(name):
    target_name = name + "/a"
    util.helper_target(
        java_import,
        name = target_name,
        jars = ["jar_a.jar"],
        srcjar = "src_jar_a.jar",
        deps = [target_name + "/b"],
    )
    util.helper_target(
        java_import,
        name = target_name + "/b",
        jars = ["jar_b.jar"],
        srcjar = "src_jar_b.jar",
    )

    analysis_test(
        name = name,
        impl = _test_src_jars_output_groups_impl,
        target = target_name,
    )

def _test_src_jars_output_groups_impl(env, target):
    env.expect.that_target(target).output_group("_source_jars").contains_exactly([
        "{package}/src_jar_a.jar",
    ])
    env.expect.that_target(target).output_group("_direct_source_jars").contains_exactly([
        "{package}/src_jar_a.jar",
    ])

def _test_with_custom_library(name):
    target_name = name + "/javalib"
    util.helper_target(
        java_library,
        name = target_name,
        srcs = ["MyClass.java"],
        deps = [target_name + "/foo"],
    )
    util.helper_target(
        java_import,
        name = target_name + "/foo",
        jars = ["foo.jar"],
        runtime_deps = [target_name + "/javacustomlib"],
    )
    util.helper_target(
        custom_library,
        name = target_name + "/javacustomlib",
        srcs = ["Other.java"],
    )

    analysis_test(
        name = name,
        impl = _test_with_custom_library_impl,
        target = target_name,
    )

def _test_with_custom_library_impl(env, target):
    assert_java_info = java_info_subject.from_target(env, target)
    assert_java_info.compilation_info().runtime_classpath_list().contains_exactly_predicates([
        matching.file_basename_equals("javalib.jar"),
        matching.file_basename_equals("foo.jar"),
        matching.file_basename_equals("javacustomlib.jar"),
    ]).in_order()

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
            _test_srcjar_added_to_validation_output_group,
            _test_from_genrule,
            _test_transitive_dependencies,
            _test_exposes_java_provider,
            _test_jars_allowed_in_srcjar,
            _test_disallows_empty_jars,
            _test_disallows_files_in_exports,
            _test_disallows_arbitrary_files,
            _test_disallows_arbitrary_files_from_genrule,
            _test_disallows_java_rules_in_jars,
            _test_disallows_exports_with_flag,
            _test_ijar_can_be_disabled,
            _test_duplicate_jars_through_filegroup,
            _test_runtime_deps_are_not_on_classpath,
            _test_exports_runfile_collection,
            _test_transitive_source_jars,
            _test_neverlink_is_populated,
            _test_transitive_proguard_specs_are_validated,
            _test_proguard_specs_are_validated,
            _test_transitive_proguard_specs_are_exported,
            _test_src_jars_output_groups,
            _test_with_custom_library,
        ],
    )
