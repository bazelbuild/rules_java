package(default_visibility = ["//visibility:public"])

load("@local_config_platform//:constraints.bzl", 'HOST_CONSTRAINTS')

platform(
    name = "host_java_platform",
#    parents = ["@local_config_platform//:host"],
    constraint_values = HOST_CONSTRAINTS + [
        "@rules_java//java/constraints:host",
    ],
)