"""Helper rule for testing java_common.merge"""

load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_info.bzl", "JavaInfo")

def _impl(ctx):
    java_infos = [dep[JavaInfo] for dep in ctx.attr.deps]
    merged_info = java_common.merge(java_infos)
    return [merged_info]

java_info_merge_rule = rule(
    implementation = _impl,
    attrs = {
        "deps": attr.label_list(providers = [JavaInfo]),
    },
    provides = [JavaInfo],
)
