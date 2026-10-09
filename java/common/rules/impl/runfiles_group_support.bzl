# Copyright 2026 The Bazel Authors. All rights reserved.
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

"""
Describes the runfiles groups of the Java rules for rules_runfiles_group.

A packaging rule (a container image or archive rule) walks a binary's graph with
an aspect and asks each target's runfiles group describer what it adds to the
binary's runfiles and which attributes it merges runfiles in from. The Java rules
point their `_runfiles_group_describer` attribute at the describers below.

It uses information visible to the aspect:
JavaInfo, DefaultInfo and the rule's attributes. The JDK, which a binary takes from
the Java runtime toolchain, is described by a singleton target that resolves the
same toolchain; every binary merges it in, so all of them share one group for it.
"""

load("@rules_runfiles_group//runfiles_group:lib.bzl", "runfiles_groups")
load("//java/common:java_semantics.bzl", "semantics")
load("//java/private:java_info.bzl", "JavaInfo")

# copybara: default visibility

# Stamped on every group the Java rules produce, so that JVM-shaped groups stay
# together when a packager has to merge groups to fit a layer limit.
MERGE_AFFINITY = "rules_java"

# The named group the java_binary / java_test rules merge in for the JDK. It is
# shared by every binary, so it is named with a string rather than with a Label.
JAVA_RUNTIME_GROUP = "rules_java#java_runtime"

# The attributes a packager's aspect visits.
LIBRARY_RUNFILES_GROUP_ATTRS = ["data", "deps", "exports", "runtime_deps"]
BINARY_RUNFILES_GROUP_ATTRS = ["_runfiles_group_java_runtime", "_test_support", "data", "deps", "runtime_deps"]

def own_kind(label):
    """Returns the `kind` of the group holding a target's own outputs.

    Only a target in the main repository is first-party. Plenty of Java targets
    Bazel builds from source belong to somebody else -- the protobuf runtime,
    say -- and a packaging rule that selects on `kind` should not have to treat
    those as the user's own code.

    Args:
      label: (Label) The label of the target owning the group.

    Returns:
      (str) One of runfiles_groups.KINDS.
    """
    return "first_party" if label.repo_name == "" else "third_party"

def java_fallback_entry(_ctx, dep):
    """Synthesizes the group of a dependency that does not describe its groups.

    A Java target's dependency may well be a custom rule that returns JavaInfo
    and lands in a binary's runtime classpath without a runfiles group describer.
    Not covering those would silently drop their runfiles.

    The group covers the two sources a Java target draws a dependency's runfiles
    from: the runtime classpath, built from the dependency's transitive runtime
    jars, and the dependency's own default runfiles, which a target collects
    implicitly. Both are empty for a neverlink dependency.

    Deliberately not all of DefaultInfo.files, which rules_runfiles_group's
    generic fallback would include: a neverlink java_library includes its jars
    there while not adding them to a binary's runfiles. Only a dependency
    without JavaInfo -- a genrule or a plain .jar file -- has the .jar files
    among them put on the runtime classpath, as "legacy jars" (see collect_deps).

    Args:
      _ctx: (ctx) The aspect context of the merging target.
      dep: (Target) A dependency without a runfiles group describer.

    Returns:
      (RunfilesGroupInfo|None) The dependency's group, if one should exist.
    """
    contents = []
    if JavaInfo in dep:
        contents.append(dep[JavaInfo].transitive_runtime_jars)
    else:
        legacy_jars = [f for f in dep[DefaultInfo].files.to_list() if f.extension == "jar"]
        if legacy_jars:
            contents.append(depset(legacy_jars))
    default_runfiles = dep[DefaultInfo].default_runfiles
    if default_runfiles != None:
        contents.append(default_runfiles)
    if not contents:
        return None

    return runfiles_groups.entry(
        name = dep.label,
        content = runfiles_groups.union(_ctx, contents),
        merge_affinity = MERGE_AFFINITY,
    )

def _java_dep_specs(attrs):
    return [runfiles_groups.merge_from(attr, fallback = java_fallback_entry) for attr in attrs] + [
        runfiles_groups.merge_from("data", fallback = "synthesize"),
    ]

