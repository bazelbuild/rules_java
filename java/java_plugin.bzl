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
"""java_plugin rule"""

load("@compatibility_proxy//:proxy.bzl", _java_plugin = "java_plugin")

def java_plugin(**attrs):
    """Bazel java_plugin rule.

    https://docs.bazel.build/versions/master/be/java.html#java_plugin

    Args:
      **attrs: Rule attributes
    """

    _java_plugin(**attrs)
