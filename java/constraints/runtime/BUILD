package(default_visibility = ["//visibility:public"])

licenses(["notice"])

load("@bazel_skylib//rules:common_settings.bzl", "string_flag")

string_flag(
	name = "version",
	build_setting_default = "11"
)

string_flag(
	name = "host_version",
	build_setting_default = "11"
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

constraint_setting(name = "local_or_remote")

string_flag(
	name = "is_local",
	build_setting_default = "local"
)

string_flag(
	name = "is_host_local",
	build_setting_default = "remote"
)

constraint_value(
    name = "local",
    constraint_setting = ":local_or_remote",
)

constraint_value(
    name = "remote",
    constraint_setting = ":local_or_remote",
)
