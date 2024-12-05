"""Module extension for compatibility with previous Bazel versions"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def _compatibility_proxy_repo_impl(rctx):
    # TODO: use @bazel_features
    bazel = native.bazel_version
    if not bazel or bazel >= "8":
        rctx.file(
            "BUILD.bazel",
            """
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
exports_files(['proxy.bzl'], visibility = ["@rules_java//test:__pkg__"])
bzl_library(
    name = "proxy_bzl",
    srcs = ["proxy.bzl"],
    deps = [
        "@rules_java//java/bazel/rules",
        "@rules_java//java/common/rules:toolchain_rules",
        "@rules_java//java/private:internals",
        "@rules_java//java/bazel:http_jar_bzl",
    ],
    visibility = ["//visibility:public"]
)
            """,
        )
        rctx.file(
            "proxy.bzl",
            """
load("@rules_java//java/bazel/rules:bazel_java_binary_wrapper.bzl", _java_binary = "java_binary")
load("@rules_java//java/bazel/rules:bazel_java_import.bzl", _java_import = "java_import")
load("@rules_java//java/bazel/rules:bazel_java_library.bzl", _java_library = "java_library")
load("@rules_java//java/bazel/rules:bazel_java_plugin.bzl", _java_plugin = "java_plugin")
load("@rules_java//java/bazel/rules:bazel_java_test.bzl", _java_test = "java_test")
load("@rules_java//java/bazel:http_jar.bzl", _http_jar = "http_jar")
load("@rules_java//java/common/rules:java_package_configuration.bzl", _java_package_configuration = "java_package_configuration")
load("@rules_java//java/common/rules:java_runtime.bzl", _java_runtime = "java_runtime")
load("@rules_java//java/common/rules:java_toolchain.bzl", _java_toolchain = "java_toolchain")
load("@rules_java//java/private:java_common.bzl", _java_common = "java_common")
load("@rules_java//java/private:java_common_internal.bzl", _java_common_internal_compile = "compile")
load("@rules_java//java/private:java_info.bzl", _JavaInfo = "JavaInfo", _JavaPluginInfo = "JavaPluginInfo", _java_info_internal_merge = "merge")

java_binary = _java_binary
java_import = _java_import
java_library = _java_library
java_plugin = _java_plugin
java_test = _java_test
java_package_configuration = _java_package_configuration
java_runtime = _java_runtime
java_toolchain = _java_toolchain
java_common = _java_common
JavaInfo = _JavaInfo
JavaPluginInfo = _JavaPluginInfo
java_common_internal_compile = _java_common_internal_compile
java_info_internal_merge = _java_info_internal_merge
http_jar = _http_jar
            """,
        )
    else:
        rctx.file(
            "BUILD.bazel",
            """
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
exports_files(['proxy.bzl'], visibility = ["@rules_java//test:__pkg__"])
bzl_library(
    name = "proxy_bzl",
    srcs = ["proxy.bzl"],
    deps = [
        "@rules_java//java/private:native_bzl",
        "@bazel_tools//tools:bzl_srcs",
    ],
    visibility = ["//visibility:public"]
)
            """,
        )
        rctx.file(
            "proxy.bzl",
            """
load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_jar = "http_jar")
load("@rules_java//java/private:native.bzl", "native_java_common", "NativeJavaInfo", "NativeJavaPluginInfo")

java_binary = native.java_binary
java_import = native.java_import
java_library = native.java_library
java_plugin = native.java_plugin
java_test = native.java_test

java_package_configuration = native.java_package_configuration
java_runtime = native.java_runtime
java_toolchain = native.java_toolchain

java_common = native_java_common
JavaInfo = NativeJavaInfo
JavaPluginInfo = NativeJavaPluginInfo
java_common_internal_compile = None
java_info_internal_merge = None

http_jar = _http_jar
            """,
        )

_compatibility_proxy_repo_rule = repository_rule(
    _compatibility_proxy_repo_impl,
    # force reruns on server restarts to use correct native.bazel_version
    local = True,
)

def compatibility_proxy_repo():
    maybe(_compatibility_proxy_repo_rule, name = "compatibility_proxy")

def _compat_proxy_impl(_unused):
    compatibility_proxy_repo()

compatibility_proxy = module_extension(_compat_proxy_impl)

def protobuf_repo():
    maybe(
        http_archive,
        name = "com_google_protobuf",
        sha256 = "ce5d00b78450a0ca400bf360ac00c0d599cc225f049d986a27e9a4e396c5a84a",
        strip_prefix = "protobuf-29.0-rc2",
        url = "https://github.com/protocolbuffers/protobuf/releases/download/v29.0-rc2/protobuf-29.0-rc2.tar.gz",
    )

def rules_cc_repo():
    maybe(
        http_archive,
        name = "rules_cc",
        sha256 = "f4aadd8387f381033a9ad0500443a52a0cea5f8ad1ede4369d3c614eb7b2682e",
        strip_prefix = "rules_cc-0.0.15",
        urls = ["https://github.com/bazelbuild/rules_cc/releases/download/0.0.15/rules_cc-0.0.15.tar.gz"],
    )

def bazel_skylib_repo():
    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "bc283cdfcd526a52c3201279cda4bc298652efa898b10b4db0837dc51652756f",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
        ],
    )

def rules_java_dependencies():
    """An utility method to load non-toolchain dependencies of rules_java.

    Loads the remote repositories used by default in Bazel.
    """
    compatibility_proxy_repo()
    bazel_skylib_repo()
    rules_cc_repo()
    protobuf_repo()
