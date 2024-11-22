load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

package(default_visibility = ["//visibility:public"])

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
        "@com_google_protobuf//bazel/common:proto_info_bzl",
    ],
)

bzl_library(
    name = "java_helper_bzl",
    srcs = ["java_helper.bzl"],
    visibility = ["//java:__subpackages__"],
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
