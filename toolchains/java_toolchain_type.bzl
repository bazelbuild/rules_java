# Copyright 2026 The Bazel Authors. All rights reserved.
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

"""Defines the Java toolchain types."""

load("@bazel_features//:features.bzl", "bazel_features")

visibility("private")

def java_toolchain_type(name):
    """Defines the Java toolchain type with the given name.

    Bazel versions that still define the type in @bazel_tools//tools/jdk get an alias instead.

    Args:
      name: The name of the toolchain type in @bazel_tools//tools/jdk.
    """
    if bazel_features.java.toolchain_types_in_rules_java:
        native.toolchain_type(name = name)
    else:
        native.alias(
            name = name,
            actual = "@bazel_tools//tools/jdk:" + name,
        )
