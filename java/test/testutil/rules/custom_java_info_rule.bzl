"""Helper rule for creating JavaInfo instances"""

load("@rules_cc//cc/common:cc_info.bzl", "CcInfo")
load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_info.bzl", "JavaInfo")
load("//java/common:java_plugin_info.bzl", "JavaPluginInfo")
load("//java/common:java_semantics.bzl", "semantics")

def _impl(ctx):
    if ctx.attr.use_ijar and ctx.attr.stamp_jar:
        fail("only one of use_ijar or stamp_jar may be set")
    ctx.actions.write(ctx.outputs.output_jar, "JavaInfo API Test", is_executable = False)
    dp = [dep[JavaInfo] for dep in ctx.attr.dep]
    dp_runtime = [dep[JavaInfo] for dep in ctx.attr.dep_runtime]
    dp_exports = [dep[java_common.provider] for dep in ctx.attr.dep_exports]
    dp_exported_plugins = [dep[JavaPluginInfo] for dep in ctx.attr.dep_exported_plugins]
    source_jar = java_common.pack_sources(
        ctx.actions,
        output_source_jar = ctx.actions.declare_file(ctx.outputs.output_jar.basename[:-4] + "-src.jar", sibling = ctx.outputs.output_jar),
        sources = ctx.files.sources,
        source_jars = ctx.files.source_jars,
        java_toolchain = semantics.find_java_toolchain(ctx),
    ) if ctx.attr.pack_sources else (
        ctx.files.source_jars[0] if ctx.files.source_jars else None
    )
    dp_libs = [dep[CcInfo] for dep in ctx.attr.cc_dep]
    compile_jar = java_common.run_ijar(
        ctx.actions,
        jar = ctx.outputs.output_jar,
        java_toolchain = semantics.find_java_toolchain(ctx),
    ) if ctx.attr.use_ijar else (
        java_common.stamp_jar(
            ctx.actions,
            jar = ctx.outputs.output_jar,
            target_label = ctx.label,
            java_toolchain = semantics.find_java_toolchain(ctx),
        ) if ctx.attr.stamp_jar else ctx.outputs.output_jar
    )

    return [
        JavaInfo(
            output_jar = ctx.outputs.output_jar,
            compile_jar = compile_jar,
            source_jar = source_jar,
            deps = dp,
            runtime_deps = dp_runtime,
            exports = dp_exports,
            exported_plugins = dp_exported_plugins,
            native_libraries = dp_libs,
            neverlink = ctx.attr.neverlink,
            jdeps = ctx.file.jdeps,
            compile_jdeps = ctx.file.compile_jdeps,
            generated_class_jar = ctx.file.generated_class_jar,
            generated_source_jar = ctx.file.generated_source_jar,
        ),
    ]

custom_java_info_rule = rule(
    _impl,
    attrs = {
        "output_jar": attr.output(mandatory = True),
        "source_jars": attr.label_list(allow_files = [".jar"]),
        "sources": attr.label_list(allow_files = [".java"]),
        "dep": attr.label_list(),
        "dep_runtime": attr.label_list(),
        "dep_exports": attr.label_list(),
        "dep_exported_plugins": attr.label_list(),
        "cc_dep": attr.label_list(),
        "jdeps": attr.label(allow_single_file = True),
        "compile_jdeps": attr.label(allow_single_file = True),
        "generated_class_jar": attr.label(allow_single_file = True),
        "generated_source_jar": attr.label(allow_single_file = True),
        "use_ijar": attr.bool(default = False),
        "neverlink": attr.bool(default = False),
        "pack_sources": attr.bool(default = False),
        "stamp_jar": attr.bool(default = False),
    },
    toolchains = [semantics.JAVA_TOOLCHAIN_TYPE],
)
