"""Tests for RunfilesGroupInfo support in java rules."""

load("@bazel_features//private:util.bzl", "ge")  # buildifier: disable=bzl-visibility
load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("@rules_runfiles_group//runfiles_group:runfiles_group_analysis_test.bzl", "runfiles_group_analysis_test")
load("//java:java_binary.bzl", "java_binary")
load("//java:java_import.bzl", "java_import")
load("//java:java_library.bzl", "java_library")
load("//java:java_test.bzl", "java_test")
load("//java/common:java_info.bzl", "JavaInfo")
load("//java/common/rules/impl:runfiles_group_support.bzl", "own_kind")

# RunfilesGroupInfo is only produced by the Starlark Java rules, which are used
# on Bazel 8 and newer. On Bazel 7 the native Java rules are used instead (and
# java_import has no runfiles_weight attribute), so there is nothing to test.
_STARLARK_JAVA_RULES = ge("8.0.0")

def _fake_jvm_import_impl(ctx):
    jar = ctx.file.jar
    return [
        DefaultInfo(files = depset([jar]), runfiles = ctx.runfiles(files = [jar])),
        JavaInfo(output_jar = jar, compile_jar = jar),
    ]

# A stand-in for a custom rule that returns the rules_java providers but no
# RunfilesGroupInfo, e.g. rules_jvm_external's jvm_import. The java rules have to
# synthesize a group for such a dependency, or a packager would find no group
# holding its jars.
_fake_jvm_import = rule(
    implementation = _fake_jvm_import_impl,
    attrs = {"jar": attr.label(allow_single_file = True, mandatory = True)},
)

def _helper(rule_fn, name, **kwargs):
    rule_fn(name = name, tags = ["manual"], **kwargs)

def _own_kind_impl(ctx):
    env = unittest.begin(ctx)

    asserts.equals(env, "first_party", own_kind(Label("//java/com/example:lib")))

    # Java code Bazel builds from source in another module -- the protobuf
    # runtime, say -- is not the user's own code.
    asserts.equals(env, "third_party", own_kind(Label("@other_repo//:lib")))

    return unittest.end(env)

_own_kind_test = unittest.make(_own_kind_impl)

def _label_str(name):
    """The canonical string form of a target's label, as the test reports it."""
    return str(native.package_relative_label(":" + name))

def runfiles_group_tests(name):
    """Registers the RunfilesGroupInfo tests and a test_suite that bundles them.

    Args:
        name: Name of the generated test_suite; also used as a prefix for the
            individual analysis test targets.
    """
    if not _STARLARK_JAVA_RULES:
        native.test_suite(name = name, tests = [])
        return

    tests = [
        "own_kind",
        "simple_binary",
        "transitive_deps",
        "runtime_deps",
        "java_import",
        "java_import_weight",
        "with_data",
        "library_with_data",
        "foreign_java_dep",
        "java_test",
        "group_ordering",
        "merge_to_limit",
    ]

    _own_kind_test(name = name + "/own_kind")
    _test_simple_binary(name + "/simple_binary")
    _test_binary_with_transitive_deps(name + "/transitive_deps")
    _test_binary_with_runtime_deps(name + "/runtime_deps")
    _test_binary_with_java_import(name + "/java_import")
    _test_binary_with_java_import_weight(name + "/java_import_weight")
    _test_binary_with_data(name + "/with_data")
    _test_library_with_data(name + "/library_with_data")
    _test_binary_with_foreign_java_dep(name + "/foreign_java_dep")
    _test_java_test_rule(name + "/java_test")
    _test_binary_group_ordering(name + "/group_ordering")
    _test_merge_to_limit(name + "/merge_to_limit")

    native.test_suite(
        name = name,
        tests = [name + "/" + test for test in tests],
    )

def _test_simple_binary(name):
    _helper(java_library, name + "_lib", srcs = ["java/A.java"])
    _helper(
        java_binary,
        name + "_bin",
        main_class = "A",
        runtime_deps = [name + "_lib"],
    )

    # The only test that keeps check_disabled = True: it analyzes the binary's
    # entire closure a second time to verify that the rules honor the global
    # switch, which is worth doing once rather than in every case.
    runfiles_group_analysis_test(
        name = name,
        binaries = [name + "_bin"],
        overlapping_group_behavior = "error",
        expected_executable_group = "rules_java#binary",
    )

def _test_binary_with_transitive_deps(name):
    _helper(java_library, name + "_leaf", srcs = ["java/A.java"])
    _helper(java_library, name + "_mid", srcs = ["java/B.java"], deps = [name + "_leaf"])
    _helper(
        java_binary,
        name + "_bin",
        main_class = "B",
        runtime_deps = [name + "_mid"],
    )
    runfiles_group_analysis_test(
        name = name,
        binaries = [name + "_bin"],
        overlapping_group_behavior = "error",
        check_disabled = False,
    )

