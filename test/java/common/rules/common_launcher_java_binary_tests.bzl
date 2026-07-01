"""Parameterized tests for java_binary with --java_launcher"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//java:java_binary.bzl", "java_binary")
load("//java:java_library.bzl", "java_library")
load("//test/java/testutil:artifact_closure.bzl", "artifact_closure")
load("//test/java/testutil:binary_executable_subject.bzl", "expect_that_executable")
load("//test/java/testutil:mock_java_toolchain.bzl", "mock_java_toolchain")

def _test_java_binary_non_executable_rule_outputs(name):
    util.helper_target(
        java_binary,
        name = name + "/test_app_noexec",
        srcs = ["InputFile.java"],
        create_executable = 0,
    )

    analysis_test(
        name = name,
        impl = _test_java_binary_non_executable_rule_outputs_impl,
        target = name + "/test_app_noexec",
    )

def _test_java_binary_non_executable_rule_outputs_impl(env, target):
    env.expect.that_target(target).default_outputs().contains_exactly([
        "{package}/{name}.jar",
    ])

def _test_java_binary_resources_only(name):
    util.helper_target(
        java_binary,
        name = name + "/bin",
        main_class = "doesnotmatter",
        resources = [
            "someFile.xml",
            "someOtherFile.xml",
        ],
        runtime_deps = [name + "/lib"],
    )
    util.helper_target(
        java_library,
        name = name + "/lib",
        srcs = ["Xml.java"],
    )
    util.helper_target(
        mock_java_toolchain,
        name = name + "/toolchain",
    )

    analysis_test(
        name = name,
        attr_values = {"tags": ["min_bazel_8"]},  # the deploy jar was created by a separate rule in Bazel 7
        config_settings = {
            "//command_line_option:extra_toolchains": [Label(name + "/toolchain")],
        },
        extra_target_under_test_aspects = [artifact_closure.aspect],
        impl = _test_java_binary_resources_only_impl,
        target = name + "/bin",
    )

def _test_java_binary_resources_only_impl(env, target):
    deploy_jar = env.expect.that_target(target).action_named("JavaDeployJar").actual.outputs.to_list()[0]
    env.expect.that_file(deploy_jar).basename().equals("bin_deploy.jar")

    # check that we do have a jar file build for bin, although
    # it does not contain any source files
    artifact_closure.of_target(env, target, extensions = ["jar"], initial = deploy_jar).contains_exactly([
        "{package}/JavaBuilder_deploy.jar",
        "{package}/lib{test_name}/lib.jar",
        "{package}/{test_name}/bin-class.jar",
        "{package}/{test_name}/bin.jar",
        "{package}/{test_name}/bin_deploy.jar",
    ])
    artifact_closure.of_target(env, target, extensions = ["xml"], initial = deploy_jar).contains_exactly([
        "{package}/someFile.xml",
        "{package}/someOtherFile.xml",
    ])

def _test_java_binary_deploy_jar_coverage_setup(name):
    util.helper_target(
        java_binary,
        name = name + "/app",
        main_class = "com.google.app",
    )

    analysis_test(
        name = name,
        attr_values = {"tags": ["min_bazel_8"]},  # the deploy jar was created by a separate rule in Bazel 7
        config_settings = {
            "//command_line_option:collect_code_coverage": True,
        },
        impl = _test_java_binary_deploy_jar_coverage_setup_impl,
        target = name + "/app",
    )

def _test_java_binary_deploy_jar_coverage_setup_impl(env, target):
    assert_that_action = env.expect.that_target(target).action_generating("{package}/{name}_deploy.jar")
    assert_that_action.argv().contains("Coverage-Main-Class: com.google.app")

def _test_java_binary_transitive_dependency_from_java_library(name):
    util.helper_target(
        java_binary,
        name = name + "/Binary",
        srcs = ["Binary.java"],
        deps = [name + "/somedep"],
    )
    util.helper_target(
        java_library,
        name = name + "/somedep",
        srcs = ["Dependency.java"],
        deps = [name + "/otherdep"],
    )
    util.helper_target(
        java_library,
        name = name + "/otherdep",
        srcs = ["OtherDependency.java"],
    )

    analysis_test(
        name = name,
        extra_target_under_test_aspects = [artifact_closure.aspect],
        impl = _test_java_binary_transitive_dependency_from_java_library_impl,
        target = name + "/Binary",
    )

def _test_java_binary_transitive_dependency_from_java_library_impl(env, target):
    artifact_closure.of_target(env, target, extensions = ["java"]).contains_exactly([
        "{package}/Binary.java",
        "{package}/Dependency.java",
        "{package}/OtherDependency.java",
    ])

def _test_java_binary_explicit_main_class(name):
    util.helper_target(
        java_binary,
        name = name + "/bin",
        main_class = "foo.bar.baz",
    )

    analysis_test(
        name = name,
        impl = _test_java_binary_explicit_main_class_impl,
        target = name + "/bin",
    )

def _test_java_binary_explicit_main_class_impl(env, target):
    expect_that_executable.of_target(env, target).java_start_class().equals(
        "foo.bar.baz",
    )

def java_binary_launcher_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_java_binary_non_executable_rule_outputs,
            _test_java_binary_resources_only,
            _test_java_binary_deploy_jar_coverage_setup,
            _test_java_binary_transitive_dependency_from_java_library,
            _test_java_binary_explicit_main_class,
        ],
    )
