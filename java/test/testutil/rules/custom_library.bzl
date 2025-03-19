"""Helper rule for testing compilation with default parameter values"""

load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_info.bzl", "JavaInfo")
load("//java/common:java_plugin_info.bzl", "JavaPluginInfo")
load("//java/common:java_semantics.bzl", "semantics")

def _custom_library_impl(ctx):
    output_jar = ctx.actions.declare_file("lib" + ctx.label.name + ".jar")
    deps = [dep[JavaInfo] for dep in ctx.attr.deps]
    runtime_deps = [dep[JavaInfo] for dep in ctx.attr.runtime_deps]
    compilation_provider = java_common.compile(
        ctx,
        source_files = ctx.files.srcs,
        output = output_jar,
        deps = deps,
        runtime_deps = runtime_deps,
        exports = [e[JavaInfo] for e in ctx.attr.exports],
        plugins = [p[JavaPluginInfo] for p in ctx.attr.plugins],
        java_toolchain = semantics.find_java_toolchain(ctx),
    )
    return [DefaultInfo(files = depset([output_jar])), compilation_provider]

custom_library = rule(
    _custom_library_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".java"]),
        "deps": attr.label_list(),
        "runtime_deps": attr.label_list(),
        "exports": attr.label_list(),
        "plugins": attr.label_list(),
    },
    toolchains = [semantics.JAVA_TOOLCHAIN_TYPE],
    fragments = ["java"],
)
