"""Bazel tests for java_common APIs"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//test/java/testutil:rules/custom_java_info_rule.bzl", "custom_java_info_rule")

def _test_java_common_pack_sources_with_external_resource(name):
    util.helper_target(
        custom_java_info_rule,
        name = name + "/custom",
        output_jar = name + "/custom.jar",
        sources = [
            ":InternalLib.java",
            "@other_repo//:ExternalLib.java",
        ],
        pack_sources = True,
    )

    analysis_test(
        name = name,
        impl = _test_java_common_pack_sources_with_external_resource_impl,
        target = name + "/custom",
        # Bazel 7 names external repos differently
        attr_values = {"tags": ["min_bazel_8"]},
    )

def _test_java_common_pack_sources_with_external_resource_impl(env, target):
    assert_that_action = env.expect.that_target(target).action_generating("{package}/{name}-src.jar")
    assert_that_action.argv().contains_at_least([
        "--resources",
        "{package}/InternalLib.java:bazel/common/InternalLib.java",
        "external/+test_repositories_ext+other_repo/ExternalLib.java:ExternalLib.java",
    ]).in_order()

def java_common_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_java_common_pack_sources_with_external_resource,
        ],
    )
