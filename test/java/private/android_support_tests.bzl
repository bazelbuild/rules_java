# Copyright 2021 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Tests for //java/private:android_support.bzl"""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//java:defs.bzl", "java_library", "java_plugin")
load("//java/common:java_info.bzl", "JavaInfo")
load("//java/private:android_support.bzl", "android_support")  # buildifier: disable=bzl-visibility
load("//test/java/testutil:java_info_subject.bzl", "java_info_subject")

def _impl(ctx):
    return [
        android_support.enable_implicit_sourceless_deps_exports_compatibility(ctx.attr.dep[JavaInfo]),
    ]

my_rule = rule(
    implementation = _impl,
    attrs = {
        "dep": attr.label(),
    },
)

def _test_enable_implicit_sourceless_deps_exports_compatibility(name):
    util.helper_target(
        java_plugin,
        name = "my_plugin",
        srcs = ["MyPlugin.java"],
    )
    util.helper_target(
        java_library,
        name = "base",
        srcs = ["Foo.java"],
        exported_plugins = [":my_plugin"],
    )
    util.helper_target(
        my_rule,
        name = "transformed",
        dep = ":base",
    )

    analysis_test(
        name = name,
        impl = _test_enable_implicit_sourceless_deps_exports_compatibility_impl,
        targets = {
            "base": Label(":base"),
            "transformed": Label(":transformed"),
        },
    )

def _test_enable_implicit_sourceless_deps_exports_compatibility_impl(env, targets):
    base_info = java_info_subject.from_target(env, targets.base)
    transformed_info = java_info_subject.from_target(env, targets.transformed)
    transformed_info.compilation_args().equals_subject(base_info.compilation_args())
    base_info.plugins().processor_jars().contains_exactly(["{package}/libmy_plugin.jar"])
    transformed_info.plugins().processor_jars().contains_exactly([])

def android_support_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_enable_implicit_sourceless_deps_exports_compatibility,
        ],
    )
