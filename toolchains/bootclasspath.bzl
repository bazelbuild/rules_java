# Copyright 2024 The Bazel Authors. All rights reserved.
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

"""Rules for extracting a platform classpath from Java runtimes."""

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("//java/common:java_common.bzl", "java_common")
load(":utf8_environment.bzl", "Utf8EnvironmentInfo")

visibility("private")

# TODO: This provider and is only necessary since --java_{language,runtime}_version
# are not available directly to Starlark.
_JavaVersionsInfo = provider(
    "Exposes the --java_{language,runtime}_version value as extracted from a transition to a dependant.",
    fields = {
        "java_language_version": "The value of --java_language_version",
        "java_runtime_version": "The value of --java_runtime_version",
    },
)

def _language_version_bootstrap_runtime(ctx):
    providers = [
        _JavaVersionsInfo(
            java_language_version = ctx.attr.java_language_version[BuildSettingInfo].value,
            java_runtime_version = ctx.attr.java_runtime_version[BuildSettingInfo].value,
        ),
    ]

    bootstrap_runtime = ctx.toolchains["@bazel_tools//tools/jdk:bootstrap_runtime_toolchain_type"]
    if bootstrap_runtime:
        providers.append(bootstrap_runtime.java_runtime)

    return providers

language_version_bootstrap_runtime = rule(
    implementation = _language_version_bootstrap_runtime,
    attrs = {
        "java_language_version": attr.label(
            providers = [BuildSettingInfo],
        ),
        "java_runtime_version": attr.label(
            providers = [BuildSettingInfo],
        ),
    },
    toolchains = [
        config_common.toolchain_type("@bazel_tools//tools/jdk:bootstrap_runtime_toolchain_type", mandatory = False),
    ],
)

def _get_bootstrap_runtime_version(*, java_language_version, java_runtime_version):
    """Returns the runtime version to use for bootstrapping the given language version.

    If the runtime version is not versioned, e.g. "local_jdk", it is used as is.
    Otherwise, the language version replaces the numeric part of the runtime version, e.g.,
    "remotejdk_17" becomes "remotejdk_8".
    """
    prefix, separator, version = java_runtime_version.rpartition("_")
    if version and version.isdigit():
        new_version = java_language_version
    else:
        # The runtime version is not versioned, e.g. "local_jdk". Use it as is.
        new_version = version

    return prefix + separator + new_version

def _bootclasspath_transition_impl(settings, _):
    java_language_version = settings["//command_line_option:java_language_version"]
    java_runtime_version = settings["//command_line_option:java_runtime_version"]

    return {
        "//command_line_option:java_runtime_version": _get_bootstrap_runtime_version(
            java_language_version = java_language_version,
            java_runtime_version = java_runtime_version,
        ),
        "//toolchains:java_language_version": java_language_version,
        "//toolchains:java_runtime_version": java_runtime_version,
    }

_bootclasspath_transition = transition(
    implementation = _bootclasspath_transition_impl,
    inputs = [
        "//command_line_option:java_language_version",
        "//command_line_option:java_runtime_version",
    ],
    outputs = [
        "//command_line_option:java_runtime_version",
        "//toolchains:java_language_version",
        "//toolchains:java_runtime_version",
    ],
)

_JAVA_BOOTSTRAP_RUNTIME_TOOLCHAIN_TYPE = Label("@bazel_tools//tools/jdk:bootstrap_runtime_toolchain_type")

# Opt the Java bootstrap actions into path mapping:
# https://github.com/bazelbuild/bazel/commit/a239ea84832f18ee8706682145e9595e71b39680
_SUPPORTS_PATH_MAPPING = {"supports-path-mapping": "1"}

def _java_home(java_executable):
    return java_executable.dirname[:-len("/bin")]

