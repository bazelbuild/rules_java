"""Helper rule to test custom bootclasspaths in java_common.compile()"""

load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_semantics.bzl", "semantics")

def _bootclasspath(ctx):
    files = ctx.files.srcs
    return [java_common.BootClassPathInfo(bootclasspath = files, system = files)]

custom_bootclasspath = rule(
    implementation = _bootclasspath,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
    },
)

def _impl(ctx):
    output_jar = ctx.actions.declare_file("lib" + ctx.label.name + ".jar")
    compilation_provider = java_common.compile(
        ctx,
        source_files = ctx.files.srcs,
        output = output_jar,
        deps = [],
        sourcepath = ctx.files.sourcepath,
        strict_deps = "ERROR",
        java_toolchain = semantics.find_java_toolchain(ctx),
        bootclasspath = ctx.attr.bootclasspath[java_common.BootClassPathInfo],
    )
    return [
        DefaultInfo(files = depset([output_jar])),
        compilation_provider,
    ]

custom_library_with_bootclasspath = rule(
    implementation = _impl,
    outputs = {
        "my_output": "lib%{name}.jar",
    },
    attrs = {
        "srcs": attr.label_list(allow_files = [".java"]),
        "sourcepath": attr.label_list(allow_files = [".jar"]),
        "bootclasspath": attr.label(),
    },
    toolchains = [semantics.JAVA_TOOLCHAIN_TYPE],
    fragments = ["java"],
)
