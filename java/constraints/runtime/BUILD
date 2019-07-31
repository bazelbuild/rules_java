load("@bazel_skylib//rules:common_settings.bzl", "string_flag")

package(default_visibility = ["//visibility:public"])

string_flag(
	name = "version",
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

constraint_value(
    name = "remote_jdk8",
    constraint_setting = ":runtime",
)

constraint_value(
    name = "remote_jdk9",
    constraint_setting = ":runtime",
)

constraint_value(
    name = "remote_jdk10",
    constraint_setting = ":runtime",
)

constraint_value(
    name = "remote_jdk11",
    constraint_setting = ":runtime",
)

constraint_value(
    name = "remote_jdk12",
    constraint_setting = ":runtime",
)