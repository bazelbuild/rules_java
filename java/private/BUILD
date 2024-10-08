load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

licenses(["notice"])

bzl_library(
    name = "private",
    srcs = [
        "native.bzl",
    ],
    visibility = ["//java:__subpackages__"],
)

bzl_library(
    name = "proto_support",
    srcs = ["proto_support.bzl"],
    deps = [":private"],
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
        ":private",
        ":proto_support",
    ],
    visibility = ["//java:__pkg__"],
)
