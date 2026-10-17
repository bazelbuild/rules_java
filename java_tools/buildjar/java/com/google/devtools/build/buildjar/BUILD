load("@rules_java//java:defs.bzl", "java_binary", "java_library")
load("//tools/build_rules:java_rules_skylark.bzl", "bootstrap_java_binary", "bootstrap_java_library")

package(
    default_applicable_licenses = ["@rules_java//:license"],
    default_visibility = ["//java_tools/buildjar:buildjar_package_group"],
)

filegroup(
    name = "srcs",
    srcs = [
        "BazelJavaBuilder.java",
        "InvalidCommandLineException.java",
        "JarOwner.java",
        "JavaLibraryBuildRequest.java",
        "OptionsParser.java",
        "ReducedClasspathJavaLibraryBuilder.java",
        "SimpleJavaLibraryBuilder.java",
        "VanillaJavaBuilder.java",
        "instrumentation/JacocoInstrumentationProcessor.java",
        "javac/BlazeJavaCompiler.java",
        "javac/BlazeJavacArguments.java",
        "javac/BlazeJavacMain.java",
        "javac/BlazeJavacResult.java",
        "javac/CancelCompilerPlugin.java",
        "javac/FormattedDiagnostic.java",
        "javac/JavacOptions.java",
        "javac/JavacRunner.java",
        "javac/WerrorCustomOption.java",
        "javac/WorkerCancellationRegistry.java",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/genclass:srcs",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/jarhelper:srcs",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/javac/plugins:srcs",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/javac/statistics:srcs",
    ],
    visibility = ["//java_tools/buildjar:__subpackages__"],
)

java_library(
    name = "optionsparser",
    srcs = [
        "InvalidCommandLineException.java",
        "OptionsParser.java",
    ],
    javacopts = [
        "-source 21",
        "-target 21",
    ],
    visibility = [
        "//java_tools/buildjar:buildjar_package_group",
    ],
    deps = [
        ":javac_options",
        "//third_party:guava",
        "//third_party:jsr305",
    ],
)

java_library(
    name = "javac",
    srcs = [
        "javac/BlazeJavaCompiler.java",
        "javac/BlazeJavacArguments.java",
        "javac/BlazeJavacMain.java",
        "javac/BlazeJavacResult.java",
        "javac/CancelCompilerPlugin.java",
        "javac/FormattedDiagnostic.java",
        "javac/JavacRunner.java",
        "javac/WorkerCancellationRegistry.java",
    ],
    add_exports = [
        "jdk.compiler/com.sun.tools.javac.api",
        "jdk.compiler/com.sun.tools.javac.code",
        "jdk.compiler/com.sun.tools.javac.comp",
        "jdk.compiler/com.sun.tools.javac.file",
        "jdk.compiler/com.sun.tools.javac.main",
        "jdk.compiler/com.sun.tools.javac.util",
    ],
    javacopts = [
        "-source 21",
        "-target 21",
    ],
    deps = [
        ":invalid_command_line_exception",
        ":javac_options",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/javac/plugins",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/javac/statistics",
        "//third_party:auto_value",
        "//third_party:guava",
        "//third_party:jsr305",
        "@com_google_protobuf//:protobuf_java",
    ],
)

alias(
    name = "jarhelper",
    actual = "//java_tools/buildjar/java/com/google/devtools/build/buildjar/jarhelper",
    visibility = ["//visibility:public"],
)

java_library(
    name = "javabuilder_core",
    srcs = [
        "BazelJavaBuilder.java",
        "JavaLibraryBuildRequest.java",
        "ReducedClasspathJavaLibraryBuilder.java",
        "SimpleJavaLibraryBuilder.java",
        "instrumentation/JacocoInstrumentationProcessor.java",
    ],
    javacopts = [
        "-source 21",
        "-target 21",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":invalid_command_line_exception",
        ":jarhelper",
        ":javac",
        ":javac_options",
        ":optionsparser",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/javac/plugins",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/javac/plugins:dependency",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/javac/plugins:javabuilder_errorprone_api",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/javac/plugins:processing",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/javac/statistics",
        "//java_tools/buildjar/java/com/google/devtools/build/lib/worker:work_request_handlers",
        "//third_party:error_prone_annotations",
        "//third_party:guava",
        "//third_party:jacoco_core",
        "//third_party:jsr305",
    ],
)

