# Standard constraint_settings and constraint_values for Java.

package(default_visibility = ["//visibility:public"])

licenses(["notice"])

load("@bazel_skylib//rules:common_settings.bzl", "int_flag")

filegroup(
    name = "srcs",
    srcs = ["BUILD"],
)

constraint_setting(name = "runtime")

constraint_value(
    name = "host_runtime",
    constraint_setting = ":runtime",
)

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

constraint_value(
    name = "host_language",
    constraint_setting = ":language",
)

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

int_flag(
	name = "source_version",
	build_setting_default = 8
)

constraint_setting(name = "source")

constraint_value(
    name = "source_version8",
    constraint_setting = ":source",
)

constraint_value(
    name = "source_version10",
    constraint_setting = ":source",
)

int_flag(
	name = "target_version",
	build_setting_default = 8
)

constraint_setting(name = "target")

constraint_value(
    name = "target_version8",
    constraint_setting = ":target",
)

constraint_value(
    name = "target_version10",
    constraint_setting = ":target",
)

int_flag(
	name = "javac_version",
	build_setting_default = 10,
)

constraint_setting(name = "javac")

constraint_value(
    name = "javac_version10",
    constraint_setting = ":javac",
)

int_flag(
	name = "jdk_version",
	build_setting_default = 11
)

config_setting(
	name = "javac10_source_8_target_8",
	flag_values = {
		":source_version": "8",
		":target_version": "8",
		":javac_version": "10",
	}
)

config_setting(
	name = "javac10_source_10_target_10",
	flag_values = {
		":source_version": "10",
		":target_version": "10",
		":javac_version": "10",
	}
)
