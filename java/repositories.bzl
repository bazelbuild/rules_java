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

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def java_tools_javac9_repos():
    maybe(
        http_archive,
        name = "remote_java_tools_javac9_linux",
        sha256 = "0bf678d9815c7212564ecc99b3bd3643450c17657becb12a7bbedcf97ece740d",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/javac9/v3.0/java_tools_javac9_linux-v3.0.zip",
        ],
    )
    maybe(
        http_archive,
        name = "remote_java_tools_javac9_windows",
        sha256 = "9b7e8de98ed2d64ea20a7512f986028ca6375b0fce7637f8d05d1517e7890867",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/javac9/v3.0/java_tools_javac9_windows-v3.0.zip",
        ],
    )
    maybe(
        http_archive,
        name = "remote_java_tools_javac9_macos",
        sha256 = "13a94ddf0c421332f0d3be1adbfc833e24a3a3715bab8f1152660f2df81e286a",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/javac9/v3.0/java_tools_javac9_darwin-v3.0.zip",
        ],
    )

def java_tools_javac10_repos():
    maybe(
        http_archive,
        name = "remote_java_tools_javac10_linux",
        sha256 = "52e03d400d978e9af6321786cdf477694c3838d7e78c2e5b926d0244670b6d3c",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/javac10/v5.0/java_tools_javac10_linux-v5.0.zip",
        ],
    )
    maybe(
        http_archive,
        name = "remote_java_tools_javac10_windows",
        sha256 = "2e3fa82f5790917b56cec5f5d389ed5ff9592a00b5d66750a1f2b6387921d8be",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/javac10/v5.0/java_tools_javac10_windows-v5.0.zip",
        ],
    )
    maybe(
        http_archive,
        name = "remote_java_tools_javac10_macos",
        sha256 = "d5503cc1700b3d544444302617ccc9b2c2780b7fa7bd013215da403148958c35",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/javac10/v5.0/java_tools_javac10_darwin-v5.0.zip",
        ],
    )

def java_tools_javac11_repos():
    maybe(
        http_archive,
        name = "remote_java_tools_javac11_linux",
        sha256 = "10d6f00c72e42b6fda378ad506cc93b1dc92e1aec6e2a490151032244b8b8df5",
        urls = [
             "https://mirror.bazel.build/bazel_java_tools/releases/javac11/v3.0/java_tools_javac11_linux-v3.0.zip",
        ],
    )
    maybe(
        http_archive,
        name = "remote_java_tools_javac11_windows",
        sha256 = "b688155d81245b4d1ee52cac447aae5444b1c59dc77158fcbde05554a6bab48b",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/javac11/v3.0/java_tools_javac11_windows-v3.0.zip",
        ],
    )
    maybe(
        http_archive,
        name = "remote_java_tools_javac11_macos",
        sha256 = "28989f78b1ce437c92dd27bb4943b2211ba4db916ccbb3aef83696a8f9b43724",
        urls = [
             "https://mirror.bazel.build/bazel_java_tools/releases/javac11/v3.0/java_tools_javac11_darwin-v3.0.zip",
        ],
    )

def java_tools_javac12_repos():
    maybe(
        http_archive,
        name = "remote_java_tools_javac12_linux",
        sha256 = "fc199be2c7873b0792e00743679fedc1d249fa779c3fe7676111f8d7ced9f2b4",
        urls = ["https://mirror.bazel.build/bazel_java_tools/releases/javac12/v2.0/java_tools_javac12_linux-v2.0.zip"],
    )
    maybe(
        http_archive,
        name = "remote_java_tools_javac12_windows",
        sha256 = "cab191830609838e99c9adc5e9628e8c839305674c5a9ecf1eea4ba0f6c0b0aa",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/javac12/v2.0/java_tools_javac12_windows-v2.0.zip",
        ],
    )
    maybe(
        http_archive,
        name = "remote_java_tools_javac12_macos",
        sha256 = "d73ff1de1fc2d3ea8403d54099dd2247a2a87390107e7cf81e3a383b0c687341",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/javac12/v2.0/java_tools_javac12_darwin-v2.0.zip",
        ],
    )

