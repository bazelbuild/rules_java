"""Custom @rules_testing subject for the JavaToolchainInfo provider"""

load("@rules_testing//lib:truth.bzl", "subjects")
load("//java/common:java_common.bzl", "java_common")

def _new_java_builder_subject(tool_info, meta):
    return subjects.struct(
        struct(
            data = [f.path for f in tool_info.data.to_list()],
            jvm_opts = tool_info.jvm_opts.to_list(),
        ),
        meta = meta,
        attrs = {
            "data": lambda values, *, meta: subjects.collection(values, meta = meta, format = True),
            "jvm_opts": lambda values, *, meta: subjects.collection(values, meta = meta, format = True),
        },
    )

def _new_java_toolchain_info_subject(info, meta):
    public = struct(
        jacocorunner = lambda: subjects.file(info.jacocorunner.executable, meta.derive("jacocorunner.executable")),
        timezone_data = lambda: subjects.file(info._timezone_data, meta.derive("_timezone_data")),
        header_compiler_builtin_processors = lambda: subjects.collection(info._header_compiler_builtin_processors.to_list(), meta.derive("_header_compiler_builtin_processors")),
        reduced_classpath_incompatible_processors = lambda: subjects.collection(info._reduced_classpath_incompatible_processors.to_list(), meta.derive("_reduced_classpath_incompatible_processors")),
        javabuilder = lambda: _new_java_builder_subject(info._javabuilder, meta.derive("_javabuilder")),
        label = lambda: subjects.label(info.label, meta.derive("label")),
        # TODO: hvd - Give label_subject predicate matching support so we don't need this str_subject variant.
        label_str = lambda: subjects.str(str(info.label), meta.derive("label_str")),
        default_javacopts = lambda: subjects.collection(info._javacopts_list, meta.derive("default_javacopts")),
        default_javacopts_depset = lambda: subjects.collection(info._javacopts.to_list(), meta.derive("default_javacopts_depset")),
    )
    return public

def _from_target(env, target):
    return env.expect.that_target(target).provider(
        java_common.JavaToolchainInfo,
        factory = _new_java_toolchain_info_subject,
        provider_name = "JavaToolchainInfo",
    )

java_toolchain_info_subject = struct(
    new = _new_java_toolchain_info_subject,
    from_target = _from_target,
)
