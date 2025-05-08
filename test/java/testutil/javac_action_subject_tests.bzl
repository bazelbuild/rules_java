"""Tests for the javac_action_subject"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load(":javac_action_subject.bzl", "javac_action_subject")

def _parse_flags_test_impl(ctx):
    env = unittest.begin(ctx)
    flags = javac_action_subject.parse_flags([
        "/usr/bin/java",
        "-Xmx1g",
        "-XX:SomeProp=SomeVal",
        "-Dcom.google.foo=bar",
        "--add-exports=jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED",
        "--add-exports=jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED",
        "--add-opens=jdk.compiler/com.sun.tools.javac.comp=ALL-UNNAMED",
        "--add-opens=jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED",
        "-jar",
        "JavaBuilder_deploy.jar",
        "--output",
        "blaze-out/k8/bin/pkg/libfoo.jar",
        "-source",
        "21",
        "-target",
        "17",
        "-g",
        "-parameters",
        "-sourcepath",
        ":",
        "-Xmaxerrs",
        "123",
        "--",
        "--strict_java_deps",
        "ERROR",
        "--classpath",
        "pkg/bar-hjar.jar",
        "other/pkg/baz.jar",
    ])
    asserts.equals(env, {
        "-Xmx1g": [],
        "-XX:SomeProp": ["SomeVal"],
        "-Dcom.google.foo": ["bar"],
        "--add-exports": [
            "jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED",
            "jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED",
        ],
        "--add-opens": [
            "jdk.compiler/com.sun.tools.javac.comp=ALL-UNNAMED",
            "jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED",
        ],
        "-jar": ["JavaBuilder_deploy.jar"],
        "--output": ["blaze-out/k8/bin/pkg/libfoo.jar"],
        "-source": ["21"],
        "-target": ["17"],
        "-g": [],
        "-parameters": [],
        "-sourcepath": [":"],
        "-Xmaxerrs": ["123"],
        "--": [],
        "--strict_java_deps": ["ERROR"],
        "--classpath": ["pkg/bar-hjar.jar", "other/pkg/baz.jar"],
    }, flags)
    return unittest.end(env)

_parse_flags_test = unittest.make(_parse_flags_test_impl)

def javac_action_subject_tests(name):
    unittest.suite(
        name,
        _parse_flags_test,
    )
