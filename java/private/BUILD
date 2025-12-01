load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

package(default_applicable_licenses = ["@rules_java//:license"])

licenses(["notice"])

bzl_library(
    name = "native_bzl",
    srcs = [
        "native.bzl",
    ],
    visibility = ["//java:__subpackages__"],
)

bzl_library(
    name = "legacy_native_bzl",
    srcs = [
        "legacy_native.bzl",
    ],
    visibility = ["@compatibility_proxy//:__pkg__"],
)

bzl_library(
    name = "internals",
    srcs = [
        "java_common.bzl",
        "java_common_internal.bzl",
        "message_bundle_info.bzl",
    ],
    visibility = [
        "//java:__subpackages__",
        "@compatibility_proxy//:__pkg__",
    ],
    deps = [
        ":boot_class_path_info_bzl",
        ":java_info_bzl",
        ":native_bzl",
        "//java/common:semantics_bzl",
        "//java/common/rules:java_helper_bzl",
        "//java/common/rules:toolchain_rules",
        "@bazel_skylib//lib:paths",
        "@bazel_skylib//rules:common_settings",
        "@rules_cc//cc:find_cc_toolchain_bzl",
        "@rules_cc//cc/common",
    ],
)

bzl_library(
    name = "boot_class_path_info_bzl",
    srcs = ["boot_class_path_info.bzl"],
    visibility = ["//java:__subpackages__"],
    deps = ["@bazel_skylib//lib:paths"],
)

bzl_library(
    name = "java_info_bzl",
    srcs = ["java_info.bzl"],
    visibility = ["//java:__subpackages__"],
    deps = [
        ":native_bzl",
        "//java/common:semantics_bzl",
        "@rules_cc//cc/common",
    ],
)

# Exposed for use by the protobuf.
bzl_library(
    name = "proto_support",
    srcs = ["proto_support.bzl"],
    visibility = ["//visibility:public"],
    deps = ["@compatibility_proxy//:proxy_bzl"],
)

# Exposed for use by the android rules.
bzl_library(
    name = "android_support",
    srcs = ["android_support.bzl"],
    visibility = ["//visibility:public"],
    deps = ["@compatibility_proxy//:proxy_bzl"],
)

filegroup(
    name = "srcs",
    srcs = glob(["**"]),
    visibility = ["//java:__pkg__"],
)

filegroup(
    name = "for_bazel_tests",
    testonly = 1,
    srcs = [
        "BUILD",
        ":android_support",
        ":internals",
        ":native_bzl",
        ":proto_support",
    ],
    visibility = ["//java:__pkg__"],
)
