# Standard constraint_settings and constraint_values for Java.

package(default_visibility = ["//visibility:public"])

licenses(["notice"])

filegroup(
    name = "srcs",
    srcs = ["BUILD"],
)

constraint_setting(name = "runtime")

constraint_value(
    name = "jdk8",
    constraint_setting = ":runtime",
)

constraint_value(
    name = "jdk9",
    constraint_setting = ":runtime",
)

constraint_value(
    name = "jdk10",
    constraint_setting = ":runtime",
)

constraint_value(
    name = "jdk11",
    constraint_setting = ":runtime",
)

constraint_value(
    name = "jdk12",
    constraint_setting = ":runtime",
)

constraint_setting(name = "language")

# visibility
constraint_value(
    name = "java7",
    constraint_setting = ":language",
)

constraint_value(
    name = "java8",
    constraint_setting = ":language",
)

constraint_value(
    name = "java9",
    constraint_setting = ":language",
)

constraint_value(
    name = "java10",
    constraint_setting = ":language",
)

constraint_value(
    name = "java11",
    constraint_setting = ":language",
)

constraint_value(
    name = "java12",
    constraint_setting = ":language",
)

platform(
    name = "jdk8_linux_x86",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
        ":jdk8",
        ":java8"
    ]
)

platform(
    name = "jdk9_linux_x86",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
        ":jdk9",
        ":java8"
    ]
)

platform(
    name = "jdk10_linux_x86",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
        ":jdk10",
        ":java8"
    ]
)

platform(
    name = "jdk11_linux_x86",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
        ":jdk11",
        ":java8"
    ]
)

platform(
    name = "jdk12_linux_x86",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
        ":jdk12",
        ":java8"
    ]
)