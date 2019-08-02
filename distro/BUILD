package(
    default_visibility = ["//visibility:private"],
)

load("@rules_java//java:defs.bzl", "version")
load("@rules_pkg//:pkg.bzl", "pkg_tar")

# Build the artifact to put on the github release page.
pkg_tar(
    name = "rules_java-%s" % version,
    srcs = [
        "@rules_java//:standard_package",
    ],
    extension = "tar.gz",
    # It is all source code, so make it read-only.
    mode = "0444",
    # Make it owned by root so it does not have the uid of the CI robot.
    owner = "0.0",
    package_dir = ".",
)

# TODO(aiuto): Package print_rel_notes as a rule so this is easier to write.
genrule(
    name = "relnotes",
    srcs = [
        ":rules_java-%s.tar.gz" % version,
    ],
    outs = ["relnotes.txt"],
    cmd = " ".join([
        "$(location :print_rel_notes)",
        "rules_java",
        version,
        "$(location :rules_java-%s.tar.gz)" % version,
        ">$@",
    ]),
    tools = [
        ":print_rel_notes",
    ],
)

# TODO(aiuto): All below should be a component of a different repo.
# Possibly rules_pkg.
py_library(
    name = "util",
    srcs = [
        "__init__.py",
        "release_tools.py",
    ],
    srcs_version = "PY3",
    deps = [
        "@bazel_tools//tools/python/runfiles",
    ],
)

py_binary(
    name = "print_rel_notes",
    srcs = [
        "print_rel_notes.py",
    ],
    python_version = "PY3",
    deps = [
        ":util",
        "@bazel_tools//tools/python/runfiles",
    ],
)
