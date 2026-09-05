"""Tests for the java_single_jar rule"""

load("@bazel_features//:features.bzl", "bazel_features")
load("@rules_testing//lib:analysis_test.bzl", _analysis_test = "analysis_test")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("@rules_testing//lib/private:util.bzl", "get_test_name_from_function")  # buildifier: disable=bzl-visibility
load("//java:java_binary.bzl", "java_binary")
load("//java:java_library.bzl", "java_library")
load("//java:java_single_jar.bzl", "java_single_jar")
load("//java/common:java_semantics.bzl", "semantics")

def _path_stripping_analysis_test(name, impl, config_settings = {}, **kwargs):
    if name.endswith("_off"):
        output_path_mode = "off"
    elif name.endswith("_strip"):
        output_path_mode = "strip"
    else:
        fail("expected test name to end with one of [_strip, _off]")

    # TODO: remove once Bazel 7 is no longer supported
    if bazel_features.rules.analysis_tests_can_transition_on_experimental_incompatible_flags:
        config_settings = config_settings | {
            "//command_line_option:experimental_output_paths": output_path_mode,
        }

    _analysis_test(
        name = name,
        impl = lambda env, target: impl(env, target, output_path_mode),
        config_settings = config_settings,
        **kwargs
    )

def _path_stripping_test_suite(name, *, tests = [], test_kwargs = {}):
    """Expands each test into 'off' and 'strip' output path mode variants"""
    test_targets = []
    for suffix in ["_off", "_strip"]:
        for setup_func in tests:
            test_name = get_test_name_from_function(setup_func) + suffix
            setup_func(name = test_name, **test_kwargs)
            test_targets.append(test_name)
    native.test_suite(
        name = name,
        tests = test_targets,
    )

def _get_bindir_for_output_path_mode(output_path_mode):
    # TODO: remove once Bazel 7 is no longer supported
    if not bazel_features.rules.analysis_tests_can_transition_on_experimental_incompatible_flags:
        return "{bindir}"

    if output_path_mode == "off":
        return "{bindir}"
    elif output_path_mode == "strip":
        return "{cfg_stripped_bindir}"
    fail("unexpected output path mode: " + output_path_mode)

def _test_java_single_jar_basic(name):
    util.helper_target(
        java_single_jar,
        name = name + "/jar",
        deps = ["1.jar", "2.jar"],
    )

    _path_stripping_analysis_test(
        name = name,
        impl = _test_java_single_jar_basic_impl,
        target = name + "/jar",
    )

def _test_java_single_jar_basic_impl(env, target, output_path_mode):
    assert_that_action = env.expect.that_target(target).action_named("JavaSingleJar")
    assert_that_action.argv().contains_at_least([
        "--sources",
        "{package}/1.jar",
        "{package}/2.jar",
        "--output",
        _get_bindir_for_output_path_mode(output_path_mode) + "/{package}/{name}.jar",
        "--normalize",
        "--dont_change_compression",
        "--exclude_build_data",
        "--multi_release",
    ]).in_order()

def _test_java_single_jar_force_enable_stamping(name):
    util.helper_target(
        java_single_jar,
        name = name + "/jar",
        stamp = 1,
        exclude_build_data = False,
    )

    _path_stripping_analysis_test(
        name = name,
        impl = _test_java_single_jar_force_enable_stamping_impl,
        targets = {
            "jar": name + "/jar",
            "build_info": semantics.BUILD_INFO_TRANSLATOR_LABEL,
        },
    )

def _assert_build_info_files(env, jar_target, build_info_files, output_path_mode):
    bin_dir = _get_bindir_for_output_path_mode(output_path_mode)
    assert_that_action = env.expect.that_target(jar_target).action_named("JavaSingleJar")
    assert_that_action.contains_flag_values([
        ("--build_info_file", bin_dir + f.path[len(f.root.path):])
        for f in build_info_files.to_list()
    ])

