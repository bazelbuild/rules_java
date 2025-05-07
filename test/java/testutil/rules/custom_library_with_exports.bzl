"""Helper rule for testing compilation with `exports`"""

load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_semantics.bzl", "semantics")

def _custom_library_with_exports_impl(ctx):
    output_name = (
        ctx.label.name + "/" + ctx.attr.output_name + ".jar"
    ) if ctx.attr.output_name else "lib" + ctx.label.name + ".jar"
    output_jar = ctx.actions.declare_file(output_name)
    compilation_provider = java_common.compile(
        ctx,
        source_files = ctx.files.srcs,
        exports = [export[java_common.provider] for export in ctx.attr.exports],
        output = output_jar,
        java_toolchain = semantics.find_java_toolchain(ctx),
    )
    return [DefaultInfo(files = depset([output_jar])), compilation_provider]

custom_library_with_exports = rule(
    _custom_library_with_exports_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".java"]),
        "exports": attr.label_list(),
        "output_name": attr.string(),
    },
    toolchains = [semantics.JAVA_TOOLCHAIN_TYPE],
    fragments = ["java"],
)
