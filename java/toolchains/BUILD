load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

package(default_visibility = ["//visibility:public"])

licenses(["notice"])

filegroup(
    name = "srcs",
    srcs = glob(["**"]),
    visibility = ["//java:__pkg__"],
)

bzl_library(
    name = "toolchain_rules",
    srcs = glob(["*.bzl"]),
    visibility = ["//visibility:public"],
    deps = ["//java/private"],
)
