"""Custom @rules_testing subject for the JavaRuntimeInfo provider"""

load("@rules_testing//lib:truth.bzl", "subjects", "truth")
load("//java/common:java_common.bzl", "java_common")

def _new_java_runtime_info_subject(java_runtime_info, meta):
    self = struct(
        actual = java_runtime_info,
        meta = meta.derive("JavaRuntimeInfo"),
    )
    public = struct(
        java_home = lambda: subjects.str(self.actual.java_home, self.meta.derive("java_home")),
        java_home_runfiles_path = lambda: subjects.str(self.actual.java_home_runfiles_path, self.meta.derive("java_home_runfiles_path")),
        java_executable_exec_path = lambda: subjects.str(self.actual.java_executable_exec_path, self.meta.derive("java_executable_exec_path")),
        java_executable_runfiles_path = lambda: subjects.str(self.actual.java_executable_runfiles_path, self.meta.derive("java_executable_runfiles_path")),
    )
    return public

def _from_target(env, target):
    return _new_java_runtime_info_subject(
        target[java_common.JavaRuntimeInfo],
        meta = truth.expect(env).meta.derive(
            format_str_kwargs = {
                "name": target.label.name,
                "package": target.label.package,
            },
        ),
    )

java_runtime_info_subject = struct(
    new = _new_java_runtime_info_subject,
    from_target = _from_target,
)