def _bootclasspath_impl(ctx):
    exec_javabase = ctx.attr.java_runtime_alias[java_common.JavaRuntimeInfo]
    env = ctx.attr._utf8_environment[Utf8EnvironmentInfo].environment

    class_dir = ctx.actions.declare_directory("%s_classes" % ctx.label.name)

    args = ctx.actions.args()
    args.add("-source")
    args.add("8")
    args.add("-target")
    args.add("8")
    args.add("-Xlint:-options")
    args.add("-J-XX:-UsePerfData")
    args.add("-d")
    args.add_all([class_dir], expand_directories = False)
    args.add(ctx.file.src)

    ctx.actions.run(
        executable = "%s/bin/javac" % exec_javabase.java_home,
        mnemonic = "JavaToolchainCompileClasses",
        inputs = [ctx.file.src] + ctx.files.java_runtime_alias,
        outputs = [class_dir],
        arguments = [args],
        env = env,
        execution_requirements = _SUPPORTS_PATH_MAPPING,
    )

    bootclasspath = ctx.outputs.output_jar

    args = ctx.actions.args()
    args.add("-XX:+IgnoreUnrecognizedVMOptions")
    args.add("-XX:-UsePerfData")
    args.add("--add-exports=jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED")
    args.add("--add-exports=jdk.compiler/com.sun.tools.javac.platform=ALL-UNNAMED")
    args.add("--add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED")
    args.add_all("-cp", [class_dir], expand_directories = False)
    args.add("DumpPlatformClassPath")
    args.add(bootclasspath)

    if ctx.attr.language_version_bootstrap_runtime:
        # The attribute is subject to a split transition.
        language_version_bootstrap_runtime = ctx.attr.language_version_bootstrap_runtime[0]
        if java_common.JavaRuntimeInfo in language_version_bootstrap_runtime:
            any_javabase = language_version_bootstrap_runtime[java_common.JavaRuntimeInfo]
        else:
            java_versions_info = language_version_bootstrap_runtime[_JavaVersionsInfo]
            bootstrap_runtime_version = _get_bootstrap_runtime_version(
                java_language_version = java_versions_info.java_language_version,
                java_runtime_version = java_versions_info.java_runtime_version,
            )
            is_exec = "-exec" in ctx.bin_dir.path
            tool_prefix = "tool_" if is_exec else ""
            fail("""
No Java runtime found to extract the bootclasspath from for --{tool_prefix}java_language_version={language_version} and --{tool_prefix}java_runtime_version={runtime_version}.
You can:

    * register a Java runtime with name "{bootstrap_runtime_version}" to provide the bootclasspath or
    * set --java_language_version to the Java version of an available runtime.

Rerun with --toolchain_resolution_debug='@bazel_tools//tools/jdk:bootstrap_runtime_toolchain_type' to see more details about toolchain resolution.
""".format(
                language_version = java_versions_info.java_language_version,
                runtime_version = java_versions_info.java_runtime_version,
                bootstrap_runtime_version = bootstrap_runtime_version,
                tool_prefix = tool_prefix,
            ))
    else:
        any_javabase = ctx.toolchains[_JAVA_BOOTSTRAP_RUNTIME_TOOLCHAIN_TYPE].java_runtime
    any_javabase_files = any_javabase.files.to_list()

    # If possible, add the Java executable to the command line as a File so that it can be path
    # mapped.
    java_executable = [f for f in any_javabase_files if f.path == any_javabase.java_executable_exec_path]
    if len(java_executable) == 1:
        args.add_all(java_executable, map_each = _java_home)
    else:
        args.add(any_javabase.java_home)

    system_files = ("release", "modules", "jrt-fs.jar")
    system = [f for f in any_javabase_files if f.basename in system_files]
    if len(system) != len(system_files):
        system = None

    inputs = depset([class_dir] + ctx.files.java_runtime_alias, transitive = [any_javabase.files])
    ctx.actions.run(
        executable = str(exec_javabase.java_executable_exec_path),
        mnemonic = "JavaToolchainCompileBootClasspath",
        inputs = inputs,
        outputs = [bootclasspath],
        arguments = [args],
        env = env,
        execution_requirements = _SUPPORTS_PATH_MAPPING,
    )
    return [
        DefaultInfo(files = depset([bootclasspath])),
        java_common.BootClassPathInfo(
            bootclasspath = [bootclasspath],
            system = system,
        ),
        OutputGroupInfo(jar = [bootclasspath]),
    ]

_bootclasspath = rule(
    implementation = _bootclasspath_impl,
    attrs = {
        "java_runtime_alias": attr.label(
            cfg = "exec",
            providers = [java_common.JavaRuntimeInfo],
        ),
        "language_version_bootstrap_runtime": attr.label(
            cfg = _bootclasspath_transition,
        ),
        "output_jar": attr.output(mandatory = True),
        "src": attr.label(
            cfg = "exec",
            allow_single_file = True,
        ),
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
        ),
        "_utf8_environment": attr.label(
            default = ":utf8_environment",
            cfg = "exec",
        ),
    },
    toolchains = [_JAVA_BOOTSTRAP_RUNTIME_TOOLCHAIN_TYPE],
)

def bootclasspath(name, **kwargs):
    _bootclasspath(
        name = name,
        output_jar = name + ".jar",
        **kwargs
    )
