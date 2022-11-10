load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

package(default_visibility = ["//visibility:public"])

licenses(["notice"])

filegroup(
    name = "srcs",
    srcs = glob(["**"]) + ["//java/private:srcs"],
    visibility = ["//:__pkg__"],
)

bzl_library(
    name = "rules",
    srcs = ["defs.bzl"],
    visibility = ["//visibility:public"],
    deps = ["//java/private"],
)
