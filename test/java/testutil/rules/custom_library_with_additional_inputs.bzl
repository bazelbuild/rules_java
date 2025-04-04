"""Custom rule to test java_common.compile() with additional inputs and outputs"""

load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_semantics.bzl", "semantics")

def _impl(ctx):
    output_jar = ctx.actions.declare_file("lib" + ctx.label.name + ".jar")
    java_common.compile(
        ctx,
        source_jars = ctx.files.srcs,
        output = output_jar,
        annotation_processor_additional_inputs = ctx.files.additional_inputs,
        annotation_processor_additional_outputs = [ctx.outputs.additional_output],
        java_toolchain = semantics.find_java_toolchain(ctx),
    )
    return [DefaultInfo(files = depset([output_jar]))]

custom_library_with_additional_inputs = rule(
    implementation = _impl,
    outputs = {
        "additional_output": "%{name}_additional_output",
    },
    attrs = {
        "srcs": attr.label_list(allow_files = [".jar"]),
        "additional_inputs": attr.label_list(allow_files = [".bin"]),
    },
    toolchains = [semantics.JAVA_TOOLCHAIN_TYPE],
    fragments = ["java"],
)
