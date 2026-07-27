"""Custom rules_testing subject for java_binary/java_test executable output"""

load("@rules_cc//cc/common:cc_common.bzl", "cc_common")
load("@rules_testing//lib:truth.bzl", "subjects")
load("//java/common:java_semantics.bzl", "semantics")

def _of_target(env, target):
    executable = target[DefaultInfo].files_to_run.executable.short_path
    action_subject = env.expect.that_target(target).action_generating(executable)
    public = struct(
        java_start_class = lambda: _java_start_class_subject(action_subject),
        test_suite = lambda: _test_suite_subject(action_subject),
        jvm_flags = lambda: _jvm_flags_subject(action_subject),
        native_library_paths = lambda: _native_library_paths_subject(action_subject),
    )
    return public

def _java_start_class_subject(action):
    if action.actual.substitutions:
        return action.substitutions().get("%java_start_class%", factory = subjects.str)
    else:
        # Windows
        return action.argv().transform(
            filter = lambda e: e.startswith("java_start_class="),
            map_each = lambda e: e.split("=", 1)[1],
            desc = "java_start_class",
        ).offset(0, factory = subjects.str)

def _test_suite_subject(action):
    return _jvm_flags_subject(action).transform(
        filter = lambda e: e.startswith("-D" + semantics.TEST_SUITE_PROPERTY_NAME + "="),
        map_each = lambda e: e.split("=", 1)[1],
        desc = semantics.TEST_SUITE_PROPERTY_NAME,
    ).offset(0, factory = subjects.str)

def _jvm_flags_subject(action):
    if action.actual.substitutions:
        return action.substitutions().get("%jvm_flags%", factory = subjects.str).split(" ")
    else:
        # Windows
        return action.argv().transform(
            filter = lambda e: e.startswith("jvm_flags="),
            map_each = lambda e: e.split("=", 1)[1],
            desc = "jvm_flags",
        ).offset(0, factory = subjects.str).split("\t")

def _native_library_paths_subject(action):
    return _jvm_flags_subject(action).transform(
        filter = lambda e: e.startswith("-Djava.library.path="),
        map_each = lambda e: e.split("=", 1)[1],
        desc = "native library paths",
    ).offset(
        0,
        factory = lambda actual, meta: subjects.str(actual, meta.derive(
            format_str_kwargs = {"cpu": meta.ctx.attr._cc_toolchain[cc_common.CcToolchainInfo].cpu},
        )),
    ).split(":").transform(
        map_each = lambda e: e.replace("_U", "_").replace("_S", "/").replace("_C", ":"),
        desc = "pretty",
        format = True,
    )

expect_that_executable = struct(
    of_target = _of_target,
)
