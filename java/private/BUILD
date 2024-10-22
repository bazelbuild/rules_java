load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

licenses(["notice"])

bzl_library(
    name = "native_bzl",
    srcs = [
        "native.bzl",
    ],
    visibility = ["//java:__subpackages__"],
)

bzl_library(
    name = "internals",
    srcs = [
        "boot_class_path_info.bzl",
        "java_common.bzl",
        "java_info.bzl",
        "message_bundle_info.bzl",
    ],
    visibility = ["//java:__subpackages__"],
    deps = [
        ":native_bzl",
        "//java/common",
        "//java/common/rules:toolchain_rules",
        "//java/common/rules/impl:java_helper_bzl",
        "@bazel_skylib//lib:paths",
        "@rules_cc//cc/common",
    ],
)

# Exposed for use by the protobuf.
bzl_library(
    name = "proto_support",
    srcs = ["proto_support.bzl"],
    visibility = ["//visibility:public"],
    deps = [":native_bzl"],
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
        ":native_bzl",
        ":proto_support",
    ],
    visibility = ["//java:__pkg__"],
)
