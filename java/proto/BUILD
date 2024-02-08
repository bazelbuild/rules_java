load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

package(default_visibility = ["//visibility:public"])

# Toolchain type provided by proto_lang_toolchain rule and used by java_proto_library
toolchain_type(name = "toolchain_type")

# Toolchain type provided by proto_lang_toolchain rule and used by java_lite_proto_library
toolchain_type(name = "lite_toolchain_type")

bzl_library(
    name = "proto_rules",
    srcs = glob(["*.bzl"]),
    visibility = ["//visibility:public"],
    deps = ["//java/private"],
)

filegroup(
    name = "srcs",
    srcs = glob(["**"]),
    visibility = ["//java:__pkg__"],
)
