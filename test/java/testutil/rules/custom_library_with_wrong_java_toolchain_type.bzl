"""Custom rule to test java_common.compile(java_toolchain = ...) expects JavaToolchainInfo"""

load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_semantics.bzl", "semantics")

def _impl(ctx):
    output_jar = ctx.actions.declare_file("lib" + ctx.label.name + ".jar")
    return java_common.compile(
        ctx,
        source_files = ctx.files.srcs,
        output = output_jar,
        java_toolchain = ctx.attr._java_toolchain[platform_common.ToolchainInfo],
    )

custom_library_with_wrong_java_toolchain_type = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".java"]),
        "deps": attr.label_list(),
        "_java_toolchain": attr.label(default = semantics.JAVA_TOOLCHAIN_LABEL),
    },
    toolchains = [semantics.JAVA_TOOLCHAIN_TYPE],
    fragments = ["java"],
)
