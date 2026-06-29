load("@rules_java//java:defs.bzl", "java_library")
load("//tools/build_rules:java_rules_skylark.bzl", "bootstrap_java_library")

package(
    default_applicable_licenses = ["@rules_java//:license"],
    default_visibility = ["//java_tools/buildjar:buildjar_package_group"],
)

java_library(
    name = "plugins",
    srcs = ["BlazeJavaCompilerPlugin.java"],
    javacopts = [
        "-source 21",
        "-target 21",
    ],
    add_exports = [
        "jdk.compiler/com.sun.tools.javac.comp",
        "jdk.compiler/com.sun.tools.javac.main",
        "jdk.compiler/com.sun.tools.javac.util",
    ],
    deps = [
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar:invalid_command_line_exception",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/javac/statistics",
        "//third_party:guava",
    ],
)

java_library(
    name = "dependency",
    srcs = [
        "dependency/DependencyModule.java",
        "dependency/ImplicitDependencyExtractor.java",
        "dependency/StrictJavaDepsPlugin.java",
    ],
    javacopts = [
        "-source 21",
        "-target 21",
    ],
    add_exports = [
        "jdk.compiler/com.sun.tools.javac.comp",
        "jdk.compiler/com.sun.tools.javac.code",
        "jdk.compiler/com.sun.tools.javac.file",
        "jdk.compiler/com.sun.tools.javac.main",
        "jdk.compiler/com.sun.tools.javac.resources",
        "jdk.compiler/com.sun.tools.javac.tree",
        "jdk.compiler/com.sun.tools.javac.util",
    ],
    deps = [
        ":plugins",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar:JarOwner",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/javac/statistics",
        "//java_tools/buildjar/protobuf:deps_java_proto",
        "//third_party:auto_value",
        "//third_party:error_prone_annotations",
        "//third_party:guava",
        "//third_party:jsr305",
    ],
)

java_library(
    name = "errorprone",
    srcs = ["errorprone/ErrorPronePlugin.java"],
    javacopts = [
        "-source 21",
        "-target 21",
        "--add-exports=jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.comp=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.main=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED",
    ],
    deps = [
        ":plugins",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar:invalid_command_line_exception",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/javac/statistics",
        "//third_party:error_prone",
        "//third_party:guava",
    ],
)

java_library(
    name = "processing",
    srcs = [
        "processing/AnnotationProcessingModule.java",
        "processing/AnnotationProcessingPlugin.java",
    ],
    javacopts = [
        "-source 21",
        "-target 21",
    ],
    add_exports = [
        "jdk.compiler/com.sun.tools.javac.comp",
        "jdk.compiler/com.sun.tools.javac.tree",
        "jdk.compiler/com.sun.tools.javac.util",
    ],
    deps = [
        ":plugins",
        "//java_tools/buildjar/protobuf:java_compilation_java_proto",
        "//third_party:guava",
        "//third_party:jsr305",
    ],
)

filegroup(
    name = "srcs",
    srcs = [
        "BlazeJavaCompilerPlugin.java",
        "dependency/DependencyModule.java",
        "dependency/ImplicitDependencyExtractor.java",
        "dependency/StrictJavaDepsPlugin.java",
        "errorprone/ErrorPronePlugin.java",
        "processing/AnnotationProcessingModule.java",
        "processing/AnnotationProcessingPlugin.java",
    ],
    visibility = ["//java_tools/buildjar:__subpackages__"],
)

bootstrap_java_library(
    name = "bootstrap_plugins",
    srcs = [
        "BlazeJavaCompilerPlugin.java",
        "dependency/DependencyModule.java",
        "dependency/ImplicitDependencyExtractor.java",
        "dependency/StrictJavaDepsPlugin.java",
        "processing/AnnotationProcessingModule.java",
        "processing/AnnotationProcessingPlugin.java",
    ],
    tags = [
        "manual",
        "nobuilder",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar:bootstrap_JarOwner",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar:bootstrap_invalid_command_line_exception",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar:starlark-deps",
    ],
)
