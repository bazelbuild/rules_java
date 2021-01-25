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
load("//toolchains:remote_java_repository.bzl", "remote_java_repository")

def java_tools_javac11_repos():
    maybe(
        http_archive,
        name = "remote_java_tools_linux",
        sha256 = "355c27c603e8fc64bb0e2d7f809741f42576d5f4540f9ce28fd55922085af639",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/javac11/v10.5/java_tools_javac11_linux-v10.5.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/javac11_v10.5/java_tools_javac11_linux-v10.5.zip",
        ],
    )
    maybe(
        http_archive,
        name = "remote_java_tools_windows",
        sha256 = "0b4469ca1a9b3f26cb82fb0f4fd00096f0d839ec2fae097e7bdbb982e3a95a59",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/javac11/v10.5/java_tools_javac11_windows-v10.5.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/javac11_v10.5/java_tools_javac11_windows-v10.5.zip",
        ],
    )
    maybe(
        http_archive,
        name = "remote_java_tools_darwin",
        sha256 = "95aae0a32a170c72a68abb0b9dd6bac7ea3e08c504a5d8c6e8bf7ac51628c98f",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/javac11/v10.5/java_tools_javac11_darwin-v10.5.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/javac11_v10.5/java_tools_javac11_darwin-v10.5.zip",
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
        remote_java_repository,
        name = "remote_jdk8_linux_aarch64",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "f4072e82faa5a09fab2accf2892d4684324fc999d614583c3ff785e87c03963f",
        strip_prefix = "zulu8.50.51.263-ca-jdk8.0.275-linux_aarch64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu-8.50.0.51-ca-jdk8.0.275/zulu8.50.51.263-ca-jdk8.0.275-linux_aarch64.tar.gz",
            "https://cdn.azul.com/zulu-embedded/bin/zulu8.50.51.263-ca-jdk8.0.275-linux_aarch64.tar.gz",
        ],
        version = "8",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk8_linux",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "1db6b2fa642950ee1b4b1ec2b6bc8a9113d7a4cd723f79398e1ada7dab1c981c",
        strip_prefix = "zulu8.50.0.51-ca-jdk8.0.275-linux_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu-8.50.0.51-ca-jdk8.0.275/zulu8.50.0.51-ca-jdk8.0.275-linux_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu8.50.0.51-ca-jdk8.0.275-linux_x64.tar.gz",
        ],
        version = "8",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk8_macos",
        exec_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "b03176597734299c9a15b7c2cc770783cf14d121196196c1248e80c026b59c17",
        strip_prefix = "zulu8.50.0.51-ca-jdk8.0.275-macosx_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu-8.50.0.51-ca-jdk8.0.275/zulu8.50.0.51-ca-jdk8.0.275-macosx_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu8.50.0.51-ca-jdk8.0.275-macosx_x64.tar.gz",
        ],
        version = "8",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk8_windows",
        exec_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "49759b2bd2ab28231a21ff3a3bb45824ddef55d89b5b1a05a62e26a365da0774",
        strip_prefix = "zulu8.50.0.51-ca-jdk8.0.275-win_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu-8.50.0.51-ca-jdk8.0.275/zulu8.50.0.51-ca-jdk8.0.275-win_x64.zip",
            "https://cdn.azul.com/zulu/bin/zulu8.50.0.51-ca-jdk8.0.275-win_x64.zip",
        ],
        version = "8",
    )

def remote_jdk9_repos():
    """Imports OpenJDK 9 repositories.

    The source-code for this OpenJDK can be found at:
    https://mirror.bazel.build/openjdk.linaro.org/releases/jdk9-src-1708.tar.xz
    https://openjdk.linaro.org/releases/jdk9-src-1708.tar.xz
    https://mirror.bazel.build/openjdk/azul-zulu-9.0.7.1-jdk9.0.7/zsrc9.0.7.1-jdk9.0.7.zip
    """
    maybe(
        remote_java_repository,
        name = "remote_jdk9_linux_aarch64",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "72e7843902b0395e2d30e1e9ad2a5f05f36a4bc62529828bcbc698d54aec6022",
        strip_prefix = "jdk9-server-release-1708",
        urls = [
            # When you update this, also update the link to the source-code above.
            "https://mirror.bazel.build/openjdk.linaro.org/releases/jdk9-server-release-170bazel_skylib8.tar.xz",
            "http://openjdk.linaro.org/releases/jdk9-server-release-1708.tar.xz",
        ],
        version = "9",
    )

    maybe(
        remote_java_repository,
        name = "remote_jdk9_linux",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "45f2dfbee93b91b1468cf81d843fc6d9a47fef1f831c0b7ceff4f1eb6e6851c8",
        strip_prefix = "zulu9.0.7.1-jdk9.0.7-linux_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu-9.0.7.1-jdk9.0.7/zulu9.0.7.1-jdk9.0.7-linux_x64.tar.gz",
        ],
        version = "9",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk9_macos",
        exec_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        strip_prefix = "zulu9.0.7.1-jdk9.0.7-macosx_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu-9.0.7.1-jdk9.0.7/zulu9.0.7.1-jdk9.0.7-macosx_x64.tar.gz",
        ],
        version = "9",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk9_windows",
        exec_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        strip_prefix = "zulu9.0.7.1-jdk9.0.7-win_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu-9.0.7.1-jdk9.0.7/zulu9.0.7.1-jdk9.0.7-win_x64.zip",
        ],
        version = "9",
    )

