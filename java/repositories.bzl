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
load("//toolchains:local_java_repository.bzl", "local_java_repository")
load("//toolchains:remote_java_repository.bzl", "remote_java_repository")

def java_tools_repos():
    maybe(
        http_archive,
        name = "remote_java_tools",
        sha256 = "b763ee80e5754e593fd6d5be6d7343f905bc8b73d661d36d842b024ca11b6793",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v11.5/java_tools-v11.5.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v11.5/java_tools-v11.5.zip",
        ],
    )

    maybe(
        http_archive,
        name = "remote_java_tools_linux",
        sha256 = "ae1eca4546eac6487c6e565f9b409536609c273207220c51e5c94f2a058a5a56",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v11.5/java_tools_linux-v11.5.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v11.5/java_tools_linux-v11.5.zip",
        ],
    )

    maybe(
        http_archive,
        name = "remote_java_tools_windows",
        sha256 = "36766802f7ec684cecb1a14c122428de6be9784e88419e2ab5912ad4b59a8c7d",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v11.5/java_tools_windows-v11.5.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v11.5/java_tools_windows-v11.5.zip",
        ],
    )

    maybe(
        http_archive,
        name = "remote_java_tools_darwin",
        sha256 = "792bc1352e736073b152528175ed424687f86a9f6f5f461f07d8b26806762738",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v11.5/java_tools_darwin-v11.5.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v11.5/java_tools_darwin-v11.5.zip",
        ],
    )

def local_jdk_repo():
    maybe(
        local_java_repository,
        name = "local_jdk",
        build_file = Label("//toolchains:jdk.BUILD"),
    )

def remote_jdk8_repos(name = ""):
    """Imports OpenJDK 8 repositories.

    Args:
        name: The name of this macro (not used)
    """
    maybe(
        remote_java_repository,
        name = "remote_jdk8_linux_aarch64",
        target_compatible_with = [
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
        target_compatible_with = [
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
        name = "remote_jdk8_macos_aarch64",
        target_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "e5c84a46bbd985c3a53358db9c97a6fd4930f92b833c3163a0d1e47dab59768c",
        strip_prefix = "zulu8.62.0.19-ca-jdk8.0.332-macosx_aarch64",
        urls = [
            "https://cdn.azul.com/zulu/bin/zulu8.62.0.19-ca-jdk8.0.332-macosx_aarch64.tar.gz",
        ],
        version = "8",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk8_macos",
        target_compatible_with = [
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
        target_compatible_with = [
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
    REMOTE_JDK8_REPOS = [
        "remote_jdk8_linux_aarch64",
        "remote_jdk8_linux",
        "remote_jdk8_macos_aarch64",
        "remote_jdk8_macos",
        "remote_jdk8_windows",
    ]
    for name in REMOTE_JDK8_REPOS:
        native.register_toolchains("@" + name + "_toolchain_config_repo//:toolchain")

def remote_jdk11_repos():
    """Imports OpenJDK 11 repositories."""
    maybe(
        remote_java_repository,
        name = "remotejdk11_linux",
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "e064b61d93304012351242bf0823c6a2e41d9e28add7ea7f05378b7243d34247",
        strip_prefix = "zulu11.56.19-ca-jdk11.0.15-linux_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.56.19-ca-jdk11.0.15-linux_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu11.56.19-ca-jdk11.0.15-linux_x64.tar.gz",
        ],
        version = "11",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk11_linux_aarch64",
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "fc7c41a0005180d4ca471c90d01e049469e0614cf774566d4cf383caa29d1a97",
        strip_prefix = "zulu11.56.19-ca-jdk11.0.15-linux_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu-embedded/bin/zulu11.56.19-ca-jdk11.0.15-linux_aarch64.tar.gz",
            "https://cdn.azul.com/zulu-embedded/bin/zulu11.56.19-ca-jdk11.0.15-linux_aarch64.tar.gz",
        ],
        version = "11",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk11_linux_ppc64le",
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:ppc",
        ],
        sha256 = "a8fba686f6eb8ae1d1a9566821dbd5a85a1108b96ad857fdbac5c1e4649fc56f",
        strip_prefix = "jdk-11.0.15+10",
        urls = [
            "https://mirror.bazel.build/github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.15+10/OpenJDK11U-jdk_ppc64le_linux_hotspot_11.0.15_10.tar.gz",
            "https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.15+10/OpenJDK11U-jdk_ppc64le_linux_hotspot_11.0.15_10.tar.gz",
        ],
        version = "11",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk11_linux_s390x",
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:s390x",
        ],
        sha256 = "a58fc0361966af0a5d5a31a2d8a208e3c9bb0f54f345596fd80b99ea9a39788b",
        strip_prefix = "jdk-11.0.15+10",
        urls = [
            "https://mirror.bazel.build/github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.15+10/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.15_10.tar.gz",
            "https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.15+10/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.15_10.tar.gz",
        ],
        version = "11",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk11_macos",
        target_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "2614e5c5de8e989d4d81759de4c333aa5b867b17ab9ee78754309ba65c7f6f55",
        strip_prefix = "zulu11.56.19-ca-jdk11.0.15-macosx_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.56.19-ca-jdk11.0.15-macosx_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu11.56.19-ca-jdk11.0.15-macosx_x64.tar.gz",
        ],
        version = "11",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk11_macos_aarch64",
        target_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "6bb0d2c6e8a29dcd9c577bbb2986352ba12481a9549ac2c0bcfd00ed60e538d2",
        strip_prefix = "zulu11.56.19-ca-jdk11.0.15-macosx_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.56.19-ca-jdk11.0.15-macosx_aarch64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu11.56.19-ca-jdk11.0.15-macosx_aarch64.tar.gz",
        ],
        version = "11",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk11_win",
        target_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "a106c77389a63b6bd963a087d5f01171bd32aa3ee7377ecef87531390dcb9050",
        strip_prefix = "zulu11.56.19-ca-jdk11.0.15-win_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.56.19-ca-jdk11.0.15-win_x64.zip",
            "https://cdn.azul.com/zulu/bin/zulu11.56.19-ca-jdk11.0.15-win_x64.zip",
        ],
        version = "11",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk11_win_arm64",
        target_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:arm64",
        ],
        sha256 = "b8a28e6e767d90acf793ea6f5bed0bb595ba0ba5ebdf8b99f395266161e53ec2",
        strip_prefix = "jdk-11.0.13+8",
        urls = [
            "https://mirror.bazel.build/aka.ms/download-jdk/microsoft-jdk-11.0.13.8.1-windows-aarch64.zip",
        ],
        version = "11",
    )

