load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

package(default_visibility = ["//visibility:public"])

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
    name = "core_rules",
    srcs = [
        "basic_java_library.bzl",
        "java_binary.bzl",
        "java_binary_wrapper.bzl",
        "java_import.bzl",
        "java_library.bzl",
        "java_plugin.bzl",
        "java_toolchain.bzl",
    ],
    visibility = [
        "//java:__pkg__",
    ],
    deps = [
        ":android_lint_bzl",
        ":rule_util_bzl",
        # TODO: re-enable after rules_cc release
        #        "@rules_cc//cc/common",
        "//java/common",
        "@bazel_skylib//lib:paths",
    ],
)

filegroup(
    name = "for_bazel_tests",
    testonly = 1,
    srcs = [
        "BUILD",
        ":core_rules",
    ],
    visibility = ["//java/common:__pkg__"],
)