def _test_java_single_jar_force_enable_stamping_impl(env, targets, output_path_mode):
    _assert_build_info_files(
        env,
        targets.jar,
        targets.build_info[OutputGroupInfo].non_redacted_build_info_files,
        output_path_mode,
    )

def _test_java_single_jar_force_disable_stamping(name):
    util.helper_target(
        java_single_jar,
        name = name + "/jar",
        stamp = 0,
        exclude_build_data = False,
    )

    _path_stripping_analysis_test(
        name = name,
        impl = _test_java_single_jar_force_disable_stamping_impl,
        targets = {
            "jar": name + "/jar",
            "build_info": semantics.BUILD_INFO_TRANSLATOR_LABEL,
        },
    )

def _test_java_single_jar_force_disable_stamping_impl(env, targets, output_path_mode):
    _assert_build_info_files(
        env,
        targets.jar,
        targets.build_info[OutputGroupInfo].redacted_build_info_files,
        output_path_mode,
    )

def _test_java_single_jar_stamping_enabled_build_data_excluded_fails(name):
    util.helper_target(
        java_single_jar,
        name = name + "/jar",
        stamp = 1,
        exclude_build_data = True,
    )

    _analysis_test(
        name = name,
        impl = _test_java_single_jar_stamping_enabled_build_data_excluded_fails_impl,
        target = name + "/jar",
        expect_failure = True,
    )

def _test_java_single_jar_stamping_enabled_build_data_excluded_fails_impl(env, target):
    env.expect.that_target(target).failures().contains_predicate(
        matching.str_matches("Enabling stamping has not effect with exclude_build_data enabled"),
    )

def _test_java_single_jar_stamp_attr_auto_stamp_flag_enabled(name):
    util.helper_target(
        java_single_jar,
        name = name + "/jar",
        stamp = -1,
        exclude_build_data = False,
    )

    _path_stripping_analysis_test(
        name = name,
        impl = _test_java_single_jar_stamp_attr_auto_stamp_flag_enabled_impl,
        targets = {
            "jar": name + "/jar",
            "build_info": semantics.BUILD_INFO_TRANSLATOR_LABEL,
        },
        config_settings = {
            "//command_line_option:stamp": True,
        },
    )

def _test_java_single_jar_stamp_attr_auto_stamp_flag_enabled_impl(env, targets, output_path_mode):
    _assert_build_info_files(
        env,
        targets.jar,
        targets.build_info[OutputGroupInfo].non_redacted_build_info_files,
        output_path_mode,
    )

def _test_java_single_jar_stamp_attr_auto_stamp_flag_disabled(name):
    util.helper_target(
        java_single_jar,
        name = name + "/jar",
        stamp = -1,
        exclude_build_data = False,
    )

    _path_stripping_analysis_test(
        name = name,
        impl = _test_java_single_jar_stamp_attr_auto_stamp_flag_disabled_impl,
        targets = {
            "jar": name + "/jar",
            "build_info": semantics.BUILD_INFO_TRANSLATOR_LABEL,
        },
        config_settings = {
            "//command_line_option:stamp": False,
        },
    )

def _test_java_single_jar_stamp_attr_auto_stamp_flag_disabled_impl(env, targets, output_path_mode):
    _assert_build_info_files(
        env,
        targets.jar,
        targets.build_info[OutputGroupInfo].redacted_build_info_files,
        output_path_mode,
    )

def _test_java_single_jar_deploy_manifest_lines(name):
    util.helper_target(
        java_single_jar,
        name = name + "/jar",
        deps = ["1.jar"],
        deploy_manifest_lines = [
            "Manifest-Entry-A: valueA",
            "Manifest-Entry-B: line1,\n line2",
        ],
    )

    _analysis_test(
        name = name,
        impl = _test_java_single_jar_deploy_manifest_lines_impl,
        target = name + "/jar",
    )

