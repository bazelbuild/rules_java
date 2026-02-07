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
"""Bazel java_single_jar rule"""

load("//java/common/rules:java_single_jar.bzl", _bazel_java_single_jar = "bazel_java_single_jar")

def java_single_jar(*, name, **kwargs):
    if "output" not in kwargs:
        kwargs["output"] = name + ".jar"
    _bazel_java_single_jar(name = name, **kwargs)
