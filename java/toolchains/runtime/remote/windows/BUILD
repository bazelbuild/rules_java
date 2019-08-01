package(default_visibility = ["//visibility:public"])

licenses(["notice"])

load(
    "@rules_java//java/constraints:constraints.bzl",
    "WINDOWS_CONSTRAINTS",
    "REMOTE_JDK9_CONSTRAINTS",
    "REMOTE_JDK10_CONSTRAINTS",
    "REMOTE_JDK11_CONSTRAINTS",
    "REMOTE_JDK12_CONSTRAINTS",
)

toolchain(
    name = "jdk9",
    target_compatible_with = WINDOWS_CONSTRAINTS + REMOTE_JDK9_CONSTRAINTS,
    exec_compatible_with = WINDOWS_CONSTRAINTS + REMOTE_JDK9_CONSTRAINTS,
    toolchain = "@remote_jdk9_windows//:jdk",
    toolchain_type = "@rules_java//java/toolchains/runtime:toolchain_type",
)

toolchain(
    name = "jdk10",
    target_compatible_with = WINDOWS_CONSTRAINTS + REMOTE_JDK10_CONSTRAINTS,
    exec_compatible_with = WINDOWS_CONSTRAINTS + REMOTE_JDK10_CONSTRAINTS,
    toolchain = "@remote_jdk9_windows//:jdk",
    toolchain_type = "@rules_java//java/toolchains/runtime:toolchain_type",
)

toolchain(
    name = "jdk11",
    target_compatible_with = WINDOWS_CONSTRAINTS + REMOTE_JDK11_CONSTRAINTS,
    exec_compatible_with = WINDOWS_CONSTRAINTS + REMOTE_JDK11_CONSTRAINTS,
    toolchain = "@remote_jdk9_windows//:jdk",
    toolchain_type = "@rules_java//java/toolchains/runtime:toolchain_type",
)

toolchain(
    name = "jdk12",
    target_compatible_with = WINDOWS_CONSTRAINTS + REMOTE_JDK12_CONSTRAINTS,
    exec_compatible_with = WINDOWS_CONSTRAINTS + REMOTE_JDK12_CONSTRAINTS,
    toolchain = "@remote_jdk9_windows//:jdk",
    toolchain_type = "@rules_java//java/toolchains/runtime:toolchain_type",
)
