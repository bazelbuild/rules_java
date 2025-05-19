"""Helper rule for testing compilation with default parameter values"""

load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_semantics.bzl", "semantics")

def _custom_library_impl(ctx):
    output_jar = ctx.actions.declare_file("lib" + ctx.label.name + ".jar")
    compilation_provider = java_common.compile(
        ctx,
        output = output_jar,
        strict_deps = ctx.attr.strict_deps,
        java_toolchain = semantics.find_java_toolchain(ctx),
    )
    return [DefaultInfo(files = depset([output_jar])), compilation_provider]

custom_library_with_strict_deps = rule(
    _custom_library_impl,
    attrs = {
        "strict_deps": attr.string(),
    },
    toolchains = [semantics.JAVA_TOOLCHAIN_TYPE],
    fragments = ["java"],
)
