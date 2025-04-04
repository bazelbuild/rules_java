"""Custom rule to test that source jar names are derived from the output jar"""

load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_semantics.bzl", "semantics")

def _impl(ctx):
    output_jar = ctx.actions.declare_file(ctx.attr.name + "/amazing.jar")
    other_output_jar = ctx.actions.declare_file(ctx.attr.name + "/wonderful.jar")
    deps = [dep[java_common.provider] for dep in ctx.attr.deps]
    compilation_provider = java_common.compile(
        ctx,
        source_files = ctx.files.srcs,
        output = output_jar,
        deps = deps,
        java_toolchain = semantics.find_java_toolchain(ctx),
    )
    other_compilation_provider = java_common.compile(
        ctx,
        source_files = ctx.files.srcs,
        output = other_output_jar,
        deps = deps,
        java_toolchain = semantics.find_java_toolchain(ctx),
    )
    result_provider = java_common.merge([compilation_provider, other_compilation_provider])
    return [
        DefaultInfo(
            files = depset([output_jar]),
        ),
        result_provider,
    ]

custom_library_with_named_outputs = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".java"]),
        "deps": attr.label_list(),
    },
    toolchains = [semantics.JAVA_TOOLCHAIN_TYPE],
    fragments = ["java"],
)
