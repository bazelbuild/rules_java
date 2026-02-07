load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

package(
    default_applicable_licenses = ["@rules_java//:license"],
    default_visibility = ["//visibility:public"],
)

filegroup(
    name = "srcs",
    srcs = glob(["**"]) + [
        "//java/common/rules/impl:srcs",
    ],
    visibility = ["//java/common:__pkg__"],
)

bzl_library(
    name = "android_lint_bzl",
    srcs = ["android_lint.bzl"],
    visibility = ["//visibility:private"],
)

bzl_library(
    name = "rule_util_bzl",
    srcs = ["rule_util.bzl"],
    visibility = ["//visibility:private"],
)

bzl_library(
    name = "java_helper_bzl",
    srcs = ["java_helper.bzl"],
    visibility = ["//java:__subpackages__"],
)

bzl_library(
    name = "java_single_jar_bzl",
    srcs = ["java_single_jar.bzl"],
    visibility = ["//java:__subpackages__"],
    deps = ["//java/common"],
)

bzl_library(
    name = "core_rules",
    srcs = [
        "basic_java_library.bzl",
        "java_binary.bzl",
        "java_binary_wrapper.bzl",
        "java_import.bzl",
        "java_library.bzl",
        "java_plugin.bzl",
    ],
    visibility = [
        "//java:__subpackages__",
    ],
    deps = [
        ":android_lint_bzl",
        ":rule_util_bzl",
        "//java/private:internals",
        "@bazel_skylib//lib:paths",
        "@rules_cc//cc/common",
    ],
)

bzl_library(
    name = "toolchain_rules",
    srcs = [
        "java_package_configuration.bzl",
        "java_runtime.bzl",
        "java_toolchain.bzl",
    ],
    visibility = [
        "//java:__subpackages__",
        "@compatibility_proxy//:__pkg__",
    ],
    deps = [
        ":java_helper_bzl",
        "//java/common:semantics_bzl",
        "//java/private:boot_class_path_info_bzl",
        "//java/private:java_info_bzl",
        "//java/private:native_bzl",
        "@bazel_skylib//lib:paths",
        "@rules_cc//cc/common",
    ],
)

filegroup(
    name = "for_bazel_tests",
    testonly = 1,
    srcs = [
        "BUILD",
        ":core_rules",
        ":java_single_jar_bzl",
        ":toolchain_rules",
        "//java/common/rules/impl:for_bazel_tests",
        "@rules_cc//cc/private/rules_impl:srcs",
    ],
    visibility = ["//java/common:__pkg__"],
)
