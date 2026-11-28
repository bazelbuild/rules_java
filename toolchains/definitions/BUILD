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

load("//toolchains:java_versions.bzl", "DEFAULT_JAVA_LANGUAGE_VERSION", "RELEASES", "toolchain_name")

package(default_applicable_licenses = ["@rules_java//:license"])

licenses(["notice"])

filegroup(
    name = "srcs",
    srcs = glob(["**"]),
    visibility = ["//:__pkg__"],
)

config_setting(
    name = "default_version_setting",
    values = {"java_language_version": ""},
    visibility = ["//visibility:private"],
)

[
    toolchain(
        name = toolchain_name(release) + "_default_definition",
        target_settings = [":default_version_setting"],
        toolchain = "//toolchains:" + toolchain_name(release),
        toolchain_type = "@bazel_tools//tools/jdk:toolchain_type",
    )
    for release in RELEASES
    if str(release) == DEFAULT_JAVA_LANGUAGE_VERSION
]

[
    config_setting(
        name = toolchain_name(release) + "_version_setting",
        values = {"java_language_version": str(release)},
        visibility = ["//visibility:private"],
    )
    for release in RELEASES
]

[
    toolchain(
        name = toolchain_name(release) + "_definition",
        target_settings = [":" + toolchain_name(release) + "_version_setting"],
        toolchain = "//toolchains:" + toolchain_name(release),
        toolchain_type = "@bazel_tools//tools/jdk:toolchain_type",
    )
    for release in RELEASES
]
