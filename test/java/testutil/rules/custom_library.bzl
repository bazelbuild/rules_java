"""Helper rule for testing compilation with default parameter values"""

load("@rules_cc//cc/common:cc_info.bzl", "CcInfo")
load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_info.bzl", "JavaInfo")
load("//java/common:java_plugin_info.bzl", "JavaPluginInfo")
load("//java/common:java_semantics.bzl", "semantics")

def _custom_library_impl(ctx):
    output_jar = ctx.actions.declare_file("lib" + ctx.label.name + ".jar")
    deps = [dep[JavaInfo] for dep in ctx.attr.deps]
    runtime_deps = [dep[JavaInfo] for dep in ctx.attr.runtime_deps]
    native_libraries = [dep[CcInfo] for dep in ctx.attr.ccdeps]
    compilation_provider = java_common.compile(
        ctx,
        source_files = ctx.files.srcs,
        source_jars = ctx.files.source_jars,
        output = output_jar,
        neverlink = ctx.attr.neverlink,
        deps = deps,
        runtime_deps = runtime_deps,
        exports = [e[JavaInfo] for e in ctx.attr.exports],
        plugins = [p[JavaPluginInfo] for p in ctx.attr.plugins],
        javac_opts = ctx.attr.javac_opts,
        java_toolchain = semantics.find_java_toolchain(ctx),
        enable_annotation_processing = ctx.attr.enable_annotation_processing,
        native_libraries = native_libraries,
    )
    return [DefaultInfo(files = depset([output_jar])), compilation_provider]

custom_library = rule(
    _custom_library_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".java"]),
        "source_jars": attr.label_list(allow_files = [".jar"]),
        "deps": attr.label_list(),
        "runtime_deps": attr.label_list(),
        "ccdeps": attr.label_list(providers = [CcInfo]),
        "exports": attr.label_list(),
        "plugins": attr.label_list(),
        "javac_opts": attr.string_list(),
        "neverlink": attr.bool(),
        "enable_annotation_processing": attr.bool(default = True),
    },
    toolchains = [semantics.JAVA_TOOLCHAIN_TYPE],
    fragments = ["java"],
)