def remote_jdk9_repos():
    # OpenJDK distributions that should only be downloaded on demand (e.g. when
    # building a java_library or a genrule that uses java make variables).
    # This will allow us to stop bundling the full JDK with Bazel.
    # Note that while these are currently the same as the openjdk_* rules in
    # Bazel's WORKSPACE file, but they don't have to be the same.

    # The source-code for this OpenJDK can be found at:
    # https://openjdk.linaro.org/releases/jdk9-src-1708.tar.xz
    maybe(
        http_archive,
        name = "remote_jdk9_linux_aarch64",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "72e7843902b0395e2d30e1e9ad2a5f05f36a4bc62529828bcbc698d54aec6022",
        strip_prefix = "jdk9-server-release-1708",
        urls = [
            # When you update this, also update the link to the source-code above.
            "https://mirror.bazel.build/openjdk.linaro.org/releases/jdk9-server-release-1708.tar.xz",
            "http://openjdk.linaro.org/releases/jdk9-server-release-1708.tar.xz",
        ],
    )

    maybe(
        http_archive,
        name = "remote_jdk9_linux",
        build_file_content = "java_runtime(name = 'runtime', srcs =  glob(['**']), visibility = ['//visibility:public'])",
        sha256 = "45f2dfbee93b91b1468cf81d843fc6d9a47fef1f831c0b7ceff4f1eb6e6851c8",
        strip_prefix = "zulu9.0.7.1-jdk9.0.7-linux_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu-9.0.7.1-jdk9.0.7/zulu9.0.7.1-jdk9.0.7-linux_x64.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "remote_jdk9_macos",
        build_file_content = "java_runtime(name = 'runtime', srcs =  glob(['**']), visibility = ['//visibility:public'])",
        strip_prefix = "zulu9.0.7.1-jdk9.0.7-macosx_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu-9.0.7.1-jdk9.0.7/zulu9.0.7.1-jdk9.0.7-macosx_x64.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "remote_jdk9_windows",
        build_file_content = "java_runtime(name = 'runtime', srcs =  glob(['**']), visibility = ['//visibility:public'])",
        strip_prefix = "zulu9.0.7.1-jdk9.0.7-win_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu-9.0.7.1-jdk9.0.7/zulu9.0.7.1-jdk9.0.7-win_x64.zip",
        ],
    )

def remote_jdk10_repos():
    # The source-code for this OpenJDK can be found at:
    # https://openjdk.linaro.org/releases/jdk10-src-1804.tar.xz
    maybe(
        http_archive,
        name = "remote_jdk10_linux_aarch64",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "b7098b7aaf6ee1ffd4a2d0371a0be26c5a5c87f6aebbe46fe9a92c90583a84be",
        strip_prefix = "jdk10-server-release-1804",
        urls = [
            # When you update this, also update the link to the source-code above.
            "https://mirror.bazel.build/openjdk.linaro.org/releases/jdk10-server-release-1804.tar.xz",
            "http://openjdk.linaro.org/releases/jdk10-server-release-1804.tar.xz",
        ],
    )
    maybe(
        http_archive,
        name = "remote_jdk10_linux",
        build_file_content = "java_runtime(name = 'runtime', srcs =  glob(['**']), visibility = ['//visibility:public'])",
        sha256 = "b3c2d762091a615b0c1424ebbd05d75cc114da3bf4f25a0dec5c51ea7e84146f",
        strip_prefix = "zulu10.2+3-jdk10.0.1-linux_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu10.2+3-jdk10.0.1/zulu10.2+3-jdk10.0.1-linux_x64.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "remote_jdk10_macos",
        build_file_content = "java_runtime(name = 'runtime', srcs =  glob(['**']), visibility = ['//visibility:public'])",
        strip_prefix = "zulu10.2+3-jdk10.0.1-macosx_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu10.2+3-jdk10.0.1/zulu10.2+3-jdk10.0.1-macosx_x64.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "remote_jdk10_windows",
        build_file_content = "java_runtime(name = 'runtime', srcs =  glob(['**']), visibility = ['//visibility:public'])",
        strip_prefix = "zulu10.2+3-jdk10.0.1-win_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu10.2+3-jdk10.0.1/zulu10.2+3-jdk10.0.1-win_x64.zip",
        ],
    )

