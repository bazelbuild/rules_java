load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("@bazel_skylib//rules:common_settings.bzl", "bool_flag")

package(default_visibility = ["//visibility:public"])

licenses(["notice"])

# If enabled, the bootclasspath for Java compilation will be extracted from a Java runtime matching
# the version specified with `--java_language_version` rather than the runtime specified with
# `--java_runtime_version`.
bool_flag(
    name = "incompatible_language_version_bootclasspath",
    build_setting_default = False,
)

filegroup(
    name = "srcs",
    srcs = glob(["**"]) + [
        "//java/common:srcs",
        "//java/private:srcs",
        "//java/proto:srcs",
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
    deps = ["//java/private"],
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
)

filegroup(
    name = "for_bazel_tests",
    srcs = [
        "BUILD",
        ":core_rules",
        ":java_single_jar",
    ],
    visibility = ["//visibility:public"],
)
