"""A custom @rules_testing subject for the CcInfo provider"""

load("@rules_testing//lib:truth.bzl", "subjects")

def _new_cc_info_subject(cc_info, meta):
    self = struct(
        actual = cc_info,
        meta = meta,
    )
    public = struct(
        linking_context = lambda: _new_cc_info_linking_context_subject(self.actual, self.meta),
        native_libraries = lambda: subjects.collection(self.actual.transitive_native_libraries(), self.meta.derive("transitive_native_libraries()")),
    )
    return public

def _new_cc_info_linking_context_subject(cc_info, meta):
    self = struct(
        actual = cc_info.linking_context,
        meta = meta.derive("linking_context"),
    )
    public = struct(
        equals = lambda other: _cc_info_linking_context_equals(self.actual, other, self.meta),
        libraries_to_link = lambda: _new_cc_info_libraries_to_link_subject(self.actual, self.meta),
        static_mode_params_for_dynamic_library_libs = lambda: _new_static_mode_params_for_dynamic_library_libs_subject(self.actual, self.meta),
    )
    return public

def _new_static_mode_params_for_dynamic_library_libs_subject(linking_context, meta):
    libs = []
    for input in linking_context.linker_inputs.to_list():
        for lib in input.libraries:
            if lib.pic_static_library:
                libs.append(lib.pic_static_library)
            elif lib.static_library:
                libs.append(lib.static_library)
            elif lib.interface_library:
                libs.append(lib.interface_library)
            else:
                libs.append(lib.dynamic_library)

    return subjects.collection(
        libs,
        meta = meta.derive("static_mode_params_for_dynamic_library_libs"),
    )

def _cc_info_linking_context_equals(actual, expected, meta):
    if actual == expected:
        return
    meta.add_failure(
        "expected: {}".format(expected),
        "actual: {}".format(actual),
    )

def _new_cc_info_libraries_to_link_subject(linking_context, meta):
    self = struct(
        actual = linking_context.libraries_to_link,
        meta = meta.derive("libraries_to_link"),
    )
    public = struct(
        identifiers = lambda: _new_library_to_link_identifiers_subject(self.actual, self.meta),
    )
    return public

def _new_library_to_link_identifiers_subject(libraries_to_link, meta):
    self = subjects.collection(
        [lib.library_identifier() for lib in libraries_to_link],
        meta = meta.derive("library_identifier()"),
    )
    public = struct(
        contains_exactly = lambda expected: self.contains_exactly([meta.format_str(e) for e in expected]),
    )
    return public

cc_info_subject = struct(
    new_from_java_info = lambda java_info, meta: _new_cc_info_subject(java_info.cc_link_params_info, meta.derive("cc_link_params_info")),
)
