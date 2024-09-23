"""Java rules"""

load("//java/bazel/rules:bazel_java_binary.bzl", _java_binary = "java_binary")
load("//java/bazel/rules:bazel_java_import.bzl", _java_import = "java_import")
load("//java/bazel/rules:bazel_java_library.bzl", _java_library = "java_library")
load("//java/bazel/rules:bazel_java_plugin.bzl", _java_plugin = "java_plugin")
load("//java/bazel/rules:bazel_java_test.bzl", _java_test = "java_test")
load("//java/common/rules:java_package_configuration.bzl", _java_package_configuration = "java_package_configuration")
load("//java/common/rules:java_runtime.bzl", _java_runtime = "java_runtime")
load("//java/common/rules:java_toolchain.bzl", _java_toolchain = "java_toolchain")

visibility("private")

java_binary = _java_binary
java_import = _java_import
java_library = _java_library
java_plugin = _java_plugin
java_test = _java_test

java_package_configuration = _java_package_configuration
java_runtime = _java_runtime
java_toolchain = _java_toolchain
