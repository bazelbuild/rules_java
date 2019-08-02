package(default_visibility = ["//visibility:public"])

licenses(["notice"])

load(
    "@rules_java//java/constraints:constraints.bzl",
    "LINUX_CONSTRAINTS",
    "MACOS_CONSTRAINTS",
    "WINDOWS_CONSTRAINTS",
    "JAVAC9_LANGUAGE8_CONSTRAINTS",
    "JAVAC10_LANGUAGE8_CONSTRAINTS",
    "JAVAC11_LANGUAGE8_CONSTRAINTS",
    "JAVAC12_LANGUAGE8_CONSTRAINTS",
    "JDK9_CONSTRAINTS",
    "JDK10_CONSTRAINTS",
    "JDK11_CONSTRAINTS",
    "JDK12_CONSTRAINTS",
    "REMOTE_JDK9_CONSTRAINTS",
    "REMOTE_JDK10_CONSTRAINTS",
    "REMOTE_JDK11_CONSTRAINTS",
    "REMOTE_JDK12_CONSTRAINTS",
)

JAVAC_TOOLCHAIN_CONSTRAINTS = select({
  "@rules_java//java/config:javac9_language8": JAVAC9_LANGUAGE8_CONSTRAINTS,
  "@rules_java//java/config:javac10_language8": JAVAC10_LANGUAGE8_CONSTRAINTS,
  "@rules_java//java/config:javac11_language8": JAVAC11_LANGUAGE8_CONSTRAINTS,
  "@rules_java//java/config:javac12_language8": JAVAC12_LANGUAGE8_CONSTRAINTS,
})

JAVA_RUNTIME_TOOLCHAIN_CONSTRAINTS = select({
 "@rules_java//java/config:jdk9": JDK9_CONSTRAINTS,
 "@rules_java//java/config:jdk10": JDK10_CONSTRAINTS,
 "@rules_java//java/config:jdk11": JDK11_CONSTRAINTS,
 "@rules_java//java/config:jdk12": JDK12_CONSTRAINTS,
 "@rules_java//java/config:remote_jdk9": REMOTE_JDK9_CONSTRAINTS,
 "@rules_java//java/config:remote_jdk10": REMOTE_JDK10_CONSTRAINTS,
 "@rules_java//java/config:remote_jdk11": REMOTE_JDK11_CONSTRAINTS,
 "@rules_java//java/config:remote_jdk12": REMOTE_JDK12_CONSTRAINTS,
})

JAVAC_TOOLCHAIN_HOST_CONSTRAINTS = select({
  "@rules_java//java/config/host:javac9_language8": JAVAC9_LANGUAGE8_CONSTRAINTS,
  "@rules_java//java/config/host:javac10_language8": JAVAC10_LANGUAGE8_CONSTRAINTS,
  "@rules_java//java/config/host:javac11_language8": JAVAC11_LANGUAGE8_CONSTRAINTS,
  "@rules_java//java/config/host:javac12_language8": JAVAC12_LANGUAGE8_CONSTRAINTS,
})

JAVA_RUNTIME_TOOLCHAIN_HOST_CONSTRAINTS = select({
 "@rules_java//java/config/host:jdk9": JDK9_CONSTRAINTS,
 "@rules_java//java/config/host:jdk10": JDK10_CONSTRAINTS,
 "@rules_java//java/config/host:jdk11": JDK11_CONSTRAINTS,
 "@rules_java//java/config/host:jdk12": JDK12_CONSTRAINTS,
 "@rules_java//java/config/host:remote_jdk9": REMOTE_JDK9_CONSTRAINTS,
 "@rules_java//java/config/host:remote_jdk10": REMOTE_JDK10_CONSTRAINTS,
 "@rules_java//java/config/host:remote_jdk11": REMOTE_JDK11_CONSTRAINTS,
 "@rules_java//java/config/host:remote_jdk12": REMOTE_JDK12_CONSTRAINTS,
})

platform(
    name = "linux_x86_64",
    constraint_values = LINUX_CONSTRAINTS + JAVAC_TOOLCHAIN_CONSTRAINTS + JAVA_RUNTIME_TOOLCHAIN_CONSTRAINTS,
)

platform(
    name = "host_linux_x86_64",
    constraint_values = LINUX_CONSTRAINTS + JAVAC_TOOLCHAIN_HOST_CONSTRAINTS + JAVA_RUNTIME_TOOLCHAIN_HOST_CONSTRAINTS,
)

platform(
    name = "windows_x86_64",
    constraint_values = WINDOWS_CONSTRAINTS + JAVAC_TOOLCHAIN_CONSTRAINTS + JAVA_RUNTIME_TOOLCHAIN_CONSTRAINTS,
)

platform(
    name = "host_windows_x86_64",
    constraint_values = WINDOWS_CONSTRAINTS + JAVAC_TOOLCHAIN_HOST_CONSTRAINTS + JAVA_RUNTIME_TOOLCHAIN_HOST_CONSTRAINTS,
)

platform(
    name = "macos_x86_64",
    constraint_values = MACOS_CONSTRAINTS + JAVAC_TOOLCHAIN_CONSTRAINTS + JAVA_RUNTIME_TOOLCHAIN_CONSTRAINTS,
)

platform(
    name = "host_macos_x86_64",
    constraint_values = MACOS_CONSTRAINTS + JAVAC_TOOLCHAIN_HOST_CONSTRAINTS + JAVA_RUNTIME_TOOLCHAIN_HOST_CONSTRAINTS,
)