def _describe_java_library_runfiles(target, ctx):
    if ctx.rule.attr.neverlink:
        # neverlink libraries do not contribute runfiles to the final binary.
        return runfiles_groups.node(add = [], merge_from = [])

    # The library's own runfiles are its output class jar.
    return runfiles_groups.node(
        add = [runfiles_groups.entry(
            name = ctx.label,
            content = depset(target[JavaInfo].runtime_output_jars),
            kind = own_kind(ctx.label),
            merge_affinity = MERGE_AFFINITY,
        )],
        merge_from = _java_dep_specs(["deps", "exports", "runtime_deps"]),
    )

java_library_runfiles_group_describer = runfiles_groups.make_describer_rule(
    describe = _describe_java_library_runfiles,
)

def _describe_java_import_runfiles(target, ctx):
    if ctx.rule.attr.neverlink:
        return runfiles_groups.node(add = [], merge_from = [])

    weight = getattr(ctx.rule.attr, "runfiles_weight", 0)
    return runfiles_groups.node(
        add = [runfiles_groups.entry(
            name = ctx.label,
            content = depset(target[JavaInfo].runtime_output_jars),
            kind = "third_party",
            rank = runfiles_groups.RANK_SHARED_DEPS,
            weight = weight if weight > 0 else None,
            merge_affinity = MERGE_AFFINITY,
        )],
        merge_from = _java_dep_specs(["deps", "exports", "runtime_deps"]),
    )

java_import_runfiles_group_describer = runfiles_groups.make_describer_rule(
    describe = _describe_java_import_runfiles,
)

def _describe_java_binary_runfiles(target, ctx):
    default_info = target[DefaultInfo]
    executable = default_info.files_to_run.executable
    merge_from = _java_dep_specs(["deps", "runtime_deps", "_test_support"])
    executable_group = None
    if executable:
        executable_group = ctx.label

        # Only a binary with an executable puts the JDK into its runfiles.
        merge_from.append("_runfiles_group_java_runtime")

    return runfiles_groups.node(
        add = [runfiles_groups.entry(
            name = ctx.label,
            content = depset([executable] if executable else [], transitive = [default_info.files]),
            kind = own_kind(ctx.label),
            rank = runfiles_groups.RANK_EXECUTABLE,
            merge_affinity = MERGE_AFFINITY,
        )],
        merge_from = merge_from,
        executable_group = executable_group,
    )

java_binary_runfiles_group_describer = runfiles_groups.make_describer_rule(
    describe = _describe_java_binary_runfiles,
)

def _describe_java_runtime_runfiles(target, _ctx):
    return runfiles_groups.node(add = [runfiles_groups.entry(
        name = JAVA_RUNTIME_GROUP,
        content = target[DefaultInfo].files,
        kind = "foundation",
        rank = runfiles_groups.RANK_FOUNDATION,
        do_not_merge = True,
        merge_affinity = MERGE_AFFINITY,
    )])

java_runtime_runfiles_group_describer = runfiles_groups.make_describer_rule(
    describe = _describe_java_runtime_runfiles,
)

def _java_runtime_runfiles_impl(ctx):
    # The same toolchain, in the same configuration, that java_binary takes its
    # runtime from, so its files are exactly what a binary puts into its runfiles.
    return [DefaultInfo(files = semantics.find_java_runtime_toolchain(ctx).files)]

java_runtime_runfiles = rule(
    implementation = _java_runtime_runfiles_impl,
    doc = """\
The files of the resolved Java runtime, as one runfiles group.

Instantiated once, as the default of java_binary's and java_test's private
`_runfiles_group_java_runtime` attribute, so that every binary in a configuration
merges in the same group for the JDK and a packager builds it once.
""",
    attrs = {
        "_runfiles_group_describer": attr.label(default = Label("//java/common/rules/impl:java_runtime_runfiles_group_describer")),
        "_runfiles_group_attrs": attr.string_list(default = []),
    },
    toolchains = [semantics.JAVA_RUNTIME_TOOLCHAIN],
)

def describer_attrs(describer, walked_attrs):
    """The private attributes that make a rule describe its runfiles groups.

    Args:
      describer: (Label) The describer target of the rule.
      walked_attrs: (list[str]) The attributes a packager's aspect walks into.

    Returns:
      (dict[str, Attribute]) Attributes to merge into the rule's attrs.
    """
    return {
        "_runfiles_group_describer": attr.label(default = describer),
        "_runfiles_group_attrs": attr.string_list(default = walked_attrs),
    }
