LINUX_CONSTRAINTS = ["@platforms//os:linux", "@platforms//cpu:x86_64",]
WINDOWS_CONSTRAINTS = ["@platforms//os:windows", "@platforms//cpu:x86_64",]
MACOS_CONSTRAINTS = ["@platforms//os:osx", "@platforms//cpu:x86_64",]

JAVAC10_SOURCE10_TARGET10_CONSTRAINTS = [
    "@rules_java//java/constraints:source_version10",
    "@rules_java//java/constraints:target_version10",
    "@rules_java//java/constraints:javac_version10",
]

JAVAC10_SOURCE8_TARGET8_CONSTRAINTS = [
    "@rules_java//java/constraints:source_version8",
    "@rules_java//java/constraints:target_version8",
    "@rules_java//java/constraints:javac_version10",
]


platform(
    name = "linux_x86_64",
    constraint_values = select({
        "@rules_java//java/config:javac10_source_8_target_8": JAVAC10_SOURCE8_TARGET8_CONSTRAINTS,
        "@rules_java//java/config:javac10_source_10_target_10": JAVAC10_SOURCE10_TARGET10_CONSTRAINTS,
    }),
    parents = ["@local_config_platform//:host"]
)

platform(
    name = "linux_x86_64_only",
    constraint_values = LINUX_CONSTRAINTS,
)