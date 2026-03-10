"""Tests for the java_single_jar rule"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_single_jar.bzl", "java_single_jar")
load("//java/common:java_semantics.bzl", "semantics")

def _label_to_bin_path(label):
    segments = ["{bindir}"]
    if label.repo_name:
        segments.extend(["external", label.repo_name])
    segments.append(label.package)
    return "/".join(segments)

_BUILD_INFO_PATH = _label_to_bin_path(Label(semantics.BUILD_INFO_TRANSLATOR_LABEL))

def _test_java_single_jar_basic(name):
    util.helper_target(
        java_single_jar,
        name = name + "/jar",
        deps = ["1.jar", "2.jar"],
    )

    analysis_test(
        name = name,
        impl = _test_java_single_jar_basic_impl,
        target = name + "/jar",
    )

def _test_java_single_jar_basic_impl(env, target):
    assert_that_action = env.expect.that_target(target).action_named("JavaSingleJar")
    assert_that_action.argv().contains_at_least([
        "--sources",
        "{package}/1.jar",
        "{package}/2.jar",
        "--output",
        "{bindir}/{package}/{name}.jar",
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

    analysis_test(
        name = name,
        impl = _test_java_single_jar_force_enable_stamping_impl,
        target = name + "/jar",
    )

def _test_java_single_jar_force_enable_stamping_impl(env, target):
    assert_that_action = env.expect.that_target(target).action_named("JavaSingleJar")
    assert_that_action.contains_flag_values([
        ("--build_info_file", _BUILD_INFO_PATH + "/non_volatile_file.properties"),
        ("--build_info_file", _BUILD_INFO_PATH + "/volatile_file.properties"),
    ])

def _test_java_single_jar_force_disable_stamping(name):
    util.helper_target(
        java_single_jar,
        name = name + "/jar",
        stamp = 0,
        exclude_build_data = False,
    )

    analysis_test(
        name = name,
        impl = _test_java_single_jar_force_disable_stamping_impl,
        target = name + "/jar",
    )

def _test_java_single_jar_force_disable_stamping_impl(env, target):
    assert_that_action = env.expect.that_target(target).action_named("JavaSingleJar")
    assert_that_action.contains_flag_values([
        ("--build_info_file", _BUILD_INFO_PATH + "/redacted_file.properties"),
    ])

def _test_java_single_jar_stamping_enabled_build_data_excluded_fails(name):
    util.helper_target(
        java_single_jar,
        name = name + "/jar",
        stamp = 1,
        exclude_build_data = True,
    )

    analysis_test(
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

    analysis_test(
        name = name,
        impl = _test_java_single_jar_stamp_attr_auto_stamp_flag_enabled_impl,
        target = name + "/jar",
        config_settings = {
            "//command_line_option:stamp": True,
        },
    )

def _test_java_single_jar_stamp_attr_auto_stamp_flag_enabled_impl(env, target):
    assert_that_action = env.expect.that_target(target).action_named("JavaSingleJar")
    assert_that_action.contains_flag_values([
        ("--build_info_file", _BUILD_INFO_PATH + "/non_volatile_file.properties"),
        ("--build_info_file", _BUILD_INFO_PATH + "/volatile_file.properties"),
    ])

def _test_java_single_jar_stamp_attr_auto_stamp_flag_disabled(name):
    util.helper_target(
        java_single_jar,
        name = name + "/jar",
        stamp = -1,
        exclude_build_data = False,
    )

    analysis_test(
        name = name,
        impl = _test_java_single_jar_stamp_attr_auto_stamp_flag_disabled_impl,
        target = name + "/jar",
        config_settings = {
            "//command_line_option:stamp": False,
        },
    )

def _test_java_single_jar_stamp_attr_auto_stamp_flag_disabled_impl(env, target):
    assert_that_action = env.expect.that_target(target).action_named("JavaSingleJar")
    assert_that_action.contains_flag_values([
        ("--build_info_file", _BUILD_INFO_PATH + "/redacted_file.properties"),
    ])

def java_single_jar_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_java_single_jar_basic,
            _test_java_single_jar_force_enable_stamping,
            _test_java_single_jar_force_disable_stamping,
            _test_java_single_jar_stamping_enabled_build_data_excluded_fails,
            _test_java_single_jar_stamp_attr_auto_stamp_flag_enabled,
            _test_java_single_jar_stamp_attr_auto_stamp_flag_disabled,
        ],
    )
