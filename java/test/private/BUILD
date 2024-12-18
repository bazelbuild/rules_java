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

load("//java:defs.bzl", "java_library", "java_plugin")
load(":android_support_tests.bzl", "android_support_tests", "my_rule")

java_plugin(
    name = "my_plugin",
    srcs = ["MyPlugin.java"],
)

java_library(
    name = "foo",
    srcs = ["Foo.java"],
    exported_plugins = [":my_plugin"],
)

my_rule(
    name = "bar",
    dep = ":foo",
)

android_support_tests(name = "android_support_tests")
