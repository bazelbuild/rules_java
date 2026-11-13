load("@rules_java//java:defs.bzl", "java_library")
load("//tools/build_rules:java_rules_skylark.bzl", "bootstrap_java_library")

package(
    default_applicable_licenses = ["@rules_java//:license"],
    default_visibility = ["//java_tools/buildjar:buildjar_package_group"],
)

java_library(
    name = "plugins",
    srcs = ["BlazeJavaCompilerPlugin.java"],
    add_exports = [
        "jdk.compiler/com.sun.tools.javac.comp",
        "jdk.compiler/com.sun.tools.javac.main",
        "jdk.compiler/com.sun.tools.javac.util",
    ],
    javacopts = [
        "-source 11",
        "-target 11",
        "--add-exports=jdk.compiler/com.sun.tools.javac.comp=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.main=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED",
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
    add_exports = [
        "jdk.compiler/com.sun.tools.javac.comp",
        "jdk.compiler/com.sun.tools.javac.code",
        "jdk.compiler/com.sun.tools.javac.file",
        "jdk.compiler/com.sun.tools.javac.main",
        "jdk.compiler/com.sun.tools.javac.resources",
        "jdk.compiler/com.sun.tools.javac.tree",
        "jdk.compiler/com.sun.tools.javac.util",
    ],
    javacopts = [
        "-source 11",
        "-target 11",
        "--add-exports=jdk.compiler/com.sun.tools.javac.comp=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.main=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.resources=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED",
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
    name = "javabuilder_errorprone_api",
    srcs = ["errorprone/ErrorProneInvoker.java"],
    visibility = ["//visibility:public"],
    deps = [
        ":plugins",
    ],
)

java_library(
    name = "errorprone",
    srcs = [
        "errorprone/BazelScannerSuppliers.java",
        "errorprone/ErrorProneInvokerImpl.java",
        "errorprone/ErrorPronePlugin.java",
    ],
    javacopts = [
        "-source 11",
        "-target 11",
        "--add-exports=jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.comp=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.main=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED",
    ],
    resource_strip_prefix = "java_tools/buildjar/java/com/google/devtools/build/buildjar/javac/plugins/errorprone",
    resources = ["errorprone/META-INF/services/com.google.devtools.build.buildjar.javac.plugins.errorprone.ErrorProneInvoker"],
    visibility = ["//visibility:public"],
    deps = [
        ":javabuilder_errorprone_api",
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
    add_exports = [
        "jdk.compiler/com.sun.tools.javac.comp",
        "jdk.compiler/com.sun.tools.javac.tree",
        "jdk.compiler/com.sun.tools.javac.util",
    ],
    javacopts = [
        "-source 11",
        "-target 11",
        "--add-exports=jdk.compiler/com.sun.tools.javac.comp=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED",
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
        "errorprone/BazelScannerSuppliers.java",
        "errorprone/ErrorProneInvoker.java",
        "errorprone/ErrorProneInvokerImpl.java",
        "errorprone/ErrorPronePlugin.java",
        "errorprone/META-INF/services/com.google.devtools.build.buildjar.javac.plugins.errorprone.ErrorProneInvoker",
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
