load(":java_binary_tests.bzl", "java_binary_tests")
load(":java_import_tests.bzl", "java_import_tests")
load(":java_library_tests.bzl", "java_library_tests")
load(":java_plugin_tests.bzl", "java_plugin_tests")
load(":java_runtime_tests.bzl", "java_runtime_tests")
load(":java_test_tests.bzl", "java_test_tests")
load(":merge_attrs_tests.bzl", "merge_attrs_test_suite")

package(default_applicable_licenses = ["@rules_java//:license"])

merge_attrs_test_suite(name = "merge_attrs_tests")

java_binary_tests(name = "java_binary_tests")

java_plugin_tests(name = "java_plugin_tests")

java_library_tests(name = "java_library_tests")

java_import_tests(name = "java_import_tests")

java_runtime_tests(name = "java_runtime_tests")

java_test_tests(name = "java_test_tests")
