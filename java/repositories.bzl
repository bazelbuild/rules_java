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

# WARNING: This file only exists for backwards-compatibility.
# rules_java uses the Bazel federation, so please add any new dependencies to
# rules_java_deps() in
# https://github.com/bazelbuild/bazel-federation/blob/master/repositories.bzl
# Java-only third party dependencies can be added to
# https://github.com/bazelbuild/bazel-federation/blob/master/java_repositories.bzl
# Ideally we'd remove anything in this file except for rules_java_toolchains(),
# which is being invoked as part of the federation setup.

"""Development and production dependencies of rules_java."""

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
        sha256 = "96e223094a12c842a66db0bb7bb6866e88e26e678f045842911f9bd6b47161f5",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/javac11/v4.0/java_tools_javac11_linux-v4.0.zip",
        ],
    )
    maybe(
        http_archive,
        name = "remote_java_tools_javac11_windows",
        sha256 = "a1de51447b2ba2eab923d589ba6c72c289c16e6091e6a3bb3e67a05ef4ad200c",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/javac11/v4.0/java_tools_javac11_windows-v4.0.zip",
        ],
    )
    maybe(
        http_archive,
        name = "remote_java_tools_javac11_macos",
        sha256 = "fbf5bf22e9aab9c622e4c8c59314a1eef5ea09eafc5672b4f3250dc0b971bbcc",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/javac11/v4.0/java_tools_javac11_darwin-v4.0.zip",
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

def remote_jdk8_repos():
    """Imports OpenJDK 8 repositories.

    The source-code for this OpenJDK can be found at:
    https://mirror.bazel.build/openjdk/azul-zulu-8.50.0.51-ca-jdk8.0.275/legacy8ujsse-Legacy8uJSSE_1_1_1.tar.gz
    https://mirror.bazel.build/openjdk/azul-zulu-8.50.0.51-ca-jdk8.0.275/openjsse-OpenJSSE_1_1_5.tar.gz
    https://mirror.bazel.build/openjdk/azul-zulu-8.50.0.51-ca-jdk8.0.275/zsrc8.50.0.53-ca-fx-jdk8.0.275.zip
    """
    maybe(
        http_archive,
        name = "remote_jdk8_linux_aarch64",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "f4072e82faa5a09fab2accf2892d4684324fc999d614583c3ff785e87c03963f",
        strip_prefix = "zulu8.50.51.263-ca-jdk8.0.275-linux_aarch64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu-8.50.0.51-ca-jdk8.0.275/zulu8.50.51.263-ca-jdk8.0.275-linux_aarch64.tar.gz",
            "https://cdn.azul.com/zulu-embedded/bin/zulu8.50.51.263-ca-jdk8.0.275-linux_aarch64.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "remote_jdk8_linux",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "1db6b2fa642950ee1b4b1ec2b6bc8a9113d7a4cd723f79398e1ada7dab1c981c",
        strip_prefix = "zulu8.50.0.51-ca-jdk8.0.275-linux_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu-8.50.0.51-ca-jdk8.0.275/zulu8.50.0.51-ca-jdk8.0.275-linux_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu8.50.0.51-ca-jdk8.0.275-linux_x64.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "remote_jdk8_macos",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "b03176597734299c9a15b7c2cc770783cf14d121196196c1248e80c026b59c17",
        strip_prefix = "zulu8.50.0.51-ca-jdk8.0.275-macosx_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu-8.50.0.51-ca-jdk8.0.275/zulu8.50.0.51-ca-jdk8.0.275-macosx_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu8.50.0.51-ca-jdk8.0.275-macosx_x64.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "remote_jdk8_windows",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "49759b2bd2ab28231a21ff3a3bb45824ddef55d89b5b1a05a62e26a365da0774",
        strip_prefix = "zulu8.50.0.51-ca-jdk8.0.275-win_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu-8.50.0.51-ca-jdk8.0.275/zulu8.50.0.51-ca-jdk8.0.275-win_x64.zip",
            "https://cdn.azul.com/zulu/bin/zulu8.50.0.51-ca-jdk8.0.275-win_x64.zip",
        ],
    )

