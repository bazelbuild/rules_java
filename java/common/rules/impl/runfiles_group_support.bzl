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
Shared pieces for emitting RunfilesGroupInfo from the Java rules.
"""

load("@rules_runfiles_group//runfiles_group:lib.bzl", "runfiles_groups")
load("@rules_runfiles_group//runfiles_group:providers.bzl", "RunfilesGroupInfo")
load("//java/private:java_info.bzl", "JavaInfo")

# copybara: default visibility

# Stamped on every group the Java rules produce, so that JVM-shaped groups stay
# together when a packager has to merge groups to fit a layer limit.
MERGE_AFFINITY = "rules_java"

# Named groups the java_binary / java_test rules contribute. Both are shared by
# every binary, so they are named with strings rather than with a Label.
JAVA_RUNTIME_GROUP = "rules_java#java_runtime"
BINARY_GROUP = "rules_java#binary"

# Merged into the attrs of every rule that emits RunfilesGroupInfo, giving it
# access to the global on/off switch read by runfiles_groups_enabled().
RUNFILES_GROUP_ATTRS = runfiles_groups.RULE_ATTRS

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

def runfiles_groups_enabled(ctx):
    """Returns whether this target should emit RunfilesGroupInfo.

    Args:
      ctx: (RuleContext) The context of the rule being evaluated.

    Returns:
      (bool) True if the global switch is on and the rule can read it.
    """

    # bazel_java_library_rule and bazel_java_import_rule are entry points for
    # other rulesets' rule implementations, which may not have merged
    # RUNFILES_GROUP_ATTRS into their attrs. Treat a missing attribute as "off"
    # instead of failing their analysis.
    return hasattr(ctx.attr, "_runfiles_group_enabled") and runfiles_groups.is_enabled(ctx)

def collect_entries(ctx, *, deps, data, own):
    """Returns the runfiles group entries of a target and of its dependencies.

    Dependencies that provide RunfilesGroupInfo propagate their entries by
    reference. Those that do not get one synthesized entry each: unlike a
    ruleset whose own rules all speak the protocol, a Java target's dependency
    may well be a custom rule that returns JavaInfo - and lands in a binary's
    runtime classpath and runfiles - without returning RunfilesGroupInfo. Not
    covering those would silently drop their files from every group.

    Args:
      ctx: (RuleContext) Used to synthesize entries and to read the providers.
      deps: (list[Target|list[Target]]) Attribute values holding the
        dependencies whose groups this target propagates.
      data: (list[Target|list[Target]]) Attribute values holding arbitrary
        targets, passed through to runfiles_groups.collect().
      own: (list[entry]) The entries this target owns.

    Returns:
      (depset[entry]) The entries of this target and of its dependencies.
    """
    participating = []
    entries = list(own)
    for dep in _targets(deps):
        if RunfilesGroupInfo in dep:
            participating.append(dep)
        else:
            entry = _foreign_entry(ctx, dep)
            if entry:
                entries.append(entry)

    return runfiles_groups.collect(
        ctx,
        deps = participating,
        data = data,
        own = entries,
    )

def _targets(attr_values):
    """Flattens attribute values holding a single Target or a list of them."""
    targets = []
    for value in attr_values:
        if type(value) == "Target":
            targets.append(value)
        else:
            targets.extend(value)
    return targets

def _foreign_entry(ctx, dep):
    """Synthesizes the entry of a dependency that provides no runfiles groups.

    It covers the two channels a Java target draws a dependency's runfiles from:
    the runtime classpath, built from the dependency's transitive runtime jars,
    and the dependency's own default runfiles, which a target collects
    implicitly. Both are empty for a neverlink dependency, which contributes
    nothing at runtime and therefore needs no group.

    Deliberately not DefaultInfo.files, which runfiles_groups.data_entry() would
    include: a neverlink java_library publishes its jars there while
    contributing nothing to a binary's runfiles, and a group holding a file that
    is not in the runfiles is as wrong as one missing a file that is.

    Args:
      ctx: (RuleContext) Used to union the two content forms.
      dep: (Target) A dependency without RunfilesGroupInfo.

    Returns:
      (entry|None) The dependency's entry, or None if it contributes nothing.
    """
    contents = []
    if JavaInfo in dep:
        contents.append(dep[JavaInfo].transitive_runtime_jars)
    default_runfiles = dep[DefaultInfo].default_runfiles
    if default_runfiles != None:
        contents.append(default_runfiles)
    if not contents:
        return None

    return runfiles_groups.entry(
        name = dep.label,
        content = runfiles_groups.union(ctx, contents),
        merge_affinity = MERGE_AFFINITY,
    )
