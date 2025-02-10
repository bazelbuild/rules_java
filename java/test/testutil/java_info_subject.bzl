"""A custom @rules_testing subject for the JavaInfo provider"""

load("@rules_testing//lib:truth.bzl", "subjects", "truth")
load("//java/common:java_info.bzl", "JavaInfo")
load(":cc_info_subject.bzl", "cc_info_subject")

def _new_java_info_subject(java_info, meta):
    self = struct(actual = java_info, meta = meta.derive("JavaInfo"))
    public = struct(
        compilation_args = lambda: _new_java_compilation_args_subject(self.actual, self.meta),
        plugins = lambda: _new_java_info_plugins_subject(self.actual, self.meta),
        is_binary = lambda: subjects.bool(getattr(java_info, "_is_binary", False), self.meta.derive("_is_binary")),
        has_attr = lambda a: subjects.bool(getattr(java_info, a, None) != None, meta = self.meta.derive("{} != None".format(a))).equals(True),
        cc_link_params_info = lambda: cc_info_subject.new_from_java_info(java_info, meta),
    )
    return public

def _java_info_subject_from_target(env, target):
    return _new_java_info_subject(target[JavaInfo], meta = truth.expect(env).meta.derive(
        format_str_kwargs = {
            "name": target.label.name,
            "package": target.label.package,
        },
    ))

def _new_java_compilation_args_subject(java_info, meta):
    is_binary = getattr(java_info, "_is_binary", False)
    actual = struct(
        transitive_runtime_jars = java_info.transitive_runtime_jars,
        compile_jars = java_info.compile_jars,
        transitive_compile_time_jars = java_info.transitive_compile_time_jars,
        full_compile_jars = java_info.full_compile_jars,
        _transitive_full_compile_time_jars = java_info._transitive_full_compile_time_jars,
        _compile_time_java_dependencies = java_info._compile_time_java_dependencies,
    ) if not is_binary else None
    self = struct(
        actual = actual,
        meta = meta,
    )
    return struct(
        equals = lambda other: _java_compilation_args_equals(self, other),
        equals_subject = lambda other: _java_compilation_args_equals(self, other.actual),
        self = self,
        actual = actual,
    )

def _java_compilation_args_equals(self, other):
    if self.actual == other:
        return
    for attr in dir(other):
        other_attr = getattr(other, attr)
        this_attr = getattr(self.actual, attr)
        if this_attr != other_attr:
            self.meta.derive(attr).add_failure(
                "expected: {}".format(other_attr),
                "actual: {}".format(this_attr),
            )

def _new_java_info_plugins_subject(java_info, meta):
    self = struct(
        actual = java_info.plugins,
        meta = meta.derive("plugins"),
    )
    public = struct(
        processor_jars = lambda: subjects.depset_file(self.actual.processor_jars, meta = self.meta.derive("processor_jars")),
    )
    return public

java_info_subject = struct(
    new = _new_java_info_subject,
    from_target = _java_info_subject_from_target,
)
