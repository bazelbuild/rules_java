load("@rules_java//java:defs.bzl", "java_library")
load("//tools/build_rules:java_rules_skylark.bzl", "bootstrap_java_library")

package(
    default_applicable_licenses = ["@rules_java//:license"],
    default_visibility = ["//java_tools/buildjar:buildjar_package_group"],
)

filegroup(
    name = "srcs",
    srcs = [
        "JarCreator.java",
        "JarHelper.java",
    ],
    visibility = ["//java_tools/buildjar:__subpackages__"],
)

java_library(
    name = "jarhelper",
    srcs = [
        "JarCreator.java",
        "JarHelper.java",
    ],
    javacopts = [
        "-source 21",
        "-target 21",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//third_party:error_prone_annotations",
    ],
)

bootstrap_java_library(
    name = "bootstrap_jarhelper",
    srcs = [
        "JarCreator.java",
        "JarHelper.java",
    ],
    tags = ["manual"],
    visibility = ["//visibility:public"],
    deps = [
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar:starlark-deps",
    ],
)
