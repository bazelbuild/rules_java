package(
    default_applicable_licenses = ["@rules_java//:license"],
    default_visibility = [":buildjar_package_group"],
)

filegroup(
    name = "srcs",
    srcs = [
        "BUILD",
        "deps.bzl",
        "//java_tools/buildjar/java/com/google/devtools/build/buildjar:srcs",
        "//java_tools/buildjar/java/com/google/devtools/build/java/turbine:srcs",
        "//java_tools/buildjar/javatests/com/google/devtools/build/buildjar:srcs",
    ],
    visibility = ["//visibility:public"],
)

package_group(
    name = "buildjar_package_group",
    packages = [
        "//...",
    ],
)

alias(
    name = "JavaBuilder",
    actual = "//java_tools/buildjar/java/com/google/devtools/build/buildjar:BazelJavaBuilder",
    visibility = ["//visibility:public"],
)

alias(
    name = "javabuilder_core",
    actual = "//java_tools/buildjar/java/com/google/devtools/build/buildjar:javabuilder_core",
    visibility = ["//visibility:public"],
)

alias(
    name = "VanillaJavaBuilder",
    actual = "//java_tools/buildjar/java/com/google/devtools/build/buildjar:VanillaJavaBuilder",
    visibility = ["//visibility:public"],
)

filegroup(
    name = "bootstrap_VanillaJavaBuilder_deploy.jar",
    srcs = ["//java_tools/buildjar/java/com/google/devtools/build/buildjar:bootstrap_VanillaJavaBuilder_deploy.jar"],
    tags = ["manual"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "bootstrap_genclass_deploy.jar",
    srcs = ["//java_tools/buildjar/java/com/google/devtools/build/buildjar/genclass:bootstrap_genclass_deploy.jar"],
    tags = ["manual"],
    visibility = ["//visibility:public"],
)

exports_files(["deps.bzl"])
