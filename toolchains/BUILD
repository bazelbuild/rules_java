load("@rules_cc//cc:defs.bzl", "cc_library")
load(
    ":default_java_toolchain.bzl",
    "DEFAULT_TOOLCHAIN_CONFIGURATION",
    "PREBUILT_TOOLCHAIN_CONFIGURATION",
    "bootclasspath",
    "default_java_toolchain",
    "java_runtime_files",
)
load(
    ":java_toolchain_alias.bzl",
    "java_host_runtime_alias",
    "java_runtime_alias",
    "java_runtime_version_alias",
    "java_toolchain_alias",
)

package(default_visibility = ["//visibility:public"])

licenses(["notice"])

filegroup(
    name = "srcs",
    srcs = glob(["**"]),
)

filegroup(
    name = "bzl_srcs",
    srcs = glob(["*.bzl"]),
)

# Used to distinguish toolchains used for Java development, ie the JavaToolchainProvider.
# TODO: migrate away from using @bazel_tools//tools/jdk:toolchain_type ?
# toolchain_type(name = "toolchain_type")

# Used to distinguish toolchains used for Java execution, ie the JavaRuntimeInfo.
# TODO: migrate away from using @bazel_tools//tools/jdk:runtime_toolchain_type ?
# toolchain_type(name = "runtime_toolchain_type")

# Points to toolchain[":runtime_toolchain_type"] (was :legacy_current_java_runtime)
java_runtime_alias(name = "current_java_runtime")

# Host configuration of ":current_java_runtime"
java_host_runtime_alias(name = "current_host_java_runtime")

# Points to toolchain[":toolchain_type"] (was :legacy_current_java_toolchain)
java_toolchain_alias(name = "current_java_toolchain")

# These individual jni_* targets are exposed for legacy reasons.
# Most users should depend on :jni.

java_runtime_files(
    name = "jni_header",
    srcs = ["include/jni.h"],
)

java_runtime_files(
    name = "jni_md_header-darwin",
    srcs = ["include/darwin/jni_md.h"],
)

java_runtime_files(
    name = "jni_md_header-linux",
    srcs = ["include/linux/jni_md.h"],
)

java_runtime_files(
    name = "jni_md_header-windows",
    srcs = ["include/win32/jni_md.h"],
)

java_runtime_files(
    name = "jni_md_header-freebsd",
    srcs = ["include/freebsd/jni_md.h"],
)

java_runtime_files(
    name = "jni_md_header-openbsd",
    srcs = ["include/openbsd/jni_md.h"],
)

# The Java native interface. Depend on this package if you #include <jni.h>.
#
# See test_jni in third_party/bazel/src/test/shell/bazel/bazel_java_test.sh for
# an example of using Bazel to build a Java program that calls a C function.
#
# TODO(ilist): use //src:condition:linux when released in Bazel
cc_library(
    name = "jni",
    hdrs = [":jni_header"] + select({
        "@bazel_tools//src/conditions:darwin": [":jni_md_header-darwin"],
        "@bazel_tools//src/conditions:freebsd": [":jni_md_header-freebsd"],
        "@bazel_tools//src/conditions:linux_aarch64": [":jni_md_header-linux"],
        "@bazel_tools//src/conditions:linux_mips64": [":jni_md_header-linux"],
        "@bazel_tools//src/conditions:linux_ppc64le": [":jni_md_header-linux"],
        "@bazel_tools//src/conditions:linux_riscv64": [":jni_md_header-linux"],
        "@bazel_tools//src/conditions:linux_s390x": [":jni_md_header-linux"],
        "@bazel_tools//src/conditions:linux_x86_64": [":jni_md_header-linux"],
        "@bazel_tools//src/conditions:openbsd": [":jni_md_header-openbsd"],
        "@bazel_tools//src/conditions:windows": [":jni_md_header-windows"],
        "//conditions:default": [],
    }),
    includes = ["include"] + select({
        "@bazel_tools//src/conditions:darwin": ["include/darwin"],
        "@bazel_tools//src/conditions:freebsd": ["include/freebsd"],
        "@bazel_tools//src/conditions:linux_aarch64": ["include/linux"],
        "@bazel_tools//src/conditions:linux_mips64": [":include/linux"],
        "@bazel_tools//src/conditions:linux_ppc64le": ["include/linux"],
        "@bazel_tools//src/conditions:linux_riscv64": [":include/linux"],
        "@bazel_tools//src/conditions:linux_s390x": ["include/linux"],
        "@bazel_tools//src/conditions:linux_x86_64": ["include/linux"],
        "@bazel_tools//src/conditions:openbsd": ["include/openbsd"],
        "@bazel_tools//src/conditions:windows": ["include/win32"],
        "//conditions:default": [],
    }),
    tags = ["nobuilder"],
)

[
    (
        alias(
            name = "ijar_prebuilt_binary_%s" % OS,
            actual = "@remote_java_tools_%s//:ijar_prebuilt_binary" % OS,
            visibility = ["//visibility:private"],
        ),
        alias(
            name = "prebuilt_singlejar_%s" % OS,
            actual = "@remote_java_tools_%s//:prebuilt_singlejar" % OS,
            visibility = ["//visibility:private"],
        ),
    )
    for OS in [
        "linux",
        "darwin_x86_64",
        "darwin_arm64",
        "windows",
    ]
]

# On Windows, executables end in ".exe", but the label we reach it through
# must be platform-independent. Thus, we create a little filegroup that
# contains the appropriate platform-dependent file.
alias(
    name = "ijar",
    actual = ":ijar_prebuilt_binary_or_cc_binary",
)

