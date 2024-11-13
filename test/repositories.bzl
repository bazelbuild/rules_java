"""Test dependencies for rules_java."""

load("@bazel_skylib//lib:modules.bzl", "modules")

# TODO: Use http_jar from //java:http_jar.bzl once it doesn't refert to cache.bzl from @bazel_tools
# anymore, which isn't available in Bazel 6.
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

def test_repositories():
    http_file(
        name = "guava",
        url = "https://repo1.maven.org/maven2/com/google/guava/guava/33.3.1-jre/guava-33.3.1-jre.jar",
        integrity = "sha256-S/Dixa+ORSXJbo/eF6T3MH+X+EePEcTI41oOMpiuTpA=",
        downloaded_file_path = "guava.jar",
    )
    http_file(
        name = "truth",
        url = "https://repo1.maven.org/maven2/com/google/truth/truth/1.4.4/truth-1.4.4.jar",
        integrity = "sha256-Ushs3a3DG8hFfB4VaJ/Gt14ul84qg9i1S3ldVW1In4w=",
        downloaded_file_path = "truth.jar",
    )

test_repositories_ext = modules.as_extension(test_repositories)
