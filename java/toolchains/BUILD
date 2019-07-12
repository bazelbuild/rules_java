load("@rules_java//java:defs.bzl", "java_toolchain")

toolchain_type(name = "javac_toolchain_type")
toolchain_type(name = "java_runtime_toolchain_type")

LINUX_CONSTRAINTS = ["@platforms//os:linux", "@platforms//cpu:x86_64",]
WINDOWS_CONSTRAINTS = ["@platforms//os:windows", "@platforms//cpu:x86_64",]
MACOS_CONSTRAINTS = ["@platforms//os:osx", "@platforms//cpu:x86_64",]

HOST_JAVA_RUNTIME_CONSTRAINTS = ["@rules_java//java/constraints:host_runtime"]
HOST_JAVA_LANGUAGE_CONSTRAINTS = ["@rules_java//java/constraints:host_language"]

############################### javac toolchains ##############################
toolchain(
    name = "javac_linux_toolchain",
    exec_compatible_with = LINUX_CONSTRAINTS,
    target_compatible_with = LINUX_CONSTRAINTS,
    toolchain = "@remote_java_tools_linux//:toolchain",
    toolchain_type = ":javac_toolchain_type"
)

toolchain(
    name = "javac_windows_toolchain",
    exec_compatible_with = WINDOWS_CONSTRAINTS,
    target_compatible_with = WINDOWS_CONSTRAINTS,
    toolchain = "@remote_java_tools_windows//:toolchain",
    toolchain_type = ":javac_toolchain_type"
)

toolchain(
    name = "javac_darwin_toolchain",
    exec_compatible_with = MACOS_CONSTRAINTS,
    target_compatible_with = MACOS_CONSTRAINTS,
    toolchain = "@remote_java_tools_darwin//:toolchain",
    toolchain_type = ":javac_toolchain_type",
)

toolchain(
    name = "host_javac_linux_toolchain",
    exec_compatible_with = LINUX_CONSTRAINTS + HOST_JAVA_LANGUAGE_CONSTRAINTS,
    target_compatible_with = LINUX_CONSTRAINTS + HOST_JAVA_LANGUAGE_CONSTRAINTS,
    toolchain = "@remote_java_tools_linux//:toolchain",
    toolchain_type = ":javac_toolchain_type"
)

toolchain(
    name = "host_javac_windows_toolchain",
    exec_compatible_with = WINDOWS_CONSTRAINTS + HOST_JAVA_LANGUAGE_CONSTRAINTS,
   target_compatible_with = WINDOWS_CONSTRAINTS + HOST_JAVA_LANGUAGE_CONSTRAINTS,
   toolchain = "@remote_java_tools_windows//:toolchain",
   toolchain_type = ":javac_toolchain_type"
)

toolchain(
    name = "host_javac_darwin_toolchain",
    exec_compatible_with = MACOS_CONSTRAINTS + HOST_JAVA_LANGUAGE_CONSTRAINTS,
    target_compatible_with = MACOS_CONSTRAINTS + HOST_JAVA_LANGUAGE_CONSTRAINTS,
    toolchain = "@remote_java_tools_darwin//:toolchain",
    toolchain_type = ":javac_toolchain_type",
)

############################ java runtime toolchains ##########################

toolchain(
    name = "java_runtime_toolchain",
    toolchain = "@local_jdk//:jdk",
    toolchain_type = ":java_runtime_toolchain_type"
)

toolchain(
    name = "host_java_runtime_linux_toolchain",
    exec_compatible_with = LINUX_CONSTRAINTS + HOST_JAVA_RUNTIME_CONSTRAINTS,
    target_compatible_with = LINUX_CONSTRAINTS + HOST_JAVA_RUNTIME_CONSTRAINTS,
    toolchain = "@host_jdk_linux//:jdk",
    toolchain_type = ":java_runtime_toolchain_type"
)

toolchain(
    name = "host_java_runtime_windows_toolchain",
    exec_compatible_with = WINDOWS_CONSTRAINTS + HOST_JAVA_RUNTIME_CONSTRAINTS,
    target_compatible_with = WINDOWS_CONSTRAINTS + HOST_JAVA_RUNTIME_CONSTRAINTS,
    toolchain = "@host_jdk_win//:jdk",
    toolchain_type = ":java_runtime_toolchain_type"
)

toolchain(
    name = "host_java_runtime_macos_toolchain",
    exec_compatible_with = MACOS_CONSTRAINTS + HOST_JAVA_RUNTIME_CONSTRAINTS,
    target_compatible_with = MACOS_CONSTRAINTS + HOST_JAVA_RUNTIME_CONSTRAINTS,
    toolchain = "@host_jdk_macos//:jdk",
    toolchain_type = ":java_runtime_toolchain_type"
)