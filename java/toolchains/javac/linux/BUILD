package(default_visibility = ["//visibility:public"])

licenses(["notice"])

load(
    "@rules_java//java/constraints:constraints.bzl",
    "LINUX_CONSTRAINTS",
    "JAVAC9_LANGUAGE8_CONSTRAINTS",
    "JAVAC10_LANGUAGE8_CONSTRAINTS",
    "JAVAC11_LANGUAGE8_CONSTRAINTS",
    "JAVAC12_LANGUAGE8_CONSTRAINTS",
)

toolchain(
    name = "javac9_language8",
    target_compatible_with = LINUX_CONSTRAINTS + JAVAC9_LANGUAGE8_CONSTRAINTS,
    exec_compatible_with = LINUX_CONSTRAINTS + JAVAC9_LANGUAGE8_CONSTRAINTS,
    toolchain = "@remote_java_tools_javac10_linux//:toolchain",
    toolchain_type = "@rules_java//java/toolchains/javac:toolchain_type",
)

toolchain(
    name = "javac10_language8",
    target_compatible_with = LINUX_CONSTRAINTS + JAVAC10_LANGUAGE8_CONSTRAINTS,
    exec_compatible_with = LINUX_CONSTRAINTS + JAVAC10_LANGUAGE8_CONSTRAINTS,
    toolchain = "@remote_java_tools_javac10_linux//:toolchain",
    toolchain_type = "@rules_java//java/toolchains/javac:toolchain_type",
)

toolchain(
    name = "javac11_language8",
    target_compatible_with = LINUX_CONSTRAINTS + JAVAC11_LANGUAGE8_CONSTRAINTS,
    exec_compatible_with = LINUX_CONSTRAINTS + JAVAC11_LANGUAGE8_CONSTRAINTS,
    toolchain = "@remote_java_tools_javac11_linux//:toolchain",
    toolchain_type = "@rules_java//java/toolchains/javac:toolchain_type",
)

toolchain(
    name = "javac12_language8",
    target_compatible_with = LINUX_CONSTRAINTS + JAVAC12_LANGUAGE8_CONSTRAINTS,
    exec_compatible_with = LINUX_CONSTRAINTS + JAVAC12_LANGUAGE8_CONSTRAINTS,
    toolchain = "@remote_java_tools_javac12_linux//:toolchain",
    toolchain_type = "@rules_java//java/toolchains/javac:toolchain_type",
)
