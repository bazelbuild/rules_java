load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_jar")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def java_tools_deps():
    maybe(
        http_jar,
        name = "rules_java_guava",
        url = "https://repo1.maven.org/maven2/com/google/guava/guava/33.5.0-jre/guava-33.5.0-jre.jar",
        sha256 = "1e301f0c52ac248b0b14fdc3d12283c77252d4d6f48521d572e7d8c4c2cc4ac7",
    )
    maybe(
        http_jar,
        name = "rules_java_jsr305",
        url = "https://repo1.maven.org/maven2/com/google/code/findbugs/jsr305/3.0.2/jsr305-3.0.2.jar",
        sha256 = "766ad2a0783f2687962c8ad74ceecc38a28b9f72a2d085ee438b7813e928d0c7",
    )
    maybe(
        http_jar,
        name = "rules_java_gson",
        url = "https://repo1.maven.org/maven2/com/google/code/gson/gson/2.11.0/gson-2.11.0.jar",
        sha256 = "57928d6e5a6edeb2abd3770a8f95ba44dce45f3b23b7a9dc2b309c581552a78b",
    )
    maybe(
        http_jar,
        name = "rules_java_auto_value",
        url = "https://repo1.maven.org/maven2/com/google/auto/value/auto-value/1.11.0/auto-value-1.11.0.jar",
        sha256 = "aaf8d637bfed3c420436b9facf1b7a88d12c8785374e4202382783005319c2c3",
    )
    maybe(
        http_jar,
        name = "rules_java_auto_value_annotations",
        url = "https://repo1.maven.org/maven2/com/google/auto/value/auto-value-annotations/1.11.0/auto-value-annotations-1.11.0.jar",
        sha256 = "5a055ce4255333b3346e1a8703da5bf8ff049532286fdcd31712d624abe111dd",
    )
    maybe(
        http_jar,
        name = "rules_java_error_prone",
        url = "https://repo1.maven.org/maven2/com/google/errorprone/error_prone_core/2.50.0/error_prone_core-2.50.0.jar",
        sha256 = "40a88d3ea732fac3a57ae0e2b27f1729ce76cc41857bcd63d5845e79eae5f72e",
    )
    maybe(
        http_jar,
        name = "rules_java_error_prone_annotations",
        url = "https://repo1.maven.org/maven2/com/google/errorprone/error_prone_annotations/2.50.0/error_prone_annotations-2.50.0.jar",
        sha256 = "4667724877f1d37a689202da191e23efa7657c62eef93ccdac406eccfe5cdd0a",
    )
    maybe(
        http_jar,
        name = "rules_java_error_prone_annotation",
        url = "https://repo1.maven.org/maven2/com/google/errorprone/error_prone_annotation/2.50.0/error_prone_annotation-2.50.0.jar",
        sha256 = "aa9b67a3aa3418b366e26594e1ae35d100ad3369cd1010ae7d4782d984ea9aaf",
    )
    maybe(
        http_jar,
        name = "rules_java_jacoco_core",
        url = "https://repo1.maven.org/maven2/org/jacoco/org.jacoco.core/0.8.14/org.jacoco.core-0.8.14.jar",
        sha256 = "28abbf0eea5a08e4f24097f2fbac663ca17c341c25c3a04d90d6cd325943c995",
    )
    maybe(
        http_jar,
        name = "rules_java_caffeine",
        url = "https://repo1.maven.org/maven2/com/github/ben-manes/caffeine/caffeine/3.1.8/caffeine-3.1.8.jar",
        sha256 = "7dd15f9df1be238ffaa367ce6f556737a88031de4294dad18eef57c474ddf1d3",
    )
    maybe(
        http_jar,
        name = "rules_java_junit4",
        url = "https://repo1.maven.org/maven2/junit/junit/4.13.2/junit-4.13.2.jar",
        sha256 = "8e495b634469d64fb8acfa3495a065cbacc8a0fff55ce1e31007be4c16dc57d3",
    )
    maybe(
        http_jar,
        name = "rules_java_truth",
        url = "https://repo1.maven.org/maven2/com/google/truth/truth/1.4.4/truth-1.4.4.jar",
        sha256 = "52c86cddadc31bc8457c1e15689fc6b75e2e97ce2a83d8b54b795d556d489f8c",
    )
    maybe(
        http_jar,
        name = "rules_java_error_prone_check_api",
        url = "https://repo1.maven.org/maven2/com/google/errorprone/error_prone_check_api/2.50.0/error_prone_check_api-2.50.0.jar",
        sha256 = "ee935a4f42ac409fb0a471affea938c3050c6887dbaadb106868936d83d8c8f1",
    )
    maybe(
        http_jar,
        name = "rules_java_javax_inject",
        url = "https://repo1.maven.org/maven2/javax/inject/javax.inject/1/javax.inject-1.jar",
        sha256 = "91c77044a50c481636c32d916fd89c9118a72195390452c81065080f957de7ff",
    )






def _java_tools_deps_impl(ctx):
    java_tools_deps()

java_tools_deps_ext = module_extension(
    implementation = _java_tools_deps_impl,
)
