load("//tools/build_defs/license:license.bzl", "license")

package(default_applicable_licenses = ["//third_party/bazel_rules/rules_java:license"])

license(
    name = "license",
    package_name = "rules_java",
)

licenses(["notice"])

exports_files(["LICENSE"])

filegroup(
    name = "distribution",
    srcs = [
        "AUTHORS",
        "BUILD",
        "LICENSE",
        "MODULE.bazel",
        "//java:srcs",
        "//toolchains:srcs",
    ],
    visibility = ["//distro:__pkg__"],
)
