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
"""Module extensions for rules_java."""

load("//java:repositories.bzl", "java_tools_repos", "local_jdk_repo", "remote_jdk11_repos", "remote_jdk17_repos", "remote_jdk19_repos")

def _toolchains_impl(_ctx):
    java_tools_repos()
    local_jdk_repo()
    remote_jdk11_repos()
    remote_jdk17_repos()
    remote_jdk19_repos()

toolchains = module_extension(implementation = _toolchains_impl)
