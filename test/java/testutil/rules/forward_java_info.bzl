"""Custom rule to forward a JavaInfo"""

load("//java/common:java_info.bzl", "JavaInfo")

def _impl(ctx):
    dep_params = ctx.attr.dep[JavaInfo]
    return [dep_params]

java_info_forwarding_rule = rule(_impl, attrs = {"dep": attr.label()})
