"""Tests for java_helper functions"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load(
    "//java/common/rules:java_helper.bzl",
    "helper",
)

def _java_segments_test_impl(ctx):
    env = unittest.begin(ctx)

    asserts.equals(
        env,
        ["com", "google", "foo", "Foo"],
        helper.java_segments("java/com/google/foo/Foo"),
    )
    asserts.equals(
        env,
        ["com", "google", "foo", "FooTest"],
        helper.java_segments("javatests/com/google/foo/FooTest"),
    )
    asserts.equals(
        env,
        ["com", "google", "foo", "Foo"],
        helper.java_segments("src/main/java/com/google/foo/Foo"),
    )
    asserts.equals(
        env,
        ["com", "google", "foo", "FooTest"],
        helper.java_segments("src/test/java/com/google/foo/FooTest"),
    )
    asserts.equals(
        env,
        ["com", "google", "foo", "Foo"],
        helper.java_segments("third_party/java/foo/java/com/google/foo/Foo"),
    )
    asserts.equals(
        env,
        ["com", "google", "foo", "FooTest"],
        helper.java_segments("third_party/java/foo/javatests/com/google/foo/FooTest"),
    )
    asserts.equals(
        env,
        ["com", "google", "foo", "Foo"],
        helper.java_segments("third_party/java/foo/src/main/java/com/google/foo/Foo"),
    )
    asserts.equals(
        env,
        ["com", "google", "foo", "FooTest"],
        helper.java_segments("third_party/java/foo/src/test/java/com/google/foo/FooTest"),
    )
    asserts.equals(
        env,
        ["foo", "org", "foo", "Foo"],
        helper.java_segments("third_party/java/foo/org/foo/Foo"),
    )
    asserts.equals(
        env,
        None,
        helper.java_segments("foo/bar/Baz"),
    )

    asserts.equals(
        env,
        "com/google/foo/Foo",
        helper.java_path("java/com/google/foo/Foo"),
    )
    asserts.equals(
        env,
        "com/google/foo/Foo",
        helper.java_path("third_party/java/foo/java/com/google/foo/Foo"),
    )
    asserts.equals(
        env,
        None,
        helper.java_path("foo/bar/Baz"),
    )

    asserts.equals(
        env,
        "java",
        helper.java_root("java/com/google/foo/Foo"),
    )
    asserts.equals(
        env,
        "javatests",
        helper.java_root("javatests/com/google/foo/FooTest"),
    )
    asserts.equals(
        env,
        "foo/java",
        helper.java_root("foo/java/com/google/foo/Foo"),
    )
    asserts.equals(
        env,
        "third_party/java/foo/java",
        helper.java_root("third_party/java/foo/java/com/google/foo/Foo"),
    )
    asserts.equals(
        env,
        None,
        helper.java_root("foo/bar/Baz"),
    )

    asserts.equals(
        env,
        "com.google.foo.Foo",
        helper.full_classname("java/com/google/foo/Foo"),
    )
    asserts.equals(
        env,
        "com.google.foo.Foo",
        helper.full_classname("third_party/java/foo/java/com/google/foo/Foo"),
    )
    asserts.equals(
        env,
        None,
        helper.full_classname("foo/bar/Baz"),
    )

    return unittest.end(env)

java_segments_test = unittest.make(_java_segments_test_impl)

def java_helper_test_suite(name):
    """Sets up java_helper test suite

    Args:
        name: the name of the test suite target
    """
    unittest.suite(
        name,
        java_segments_test,
    )
