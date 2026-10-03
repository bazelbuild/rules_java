load("@rules_java//java:defs.bzl", "java_binary", "java_library")
load("//tools/build_rules:java_rules_skylark.bzl", "bootstrap_java_binary")

package(
    default_applicable_licenses = ["@rules_java//:license"],
    default_visibility = ["//java_tools/buildjar:buildjar_package_group"],
)

filegroup(
    name = "srcs",
    srcs = [
        "GenClass.java",
        "GenClassOptions.java",
        "GenClassOptionsParser.java",
    ],
    visibility = ["//java_tools/buildjar:__subpackages__"],
)

java_binary(
    name = "GenClass",
    visibility = ["//visibility:public"],
    runtime_deps = [":genclass_lib"],
)

java_library(
    name = "genclass_lib",
    srcs = [
        "GenClass.java",
        "GenClassOptions.java",
        "GenClassOptionsParser.java",
    ],
    deps = [
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/jarhelper",
        "//java_tools/buildjar/protobuf:java_compilation_java_proto",
        "//third_party:guava",
    ],
)

bootstrap_java_binary(
    name = "bootstrap_genclass",
    srcs = [
        "GenClass.java",
        "GenClassOptions.java",
        "GenClassOptionsParser.java",
    ],
    main_class = "com.google.devtools.build.buildjar.genclass.GenClass",
    tags = ["manual"],
    visibility = ["//visibility:public"],
    deps = [
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar:starlark-deps",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/jarhelper:bootstrap_jarhelper",
    ],
)
