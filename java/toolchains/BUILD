load("@rules_java//java:defs.bzl", "java_toolchain")

toolchain_type(name = "javac_toolchain")

toolchain(
    name = "javac_linux_toolchain",
    exec_compatible_with = [
       "@platforms//os:linux",
       "@platforms//cpu:x86_64",
   ],
   target_compatible_with = [
       "@platforms//os:linux",
       "@platforms//cpu:x86_64",
   ],
   toolchain = "@remote_java_tools_linux//:toolchain",
   toolchain_type = ":javac_toolchain"
)

toolchain(
    name = "javac_windows_toolchain",
    exec_compatible_with = [
       "@platforms//os:windows",
       "@platforms//cpu:x86_64",
   ],
   target_compatible_with = [
       "@platforms//os:linux",
       "@platforms//cpu:x86_64",
   ],
   toolchain = "@remote_java_tools_windows//:toolchain",
   toolchain_type = ":javac_toolchain"
)

toolchain(
    name = "javac_darwin_toolchain",
    exec_compatible_with = [
       "@platforms//os:windows",
       "@platforms//cpu:x86_64",
   ],
   target_compatible_with = [
       "@platforms//os:linux",
       "@platforms//cpu:x86_64",
   ],
   toolchain = "@remote_java_tools_darwin//:toolchain",
   toolchain_type = ":javac_toolchain"
)