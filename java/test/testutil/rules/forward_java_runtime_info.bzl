"""Helper rule to test java_runtime and JavaRuntimeInfo"""

load("//java/common:java_common.bzl", "java_common")

def _impl(ctx):
    return ctx.attr.java_runtime[java_common.JavaRuntimeInfo]

java_runtime_info_forwarding_rule = rule(
    _impl,
    attrs = {
        "java_runtime": attr.label(),
    },
)
