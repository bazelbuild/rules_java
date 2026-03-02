"""Custom @rules_testing subject for the JavaToolchainInfo provider"""

load("@rules_testing//lib:truth.bzl", "subjects")
load("//java/common:java_common.bzl", "java_common")

def _new_java_toolchain_info_subject(info, meta):
    public = struct(
        jacocorunner = lambda: subjects.file(info.jacocorunner.executable, meta.derive("jacocorunner.executable")),
        timezone_data = lambda: subjects.file(info._timezone_data, meta.derive("_timezone_data")),
        header_compiler_builtin_processors = lambda: subjects.collection(info._header_compiler_builtin_processors.to_list(), meta.derive("_header_compiler_builtin_processors")),
        reduced_classpath_incompatible_processors = lambda: subjects.collection(info._reduced_classpath_incompatible_processors.to_list(), meta.derive("_reduced_classpath_incompatible_processors")),
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
