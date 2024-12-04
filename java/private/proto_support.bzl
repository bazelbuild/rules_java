# Copyright 2024 The Bazel Authors. All rights reserved.
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
"""Support for Java compilation of protocol buffer generated code."""

load("@compatibility_proxy//:proxy.bzl", "java_common", "java_common_internal_compile", "java_info_internal_merge")

def compile(*, injecting_rule_kind, enable_jspecify, include_compilation_info, **kwargs):
    if java_common_internal_compile:
        return java_common_internal_compile(
            injecting_rule_kind = injecting_rule_kind,
            enable_jspecify = enable_jspecify,
            include_compilation_info = include_compilation_info,
            **kwargs
        )
    else:
        return java_common.compile(**kwargs)

def merge(providers, *, merge_java_outputs = True, merge_source_jars = True):
    if java_info_internal_merge:
        return java_info_internal_merge(
            providers,
            merge_java_outputs = merge_java_outputs,
            merge_source_jars = merge_source_jars,
        )
    else:
        return java_common.merge(providers)
