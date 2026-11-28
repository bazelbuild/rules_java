load("@rules_java//java:defs.bzl", "java_library")

package(
    default_applicable_licenses = ["@rules_java//:license"],
    default_visibility = ["//visibility:public"],
)

java_library(
    name = "statistics",
    srcs = ["BlazeJavacStatistics.java"],
    add_exports = [
        "jdk.compiler/com.sun.tools.javac.util",
    ],
    javacopts = [
        "-source 21",
        "-target 21",
    ],
    deps = [
        "//third_party:auto_value",
        "//third_party:caffeine",
        "//third_party:error_prone_annotations",
        "//third_party:guava",
    ],
)

filegroup(
    name = "srcs",
    srcs = [
        "BlazeJavacStatistics.java",
    ],
    visibility = ["//java_tools/buildjar:__subpackages__"],
)