def remote_jdk11_repos():
    # The source-code for this OpenJDK can be found at:
    # https://openjdk.linaro.org/releases/jdk10-src-1804.tar.xz
    maybe(
        http_archive,
        name = "remote_jdk11_linux_aarch64",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "3b0d91611b1bdc4d409afcf9eab4f0e7f4ae09f88fc01bd9f2b48954882ae69b",
        strip_prefix = "zulu11.31.15-ca-jdk11.0.3-linux_aarch64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.31.15-ca-jdk11.0.3/zulu11.31.15-ca-jdk11.0.3-linux_aarch64.tar.gz",
        ],
    )
    maybe(
        http_archive,
        "remote_jdk11_linux",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "232b1c3511f0d26e92582b7c3cc363be7ac633e371854ca2f2e9f2b50eb72a75",
        strip_prefix = "zulu11.2.3-jdk11.0.1-linux_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.2.3-jdk11.0.1/zulu11.2.3-jdk11.0.1-linux_x64.tar.gz",
        ],
    )

    maybe(
        http_archive,
        "remote_jdk11_macos",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "1edf366ee821e5db8e348152fcb337b28dfd6bf0f97943c270dcc6747cedb6cb",
        strip_prefix = "zulu11.2.3-jdk11.0.1-macosx_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.2.3-jdk11.0.1/zulu11.2.3-jdk11.0.1-macosx_x64.tar.gz",
        ],
    )

    maybe(
        http_archive,
        "remote_jdk11_windows",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "8e1e2b8347de6746f3fd1538840dd643201533ab113abc4ed93678e342d28aa3",
        strip_prefix = "zulu11.2.3-jdk11.0.1-win_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.2.3-jdk11.0.1/zulu11.2.3-jdk11.0.1-win_x64.zip",
        ],
    )

def remote_jdk12_repos():
    maybe(
        http_archive,
        name = "remote_jdk12_linux",
        build_file_content = "java_runtime(name = 'runtime', srcs =  glob(['**']), visibility = ['//visibility:public'])",
        strip_prefix = "zulu12.2.3-ca-jdk12.0.1-linux_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu12.2.3-ca-jdk12.0.1/zulu12.2.3-ca-jdk12.0.1-linux_x64.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "remote_jdk12_macos",
        build_file_content = "java_runtime(name = 'runtime', srcs =  glob(['**']), visibility = ['//visibility:public'])",
        strip_prefix = "zulu12.2.3-ca-jdk12.0.1-macosx_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu12.2.3-ca-jdk12.0.1/zulu12.2.3-ca-jdk12.0.1-macosx_x64.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "remote_jdk12_windows",
        build_file_content = "java_runtime(name = 'runtime', srcs =  glob(['**']), visibility = ['//visibility:public'])",
        strip_prefix = "zulu12.2.3-ca-jdk12.0.1-win_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu12.2.3-ca-jdk12.0.1/zulu12.2.3-ca-jdk12.0.1-win_x64.zip",
        ],
    )

def remote_jdk_repos():
    remote_jdk9_repos()
#    remote_jdk10_repos()
    remote_jdk11_repos()
#    remote_jdk12_repos()

def java_tools_repos():
#    java_tools_javac9_repos()
#    java_tools_javac10_repos()
    java_tools_javac11_repos()
#    java_tools_javac12_repos()

def _bazel_skylib():
    maybe(
        http_archive,
        name = "bazel_skylib",
        type = "tar.gz",
        url = "https://github.com/bazelbuild/bazel-skylib/releases/download/0.9.0/bazel_skylib-0.9.0.tar.gz",
        sha256 = "1dde365491125a3db70731e25658dfdd3bc5dbdfd11b840b3e987ecf043c7ca0",
    )

def rules_java_dependencies():
    """An utility method to load all dependencies of rules_java.

    It doesn't do anything at the moment.
    """
    java_tools_repos()
    remote_jdk_repos()
    _bazel_skylib()

def rules_java_toolchains():
    """An utility method to load all Java toolchains.

    It doesn't do anything at the moment.
    """

    native.register_toolchains("@rules_java//java/toolchains/javac/linux:all")
    native.register_toolchains("@rules_java//java/toolchains/javac/macos:all")
    native.register_toolchains("@rules_java//java/toolchains/javac/windows:all")
    native.register_toolchains("@rules_java//java/toolchains/runtime:local_jdk")
    native.register_toolchains("@rules_java//java/toolchains/runtime/remote/linux:all")
    native.register_toolchains("@rules_java//java/toolchains/runtime/remote/macos:all")
    native.register_toolchains("@rules_java//java/toolchains/runtime/remote/windows:all")
