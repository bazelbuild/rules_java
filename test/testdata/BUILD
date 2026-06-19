load("@rules_testing//lib:util.bzl", "util")
load("//java:java_binary.bzl", "java_binary")
load("//java:java_library.bzl", "java_library")

package(default_applicable_licenses = ["@rules_java//:license"])

# Make a sample jar for the http_jar test.
java_library(
    name = "my_jar",
    srcs = ["MyLib.java"],
)

# Used by //test/java/common/rules/java_binary_tests.bzl%_test_java_binary_java_package
util.helper_target(
    java_binary,
    name = "non_java",
    srcs = ["Foo.java"],
    visibility = [
        "//test/java/common/rules:__pkg__",
    ],
)