def remote_jdk10_repos():
    """Imports OpenJDK 10 repositories.

    The source-code for this OpenJDK can be found at:
    https://openjdk.linaro.org/releases/jdk10-src-1804.tar.xz
    https://mirror.bazel.build/openjdk.linaro.org/releases/jdk10-src-1804.tar.xz
    https://mirror.bazel.build/openjdk/azul-zulu10.2+3-jdk10.0.1/zsrc10.2+3-jdk10.0.1.zip
    """

    maybe(
        remote_java_repository,
        name = "remote_jdk10_linux_aarch64",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "b7098b7aaf6ee1ffd4a2d0371a0be26c5a5c87f6aebbe46fe9a92c90583a84be",
        strip_prefix = "jdk10-server-release-1804",
        urls = [
            # When you update this, also update the link to the source-code above.
            "https://mirror.bazel.build/openjdk.linaro.org/releases/jdk10-server-release-1804.tar.xz",
            "http://openjdk.linaro.org/releases/jdk10-server-release-1804.tar.xz",
        ],
        version = "10",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk10_linux",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "b3c2d762091a615b0c1424ebbd05d75cc114da3bf4f25a0dec5c51ea7e84146f",
        strip_prefix = "zulu10.2+3-jdk10.0.1-linux_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu10.2+3-jdk10.0.1/zulu10.2+3-jdk10.0.1-linux_x64.tar.gz",
        ],
        version = "10",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk10_macos",
        exec_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "7394d5f41804cfbdb47c609879c4e738bf53358484ea0995076190915b94c702",
        strip_prefix = "zulu10.2+3-jdk10.0.1-macosx_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu10.2+3-jdk10.0.1/zulu10.2+3-jdk10.0.1-macosx_x64.tar.gz",
        ],
        version = "10",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk10_windows",
        exec_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "fd9456b53dab8b9f504ed0f0e2f6305bd0815978d0e02a41643d111290bf940c",
        strip_prefix = "zulu10.2+3-jdk10.0.1-win_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu10.2+3-jdk10.0.1/zulu10.2+3-jdk10.0.1-win_x64.zip",
        ],
        version = "10",
    )

def remote_jdk11_repos():
    """Imports OpenJDK 11 repositories.

    The source-code for this OpenJDK can be found at:
    https://mirror.bazel.build/openjdk/azul-zulu11.43.55-ca-jdk11.0.9.1/zsrc11.43.55-jdk11.0.9.1.zip
    https://mirror.bazel.build/openjdk/azul-zulu11.43.55-ca-jdk11.0.9.1/openjsse-OpenJSSE_1_1_5.tar.gz
    https://mirror.bazel.build/openjdk/azul-zulu11.43.100-ca-jdk11.0.9.1/zulu11.43.100-ca-src-jdk11.0.9.1-linux_aarch64.zip
    """

    maybe(
        remote_java_repository,
        name = "remote_jdk11_linux_aarch64",
        sha256 = "a452f1b9682d9f83c1c14e54d1446e1c51b5173a3a05dcb013d380f9508562e4",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
        strip_prefix = "zulu11.37.48-ca-jdk11.0.6-linux_aarch64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.37.48-ca-jdk11.0.6/zulu11.37.48-ca-jdk11.0.6-linux_aarch64.tar.gz",
        ],
        version = "11",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk11_linux",
        sha256 = "360626cc19063bc411bfed2914301b908a8f77a7919aaea007a977fa8fb3cde1",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.37.17-ca-jdk11.0.6/zulu11.37.17-ca-jdk11.0.6-linux_x64.tar.gz",
        ],
        version = "11",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk11_macos",
        sha256 = "e1fe56769f32e2aaac95e0a8f86b5a323da5af3a3b4bba73f3086391a6cc056f",
        exec_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        strip_prefix = "zulu11.37.17-ca-jdk11.0.6-macosx_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.37.17-ca-jdk11.0.6/zulu11.37.17-ca-jdk11.0.6-macosx_x64.tar.gz",
        ],
        version = "11",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk11_windows",
        sha256 = "a9695617b8374bfa171f166951214965b1d1d08f43218db9a2a780b71c665c18",
        exec_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        strip_prefix = "zulu11.37.17-ca-jdk11.0.6-win_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.37.17-ca-jdk11.0.6/zulu11.37.17-ca-jdk11.0.6-win_x64.zip",
        ],
        version = "11",
    )

    maybe(
        remote_java_repository,
        name = "remote_jdk11_linux_ppc64le",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:ppc",
        ],
        sha256 = "a417db0295b1f4b538ecbaf7c774f3a177fab9657a665940170936c0eca4e71a",
        strip_prefix = "jdk-11.0.7+10",
        urls = [
            "https://mirror.bazel.build/openjdk/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.7+10/OpenJDK11U-jdk_ppc64le_linux_hotspot_11.0.7_10.tar.gz",
            "https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.7+10/OpenJDK11U-jdk_ppc64le_linux_hotspot_11.0.7_10.tar.gz",
        ],
        version = "11",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk11_linux_s390x",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:s390x",
        ],
        sha256 = "d9b72e87a1d3ebc0c9552f72ae5eb150fffc0298a7cb841f1ce7bfc70dcd1059",
        strip_prefix = "jdk-11.0.7+10",
        urls = [
            "https://mirror.bazel.build/github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.7+10/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.7_10.tar.gz",
            "https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.7+10/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.7_10.tar.gz",
        ],
        version = "11",
    )

