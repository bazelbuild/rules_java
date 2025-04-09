load("@rules_license//rules:license.bzl", "license")

package(default_applicable_licenses = ["@rules_java//:license"])

licenses(["notice"])

exports_files([
    "LICENSE",
    "WORKSPACE",
])

filegroup(
    name = "distribution",
    srcs = [
        "AUTHORS",
        "BUILD",
        "LICENSE",
        "MODULE.bazel",
        "WORKSPACE",
        "//java:srcs",
        "//toolchains:srcs",
    ],
    visibility = ["//visibility:public"],
)

license(
    name = "license",
    package_name = "rules_java",
)
