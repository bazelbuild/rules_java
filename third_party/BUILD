load("@rules_java//java:defs.bzl", "java_library", "java_plugin")

package(default_visibility = ["//visibility:public"])

alias(
    name = "guava",
    actual = "@rules_java_guava//jar",
)

alias(
    name = "jsr305",
    actual = "@rules_java_jsr305//jar",
)

alias(
    name = "gson",
    actual = "@rules_java_gson//jar",
)

java_plugin(
    name = "auto_value_plugin",
    processor_class = "com.google.auto.value.processor.AutoValueProcessor",
    deps = ["@rules_java_auto_value//jar"],
)

java_plugin(
    name = "auto_oneof_plugin",
    processor_class = "com.google.auto.value.processor.AutoOneOfProcessor",
    deps = ["@rules_java_auto_value//jar"],
)

java_library(
    name = "auto_value",
    exported_plugins = [
        ":auto_value_plugin",
        ":auto_oneof_plugin",
    ],
    exports = ["@rules_java_auto_value_annotations//jar"],
)

alias(
    name = "auto_value_annotations",
    actual = "@rules_java_auto_value_annotations//jar",
)

java_library(
    name = "error_prone",
    exports = [
        ":error_prone_annotations",
        "@rules_java_error_prone//jar",
        "@rules_java_error_prone_check_api//jar",
    ],
)

alias(
    name = "error_prone_annotations",
    actual = "@rules_java_error_prone_annotations//jar",
)

alias(
    name = "jacoco_core",
    actual = "@rules_java_jacoco_core//jar",
)

alias(
    name = "caffeine",
    actual = "@rules_java_caffeine//jar",
)

alias(
    name = "junit4",
    actual = "@rules_java_junit4//jar",
)

alias(
    name = "truth",
    actual = "@rules_java_truth//jar",
)


