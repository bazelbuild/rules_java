"""Custom rule to test the JavaPluginInfo provider"""

load("//java/common:java_info.bzl", "JavaInfo")
load(
    "//java/common:java_plugin_info.bzl",
    "JavaPluginInfo",
)

def _impl(ctx):
    output_jar = ctx.actions.declare_file(ctx.label.name + "/lib.jar")
    ctx.actions.write(output_jar, "")
    dep = JavaInfo(
        output_jar = output_jar,
        compile_jar = None,
        deps = [d[JavaInfo] for d in ctx.attr.deps],
    )
    return [JavaPluginInfo(
        runtime_deps = [dep],
        processor_class = ctx.attr.processor_class,
        data = ctx.files.data,
        generates_api = ctx.attr.generates_api,
    )]

custom_plugin = rule(
    implementation = _impl,
    attrs = {
        "deps": attr.label_list(),
        "processor_class": attr.string(),
        "data": attr.label_list(allow_files = True),
        "generates_api": attr.bool(default = False),
    },
)
