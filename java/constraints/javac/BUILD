package(default_visibility = ["//visibility:public"])

licenses(["notice"])

load("@bazel_skylib//rules:common_settings.bzl", "string_flag")

string_flag(
	name = "version",
	build_setting_default = "11",
)

string_flag(
	name = "host_version",
	build_setting_default = "11",
)

constraint_setting(name = "javac")

constraint_value(
    name = "9",
    constraint_setting = ":javac",
)

constraint_value(
    name = "10",
    constraint_setting = ":javac",
)

constraint_value(
    name = "11",
    constraint_setting = ":javac",
)

constraint_value(
    name = "12",
    constraint_setting = ":javac",
)
