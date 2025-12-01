# Copyright 2025 The Bazel Authors. All rights reserved.
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

"""Common util functions for java_* rules"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//java/common:java_semantics.bzl", "semantics")

# copybara: rules_java visibility

def _java_segments(path):
    if path.startswith("/"):
        fail("path must not be absolute: '%s'" % path)
    segments = path.split("/")
    root_idx = -1
    for idx, segment in enumerate(segments):
        if segment in ["java", "javatests", "src", "testsrc"]:
            root_idx = idx
            break
    if root_idx < 0:
        return None
    is_src = "src" == segments[root_idx]
    check_mvn_idx = root_idx if is_src else -1
    if (root_idx == 0 or is_src):
        for i in range(root_idx + 1, len(segments) - 1):
            segment = segments[i]
            if "src" == segment or (is_src and (segment in ["java", "javatests"])):
                next = segments[i + 1]
                if next in ["com", "org", "net"]:
                    root_idx = i
                elif "src" == segment:
                    check_mvn_idx = i
                break

    if check_mvn_idx >= 0 and check_mvn_idx < len(segments) - 2:
        next = segments[check_mvn_idx + 1]
        if next in ["main", "test"]:
            next = segments[check_mvn_idx + 2]
            if next in ["java", "resources"]:
                root_idx = check_mvn_idx + 2
    return segments[(root_idx + 1):]

def _has_target_constraints(ctx, constraints):
    # Constraints is a label_list.
    for constraint in constraints:
        constraint_value = constraint[platform_common.ConstraintValueInfo]
        if ctx.target_platform_has_constraint(constraint_value):
            return True
    return False

def _is_target_platform_windows(ctx):
    return _has_target_constraints(ctx, ctx.attr._windows_constraints)

def _resource_mapper(file):
    root_relative_path = paths.relativize(
        path = file.path,
        start = paths.join(file.root.path, file.owner.workspace_root),
    )
    return "%s:%s" % (
        file.path,
        semantics.get_default_resource_path(root_relative_path, segment_extractor = _java_segments),
    )

def _create_single_jar(
        actions,
        toolchain,
        output,
        sources = depset(),
        resources = depset(),
        mnemonic = "JavaSingleJar",
        progress_message = "Building singlejar jar %{output}",
        build_target = None,
        output_creator = None):
    """Register singlejar action for the output jar.

    Args:
      actions: (actions) ctx.actions
      toolchain: (JavaToolchainInfo) The java toolchain
      output: (File) Output file of the action.
      sources: (depset[File]) The jar files to merge into the output jar.
      resources: (depset[File]) The files to add to the output jar.
      mnemonic: (str) The action identifier
      progress_message: (str) The action progress message
      build_target: (Label) The target label to stamp in the manifest. Optional.
      output_creator: (str) The name of the tool to stamp in the manifest. Optional,
          defaults to 'singlejar'
    Returns:
      (File) Output file which was used for registering the action.
    """
    args = actions.args()
    args.set_param_file_format("shell").use_param_file("@%s", use_always = True)
    args.add("--output", output)
    args.add_all(
        [
            "--compression",
            "--normalize",
            "--exclude_build_data",
            "--warn_duplicate_resources",
        ],
    )
    args.add_all("--sources", sources)
    args.add_all("--resources", resources, map_each = _resource_mapper)

    args.add("--build_target", build_target)
    args.add("--output_jar_creator", output_creator)

    actions.run(
        mnemonic = mnemonic,
        progress_message = progress_message,
        executable = toolchain.single_jar,
        toolchain = semantics.JAVA_TOOLCHAIN_TYPE,
        inputs = depset(transitive = [resources, sources]),
        tools = [toolchain.single_jar],
        outputs = [output],
        arguments = [args],
        use_default_shell_env = True,
    )
    return output

# TODO(hvd): use skylib shell.quote()
def _shell_escape(s):
    """Shell-escape a string

    Quotes a word so that it can be used, without further quoting, as an argument
    (or part of an argument) in a shell command.

    Args:
        s: (str) the string to escape

    Returns:
        (str) the shell-escaped string
    """
    if not s:
        # Empty string is a special case: needs to be quoted to ensure that it
        # gets treated as a separate argument.
        return "''"
    for c in s.elems():
        # We do this positively so as to be sure we don't inadvertently forget
        # any unsafe characters.
        if not c.isalnum() and c not in "@%-_+:,./":
            return "'" + s.replace("'", "'\\''") + "'"
    return s

def _detokenize_javacopts(opts):
    """Detokenizes a list of options to a depset.

    Args:
        opts: ([str]) the javac options to detokenize

    Returns:
        (depset[str]) depset of detokenized options
    """
    return depset(
        [" ".join([_shell_escape(opt) for opt in opts])],
        order = "preorder",
    )

def _get_relative(path_a, path_b):
    if paths.is_absolute(path_b):
        return path_b
    return paths.normalize(paths.join(path_a, path_b))

def _tokenize_javacopts(ctx = None, opts = []):
    """Tokenizes a list or depset of options to a list.

    Iff opts is a depset, we reverse the flattened list to ensure right-most
    duplicates are preserved in their correct position.

    If the ctx parameter is omitted, a slow, but pure Starlark, implementation
    of shell tokenization is used. Otherwise, tokenization is performed using
    ctx.tokenize() which has significantly better performance (up to 100x for
    large options lists).

    Args:
        ctx: (RuleContext|None) the rule context
        opts: (depset[str]|[str]) the javac options to tokenize
    Returns:
        [str] list of tokenized options
    """
    if hasattr(opts, "to_list"):
        opts = reversed(opts.to_list())
    if ctx:
        return [
            token
            for opt in opts
            for token in ctx.tokenize(opt)
        ]
    else:
        # TODO: optimize and use the pure Starlark implementation in cc_helper
        return semantics.tokenize_javacopts(opts)

helper = struct(
    is_target_platform_windows = _is_target_platform_windows,
    create_single_jar = _create_single_jar,
    shell_escape = _shell_escape,
    detokenize_javacopts = _detokenize_javacopts,
    tokenize_javacopts = _tokenize_javacopts,
    get_relative = _get_relative,
    has_target_constraints = _has_target_constraints,
    java_segments = _java_segments,
)
