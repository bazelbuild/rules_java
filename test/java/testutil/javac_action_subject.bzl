"""Bespoke rules_testing subject for the Java compilation action"""

load("@rules_testing//lib:truth.bzl", "subjects", "truth")
load("@rules_testing//lib:util.bzl", "TestingAspectInfo")

def _new_javac_action_subject(env, target, output):
    action_subject = env.expect.that_target(target).action_generating(output)
    self = struct(
        actual = action_subject.actual,
        parsed_flags = _parse_flags(action_subject.actual.argv),
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
        direct_dependencies = lambda: _create_subject_for_flag("--direct_dependencies", self.parsed_flags, self.meta),
        source = lambda: _create_subject_for_flag("-source", self.parsed_flags, self.meta),
        target = lambda: _create_subject_for_flag("-target", self.parsed_flags, self.meta),
        xmaxerrs = lambda: _create_subject_for_flag("-Xmaxerrs", self.parsed_flags, self.meta),
        jar = lambda: _create_subject_for_flag("-jar", self.parsed_flags, self.meta),
        executable_file_name = lambda: subjects.str(action_subject.actual.argv[0], self.meta),
        inputs = action_subject.inputs,
        argv = action_subject.argv,
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

def _create_subject_for_flag(flag_name, parsed_flags, meta):
    """Helper to create a collection subject for a given flag."""
    return subjects.collection(parsed_flags[flag_name], meta.derive(flag_name), format = True)

javac_action_subject = struct(
    of = _new_javac_action_subject,
    parse_flags = _parse_flags,  # exposed for testing this method itself
)
