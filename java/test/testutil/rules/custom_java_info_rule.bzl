"""Helper rule for creating JavaInfo instances"""

load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_info.bzl", "JavaInfo")
load("//java/common:java_semantics.bzl", "semantics")

def _impl(ctx):
    ctx.actions.write(ctx.outputs.output_jar, "JavaInfo API Test", is_executable = False)
    source_jar = ctx.files.source_jars[0] if ctx.files.source_jars else None
    compile_jar = java_common.run_ijar(
        ctx.actions,
        jar = ctx.outputs.output_jar,
        java_toolchain = semantics.find_java_toolchain(ctx),
    ) if ctx.attr.use_ijar else ctx.outputs.output_jar

    return [
        JavaInfo(
            output_jar = ctx.outputs.output_jar,
            compile_jar = compile_jar,
            source_jar = source_jar,
        ),
    ]

custom_java_info_rule = rule(
    _impl,
    attrs = {
        "output_jar": attr.output(mandatory = True),
        "source_jars": attr.label_list(allow_files = [".jar"]),
        "use_ijar": attr.bool(default = False),
    },
    toolchains = [semantics.JAVA_TOOLCHAIN_TYPE],
)
