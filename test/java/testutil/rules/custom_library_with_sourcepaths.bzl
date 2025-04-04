"""Helper rule for testing compilation with `sourcepath`s"""

load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_semantics.bzl", "semantics")

def _custom_library_with_sourcepaths_impl(ctx):
    output_jar = ctx.actions.declare_file("lib" + ctx.label.name + ".jar")
    compilation_provider = java_common.compile(
        ctx,
        source_files = ctx.files.srcs,
        output = output_jar,
        sourcepath = ctx.files.sourcepath,
        java_toolchain = semantics.find_java_toolchain(ctx),
    )
    return [DefaultInfo(files = depset([output_jar])), compilation_provider]

custom_library_with_sourcepaths = rule(
    _custom_library_with_sourcepaths_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".java"]),
        "sourcepath": attr.label_list(allow_files = [".jar"]),
    },
    toolchains = [semantics.JAVA_TOOLCHAIN_TYPE],
    fragments = ["java"],
)
