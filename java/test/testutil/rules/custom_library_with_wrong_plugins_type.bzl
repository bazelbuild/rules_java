"""Custom rule to test java_common.compile(plugins = ...) expects JavaPluginInfo"""

load("//java:defs.bzl", "JavaInfo", "java_common")
load("//java/common:java_semantics.bzl", "semantics")

def _impl(ctx):
    output_jar = ctx.actions.declare_file("lib" + ctx.label.name + ".jar")
    return java_common.compile(
        ctx,
        source_files = ctx.files.srcs,
        plugins = [p[JavaInfo] for p in ctx.attr.deps],
        output = output_jar,
        java_toolchain = semantics.find_java_toolchain(ctx),
    )

custom_library_with_wrong_plugins_type = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".java"]),
        "deps": attr.label_list(),
    },
    toolchains = [semantics.JAVA_TOOLCHAIN_TYPE],
    fragments = ["java"],
)
