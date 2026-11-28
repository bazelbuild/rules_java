# Copyright 2020 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Rules for importing JDKs from http archive.

Rule remote_java_repository imports a JDK and creates toolchain definitions for it.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//toolchains:jdk_build_file.bzl", "JDK_BUILD_TEMPLATE")

def _toolchain_config_impl(ctx):
    ctx.file("WORKSPACE", "workspace(name = \"{name}\")\n".format(name = ctx.name))
    ctx.file("BUILD.bazel", ctx.attr.build_file)
    if hasattr(ctx, "repo_metadata"):
        return ctx.repo_metadata(reproducible = True)
    return None

_toolchain_config = repository_rule(
    local = True,
    implementation = _toolchain_config_impl,
    attrs = {
        "build_file": attr.string(),
    },
)

def _toolchain_configs_impl(ctx):
    ctx.file("WORKSPACE", "workspace(name = \"{name}\")\n".format(name = ctx.name))
    ctx.file("BUILD.bazel", "")
    for package, build_file in ctx.attr.build_files.items():
        ctx.file(package + "/BUILD.bazel", build_file)
    if hasattr(ctx, "repo_metadata"):
        return ctx.repo_metadata(reproducible = True)
    return None

remote_java_toolchain_configs = repository_rule(
    implementation = _toolchain_configs_impl,
    doc = """Holds the toolchain definitions of many remote JDKs, one package per JDK.

Registering `@<name>//<jdk>:all` for every JDK fetches this single repository, while registering
`@<jdk>_toolchain_config_repo//:all` fetches one repository per JDK.""",
    attrs = {
        "build_files": attr.string_dict(doc = "The BUILD file of each package, keyed by package."),
    },
)

def remote_java_toolchain_config(name, version, target_compatible_with = None, prefix = "remotejdk"):
    """Returns the BUILD file that defines the toolchains of the remote JDK `@<name>`.

    Args:
      name: The name of the JDK repository.
      version: Version of the JDK.
      target_compatible_with: Target platform constraints (CPU and OS) for this JDK.
      prefix: Optional alternative prefix for configuration flag value used to determine this JDK.

    Returns:
      The BUILD file content.
    """
    return """
config_setting(
    name = "prefix_version_setting",
    values = {{"java_runtime_version": "{prefix}_{version}"}},
    visibility = ["//visibility:private"],
)
config_setting(
    name = "version_setting",
    values = {{"java_runtime_version": "{version}"}},
    visibility = ["//visibility:private"],
)
alias(
    name = "version_or_prefix_version_setting",
    actual = select({{
        ":version_setting": ":version_setting",
        "//conditions:default": ":prefix_version_setting",
    }}),
    visibility = ["//visibility:private"],
)
toolchain(
    name = "toolchain",
    target_compatible_with = {target_compatible_with},
    target_settings = [":version_or_prefix_version_setting"],
    toolchain_type = "@bazel_tools//tools/jdk:runtime_toolchain_type",
    toolchain = "{toolchain}",
)
toolchain(
    name = "bootstrap_runtime_toolchain",
    # These constraints are not required for correctness, but prevent fetches of remote JDK for
    # different architectures. As every Java compilation toolchain depends on a bootstrap runtime in
    # the same configuration, this constraint will not result in toolchain resolution failures.
    exec_compatible_with = {target_compatible_with},
    target_settings = [":version_or_prefix_version_setting"],
    toolchain_type = "@bazel_tools//tools/jdk:bootstrap_runtime_toolchain_type",
    toolchain = "{toolchain}",
)
""".format(
        prefix = prefix,
        version = version,
        target_compatible_with = target_compatible_with,
        toolchain = "@{repo}//:jdk".format(repo = name),
    )

def remote_java_repository(name, version, target_compatible_with = None, prefix = "remotejdk", **kwargs):
    """Imports a JDK from a http archive and creates runtime toolchain definitions for it.

    Register the toolchains defined by this macro via `register_toolchains("@<name>//:all")`, where
    `<name>` is the value of the `name` parameter.

    Toolchain resolution is determined with target_compatible_with
    parameter and constrained with --java_runtime_version flag either having value
    of "version" or "{prefix}_{version}" parameters.

    Args:
      name: A unique name for this rule.
      version: Version of the JDK imported.
      target_compatible_with: Target platform constraints (CPU and OS) for this JDK.
      prefix: Optional alternative prefix for configuration flag value used to determine this JDK.
      **kwargs: Refer to http_archive documentation
    """
    http_archive(
        name = name,
        build_file_content = JDK_BUILD_TEMPLATE.format(RUNTIME_VERSION = version),
        **kwargs
    )
    _toolchain_config(
        name = name + "_toolchain_config_repo",
        build_file = remote_java_toolchain_config(name, version, target_compatible_with, prefix),
    )
