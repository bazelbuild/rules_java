load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

package(default_visibility = ["//visibility:public"])

licenses(["notice"])

filegroup(
    name = "srcs",
    srcs = glob(["**"]) + [
        "//java/bazel:srcs",
        "//java/bazel/common:srcs",
        "//java/bazel/rules:srcs",
        "//java/common:srcs",
        "//java/private:srcs",
        "//java/proto:srcs",
        "//java/runfiles:srcs",
        "//java/toolchains:srcs",
    ],
    visibility = ["//:__pkg__"],
)

bzl_library(
    name = "rules",
    srcs = ["defs.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        ":core_rules",
        "//java/common",
        "//java/toolchains:toolchain_rules",
        "@com_google_protobuf//bazel:java_lite_proto_library_bzl",
        "@com_google_protobuf//bazel:java_proto_library_bzl",
    ],
)

bzl_library(
    name = "core_rules",
    srcs = [
        "java_binary.bzl",
        "java_import.bzl",
        "java_library.bzl",
        "java_plugin.bzl",
        "java_single_jar.bzl",
        "java_test.bzl",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//java/bazel/common",  # copybara-use-repo-external-label
        "//java/bazel/rules",  # copybara-use-repo-external-label
        "//java/common",
        "//java/common/rules:core_rules",
        "//java/private:native_bzl",
    ],
)

bzl_library(
    name = "utils",
    srcs = ["java_utils.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "java_single_jar",
    srcs = ["java_single_jar.bzl"],
    visibility = ["//visibility:public"],
    deps = ["//java/common"],
)

bzl_library(
    name = "http_jar_bzl",
    srcs = ["http_jar.bzl"],
    visibility = ["//visibility:public"],
    deps = ["@compatibility_proxy//:proxy_bzl"],
)

filegroup(
    name = "for_bazel_tests",
    testonly = 1,
    srcs = [
        "BUILD",
        ":core_rules",
        ":java_single_jar",
        ":rules",
        "//java/bazel:for_bazel_tests",  # copybara-use-repo-external-label
        "//java/bazel/rules:for_bazel_tests",  # copybara-use-repo-external-label
        "//java/common:for_bazel_tests",
        "//java/private:for_bazel_tests",
        "//java/toolchains:for_bazel_tests",
        "@bazel_skylib//lib:test_deps",
    ],
    visibility = ["//visibility:public"],
)
