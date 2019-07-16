load("@rules_java//java:defs.bzl", "java_toolchain")

toolchain_type(name = "target_javac_toolchain_type")
toolchain_type(name = "host_javac_toolchain_type")
toolchain_type(name = "target_java_runtime_toolchain_type")
toolchain_type(name = "host_java_runtime_toolchain_type")

LINUX_CONSTRAINTS = ["@platforms//os:linux", "@platforms//cpu:x86_64",]
WINDOWS_CONSTRAINTS = ["@platforms//os:windows", "@platforms//cpu:x86_64",]
MACOS_CONSTRAINTS = ["@platforms//os:osx", "@platforms//cpu:x86_64",]

load("@local_config_platform//:constraints.bzl", 'HOST_CONSTRAINTS')

############################### javac toolchains ##############################

CONFIGURATIONS = ["host", "target"]

[
    toolchain(
        name = config + "_javac_linux_toolchain",
        exec_compatible_with = LINUX_CONSTRAINTS,
        target_compatible_with = LINUX_CONSTRAINTS,
        toolchain = "@remote_java_tools_linux//:toolchain",
        toolchain_type = ":" + config + "_javac_toolchain_type"
    )
    for config in CONFIGURATIONS
]

[
    toolchain(
        name = config + "_javac_windows_toolchain",
        exec_compatible_with = WINDOWS_CONSTRAINTS,
        target_compatible_with = WINDOWS_CONSTRAINTS,
        toolchain = "@remote_java_tools_windows//:toolchain",
        toolchain_type = ":" + config + "_javac_toolchain_type"
    )
    for config in CONFIGURATIONS
]

[
    toolchain(
        name = config + "_javac_darwin_toolchain",
        exec_compatible_with = MACOS_CONSTRAINTS,
        target_compatible_with = MACOS_CONSTRAINTS,
        toolchain = "@remote_java_tools_darwin//:toolchain",
        toolchain_type = ":" + config + "_javac_toolchain_type"
    )
    for config in CONFIGURATIONS
]

############################ java runtime toolchains ##########################

toolchain(
    name = "target_java_runtime_toolchain",
    exec_compatible_with = HOST_CONSTRAINTS,
    target_compatible_with = HOST_CONSTRAINTS,
    toolchain = "@local_jdk//:jdk",
    toolchain_type = ":target_java_runtime_toolchain_type"
)

toolchain(
    name = "host_java_runtime_linux_toolchain",
    exec_compatible_with = LINUX_CONSTRAINTS,
    target_compatible_with = LINUX_CONSTRAINTS,
    toolchain = "@host_jdk_linux//:jdk",
    toolchain_type = ":host_java_runtime_toolchain_type"
)

toolchain(
    name = "host_java_runtime_windows_toolchain",
    exec_compatible_with = WINDOWS_CONSTRAINTS,
    target_compatible_with = WINDOWS_CONSTRAINTS,
    toolchain = "@host_jdk_win//:jdk",
    toolchain_type = ":host_java_runtime_toolchain_type"
)

toolchain(
    name = "host_java_runtime_macos_toolchain",
    exec_compatible_with = MACOS_CONSTRAINTS,
    target_compatible_with = MACOS_CONSTRAINTS,
    toolchain = "@host_jdk_macos//:jdk",
    toolchain_type = ":host_java_runtime_toolchain_type"
)
