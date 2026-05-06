load("@rules_license//rules:license.bzl", "license")
load("//java:java_test.bzl", "java_test")

package(default_applicable_licenses = [":license"])

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

# For exercising root-package behavior in tests
java_test(
    name = "invalid_test_at_repo_root",
    srcs = ["SomeTest.java"],
    tags = [
        "manual",
        "nobuilder",
        "notap",
    ],
    visibility = [
        "//test/java/bazel/rules:__pkg__",
    ],
)
