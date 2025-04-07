"""Helper for computing the artifact closure of a target"""

# TODO: consider upstreaming this to @rules_testing

def _of_target(target):
    to_process = target[DefaultInfo].files.to_list()
    if _ArtifactActionMapInfo not in target:
        fail("Did you forget to add the aspect to analysis_test(extra_target_under_test_aspects = )?")
    map = target[_ArtifactActionMapInfo].map
    result = []
    visited = {}
    for __ in range(len(map)):
        if not to_process:
            break
        next_to_process = []
        for x in to_process:
            if x in visited:
                continue
            visited[x] = None
            result.append(x)
            if x not in map:
                # source file or not visible to us (toolchain?)
                continue
            a = map[x]
            next_to_process.extend([f for f in a.inputs.to_list() if f not in visited])
        to_process = next_to_process
    return result

_ArtifactActionMapInfo = provider(
    "Map of artifacts to actions",
    fields = ["map"],
)

def _aspect_impl(target, ctx):
    map = {}
    for action in target.actions:
        for output in action.outputs.to_list():
            map[output] = action

    # Rollup from all dep attributes
    for attr_name in dir(ctx.rule.attr):
        attr = getattr(ctx.rule.attr, attr_name)
        if type(attr) != "list":
            attr = [attr]
        for val in attr:
            if type(val) == "Target" and _ArtifactActionMapInfo in val:
                map = map | val[_ArtifactActionMapInfo].map
    return _ArtifactActionMapInfo(map = map)

_aspect = aspect(_aspect_impl, attr_aspects = ["*"])

artifact_closure = struct(
    aspect = _aspect,
    of_target = _of_target,
)