def remote_jdk15_repos():
    """Imports OpenJDK 15 repositories."""
    maybe(
        remote_java_repository,
        name = "remotejdk15_linux",
        target_compatible_with = [
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
        name = "remotejdk15_macos",
        target_compatible_with = [
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
        name = "remotejdk15_macos_aarch64",
        target_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "2613c3f15eef6b6ecd0fd102da92282b985e4573905dc902f1783d8059c1efc5",
        strip_prefix = "zulu15.29.15-ca-jdk15.0.2-macosx_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu15.29.15-ca-jdk15.0.2-macosx_aarch64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu15.29.15-ca-jdk15.0.2-macosx_aarch64.tar.gz",
        ],
        version = "15",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk15_win",
        target_compatible_with = [
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

def remote_jdk16_repos():
    """Imports OpenJDK 16 repositories."""
    maybe(
        remote_java_repository,
        name = "remotejdk16_linux",
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "236b5ea97aff3cb312e743848d7efa77faf305170e41371a732ca93c1b797665",
        strip_prefix = "zulu16.28.11-ca-jdk16.0.0-linux_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu16.28.11-ca-jdk16.0.0-linux_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu16.28.11-ca-jdk16.0.0-linux_x64.tar.gz",
        ],
        version = "16",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk16_macos",
        target_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "6d47ef22dc56ce1f5a102ed39e21d9a97320f0bb786818e2c686393109d79bc5",
        strip_prefix = "zulu16.28.11-ca-jdk16.0.0-macosx_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu16.28.11-ca-jdk16.0.0-macosx_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu16.28.11-ca-jdk16.0.0-macosx_x64.tar.gz",
        ],
        version = "16",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk16_macos_aarch64",
        target_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "c92131e83bc71474850e667bc4e05fca33662b8feb009a0547aa14e76b40e890",
        strip_prefix = "zulu16.28.11-ca-jdk16.0.0-macosx_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu16.28.11-ca-jdk16.0.0-macosx_aarch64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu16.28.11-ca-jdk16.0.0-macosx_aarch64.tar.gz",
        ],
        version = "16",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk16_win",
        target_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "6cbf98ada27476526a5f6dff79fd5f2c15e2f671818e503bdf741eb6c8fed3d4",
        strip_prefix = "zulu16.28.11-ca-jdk16.0.0-win_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu16.28.11-ca-jdk16.0.0-win_x64.zip",
            "https://cdn.azul.com/zulu/bin/zulu16.28.11-ca-jdk16.0.0-win_x64.zip",
        ],
        version = "16",
    )

