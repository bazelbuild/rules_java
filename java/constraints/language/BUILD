package(default_visibility = ["//visibility:public"])

licenses(["notice"])

load("@bazel_skylib//rules:common_settings.bzl", "string_flag")

string_flag(
	name = "version",
	build_setting_default = "8",
)

string_flag(
	name = "host_version",
	build_setting_default = "8",
)

constraint_setting(name = "language")

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
