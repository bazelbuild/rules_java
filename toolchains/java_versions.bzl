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

"""The Java language versions that rules_java declares toolchains for."""

visibility(["//toolchains/..."])

# If this is changed, the docs for "{,tool_}java_language_version" also
# need to be updated in the Bazel user manual
DEFAULT_JAVA_LANGUAGE_VERSION = "11"

RELEASES = (8, 9, 10, 11, 17, 21, 25)

def toolchain_name(release):
    """The name of the java_toolchain in //toolchains for a release."""
    return ("toolchain_java%d" if release <= 11 else "toolchain_jdk_%d") % release
