"""Helper rules to test private API usage"""

load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_info.bzl", "JavaInfo")
load("//java/common:java_semantics.bzl", "semantics")

_PRIVATE_ATTR_ATTRS = {
    "private_attr_name": attr.string(mandatory = True),
}

def _private_compile_api_impl(ctx):
    out = ctx.actions.declare_file(ctx.label.name + ".jar")
    java_common.compile(
        ctx = ctx,
        output = out,
        java_toolchain = semantics.find_java_toolchain(ctx),
        **{ctx.attr.private_attr_name: "does_not_matter"}
    )
    return []

private_compile_api_usage = rule(
    _private_compile_api_impl,
    attrs = _PRIVATE_ATTR_ATTRS,
    fragments = ["java"],
    toolchains = [semantics.JAVA_TOOLCHAIN_TYPE],
)

def _private_merge_api_impl(ctx):
    out = ctx.actions.declare_file(ctx.label.name + ".jar")
    info = JavaInfo(output_jar = out, compile_jar = out)
    java_common.merge(
        providers = [info],
        **{ctx.attr.private_attr_name: "does_not_matter"}
    )
    return []

private_merge_api_usage = rule(
    _private_merge_api_impl,
    attrs = _PRIVATE_ATTR_ATTRS,
    fragments = ["java"],
)

def _private_run_ijar_api_impl(ctx):
    java_common.run_ijar(
        ctx.actions,
        java_toolchain = semantics.find_java_toolchain(ctx),
        jar = ctx.actions.declare_file(ctx.label.name + "_ijar.jar"),
        **{ctx.attr.private_attr_name: "does_not_matter"}
    )
    return []

private_run_ijar_api_usage = rule(
    _private_run_ijar_api_impl,
    attrs = _PRIVATE_ATTR_ATTRS,
    fragments = ["java"],
    toolchains = [semantics.JAVA_TOOLCHAIN_TYPE],
)
