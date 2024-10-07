"""Tests for merge_attrsfunction"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load(
    "//java/common/rules:rule_util.bzl",
    "merge_attrs",
)

_attr_string = attr.string()
_attr_string_different_ref = attr.string()
_attr_string_different = attr.string(default = "Some default")

def _merge_attrs_merges_impl(ctx):
    env = unittest.begin(ctx)

    attrs = merge_attrs(
        {"A": _attr_string},
        {"B": _attr_string_different_ref, "C": _attr_string_different},
        override_attrs = {"B": _attr_string_different},
        remove_attrs = ["C"],
    )

    asserts.equals(env, attrs, {"A": _attr_string, "B": _attr_string_different})

    return unittest.end(env)

merge_attrs_merges_test = unittest.make(_merge_attrs_merges_impl)

def merge_attrs_test_suite(name):
    """Sets up util test suite

    Args:
        name: the name of the test suite target
    """
    unittest.suite(
        name,
        merge_attrs_merges_test,
    )
