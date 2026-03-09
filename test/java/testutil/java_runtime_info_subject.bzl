"""Custom @rules_testing subject for the JavaRuntimeInfo provider"""

load("@rules_testing//lib:truth.bzl", "subjects", "truth")
load("@rules_testing//lib:util.bzl", "TestingAspectInfo")
load("//java/common:java_common.bzl", "java_common")
load(":cc_info_subject.bzl", "cc_info_subject")

def _new_java_runtime_info_subject(java_runtime_info, meta):
    self = struct(
        actual = java_runtime_info,
        meta = meta.derive("JavaRuntimeInfo"),
    )
    public = struct(
        hermetic_static_libs = lambda: _new_hermetic_static_libs_subject(self.actual.hermetic_static_libs, self.meta.derive("hermetic_static_libs")),
        java_home = lambda: _new_path_string_subject(self.actual.java_home, self.meta.derive("java_home")),
        java_home_runfiles_path = lambda: _new_path_string_subject(self.actual.java_home_runfiles_path, self.meta.derive("java_home_runfiles_path")),
        java_executable_exec_path = lambda: _new_path_string_subject(self.actual.java_executable_exec_path, self.meta.derive("java_executable_exec_path")),
        java_executable_runfiles_path = lambda: _new_path_string_subject(self.actual.java_executable_runfiles_path, self.meta.derive("java_executable_runfiles_path")),
        files = lambda: subjects.depset_file(self.actual.files, self.meta.derive("files")),
        lib_ct_sym = lambda: subjects.file(self.actual.lib_ct_sym, self.meta.derive("lib_ct_sym")),
    )
    return public

def _new_hermetic_static_libs_subject(hermetic_static_libs, meta):
    public = struct(
        singleton = lambda: cc_info_subject.new_from_cc_info(_get_singleton(hermetic_static_libs), meta.derive("cc_info")),
    )
    return public

def _new_path_string_subject(str, meta):
    public = struct(
        equals = lambda other: subjects.str(str, meta).equals(meta.format_str(other)),
        is_in = lambda expected: subjects.str(str, meta).is_in([meta.format_str(e) for e in expected]),
        starts_with = lambda prefix: _check_str_prefix(str, prefix, meta),
    )
    return public

def _check_str_prefix(actual, prefix, meta):
    if not actual.startswith(meta.format_str(prefix)):
        meta.add_failure(
            "did not start with required prefix: {}".format(prefix),
            "actual: {}".format(actual),
        )

def _from_target(env, target):
    return _new_java_runtime_info_subject(
        target[java_common.JavaRuntimeInfo],
        meta = truth.expect(env).meta.derive(
            format_str_kwargs = {
                "name": target.label.name,
                "package": target.label.package,
                "bindir": target[TestingAspectInfo].bin_path,
                "gendir": env.ctx.configuration.genfiles_dir.path,
            },
        ),
    )

def _get_singleton(seq):
    if len(seq) != 1:
        fail("expected singleton, got:", seq)
    return seq[0]

java_runtime_info_subject = struct(
    new = _new_java_runtime_info_subject,
    from_target = _from_target,
)
