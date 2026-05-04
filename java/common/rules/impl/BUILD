load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load(
    ":runfiles_group_support.bzl",
    "java_binary_runfiles_group_describer",
    "java_import_runfiles_group_describer",
    "java_library_runfiles_group_describer",
    "java_runtime_runfiles",
    "java_runtime_runfiles_group_describer",
)

package(
    default_applicable_licenses = ["@rules_java//:license"],
    default_visibility = ["//visibility:public"],
)

filegroup(
    name = "srcs",
    srcs = glob(["**"]),
    visibility = ["//java/common/rules:__pkg__"],
)

bzl_library(
    name = "impl",
    srcs = glob(
        ["*.bzl"],
        exclude = ["java_helper.bzl"],
    ),
    visibility = ["//java:__subpackages__"],
    deps = [
        ":java_helper_bzl",
        "//java/common:proguard_spec_info_bzl",
        "@rules_cc//cc:action_names_bzl",  # TODO: remove after https://github.com/bazelbuild/rules_cc/issues/913 is fixed
        "@rules_cc//cc/common:cc_helper_bzl",
        "@rules_runfiles_group//runfiles_group:lib",
    ],
)

bzl_library(
    name = "java_helper_bzl",
    srcs = ["java_helper.bzl"],
    visibility = ["//java:__subpackages__"],
    deps = [
        "//java/common:semantics_bzl",
        "//java/common/rules:java_helper_bzl",
        "@bazel_skylib//lib:paths",
        "@rules_cc//cc:find_cc_toolchain_bzl",
        "@rules_cc//cc/common",
    ],
)

filegroup(
    name = "for_bazel_tests",
    testonly = 1,
    srcs = [
        "BUILD",
        ":impl",
    ],
    visibility = ["//java/common/rules:__pkg__"],
)

# Runfiles group describers of the Java rules (see runfiles_group_support.bzl),
# the defaults of their private _runfiles_group_describer attributes.
java_library_runfiles_group_describer(name = "java_library_runfiles_group_describer")

java_import_runfiles_group_describer(name = "java_import_runfiles_group_describer")

java_binary_runfiles_group_describer(name = "java_binary_runfiles_group_describer")

java_runtime_runfiles_group_describer(name = "java_runtime_runfiles_group_describer")

# The JDK as one runfiles group, merged in by every java_binary and java_test.
java_runtime_runfiles(name = "runfiles_group_java_runtime")