java_binary(
    name = "BazelJavaBuilder",
    srcs = ["BazelJavaBuilder.java"],
    javacopts = [
        "-source 21",
        "-target 21",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":invalid_command_line_exception",
        ":javabuilder_core",
        ":javac",
        ":javac_options",
        ":optionsparser",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/javac/plugins",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/javac/plugins:dependency",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/javac/plugins:javabuilder_errorprone_api",
        "//java_tools/buildjar/java/com/google/devtools/build/lib/worker:work_request_handlers",
        "//third_party:guava",
        "//third_party:jsr305",
    ],
)

java_library(
    name = "javac_options",
    srcs = [
        "javac/JavacOptions.java",
        "javac/WerrorCustomOption.java",
    ],
    javacopts = [
        "-source 21",
        "-target 21",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//third_party:auto_value",
        "//third_party:error_prone_annotations",
        "//third_party:guava",
    ],
)

java_library(
    name = "invalid_command_line_exception",
    srcs = ["InvalidCommandLineException.java"],
    javacopts = [
        "-source 21",
        "-target 21",
    ],
)

java_library(
    name = "JarOwner",
    srcs = ["JarOwner.java"],
    javacopts = [
        "-source 21",
        "-target 21",
    ],
    deps = [
        "//third_party:auto_value",
        "//third_party:guava",
        "//third_party:jsr305",
    ],
)

java_binary(
    name = "VanillaJavaBuilder",
    srcs = ["VanillaJavaBuilder.java"],
    javacopts = [
        "-source 21",
        "-target 21",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":jarhelper",
        ":javac_options",
        ":optionsparser",
        "//java_tools/buildjar/protobuf:deps_java_proto",
        "//java_tools/buildjar/protobuf:java_compilation_java_proto",
        "//java_tools/buildjar/protobuf:worker_protocol_java_proto",
        "//third_party:guava",
    ],
)

bootstrap_java_library(
    name = "starlark-deps",
    jars = [
        "//third_party:guava",
        "//third_party:jsr305",
        "//third_party:gson",
        "//java_tools/buildjar/protobuf:deps_java_proto",
        "//java_tools/buildjar/protobuf:worker_protocol_java_proto",
        "//java_tools/buildjar/protobuf:java_compilation_java_proto",
    ],
    neverlink_jars = ["//third_party:auto_value_annotations"],
    tags = ["manual"],
    visibility = ["//visibility:public"],
)

bootstrap_java_library(
    name = "bootstrap_invalid_command_line_exception",
    srcs = ["InvalidCommandLineException.java"],
    tags = ["manual"],
    visibility = ["//visibility:public"],
)

bootstrap_java_library(
    name = "bootstrap_JarOwner",
    srcs = ["JarOwner.java"],
    jars = [
        "//third_party:jsr305",
        "//third_party:auto_value_annotations",
        "//third_party:guava",
    ],
    tags = ["manual"],
    visibility = ["//visibility:public"],
)

bootstrap_java_binary(
    name = "bootstrap_VanillaJavaBuilder",
    srcs = [
        "InvalidCommandLineException.java",
        "JarOwner.java",
        "OptionsParser.java",
        "VanillaJavaBuilder.java",
        "javac/JavacOptions.java",
        "javac/WerrorCustomOption.java",
    ],
    main_class = "com.google.devtools.build.buildjar.VanillaJavaBuilder",
    neverlink_jars = ["//third_party:auto_value_annotations"],
    tags = ["manual"],
    visibility = ["//visibility:public"],
    deps = [
        ":starlark-deps",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/jarhelper:bootstrap_jarhelper",
    ],
)
