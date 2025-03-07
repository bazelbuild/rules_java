"""A custom @rules_testing subject for the JavaInfo provider"""

load("@rules_testing//lib:truth.bzl", "subjects", "truth")
load("//java/common:java_common.bzl", "java_common")
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
        transitive_native_libraries = lambda: cc_info_subject.libraries_to_link(java_info.transitive_native_libraries, self.meta.derive("transitive_native_libraries")),
        constraints = lambda: subjects.collection(java_common.get_constraints(java_info), self.meta.derive("constraints")),
        annotation_processing = lambda: _new_annotation_processing_subject(self.actual, self.meta),
        outputs = lambda: _new_rule_output_info_subject(self.actual, self.meta),
        source_jars = lambda: subjects.collection(java_info.source_jars, self.meta.derive("source_jars")),
        transitive_source_jars = lambda: subjects.depset_file(java_info.transitive_source_jars, self.meta.derive("transitive_source_jars")),
    )
    return public

def _java_info_subject_from_target(env, target):
    return _new_java_info_subject(target[JavaInfo], meta = truth.expect(env).meta.derive(
        format_str_kwargs = {
            "name": target.label.name,
            "package": target.label.package,
        },
    ))

def _new_rule_output_info_subject(java_info, meta):
    actual = java_info.outputs
    self = struct(
        actual = actual,
        meta = meta.derive("outputs"),
    )

    # JavaOutputInfo.source_jars is a list before Bazel 7
    source_jars_depset = depset([f for o in actual.jars for f in (o.source_jars.to_list() if hasattr(o.source_jars, "to_list") else o.source_jars)])
    public = struct(
        jars = lambda: _new_java_outputs_collection_subject(actual.jars, self.meta.derive("jars")),
        class_output_jars = lambda: subjects.depset_file(depset([o.class_jar for o in actual.jars]), self.meta.derive("class_output_jars")),
        source_output_jars = lambda: subjects.depset_file(source_jars_depset, self.meta.derive("source_output_jars")),
        generated_class_jars = lambda: subjects.depset_file(depset([o.generated_class_jar for o in actual.jars]), self.meta.derive("generated_class_jars")),
        generated_source_jars = lambda: subjects.depset_file(depset([o.generated_source_jar for o in actual.jars]), self.meta.derive("generated_source_jars")),
        jdeps = lambda: subjects.depset_file(depset([o.jdeps for o in actual.jars]), self.meta.derive("jdeps")),
    )
    return public

def _new_java_outputs_collection_subject(java_outputs, meta):
    public = struct(
        singleton = lambda: _new_java_outputs_subject(_get_singleton(java_outputs), meta.derive("[0]")),
    )
    return public

def _new_java_outputs_subject(java_output, meta):
    public = struct(
        compile_jar = lambda: subjects.file(java_output.compile_jar, meta.derive("compile_jar")),
    )
    return public

def _new_java_compilation_args_subject(java_info, meta):
    is_binary = getattr(java_info, "_is_binary", False)
    actual = struct(
        transitive_runtime_jars = java_info.transitive_runtime_jars,
        compile_jars = java_info.compile_jars,
        transitive_compile_time_jars = java_info.transitive_compile_time_jars,
        full_compile_jars = java_info.full_compile_jars,
        _transitive_full_compile_time_jars = getattr(java_info, "_transitive_full_compile_time_jars", None),  # not in Bazel 6
        _compile_time_java_dependencies = getattr(java_info, "_compile_time_java_dependencies", None),  # not in Bazel 6
    ) if not is_binary else None
    self = struct(
        actual = actual,
        meta = meta,
    )
    return struct(
        equals = lambda other: _java_compilation_args_equals(self, other),
        equals_subject = lambda other: _java_compilation_args_equals(self, other.actual),
        compile_jars = lambda: subjects.depset_file(actual.compile_jars, self.meta.derive("compile_jars")),
        full_compile_jars = lambda: subjects.depset_file(actual.full_compile_jars, self.meta.derive("full_compile_jars")),
        transitive_runtime_jars = lambda: subjects.depset_file(actual.transitive_runtime_jars, self.meta.derive("transitive_runtime_jars")),
        transitive_compile_time_jars = lambda: subjects.depset_file(actual.transitive_compile_time_jars, self.meta.derive("transitive_compile_time_jars")),
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
        processor_classes = lambda: subjects.collection(self.actual.processor_classes, meta = self.meta.derive("processor_classes")),
    )
    return public

def _new_annotation_processing_subject(java_info, meta):
    actual = java_info.annotation_processing
    meta = meta.derive("annotation_processing")
    self = struct(
        actual = actual,
        meta = meta,
    )
    public = struct(
        is_enabled = lambda: subjects.bool(actual.enabled, meta = meta.derive("is_enabled")),
        processor_classnames = lambda: subjects.collection(actual.processor_classnames, meta = meta.derive("processor_classnames")),
        processor_classpath = lambda: subjects.depset_file(actual.processor_classpath, meta = meta.derive("processor_classpath")),
        class_jar = lambda: subjects.file(actual.class_jar, meta = meta.derive("class_jar")),
        source_jar = lambda: subjects.file(actual.source_jar, meta = meta.derive("source_jar")),
        transitive_class_jars = lambda: subjects.depset_file(actual.transitive_class_jars, meta = meta.derive("transitive_class_jars")),
        transitive_source_jars = lambda: subjects.depset_file(actual.transitive_source_jars, meta = meta.derive("transitive_source_jars")),
        actual = actual,
        self = self,
    )
    return public

def _get_singleton(seq):
    if len(seq) != 1:
        fail("expected singleton, got:", seq)
    return seq[0]

java_info_subject = struct(
    new = _new_java_info_subject,
    from_target = _java_info_subject_from_target,
)