def remote_jdk9_repos():
    """Imports OpenJDK 9 repositories.

    The source-code for this OpenJDK can be found at:
    https://mirror.bazel.build/openjdk.linaro.org/releases/jdk9-src-1708.tar.xz
    https://openjdk.linaro.org/releases/jdk9-src-1708.tar.xz
    https://mirror.bazel.build/openjdk/azul-zulu-9.0.7.1-jdk9.0.7/zsrc9.0.7.1-jdk9.0.7.zip
    """
    maybe(
        http_archive,
        name = "remote_jdk9_linux_aarch64",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "72e7843902b0395e2d30e1e9ad2a5f05f36a4bc62529828bcbc698d54aec6022",
        strip_prefix = "jdk9-server-release-1708",
        urls = [
            # When you update this, also update the link to the source-code above.
            "https://mirror.bazel.build/openjdk.linaro.org/releases/jdk9-server-release-170bazel_skylib8.tar.xz",
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
    """Imports OpenJDK 10 repositories.

    The source-code for this OpenJDK can be found at:
    https://openjdk.linaro.org/releases/jdk10-src-1804.tar.xz
    https://mirror.bazel.build/openjdk.linaro.org/releases/jdk10-src-1804.tar.xz
    https://mirror.bazel.build/openjdk/azul-zulu10.2+3-jdk10.0.1/zsrc10.2+3-jdk10.0.1.zip
    """

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
    """Imports OpenJDK 11 repositories.

    The source-code for this OpenJDK can be found at:
    https://mirror.bazel.build/openjdk/azul-zulu11.43.55-ca-jdk11.0.9.1/zsrc11.43.55-jdk11.0.9.1.zip
    https://mirror.bazel.build/openjdk/azul-zulu11.43.55-ca-jdk11.0.9.1/openjsse-OpenJSSE_1_1_5.tar.gz
    https://mirror.bazel.build/openjdk/azul-zulu11.43.100-ca-jdk11.0.9.1/zulu11.43.100-ca-src-jdk11.0.9.1-linux_aarch64.zip
    """

    maybe(
        http_archive,
        name = "remote_jdk11_linux_aarch64",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "15f9e3512b2c011a33c36b4ff27a8e70fefc18805509d5d58b0bd3b6684cbe8e",
        strip_prefix = "zulu11.43.100-ca-jdk11.0.9.1-linux_aarch64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.43.100-ca-jdk11.0.9.1/zulu11.43.100-ca-jdk11.0.9.1-linux_aarch64.tar.gz",
            "https://cdn.azul.com/zulu-embedded/bin/zulu11.43.100-ca-jdk11.0.9.1-linux_aarch64.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "remote_jdk11_linux",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "6c79bfe8bb06c82b72ef2f293a14becef56b3078d298dc75fda4225cbb2d3d0c",
        strip_prefix = "zulu11.43.55-ca-jdk11.0.9.1-linux_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.43.55-ca-jdk11.0.9.1/zulu11.43.55-ca-jdk11.0.9.1-linux_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu11.43.55-ca-jdk11.0.9.1-linux_x64.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "remote_jdk11_macos",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "11701b54e62d5cde81a4fa0211776448e38a368c1cfc4ad73bb3bbd628107563",
        strip_prefix = "zulu11.43.55-ca-jdk11.0.9.1-macosx_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.43.55-ca-jdk11.0.9.1/zulu11.43.55-ca-jdk11.0.9.1-macosx_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu11.43.55-ca-jdk11.0.9.1-macosx_x64.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "remote_jdk11_windows",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "b619df7a6f625095ee4adb3add44839b0b1af2adc09a16c7312ca96bb2b61ec9",
        strip_prefix = "zulu11.43.55-ca-jdk11.0.9.1-win_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.43.55-ca-jdk11.0.9.1/zulu11.43.55-ca-jdk11.0.9.1-win_x64.zip",
            "https://cdn.azul.com/zulu/bin/zulu11.43.55-ca-jdk11.0.9.1-win_x64.zip",
        ],
    )

    maybe(
        http_archive,
        name = "remote_jdk11_linux_ppc64le",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "a417db0295b1f4b538ecbaf7c774f3a177fab9657a665940170936c0eca4e71a",
        strip_prefix = "jdk-11.0.7+10",
        urls = [
            "https://mirror.bazel.build/openjdk/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.7+10/OpenJDK11U-jdk_ppc64le_linux_hotspot_11.0.7_10.tar.gz",
            "https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.7+10/OpenJDK11U-jdk_ppc64le_linux_hotspot_11.0.7_10.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "remote_jdk11_linux_s390x",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "d9b72e87a1d3ebc0c9552f72ae5eb150fffc0298a7cb841f1ce7bfc70dcd1059",
        strip_prefix = "jdk-11.0.7+10",
        urls = [
            "https://mirror.bazel.build/github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.7+10/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.7_10.tar.gz",
            "https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.7+10/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.7_10.tar.gz",
        ],
    )

def remote_jdk12_repos():
    """Imports OpenJDK 12 repositories.

    The source-code for this OpenJDK can be found at:
    https://mirror.bazel.build/openjdk/azul-zulu12.2.3-ca-jdk12.0.1/zsrc12.2.3-jdk12.0.1.zip
    """
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

def remote_jdk14_repos():
    """Imports OpenJDK 14 repositories."""
    maybe(
        http_archive,
        name = "remote_jdk14_linux",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "48bb8947034cd079ad1ef83335e7634db4b12a26743a0dc314b6b861480777aa",
        strip_prefix = "zulu14.28.21-ca-jdk14.0.1-linux_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu14.28.21-ca-jdk14.0.1-linux_x64.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "remote_jdk14_macos",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "088bd4d0890acc9f032b738283bf0f26b2a55c50b02d1c8a12c451d8ddf080dd",
        strip_prefix = "zulu14.28.21-ca-jdk14.0.1-macosx_x64",
        urls = ["https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu14.28.21-ca-jdk14.0.1-macosx_x64.tar.gz"],
    )
    maybe(
        http_archive,
        name = "remote_jdk14_windows",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "9cb078b5026a900d61239c866161f0d9558ec759aa15c5b4c7e905370e868284",
        strip_prefix = "zulu14.28.21-ca-jdk14.0.1-win_x64",
        urls = ["https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu14.28.21-ca-jdk14.0.1-win_x64.zip"],
    )

def remote_jdk15_repos():
    """Imports OpenJDK 15 repositories."""
    maybe(
        http_archive,
        name = "remote_jdk15_linux",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "0a38f1138c15a4f243b75eb82f8ef40855afcc402e3c2a6de97ce8235011b1ad",
        strip_prefix = "zulu15.27.17-ca-jdk15.0.0-linux_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu15.27.17-ca-jdk15.0.0-linux_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu15.27.17-ca-jdk15.0.0-linux_x64.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "remote_jdk15_macos",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "f80b2e0512d9d8a92be24497334c974bfecc8c898fc215ce0e76594f00437482",
        strip_prefix = "zulu15.27.17-ca-jdk15.0.0-macosx_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu15.27.17-ca-jdk15.0.0-macosx_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu15.27.17-ca-jdk15.0.0-macosx_x64.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "remote_jdk15_windows",
        build_file = "@local_jdk//:BUILD.bazel",
        sha256 = "f535a530151e6c20de8a3078057e332b08887cb3ba1a4735717357e72765cad6",
        strip_prefix = "zulu15.27.17-ca-jdk15.0.0-win_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu15.27.17-ca-jdk15.0.0-win_x64.zip",
            "https://cdn.azul.com/zulu/bin/zulu15.27.17-ca-jdk15.0.0-win_x64.zip",
        ],
    )

def bazel_skylib():
    maybe(
        http_archive,
        name = "bazel_skylib",
        type = "tar.gz",
        url = "https://github.com/bazelbuild/bazel-skylib/releases/download/0.9.0/bazel_skylib-0.9.0.tar.gz",
        sha256 = "1dde365491125a3db70731e25658dfdd3bc5dbdfd11b840b3e987ecf043c7ca0",
    )

def rules_java_dependencies():
    """An utility method to load all dependencies of rules_java.

    Loads the remote repositories used by default in Bazel.
    """

    remote_jdk11_repos()
    java_tools_javac11_repos()
    bazel_skylib()

def rules_java_toolchains():
    """An utility method to load all Java toolchains.

    It doesn't do anything at the moment.
    """
    pass
