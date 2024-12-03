# Copyright 2022 The Bazel Authors. All rights reserved.
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

"""Rules for defining default_java_toolchain"""

load("//java/common:java_common.bzl", "java_common")
load("//java/toolchains:java_toolchain.bzl", "java_toolchain")
load(":bootclasspath.bzl", _bootclasspath = "bootclasspath")

# JVM options, without patching java.compiler and jdk.compiler modules.
BASE_JDK9_JVM_OPTS = [
    # Allow JavaBuilder to access internal javac APIs.
    "--add-exports=jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED",
    "--add-exports=jdk.compiler/com.sun.tools.javac.main=ALL-UNNAMED",
    "--add-exports=jdk.compiler/com.sun.tools.javac.model=ALL-UNNAMED",
    "--add-exports=jdk.compiler/com.sun.tools.javac.processing=ALL-UNNAMED",
    "--add-exports=jdk.compiler/com.sun.tools.javac.resources=ALL-UNNAMED",
    "--add-exports=jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED",
    "--add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED",
    "--add-opens=jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED",
    "--add-opens=jdk.compiler/com.sun.tools.javac.comp=ALL-UNNAMED",
    "--add-opens=jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED",
    "--add-opens=jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED",

    # quiet warnings from com.google.protobuf.UnsafeUtil,
    # see: https://github.com/google/protobuf/issues/3781
    # and: https://github.com/bazelbuild/bazel/issues/5599
    "--add-opens=java.base/java.nio=ALL-UNNAMED",
    "--add-opens=java.base/java.lang=ALL-UNNAMED",

    # TODO(b/64485048): Disable this option in persistent worker mode only.
    # Disable symlinks resolution cache since symlinks in exec root change
    "-Dsun.io.useCanonCaches=false",

    # Compact strings make JavaBuilder slightly slower.
    "-XX:-CompactStrings",

    # Since https://bugs.openjdk.org/browse/JDK-8153723, JVM logging goes to stdout. This
    # makes it go to stderr instead.
    "-Xlog:disable",
    "-Xlog:all=warning:stderr:uptime,level,tags",
]

JDK9_JVM_OPTS = BASE_JDK9_JVM_OPTS

DEFAULT_JAVACOPTS = [
    "-XDskipDuplicateBridges=true",
    "-XDcompilePolicy=simple",
    "--should-stop=ifError=FLOW",  # See b/27049950, https://github.com/google/error-prone/issues/4595
    "-g",
    "-parameters",
    # https://github.com/bazelbuild/bazel/issues/15219
    "-Xep:ReturnValueIgnored:OFF",
    # https://github.com/bazelbuild/bazel/issues/16996
    "-Xep:IgnoredPureGetter:OFF",
    "-Xep:EmptyTopLevelDeclaration:OFF",
    "-Xep:LenientFormatStringValidation:OFF",
    "-Xep:ReturnMissingNullable:OFF",
    "-Xep:UseCorrectAssertInTests:OFF",
]

# If this is changed, the docs for "{,tool_}java_language_version" also
# need to be updated in the Bazel user manual
_DEFAULT_JAVA_LANGUAGE_VERSION = "11"

# Default java_toolchain parameters
_BASE_TOOLCHAIN_CONFIGURATION = dict(
    forcibly_disable_header_compilation = False,
    genclass = [Label("@remote_java_tools//:GenClass")],
    header_compiler = [Label("@remote_java_tools//:TurbineDirect")],
    header_compiler_direct = [Label("//toolchains:turbine_direct")],
    ijar = [Label("//toolchains:ijar")],
    javabuilder = [Label("@remote_java_tools//:JavaBuilder")],
    javac_supports_workers = True,
    jacocorunner = Label("@remote_java_tools//:jacoco_coverage_runner_filegroup"),
    jvm_opts = BASE_JDK9_JVM_OPTS,
    turbine_jvm_opts = [
        # Turbine is not a worker and parallel GC is faster for short-lived programs.
        "-XX:+UseParallelGC",
    ],
    misc = DEFAULT_JAVACOPTS,
    singlejar = [Label("//toolchains:singlejar")],
    # Code to enumerate target JVM boot classpath uses host JVM. Because
    # java_runtime-s are involved, its implementation is in @bazel_tools.
    bootclasspath = [Label("//toolchains:platformclasspath")],
    source_version = _DEFAULT_JAVA_LANGUAGE_VERSION,
    target_version = _DEFAULT_JAVA_LANGUAGE_VERSION,
    reduced_classpath_incompatible_processors = [
        "dagger.hilt.processor.internal.root.RootProcessor",  # see b/21307381
    ],
    java_runtime = Label("//toolchains:remotejdk_21"),
    oneversion = Label("//toolchains:one_version"),
)

