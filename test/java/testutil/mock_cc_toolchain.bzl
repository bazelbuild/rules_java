"""Fake cc_toolchain for testing arbitrary --platforms/--cpu"""

load("@rules_cc//cc:find_cc_toolchain.bzl", "CC_TOOLCHAIN_TYPE")
load("@rules_cc//cc/common:cc_common.bzl", "cc_common")
load("@rules_cc//cc/toolchains:cc_toolchain.bzl", "cc_toolchain")
load("@rules_cc//cc/toolchains:cc_toolchain_config_info.bzl", "CcToolchainConfigInfo")

def _mock_config_impl(ctx):
    return [
        cc_common.create_cc_toolchain_config_info(
            ctx = ctx,
            toolchain_identifier = ctx.attr.id,
            compiler = "nothing",
            # These are deprecated but are mandatory parameters for older Bazel versions.
            target_system_name = "deprecated_system_name",
            target_cpu = "deprecated_cpu",
            target_libc = "deprecated_libc",
        ),
    ]

_mock_config = rule(
    implementation = _mock_config_impl,
    attrs = {
        "id": attr.string(mandatory = True),
    },
    provides = [CcToolchainConfigInfo],
)

def mock_cc_toolchain(*, name, cpu, os, **kwargs):
    _mock_config(
        name = name + "_config",
        id = cpu + "-" + os,
        **kwargs
    )
    cc_toolchain(
        name = name + "_impl",
        all_files = ":nothing",
        as_files = ":nothing",
        compiler_files = ":nothing",
        dwp_files = ":nothing",
        linker_files = ":nothing",
        objcopy_files = ":nothing",
        strip_files = ":nothing",
        toolchain_config = name + "_config",
        **kwargs
    )
    native.toolchain(
        name = name,
        toolchain = name + "_impl",
        toolchain_type = CC_TOOLCHAIN_TYPE,
        target_compatible_with = [
            "@platforms//cpu:" + cpu,
            "@platforms//os:" + os,
        ],
        **kwargs
    )