alias(
    name = "ijar_prebuilt_binary_or_cc_binary",
    actual = select({
        "@bazel_tools//src/conditions:darwin_arm64": ":ijar_prebuilt_binary_darwin_arm64",
        "@bazel_tools//src/conditions:darwin_x86_64": ":ijar_prebuilt_binary_darwin_x86_64",
        "@bazel_tools//src/conditions:linux_x86_64": ":ijar_prebuilt_binary_linux",
        "@bazel_tools//src/conditions:windows": ":ijar_prebuilt_binary_windows",
        "//conditions:default": "@remote_java_tools//:ijar_cc_binary",
    }),
)

alias(
    name = "ijar_prebuilt_binary",
    actual = select({
        "@bazel_tools//src/conditions:darwin_arm64": ":ijar_prebuilt_binary_darwin_arm64",
        "@bazel_tools//src/conditions:darwin_x86_64": ":ijar_prebuilt_binary_darwin_x86_64",
        "@bazel_tools//src/conditions:linux_x86_64": ":ijar_prebuilt_binary_linux",
        "@bazel_tools//src/conditions:windows": ":ijar_prebuilt_binary_windows",
    }),
)

# On Windows, Java implementation of singlejar is used. We create a little
# filegroup that contains the appropriate platform-dependent file.
# Once https://github.com/bazelbuild/bazel/issues/2241 is fixed (that is,
# the native singlejar is used on windows), this file group can be reused since
# on Windows, executables end in ".exe", but the label we reach it through
# must be platform-independent.
alias(
    name = "singlejar",
    actual = ":singlejar_prebuilt_or_cc_binary",
)

alias(
    name = "singlejar_prebuilt_or_cc_binary",
    actual = select({
        "@bazel_tools//src/conditions:darwin_arm64": ":prebuilt_singlejar_darwin_arm64",
        "@bazel_tools//src/conditions:darwin_x86_64": ":prebuilt_singlejar_darwin_x86_64",
        "@bazel_tools//src/conditions:linux_x86_64": ":prebuilt_singlejar_linux",
        "@bazel_tools//src/conditions:windows": ":prebuilt_singlejar_windows",
        "//conditions:default": "@remote_java_tools//:singlejar_cc_bin",
    }),
)

alias(
    name = "prebuilt_singlejar",
    actual = select({
        "@bazel_tools//src/conditions:darwin_arm64": ":prebuilt_singlejar_darwin_arm64",
        "@bazel_tools//src/conditions:darwin_x86_64": ":prebuilt_singlejar_darwin_x86_64",
        "@bazel_tools//src/conditions:linux_x86_64": ":prebuilt_singlejar_linux",
        "@bazel_tools//src/conditions:windows": ":prebuilt_singlejar_windows",
    }),
)

bootclasspath(
    name = "platformclasspath",
    src = "DumpPlatformClassPath.java",
    host_javabase = ":current_java_runtime",
    target_javabase = ":current_java_runtime",
)

default_java_toolchain(
    name = "toolchain",
    configuration = DEFAULT_TOOLCHAIN_CONFIGURATION,
    toolchain_definition = False,
)

alias(
    name = "remote_toolchain",
    actual = ":toolchain",
)

RELEASES = (8, 9, 10, 11)

[
    default_java_toolchain(
        name = "toolchain_java%d" % release,
        configuration = DEFAULT_TOOLCHAIN_CONFIGURATION,
        source_version = "%s" % release,
        target_version = "%s" % release,
    )
    for release in RELEASES
]

# A toolchain that targets java 14.
default_java_toolchain(
    name = "toolchain_jdk_14",
    configuration = dict(),
    java_runtime = "//toolchains:remotejdk_14",
    source_version = "14",
    target_version = "14",
)

# A toolchain that targets java 15.
default_java_toolchain(
    name = "toolchain_jdk_15",
    configuration = dict(),
    java_runtime = "//toolchains:remotejdk_15",
    source_version = "15",
    target_version = "15",
)

# A toolchain that targets java 16.
default_java_toolchain(
    name = "toolchain_jdk_16",
    configuration = dict(),
    java_runtime = "//toolchains:remotejdk_16",
    source_version = "16",
    target_version = "16",
)

# A toolchain that targets java 17.
default_java_toolchain(
    name = "toolchain_jdk_17",
    configuration = dict(),
    java_runtime = "//toolchains:remotejdk_17",
    source_version = "17",
    target_version = "17",
)

# A toolchain that targets java 20.
default_java_toolchain(
    name = "toolchain_jdk_20",
    configuration = dict(),
    java_runtime = "//toolchains:remotejdk_20",
    source_version = "20",
    target_version = "20",
)

default_java_toolchain(
    name = "prebuilt_toolchain",
    configuration = PREBUILT_TOOLCHAIN_CONFIGURATION,
    toolchain_definition = False,
)

# A JDK 11 for use as a --host_javabase.
java_runtime_version_alias(
    name = "remote_jdk11",
    runtime_version = "remotejdk_11",
    visibility = ["//visibility:public"],
)

java_runtime_version_alias(
    name = "remotejdk_15",
    runtime_version = "remotejdk_15",
    visibility = ["//visibility:public"],
)

java_runtime_version_alias(
    name = "remotejdk_16",
    runtime_version = "remotejdk_16",
    visibility = ["//visibility:public"],
)

java_runtime_version_alias(
    name = "remotejdk_17",
    runtime_version = "remotejdk_17",
    visibility = ["//visibility:public"],
)

java_runtime_version_alias(
    name = "remotejdk_20",
    runtime_version = "remotejdk_20",
    visibility = ["//visibility:public"],
)

java_runtime_version_alias(
    name = "jdk_8",
    runtime_version = "8",
    visibility = ["//visibility:public"],
)