def _test_binary_with_runtime_deps(name):
    _helper(java_library, name + "_compile_dep", srcs = ["java/A.java"])
    _helper(java_library, name + "_runtime_dep", srcs = ["java/B.java"])
    _helper(
        java_binary,
        name + "_bin",
        srcs = ["java/Main.java"],
        main_class = "Main",
        deps = [name + "_compile_dep"],
        runtime_deps = [name + "_runtime_dep"],
    )
    runfiles_group_analysis_test(
        name = name,
        binaries = [name + "_bin"],
        overlapping_group_behavior = "error",
        check_disabled = False,
    )

def _test_binary_with_java_import(name):
    _helper(
        java_import,
        name + "_imported",
        jars = ["B.jar"],
    )
    _helper(
        java_binary,
        name + "_bin",
        main_class = "A",
        runtime_deps = [name + "_imported"],
    )
    runfiles_group_analysis_test(
        name = name,
        binaries = [name + "_bin"],
        overlapping_group_behavior = "error",
        check_disabled = False,
    )

def _test_binary_with_java_import_weight(name):
    _helper(
        java_import,
        name + "_imported",
        jars = ["B.jar"],
        runfiles_weight = 42,
    )
    _helper(
        java_binary,
        name + "_bin",
        main_class = "A",
        runtime_deps = [name + "_imported"],
    )
    runfiles_group_analysis_test(
        name = name,
        binaries = [name + "_bin"],
        overlapping_group_behavior = "error",
        check_disabled = False,
    )

def _test_binary_with_data(name):
    _helper(java_library, name + "_lib", srcs = ["java/A.java"])
    _helper(
        java_binary,
        name + "_bin",
        main_class = "A",
        runtime_deps = [name + "_lib"],
        data = ["java/A.java"],
    )
    runfiles_group_analysis_test(
        name = name,
        binaries = [name + "_bin"],
        overlapping_group_behavior = "error",
        check_disabled = False,
    )

def _test_library_with_data(name):
    # A library's data files land in the binary's runfiles through
    # collect_default, so the library has to put them in a group of their own.
    _helper(java_library, name + "_lib", srcs = ["java/A.java"], data = ["java/A.java"])
    _helper(
        java_binary,
        name + "_bin",
        main_class = "A",
        runtime_deps = [name + "_lib"],
    )
    runfiles_group_analysis_test(
        name = name,
        binaries = [name + "_bin"],
        overlapping_group_behavior = "error",
        check_disabled = False,
    )

def _test_binary_with_foreign_java_dep(name):
    _helper(_fake_jvm_import, name + "_foreign", jar = "B.jar")
    _helper(
        java_binary,
        name + "_bin",
        main_class = "A",
        runtime_deps = [name + "_foreign"],
    )
    runfiles_group_analysis_test(
        name = name,
        binaries = [name + "_bin"],
        overlapping_group_behavior = "error",
        check_disabled = False,
    )

def _test_java_test_rule(name):
    _helper(java_library, name + "_lib", srcs = ["java/A.java"])
    _helper(
        java_test,
        name + "_test_bin",
        srcs = ["java/A.java"],
        test_class = "A",
        runtime_deps = [name + "_lib"],
    )
    runfiles_group_analysis_test(
        name = name,
        binaries = [name + "_test_bin"],
        overlapping_group_behavior = "error",
        check_disabled = False,
    )

def _test_binary_group_ordering(name):
    _helper(java_library, name + "_lib", srcs = ["java/A.java"])
    _helper(
        java_binary,
        name + "_bin",
        main_class = "A",
        runtime_deps = [name + "_lib"],
    )
    runfiles_group_analysis_test(
        name = name,
        binaries = [name + "_bin"],
        overlapping_group_behavior = "error",
        check_disabled = False,
        # The java_runtime is at the foundation rank, everything else at the
        # executable rank, where the per-target groups (named by a Label) sort
        # before the named ones.
        expected_group_names = [
            "rules_java#java_runtime",
            _label_str(name + "_bin"),
            _label_str(name + "_lib"),
            "rules_java#binary",
        ],
    )

def _test_merge_to_limit(name):
    _helper(java_library, name + "_lib_a", srcs = ["java/A.java"])
    _helper(java_library, name + "_lib_b", srcs = ["java/B.java"])
    _helper(java_library, name + "_lib_c", srcs = ["java/C.java"])
    _helper(
        java_binary,
        name + "_bin",
        main_class = "A",
        runtime_deps = [
            name + "_lib_a",
            name + "_lib_b",
            name + "_lib_c",
        ],
    )
    runfiles_group_analysis_test(
        name = name,
        binaries = [name + "_bin"],
        overlapping_group_behavior = "error",
        check_disabled = False,
        max_groups = 4,
        expected_group_count = 4,
    )
