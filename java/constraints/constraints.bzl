# Copyright 2019 The Bazel Authors. All rights reserved.
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

"""A collection of constants to be re-used in platforms and toolchains."""

LINUX_CONSTRAINTS = [
    "@platforms//os:linux",
    "@platforms//cpu:x86_64",
]

WINDOWS_CONSTRAINTS = [
    "@platforms//os:windows",
    "@platforms//cpu:x86_64",
]

MACOS_CONSTRAINTS = [
    "@platforms//os:osx",
    "@platforms//cpu:x86_64",
]

JAVAC9_LANGUAGE8_CONSTRAINTS = [
    "@rules_java//java/constraints/language:java8",
    "@rules_java//java/constraints/javac:9",
]

JAVAC10_LANGUAGE8_CONSTRAINTS = [
    "@rules_java//java/constraints/language:java8",
    "@rules_java//java/constraints/javac:10",
]

JAVAC11_LANGUAGE8_CONSTRAINTS = [
    "@rules_java//java/constraints/language:java8",
    "@rules_java//java/constraints/javac:11",
]

JAVAC12_LANGUAGE8_CONSTRAINTS = [
    "@rules_java//java/constraints/language:java8",
    "@rules_java//java/constraints/javac:12",
]

JDK9_CONSTRAINTS = ["@rules_java//java/constraints/runtime:jdk9"]

JDK10_CONSTRAINTS = ["@rules_java//java/constraints/runtime:jdk10"]

JDK11_CONSTRAINTS = ["@rules_java//java/constraints/runtime:jdk11"]

JDK12_CONSTRAINTS = ["@rules_java//java/constraints/runtime:jdk12"]

REMOTE_JDK9_CONSTRAINTS = [
    "@rules_java//java/constraints/runtime:jdk9",
    "@rules_java//java/constraints/runtime:remote",
]

REMOTE_JDK10_CONSTRAINTS = [
    "@rules_java//java/constraints/runtime:jdk10",
    "@rules_java//java/constraints/runtime:remote",
]

REMOTE_JDK11_CONSTRAINTS = [
    "@rules_java//java/constraints/runtime:jdk11",
    "@rules_java//java/constraints/runtime:remote",
]

REMOTE_JDK12_CONSTRAINTS = [
    "@rules_java//java/constraints/runtime:jdk12",
    "@rules_java//java/constraints/runtime:remote",
]