DEFAULT_TOOLCHAIN_CONFIGURATION = _BASE_TOOLCHAIN_CONFIGURATION

# The 'vanilla' toolchain is an unsupported alternative to the default.
#
# It does not provide any of the following features:
#   * Error Prone
#   * Strict Java Deps
#   * Reduced Classpath Optimization
#
# It uses the version of internal javac from the `--host_javabase` JDK instead
# of providing a javac. Internal javac may not be source- or bug-compatible with
# the javac that is provided with other toolchains.
#
# However it does allow using a wider range of `--host_javabase`s, including
# versions newer than the current JDK.
VANILLA_TOOLCHAIN_CONFIGURATION = dict(
    javabuilder = [Label("@remote_java_tools//:VanillaJavaBuilder")],
    jvm_opts = [],
    java_runtime = None,
)

# The new toolchain is using all the pre-built tools, including
# singlejar and ijar, even on remote execution. This toolchain
# should be used only when host and execution platform are the
# same, otherwise the binaries will not work on the execution
# platform.
PREBUILT_TOOLCHAIN_CONFIGURATION = dict(
    ijar = [Label("//toolchains:ijar_prebuilt_binary")],
    singlejar = [Label("//toolchains:prebuilt_singlejar")],
    oneversion = Label("//toolchains:prebuilt_one_version"),
)

# The new toolchain is using all the tools from sources.
NONPREBUILT_TOOLCHAIN_CONFIGURATION = dict(
    ijar = [Label("@remote_java_tools//:ijar_cc_binary")],
    singlejar = [Label("@remote_java_tools//:singlejar_cc_bin")],
    header_compiler_direct = [Label("@remote_java_tools//:TurbineDirect")],
    oneversion = Label("@remote_java_tools//:one_version_cc_bin"),
)

def default_java_toolchain(name, configuration = DEFAULT_TOOLCHAIN_CONFIGURATION, toolchain_definition = True, exec_compatible_with = [], target_compatible_with = [], **kwargs):
    """Defines a remote java_toolchain with appropriate defaults for Bazel.

    Args:
        name: The name of the toolchain
        configuration: Toolchain configuration
        toolchain_definition: Whether to define toolchain target and its config setting
        exec_compatible_with: A list of constraint values that must be
            satisifed for the exec platform.
        target_compatible_with: A list of constraint values that must be
            satisifed for the target platform.
        **kwargs: More arguments for the java_toolchain target
    """

    toolchain_args = dict(_BASE_TOOLCHAIN_CONFIGURATION)
    toolchain_args.update(configuration)
    toolchain_args.update(kwargs)
    java_toolchain(
        name = name,
        **toolchain_args
    )
    if toolchain_definition:
        source_version = toolchain_args["source_version"]
        if source_version == _DEFAULT_JAVA_LANGUAGE_VERSION:
            native.config_setting(
                name = name + "_default_version_setting",
                values = {"java_language_version": ""},
                visibility = ["//visibility:private"],
            )
            native.toolchain(
                name = name + "_default_definition",
                toolchain_type = Label("@bazel_tools//tools/jdk:toolchain_type"),
                target_settings = [name + "_default_version_setting"],
                toolchain = name,
                exec_compatible_with = exec_compatible_with,
                target_compatible_with = target_compatible_with,
            )

        native.config_setting(
            name = name + "_version_setting",
            values = {"java_language_version": source_version},
            visibility = ["//visibility:private"],
        )
        native.toolchain(
            name = name + "_definition",
            toolchain_type = Label("@bazel_tools//tools/jdk:toolchain_type"),
            target_settings = [name + "_version_setting"],
            toolchain = name,
            exec_compatible_with = exec_compatible_with,
            target_compatible_with = target_compatible_with,
        )

def java_runtime_files(name, srcs):
    """Copies the given sources out of the current Java runtime."""

    native.filegroup(
        name = name,
        srcs = srcs,
        tags = ["manual"],
    )
    for src in srcs:
        native.genrule(
            name = "gen_%s" % src,
            srcs = [Label("//toolchains:current_java_runtime")],
            toolchains = [Label("//toolchains:current_java_runtime")],
            cmd = "cp $(JAVABASE)/%s $@" % src,
            outs = [src],
            tags = ["manual"],
        )

bootclasspath = _bootclasspath
