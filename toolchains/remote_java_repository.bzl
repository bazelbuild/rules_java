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

"""Rules for importing and registering JDKs from http archive.

Rule remote_java_repository imports and registers JDK with the toolchain resolution.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _toolchain_config_impl(ctx):
    ctx.file("WORKSPACE", "workspace(name = \"{name}\")\n".format(name = ctx.name))
    ctx.file("BUILD.bazel", ctx.attr.build_file)

_toolchain_config = repository_rule(
    local = True,
    implementation = _toolchain_config_impl,
    attrs = {
        "build_file": attr.string(),
    },
)

def remote_java_repository(name, version, exec_compatible_with, prefix = "remotejdk", **kwargs):
    """Imports and registers a JDK from a http archive.

    Toolchain resolution is determined with exec_compatible_with
    parameter and constrained with --java_runtime_version flag either having value
    of "version" or "{prefix}_{version}" parameters.

    Args:
      name: A unique name for this rule.
      version: Version of the JDK imported.
      exec_compatible_with: Platform constraints (CPU and OS) for this JDK.
      prefix: Optional alternative prefix for configuration flag value used to determine this JDK.
      **kwargs: Refer to http_archive documentation
    """
    http_archive(
        name = name,
        build_file = Label("//toolchains:jdk.BUILD"),
        **kwargs
    )
    _toolchain_config(
        name = name + "_toolchain_config_repo",
        build_file = """
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
    exec_compatible_with = {exec_compatible_with},
    target_settings = [":version_or_prefix_version_setting"],
    toolchain_type = "@bazel_tools//tools/jdk:runtime_toolchain_type",
    toolchain = "{toolchain}",
)
""".format(
            prefix = prefix,
            version = version,
            exec_compatible_with = exec_compatible_with,
            toolchain = "@{repo}//:jdk".format(repo = name),
        ),
    )
