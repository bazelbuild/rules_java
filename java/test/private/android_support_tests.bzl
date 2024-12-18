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
load("//java/common:java_info.bzl", "JavaInfo")
load("//java/private:android_support.bzl", "android_support")

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
    analysis_test(
        name = name,
        impl = _test_enable_implicit_sourceless_deps_exports_compatibility_impl,
        targets = {
            "foo": Label(":foo"),
            "bar": Label(":bar"),
        },
    )

def _test_enable_implicit_sourceless_deps_exports_compatibility_impl(env, targets):
    # TODO(hvd): write a ProviderSubject for JavaInfo
    foo_javainfo = targets.foo[JavaInfo]
    bar_javainfo = targets.bar[JavaInfo]
    for attr in ["transitive_runtime_jars", "compile_jars", "transitive_compile_time_jars", "full_compile_jars", "_transitive_full_compile_time_jars", "_compile_time_java_dependencies"]:
        env.expect.that_bool(getattr(foo_javainfo, attr) == getattr(bar_javainfo, attr)).equals(True)
    env.expect.that_depset_of_files(foo_javainfo.plugins.processor_jars).contains_exactly([
        "java/test/private/libmy_plugin.jar",
    ])
    env.expect.that_depset_of_files(bar_javainfo.plugins.processor_jars).contains_exactly([])

def android_support_tests(name):
    test_suite(
        name = name,
        tests = [
            _test_enable_implicit_sourceless_deps_exports_compatibility,
        ],
    )
