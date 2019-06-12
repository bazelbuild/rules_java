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
"""Starlark rules for building Java projects."""

def java_binary(**attrs):
    """Bazel java_binary rule.

    https://docs.bazel.build/versions/master/be/java.html#java_binary

    Args:
      **attrs: Rule attributes
    """
    native.java_binary(**attrs)

def java_import(**attrs):
    """Bazel java_import rule.

    https://docs.bazel.build/versions/master/be/java.html#java_import

    Args:
      **attrs: Rule attributes
    """
    native.java_import(**attrs)

def java_library(**attrs):
    """Bazel java_library rule.

    https://docs.bazel.build/versions/master/be/java.html#java_library

    Args:
      **attrs: Rule attributes
    """
    native.java_library(**attrs)

def java_lite_proto_library(**attrs):
    """Bazel java_lite_proto_library rule.

    https://docs.bazel.build/versions/master/be/java.html#java_lite_proto_library

    Args:
      **attrs: Rule attributes
    """
    native.java_lite_proto_library(**attrs)

def java_proto_library(**attrs):
    """Bazel java_proto_library rule.

    https://docs.bazel.build/versions/master/be/java.html#java_proto_library

    Args:
      **attrs: Rule attributes
    """
    native.java_proto_library(**attrs)

def java_test(**attrs):
    """Bazel java_test rule.

    https://docs.bazel.build/versions/master/be/java.html#java_test

    Args:
      **attrs: Rule attributes
    """
    native.java_test(**attrs)

def java_package_configuration(**attrs):
    """Bazel java_package_configuration rule.

    https://docs.bazel.build/versions/master/be/java.html#java_package_configuration

    Args:
      **attrs: Rule attributes
    """
    native.java_package_configuration(**attrs)

def java_plugin(**attrs):
    """Bazel java_plugin rule.

    https://docs.bazel.build/versions/master/be/java.html#java_plugin

    Args:
      **attrs: Rule attributes
    """
    native.java_plugin(**attrs)

def java_runtime(**attrs):
    """Bazel java_runtime rule.

    https://docs.bazel.build/versions/master/be/java.html#java_runtime

    Args:
      **attrs: Rule attributes
    """
    native.java_runtime(**attrs)

def java_toolchain(**attrs):
    """Bazel java_toolchain rule.

    https://docs.bazel.build/versions/master/be/java.html#java_toolchain

    Args:
      **attrs: Rule attributes
    """
    native.java_toolchain(**attrs)
