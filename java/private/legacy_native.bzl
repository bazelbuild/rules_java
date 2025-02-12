# Copyright 2022 The Bazel Authors. All rights reserved.
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

# Redefine native symbols with a new name as a workaround for
# exporting them in @compatibility_proxy//:proxy.bzl with their original name.

"""Lovely workaround to be able to expose native constants pretending to be Starlark."""

# Unused with Bazel@HEAD, only used by the compatibility layer for older Bazel versions

# buildifier: disable=native-java-common
native_java_common = java_common

# buildifier: disable=native-java-info
NativeJavaInfo = JavaInfo

# buildifier: disable=native-java-plugin-info
NativeJavaPluginInfo = JavaPluginInfo
