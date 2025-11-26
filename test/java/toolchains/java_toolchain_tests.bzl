"""Tests for the java_toolchain rule"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//java/toolchains:java_runtime.bzl", "java_runtime")
load("//java/toolchains:java_toolchain.bzl", "java_toolchain")
load("//test/java/testutil:java_toolchain_info_subject.bzl", "java_toolchain_info_subject")

def _declare_java_toolchain(*, name, **kwargs):
    if "java_runtime" not in kwargs:
        kwargs["java_runtime"] = name + "/runtime"
        java_runtime(name = name + "/runtime")
    util.helper_target(
        java_toolchain,
        name = name,
        genclass = kwargs.get("genclass", "default_genclass.jar"),
        jacocorunner = kwargs.get("jacocorunner", None),
        javabuilder = kwargs.get("javabuilder", "default_javabuilder.jar"),
        java_runtime = kwargs["java_runtime"],
        ijar = kwargs.get("ijar", "default_ijar.jar"),
        singlejar = kwargs.get("singlejar", "default_singlejar.jar"),
    )

def _test_jacocorunner(name):
    _declare_java_toolchain(
        name = name + "/java_toolchain",
        jacocorunner = "myjacocorunner.jar",
    )

    analysis_test(
        name = name,
        impl = _test_jacocorunner_impl,
        target = name + "/java_toolchain",
    )

def _test_jacocorunner_impl(env, target):
    assert_toolchain = java_toolchain_info_subject.from_target(env, target)

    assert_toolchain.jacocorunner().short_path_equals("{package}/myjacocorunner.jar")

def java_toolchain_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_jacocorunner,
        ],
    )
