"""Helper rule to test extending compile time jdeps"""

load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_info.bzl", "JavaInfo")
load("//java/common:java_semantics.bzl", "semantics")

CompileJdepsInfo = provider("Provider to testing compile jdeps", fields = ["before", "after"])

def _compile_time_jdeps(info):
    return depset([outputs.compile_jdeps for outputs in info.java_outputs if outputs.compile_jdeps != None])

def _impl(ctx):
    output_jar = ctx.actions.declare_file("lib" + ctx.label.name + ".jar")
    info = java_common.compile(
        ctx,
        source_files = ctx.files.srcs,
        output = output_jar,
        java_toolchain = semantics.find_java_toolchain(ctx),
    )
    jdeps_info = JavaInfo(
        output_jar = output_jar,
        compile_jar = None,
        compile_jdeps = ctx.file.extra_jdeps,
    )
    extra_info = java_common.merge([info, jdeps_info])
    return [
        extra_info,
        CompileJdepsInfo(
            before = _compile_time_jdeps(info),
            after = _compile_time_jdeps(extra_info),
        ),
    ]

custom_library_extended_jdeps = rule(
    implementation = _impl,
    outputs = {
        "my_output": "lib%{name}.jar",
    },
    attrs = {
        "srcs": attr.label_list(allow_files = [".java"]),
        "extra_jdeps": attr.label(allow_single_file = True),
    },
    toolchains = [semantics.JAVA_TOOLCHAIN_TYPE],
    fragments = ["java"],
)