def _test_java_single_jar_deploy_manifest_lines_impl(env, target):
    assert_that_action = env.expect.that_target(target).action_named("JavaSingleJar")
    assert_that_action.argv().contains_at_least([
        "--deploy_manifest_lines",
        "Manifest-Entry-A: valueA",
        "Manifest-Entry-B: line1,\n line2",
    ])

def _test_java_single_jar_transitive_deploy_env(name):
    util.helper_target(
        java_library,
        name = name + "_lib_a",
        srcs = ["A.java"],
    )
    util.helper_target(
        java_library,
        name = name + "_lib_b",
        srcs = ["B.java"],
    )
    util.helper_target(
        java_library,
        name = name + "_lib_c",
        srcs = ["C.java"],
    )
    util.helper_target(
        java_single_jar,
        name = name + "_env1",
        deps = [name + "_lib_a"],
    )
    util.helper_target(
        java_single_jar,
        name = name + "_inner",
        deps = [name + "_lib_a", name + "_lib_b"],
        deploy_env = [name + "_env1"],
    )
    util.helper_target(
        java_single_jar,
        name = name + "_outer",
        deps = [name + "_lib_a", name + "_lib_b", name + "_lib_c"],
        deploy_env = [name + "_inner"],
    )

    _path_stripping_analysis_test(
        name = name,
        impl = _test_java_single_jar_transitive_deploy_env_impl,
        target = name + "_outer",
    )

def _test_java_single_jar_transitive_deploy_env_impl(env, target, output_path_mode):
    bin_dir = _get_bindir_for_output_path_mode(output_path_mode)
    assert_that_action = env.expect.that_target(target).action_named("JavaSingleJar")
    assert_that_action.argv().contains_at_least([
        "--sources",
        bin_dir + "/{package}/lib{test_name}_lib_c.jar",
        "--output",
    ])
    assert_that_action.argv().not_contains(bin_dir + "/{package}/lib{test_name}_lib_a.jar")
    assert_that_action.argv().not_contains(bin_dir + "/{package}/lib{test_name}_lib_b.jar")

def _test_java_binary_deploy_env_with_java_single_jar(name):
    util.helper_target(
        java_library,
        name = name + "_lib_a",
        srcs = ["A.java"],
    )
    util.helper_target(
        java_library,
        name = name + "_lib_b",
        srcs = ["B.java"],
    )
    util.helper_target(
        java_single_jar,
        name = name + "_single_jar",
        deps = [name + "_lib_a"],
    )
    util.helper_target(
        java_binary,
        name = name + "_bin",
        main_class = "Main",
        runtime_deps = [name + "_lib_a", name + "_lib_b"],
        deploy_env = [name + "_single_jar"],
    )

    _analysis_test(
        name = name,
        attr_values = {"tags": ["min_bazel_8"]},  # the deploy jar was created by a separate rule in Bazel 7
        impl = _test_java_binary_deploy_env_with_java_single_jar_impl,
        target = name + "_bin",
    )

def _test_java_binary_deploy_env_with_java_single_jar_impl(env, target):
    assert_that_action = env.expect.that_target(target).action_named("JavaDeployJar")
    assert_that_action.inputs().contains_at_least([
        "{package}/lib{test_name}_lib_b.jar",
    ])
    assert_that_action.inputs().not_contains("{package}/lib{test_name}_lib_a.jar")

def java_single_jar_tests(name):
    _path_stripping_test_suite(
        name = name,
        tests = [
            _test_java_single_jar_basic,
            _test_java_single_jar_deploy_manifest_lines,
            _test_java_single_jar_force_enable_stamping,
            _test_java_single_jar_force_disable_stamping,
            _test_java_single_jar_stamping_enabled_build_data_excluded_fails,
            _test_java_single_jar_stamp_attr_auto_stamp_flag_enabled,
            _test_java_single_jar_stamp_attr_auto_stamp_flag_disabled,
            _test_java_single_jar_transitive_deploy_env,
            _test_java_binary_deploy_env_with_java_single_jar,
        ],
    )
