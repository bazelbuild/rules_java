package(default_visibility = ["//visibility:public"])

licenses(["notice"])

toolchain_type(name = "toolchain_type")

load("@local_config_platform//:constraints.bzl", "HOST_CONSTRAINTS")

toolchain(
    name = "local_jdk",
    target_compatible_with = HOST_CONSTRAINTS,
    exec_compatible_with = HOST_CONSTRAINTS,
    toolchain = "@local_jdk//:jdk",
    toolchain_type = "@rules_java//java/toolchains/runtime:toolchain_type",
)
