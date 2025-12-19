load("//java:java_library.bzl", "java_library")
load("//java:java_plugin.bzl", "java_plugin")

package(default_applicable_licenses = ["@rules_java//:license"])

java_library(
    name = "runfiles",
    srcs = [
        "Runfiles.java",
        "Util.java",
    ],
    exported_plugins = [":auto_bazel_repository_processor"],
    visibility = ["//java/runfiles:__pkg__"],
    exports = [":auto_bazel_repository"],
)

java_library(
    name = "auto_bazel_repository",
    srcs = ["AutoBazelRepository.java"],
)

java_plugin(
    name = "auto_bazel_repository_processor",
    srcs = ["AutoBazelRepositoryProcessor.java"],
    processor_class = "com.google.devtools.build.runfiles.AutoBazelRepositoryProcessor",
)

filegroup(
    name = "srcs",
    srcs = glob(["**"]),
    visibility = ["//java/runfiles:__pkg__"],
)
