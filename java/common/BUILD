load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

package(default_visibility = ["//visibility:public"])

licenses(["notice"])

filegroup(
    name = "srcs",
    srcs = glob(["**"]) + [
        "//java/common/rules:srcs",
    ],
    visibility = ["//java:__pkg__"],
)

bzl_library(
    name = "common",
    srcs = glob(
        ["*.bzl"],
        exclude = [
            "java_semantics.bzl",
            "proguard_spec_info.bzl",
        ],
    ),
    visibility = ["//visibility:public"],
    deps = [
        ":proguard_spec_info_bzl",
        ":semantics_bzl",
        "@compatibility_proxy//:proxy_bzl",
    ],
)

bzl_library(
    name = "semantics_bzl",
    srcs = ["java_semantics.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "@rules_cc//cc/common",
    ],
)

bzl_library(
    name = "proguard_spec_info_bzl",
    srcs = ["proguard_spec_info.bzl"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "for_bazel_tests",
    testonly = 1,
    srcs = [
        "BUILD",
        ":common",
        "//java/common/rules:for_bazel_tests",
    ],
    visibility = ["//java:__pkg__"],
)