def remote_jdk17_repos():
    """Imports OpenJDK 17 repositories."""
    maybe(
        remote_java_repository,
        name = "remotejdk17_linux",
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "73d5c4bae20325ca41b606f7eae64669db3aac638c5b3ead4a975055846ad6de",
        strip_prefix = "zulu17.32.13-ca-jdk17.0.2-linux_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.32.13-ca-jdk17.0.2-linux_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu17.32.13-ca-jdk17.0.2-linux_x64.tar.gz",
        ],
        version = "17",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk17_macos",
        target_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "89d04b2d99b05dcb25114178e65f6a1c5ca742e125cab0a63d87e7e42f3fcb80",
        strip_prefix = "zulu17.32.13-ca-jdk17.0.2-macosx_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.32.13-ca-jdk17.0.2-macosx_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu17.32.13-ca-jdk17.0.2-macosx_x64.tar.gz",
        ],
        version = "17",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk17_macos_aarch64",
        target_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "54247dde248ffbcd3c048675504b1c503b81daf2dc0d64a79e353c48d383c977",
        strip_prefix = "zulu17.32.13-ca-jdk17.0.2-macosx_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.32.13-ca-jdk17.0.2-macosx_aarch64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu17.32.13-ca-jdk17.0.2-macosx_aarch64.tar.gz",
        ],
        version = "17",
    )
    maybe(
        remote_java_repository,
        name = "remotejdk17_win",
        target_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "e965aa0ea7a0661a3446cf8f10ee00684b851f883b803315289f26b4aa907fdb",
        strip_prefix = "zulu17.32.13-ca-jdk17.0.2-win_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.32.13-ca-jdk17.0.2-win_x64.zip",
            "https://cdn.azul.com/zulu/bin/zulu17.32.13-ca-jdk17.0.2-win_x64.zip",
        ],
        version = "17",
    )
    maybe(
        remote_java_repository,
        name = "remotejdk17_win_arm64",
        target_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:arm64",
        ],
        sha256 = "811d7e7591bac4f081dfb00ba6bd15b6fc5969e1f89f0f327ef75147027c3877",
        strip_prefix = "zulu17.30.15-ca-jdk17.0.1-win_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.30.15-ca-jdk17.0.1-win_aarch64.zip",
            "https://cdn.azul.com/zulu/bin/zulu17.30.15-ca-jdk17.0.1-win_aarch64.zip",
        ],
        version = "17",
    )

def rules_java_dependencies():
    """An utility method to load all dependencies of rules_java.

    Loads the remote repositories used by default in Bazel.
    """

    local_jdk_repo()
    remote_jdk11_repos()
    remote_jdk15_repos()
    remote_jdk16_repos()
    remote_jdk17_repos()

    # TODO: load this will break compatibility with Bazel 4.2.1,
    # Enable this when Bazel 5.0.0 is released.
    # java_tools_repos()

def rules_java_toolchains(name = "toolchains"):
    """An utility method to load all Java toolchains.

    Args:
        name: The name of this macro (not used)
    """
    JDK_VERSIONS = ["11", "15", "16", "17"]
    PLATFORMS = ["linux", "macos", "macos_aarch64", "win"]

    # Remote JDK repos for those Linux platforms are only defined for JDK 11.
    EXTRA_REMOTE_JDK11_REPOS = [
        "remotejdk11_linux_aarch64",
        "remotejdk11_linux_ppc64le",
        "remotejdk11_linux_s390x",
    ]

    REMOTE_JDK_REPOS = [("remotejdk" + version + "_" + platform) for version in JDK_VERSIONS for platform in PLATFORMS] + EXTRA_REMOTE_JDK11_REPOS

    native.register_toolchains("//toolchains:all")
    native.register_toolchains("@local_jdk//:runtime_toolchain_definition")
    for name in REMOTE_JDK_REPOS:
        native.register_toolchains("@" + name + "_toolchain_config_repo//:toolchain")
