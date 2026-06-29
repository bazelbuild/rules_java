load("@rules_java//java:defs.bzl", "java_test")

package(
    default_applicable_licenses = ["@rules_java//:license"],
    default_visibility = ["//java_tools/buildjar:buildjar_package_group"],
)

filegroup(
    name = "srcs",
    srcs = [
        "VanillaJavaBuilderTest.java",
        "JavacWorkDirStrippingTest.java",
    ],
    visibility = ["//java_tools/buildjar:__subpackages__"],
)

java_test(
    name = "VanillaJavaBuilderTest",
    srcs = ["VanillaJavaBuilderTest.java"],
    deps = [
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar:VanillaJavaBuilder",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar:invalid_command_line_exception",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar:javac_options",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar:optionsparser",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar:jarhelper",
        "//java_tools/buildjar/protobuf:deps_java_proto",
        "//java_tools/buildjar/protobuf:java_compilation_java_proto",
        "//java_tools/buildjar/protobuf:worker_protocol_java_proto",
        "//third_party:guava",
        "//third_party:junit4",
        "//third_party:truth",
    ],
)

java_test(
    name = "JavacWorkDirStrippingTest",
    srcs = ["JavacWorkDirStrippingTest.java"],
    deps = [
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/javac/plugins:dependency",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar/javac/plugins:processing",
        "//third_party:junit4",
        "//third_party:truth",
    ],
)
