"""Bespoke rules_testing subject for the Java compilation action"""

load("@rules_testing//lib:truth.bzl", "subjects", "truth")
load("@rules_testing//lib:util.bzl", "TestingAspectInfo")

def _new_javac_action_subject(env, target, output):
    action = env.expect.that_target(target).action_generating(output).actual
    self = struct(
        actual = action,
        parsed_flags = _parse_flags(action.argv),
        meta = truth.expect(env).meta.derive(
            "Javac",
            format_str_kwargs = {
                "name": target.label.name,
                "package": target.label.package,
                "bin_path": target[TestingAspectInfo].bin_path,
            },
        ),
    )
    public = struct(
        direct_dependencies = lambda: subjects.collection(self.parsed_flags["--direct_dependencies"], self.meta.derive("--direct_dependencies"), format = True),
    )
    return public

def _parse_flags(argv):
    flag_values = {}
    current_flag_name = None
    for idx, arg in enumerate(argv):
        if idx == 0:
            continue  # java command
        if arg.startswith("-"):
            if "=" in arg:
                parts = arg.split("=", 1)
                flag_values.setdefault(parts[0], []).append(parts[1])
                current_flag_name = None
            else:
                flag_values.setdefault(arg, [])
                current_flag_name = arg
        else:
            if not current_flag_name:
                fail("No preceding flag for value:", arg, "at index:", idx, "\nargv:\n", argv)
            flag_values[current_flag_name].append(arg)

    return flag_values

javac_action_subject = struct(
    of = _new_javac_action_subject,
    parse_flags = _parse_flags,  # exposed for testing this method itself
)