def remote_jdk12_repos():
    """Imports OpenJDK 12 repositories.

    The source-code for this OpenJDK can be found at:
    https://mirror.bazel.build/openjdk/azul-zulu12.2.3-ca-jdk12.0.1/zsrc12.2.3-jdk12.0.1.zip
    """
    maybe(
        remote_java_repository,
        name = "remote_jdk12_linux",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "529c99841d69e11a85aea967ccfb9d0fd40b98c5b68dbe1d059002655e0a9c13",
        strip_prefix = "zulu12.2.3-ca-jdk12.0.1-linux_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu12.2.3-ca-jdk12.0.1/zulu12.2.3-ca-jdk12.0.1-linux_x64.tar.gz",
        ],
        version = "12",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk12_macos",
        exec_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "67ca9d285056132ebb19fa237a14affda52132142e1171fe1c20e18974b3b8a5",
        strip_prefix = "zulu12.2.3-ca-jdk12.0.1-macosx_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu12.2.3-ca-jdk12.0.1/zulu12.2.3-ca-jdk12.0.1-macosx_x64.tar.gz",
        ],
        version = "12",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk12_windows",
        exec_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "cf28404c23c3aa1115363ba6e796c30580a768e1d7d6681a7d053e516008e00d",
        strip_prefix = "zulu12.2.3-ca-jdk12.0.1-win_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu12.2.3-ca-jdk12.0.1/zulu12.2.3-ca-jdk12.0.1-win_x64.zip",
        ],
        version = "12",
    )

def remote_jdk14_repos():
    """Imports OpenJDK 14 repositories."""
    maybe(
        remote_java_repository,
        name = "remote_jdk14_linux",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "48bb8947034cd079ad1ef83335e7634db4b12a26743a0dc314b6b861480777aa",
        strip_prefix = "zulu14.28.21-ca-jdk14.0.1-linux_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu14.28.21-ca-jdk14.0.1-linux_x64.tar.gz",
        ],
        version = "14",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk14_macos",
        exec_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "088bd4d0890acc9f032b738283bf0f26b2a55c50b02d1c8a12c451d8ddf080dd",
        strip_prefix = "zulu14.28.21-ca-jdk14.0.1-macosx_x64",
        urls = ["https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu14.28.21-ca-jdk14.0.1-macosx_x64.tar.gz"],
        version = "14",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk14_windows",
        exec_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "9cb078b5026a900d61239c866161f0d9558ec759aa15c5b4c7e905370e868284",
        strip_prefix = "zulu14.28.21-ca-jdk14.0.1-win_x64",
        urls = ["https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu14.28.21-ca-jdk14.0.1-win_x64.zip"],
        version = "14",
    )

def remote_jdk15_repos():
    """Imports OpenJDK 15 repositories."""
    maybe(
        remote_java_repository,
        name = "remote_jdk15_linux",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "0a38f1138c15a4f243b75eb82f8ef40855afcc402e3c2a6de97ce8235011b1ad",
        strip_prefix = "zulu15.27.17-ca-jdk15.0.0-linux_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu15.27.17-ca-jdk15.0.0-linux_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu15.27.17-ca-jdk15.0.0-linux_x64.tar.gz",
        ],
        version = "15",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk15_macos",
        exec_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "f80b2e0512d9d8a92be24497334c974bfecc8c898fc215ce0e76594f00437482",
        strip_prefix = "zulu15.27.17-ca-jdk15.0.0-macosx_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu15.27.17-ca-jdk15.0.0-macosx_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu15.27.17-ca-jdk15.0.0-macosx_x64.tar.gz",
        ],
        version = "15",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk15_windows",
        exec_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "f535a530151e6c20de8a3078057e332b08887cb3ba1a4735717357e72765cad6",
        strip_prefix = "zulu15.27.17-ca-jdk15.0.0-win_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu15.27.17-ca-jdk15.0.0-win_x64.zip",
            "https://cdn.azul.com/zulu/bin/zulu15.27.17-ca-jdk15.0.0-win_x64.zip",
        ],
        version = "15",
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
