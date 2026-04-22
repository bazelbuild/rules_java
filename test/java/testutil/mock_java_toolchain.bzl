"""Fake java toolchains for testing"""

load("//java/common:java_semantics.bzl", "semantics")
load("//java/toolchains:java_runtime.bzl", _java_runtime_rule = "java_runtime")
load("//java/toolchains:java_toolchain.bzl", "java_toolchain")

# buildifier: disable=function-docstring
def mock_java_toolchain(
        *,
        name,
        singlejar = "singlejar",
        javabuilder = "JavaBuilder_deploy.jar",
        header_compiler = "turbine_canary_deploy.jar",
        header_compiler_direct = "turbine_direct",
        ijar = "ijar",
        genclass = "genclass",
        java_runtime = None,
        tags = None,  # for util.helper_target
        **kwargs):
    if not java_runtime:
        java_runtime = name + "_runtime"
        _java_runtime_rule(name = java_runtime)
    java_toolchain(
        name = name + "_java",
        javabuilder = javabuilder,
        singlejar = singlejar,
        header_compiler = header_compiler,
        header_compiler_direct = header_compiler_direct,
        ijar = ijar,
        java_runtime = java_runtime,
        genclass = genclass,
        tags = tags,
        **kwargs
    )
    native.toolchain(
        name = name,
        toolchain = name + "_java",
        toolchain_type = semantics.JAVA_TOOLCHAIN_TYPE,
        tags = tags,
    )

# buildifier: disable=function-docstring
def mock_java_runtime_toolchain(
        *,
        name,
        srcs = [],
        java_home = None,
        java = None,
        version = None,
        **kwargs):
    _java_runtime_rule(
        name = name + "_runtime",
        srcs = srcs,
        java_home = java_home,
        java = java,
        version = version,
        **kwargs
    )
    native.toolchain(
        name = name,
        toolchain = name + "_runtime",
        toolchain_type = semantics.JAVA_RUNTIME_TOOLCHAIN_TYPE,
        **kwargs
    )
