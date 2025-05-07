"""A custom @rules_testing subject for the JavaInfo provider"""

load("@rules_testing//lib:truth.bzl", "subjects", "truth")
load("//java/common:java_common.bzl", "java_common")
load("//java/common:java_info.bzl", "JavaInfo")
load("//java/common:java_plugin_info.bzl", "JavaPluginInfo")
load("//java/common/rules/impl:java_helper.bzl", "helper")
load(":cc_info_subject.bzl", "cc_info_subject")

def _new_java_info_subject(java_info, meta):
    self = struct(actual = java_info, meta = meta.derive("JavaInfo"))
    public = struct(
        compilation_args = lambda: _new_java_compilation_args_subject(self.actual, self.meta),
        compilation_info = lambda: _new_java_compilation_info_subject(self.actual, self.meta),
        plugins = lambda: _new_java_plugin_data_subject(self.actual.plugins, self.meta.derive("plugins")),
        api_generating_plugins = lambda: _new_java_plugin_data_subject(self.actual.api_generating_plugins, self.meta.derive("api_generating_plugins")),
        is_binary = lambda: subjects.bool(getattr(java_info, "_is_binary", False), self.meta.derive("_is_binary")),
        has_attr = lambda a: subjects.bool(getattr(java_info, a, None) != None, meta = self.meta.derive("{} != None".format(a))).equals(True),
        cc_link_params_info = lambda: cc_info_subject.new_from_java_info(java_info, meta),
        transitive_native_libraries = lambda: cc_info_subject.libraries_to_link(java_info.transitive_native_libraries, self.meta.derive("transitive_native_libraries")),
        constraints = lambda: subjects.collection(java_common.get_constraints(java_info), self.meta.derive("constraints")),
        annotation_processing = lambda: _new_annotation_processing_subject(self.actual, self.meta),
        outputs = lambda: _new_rule_output_info_subject(self.actual, self.meta),
        java_outputs = lambda: _new_java_outputs_collection_subject(self.actual.java_outputs, self.meta.derive("java_outputs")),
        source_jars = lambda: subjects.collection(java_info.source_jars, self.meta.derive("source_jars")),
        transitive_source_jars = lambda: subjects.depset_file(java_info.transitive_source_jars, self.meta.derive("transitive_source_jars")),
        transitive_source_jars_list = lambda: subjects.collection(java_info.transitive_source_jars.to_list(), self.meta.derive("transitive_source_jars.to_list()")),
        runtime_output_jars = lambda: subjects.depset_file(java_info.runtime_output_jars, self.meta.derive("runtime_output_jars")),
    )
    return public

def _java_info_subject_from_target(env, target):
    return _new_java_info_subject(target[JavaInfo], meta = truth.expect(env).meta.derive(
        format_str_kwargs = {
            "name": target.label.name,
            "package": target.label.package,
        },
    ))

def _new_java_compilation_info_subject(java_info, meta):
    self = struct(
        actual = java_info.compilation_info,
        meta = meta.derive("compilation_info"),
    )
    public = struct(
        compilation_classpath = lambda: subjects.depset_file(self.actual.compilation_classpath, self.meta.derive("compilation_classpath")),
        runtime_classpath = lambda: subjects.depset_file(self.actual.runtime_classpath, self.meta.derive("runtime_classpath")),
        runtime_classpath_list = lambda: subjects.collection(self.actual.runtime_classpath.to_list(), self.meta.derive("runtime_classpath.to_list()")),
        javac_options = lambda: subjects.collection(helper.tokenize_javacopts(opts = self.actual.javac_options), self.meta.derive("javac_options")),
    )
    return public

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
        compile_jdeps = lambda: subjects.depset_file(depset([o.compile_jdeps for o in actual.jars]), self.meta.derive("compile_jdeps")),
        native_headers = lambda: subjects.depset_file(depset([o.native_headers_jar for o in actual.jars]), self.meta.derive("native_headers")),
        manifest_protos = lambda: subjects.depset_file(depset([o.manifest_proto for o in actual.jars]), self.meta.derive("manifest_protos")),
    )
    return public

def _new_java_outputs_collection_subject(java_outputs, meta):
    public = struct(
        singleton = lambda: _new_java_outputs_subject(_get_singleton(java_outputs), meta.derive("[0]")),
    )
    return public

def _new_java_outputs_subject(java_output, meta):
    public = struct(
        class_jar = lambda: subjects.file(java_output.class_jar, meta.derive("class_jar")),
        compile_jar = lambda: subjects.file(java_output.compile_jar, meta.derive("compile_jar")),
        source_jars = lambda: subjects.depset_file(java_output.source_jars if hasattr(java_output.source_jars, "to_list") else depset(java_output.source_jars), meta.derive("source_jars")),
        jdeps = lambda: subjects.file(java_output.jdeps, meta.derive("jdeps")),
        compile_jdeps = lambda: subjects.file(java_output.compile_jdeps, meta.derive("compile_jdeps")),
        native_headers_jar = lambda: subjects.file(java_output.native_headers_jar, meta.derive("native_headers_jar")),
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
        transitive_runtime_jars_list = lambda: subjects.collection(actual.transitive_runtime_jars.to_list(), self.meta.derive("transitive_runtime_jars.to_list()")),
        compile_time_java_dependencies = lambda: subjects.depset_file(actual._compile_time_java_dependencies, self.meta.derive("_compile_time_java_dependencies")),
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

def _new_java_plugin_data_subject(java_plugin_data, meta):
    public = struct(
        processor_jars = lambda: subjects.depset_file(java_plugin_data.processor_jars, meta = meta.derive("processor_jars")),
        processor_classes = lambda: subjects.collection(java_plugin_data.processor_classes, meta = meta.derive("processor_classes")),
        processor_data = lambda: subjects.depset_file(java_plugin_data.processor_data, meta = meta.derive("processor_data")),
        is_empty = lambda: _check_plugin_data_empty(java_plugin_data, meta.derive("is_empty()")),
        equals = lambda other: subjects.bool(java_plugin_data == other, meta.derive("equals({})".format(other))).equals(True),
    )
    return public

def _check_plugin_data_empty(plugin_data, meta):
    for attr in ["processor_jars", "processor_classes", "processor_data"]:
        value = getattr(plugin_data, attr)
        if value:
            meta.add_failure(
                "expected: {} to be empty".format(attr),
                "actual: {}".format(value),
            )

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

def _new_java_plugin_info_subject(java_plugin_info, meta):
    self = struct(actual = java_plugin_info, meta = meta.derive("JavaPluginInfo"))
    public = struct(
        java_outputs = lambda: _new_java_outputs_collection_subject(self.actual.java_outputs, self.meta.derive("java_outputs")),
        plugins = lambda: _new_java_plugin_data_subject(self.actual.plugins, self.meta.derive("plugins")),
        api_generating_plugins = lambda: _new_java_plugin_data_subject(self.actual.api_generating_plugins, self.meta.derive("api_generating_plugins")),
    )
    return public

def _java_plugin_info_subject_from_target(env, target):
    return _new_java_plugin_info_subject(target[JavaPluginInfo], meta = truth.expect(env).meta.derive(
        format_str_kwargs = {
            "name": target.label.name,
            "package": target.label.package,
        },
    ))

def _get_singleton(seq):
    if len(seq) != 1:
        fail("expected singleton, got:", seq)
    return seq[0]

java_info_subject = struct(
    new = _new_java_info_subject,
    from_target = _java_info_subject_from_target,
)

java_plugin_info_subject = struct(
    new = _new_java_plugin_info_subject,
    from_target = _java_plugin_info_subject_from_target,
)
