"""Misc helpers for rules_java testing"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test")
load("@rules_testing//lib:util.bzl", "util")

def always_passes(name):
    """Declares a fake, always passing test

    Args:
        name: (str) the name of the test
    """
    util.helper_target(
        native.filegroup,
        name = name + "/empty",
    )
    analysis_test(
        name = name,
        impl = lambda *a, **kw: None,
        target = name + "/empty",
    )
