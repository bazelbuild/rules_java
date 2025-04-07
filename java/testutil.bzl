"""Exposes some private APIs for tests"""

# copybara: rules_java visibility

# TODO: consider eventually upstreaming to rules_cc

def _cc_info_transitive_native_libraries(cc_info):
    return cc_info.transitive_native_libraries()

def _cc_library_to_link_identifier(library_to_link):
    return library_to_link.library_identifier()

testutil = struct(
    cc_info_transitive_native_libraries = _cc_info_transitive_native_libraries,
    cc_library_to_link_identifier = _cc_library_to_link_identifier,
)
