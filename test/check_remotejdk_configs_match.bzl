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
"""Checks for keeping repository_util.bzl and repositories.bzl in sync"""

load("//java:repositories.bzl", "REMOTE_JDK_CONFIGS")
load("//java/bazel:repositories_util.bzl", "FLAT_CONFIGS")

def validate_configs():
    """Ensures repository_util.bzl and repositories.bzl are in sync"""
    for expected in FLAT_CONFIGS:
        actual = [cfg for cfg in REMOTE_JDK_CONFIGS[expected.version] if cfg.name == expected.name]
        if len(actual) != 1:
            fail("Expected to find exactly one configuration for:", expected.name, "found: ", actual)
        actual = actual[0]
        if expected.urls != actual.urls or expected.strip_prefix != actual.strip_prefix:
            fail("config mismatch! wanted:", expected, "got:", actual)
