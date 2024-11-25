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

"""
Determines the environment required for Java actions to support UTF-8.
"""

visibility("private")

Utf8EnvironmentInfo = provider(
    doc = "The environment required for Java actions to support UTF-8.",
    fields = {
        "environment": "The environment to use for Java actions to support UTF-8.",
    },
)

# The default UTF-8 locale on all recent Linux distributions. It is also available in Cygwin and
# MSYS2, but doesn't matter for determining the JVM's platform encoding on Windows, which always
# uses the active code page.
_DEFAULT_UTF8_ENVIRONMENT = Utf8EnvironmentInfo(environment = {"LC_CTYPE": "C.UTF-8"})

# macOS doesn't have the C.UTF-8 locale, but en_US.UTF-8 is available and works the same way.
_MACOS_UTF8_ENVIRONMENT = Utf8EnvironmentInfo(environment = {"LC_CTYPE": "en_US.UTF-8"})

def _utf8_environment_impl(ctx):
    if ctx.target_platform_has_constraint(ctx.attr._macos_constraint[platform_common.ConstraintValueInfo]):
        return _MACOS_UTF8_ENVIRONMENT
    else:
        return _DEFAULT_UTF8_ENVIRONMENT

utf8_environment = rule(
    _utf8_environment_impl,
    attrs = {
        "_macos_constraint": attr.label(default = "@platforms//os:macos"),
    },
    doc = "Returns a suitable environment for Java actions to support UTF-8.",
)
