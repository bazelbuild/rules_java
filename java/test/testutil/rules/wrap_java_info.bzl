"""Custom rule to test wrapping of the JavaInfo provider"""

load("//java/common:java_info.bzl", "JavaInfo")

JavaInfoWrappingInfo = provider(
    "Simple provider to wrap a JavaInfo",
    fields = ["p"],
)

def _impl(ctx):
    dep_params = ctx.attr.dep[JavaInfo]
    return [JavaInfoWrappingInfo(p = dep_params)]

java_info_wrapping_rule = rule(_impl, attrs = {"dep": attr.label()})
