"""Custom rule to test java_common.compile() with a custom output source jar"""

load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_semantics.bzl", "semantics")

def _impl(ctx):
    output_jar = ctx.actions.declare_file("lib" + ctx.label.name + ".jar")
    output_source_jar = ctx.actions.declare_file("lib" + ctx.label.name + "-mysrc.jar")
    compilation_provider = java_common.compile(
        ctx,
        source_jars = ctx.files.srcs,
        output = output_jar,
        output_source_jar = output_source_jar,
        java_toolchain = semantics.find_java_toolchain(ctx),
    )
    return [
        DefaultInfo(
            files = depset([output_source_jar]),
        ),
        compilation_provider,
    ]

custom_library_with_custom_output_source_jar = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".jar"]),
    },
    toolchains = [semantics.JAVA_TOOLCHAIN_TYPE],
    fragments = ["java"],
)
