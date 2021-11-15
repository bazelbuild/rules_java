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
load("//toolchains:local_java_repository.bzl", "local_java_repository")
load("//toolchains:remote_java_repository.bzl", "remote_java_repository")

def java_tools_repos():
    http_archive(
        name = "remote_java_tools",
        sha256 = "b763ee80e5754e593fd6d5be6d7343f905bc8b73d661d36d842b024ca11b6793",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v11.5/java_tools-v11.5.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v11.5/java_tools-v11.5.zip",
        ],
    )

    http_archive(
        name = "remote_java_tools_linux",
        sha256 = "ae1eca4546eac6487c6e565f9b409536609c273207220c51e5c94f2a058a5a56",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v11.5/java_tools_linux-v11.5.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v11.5/java_tools_linux-v11.5.zip",
        ],
    )

    http_archive(
        name = "remote_java_tools_windows",
        sha256 = "36766802f7ec684cecb1a14c122428de6be9784e88419e2ab5912ad4b59a8c7d",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v11.5/java_tools_windows-v11.5.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v11.5/java_tools_windows-v11.5.zip",
        ],
    )

    http_archive(
        name = "remote_java_tools_darwin",
        sha256 = "792bc1352e736073b152528175ed424687f86a9f6f5f461f07d8b26806762738",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v11.5/java_tools_darwin-v11.5.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v11.5/java_tools_darwin-v11.5.zip",
        ],
    )

def local_jdk_repo():
    local_java_repository(
        name = "local_jdk",
        build_file = Label("//toolchains:jdk.BUILD"),
    )

def remote_jdk11_repos():
    """Imports OpenJDK 11 repositories."""
    remote_java_repository(
        name = "remotejdk11_linux",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "b8e8a63b79bc312aa90f3558edbea59e71495ef1a9c340e38900dd28a1c579f3",
        strip_prefix = "zulu11.50.19-ca-jdk11.0.12-linux_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.50.19-ca-jdk11.0.12/zulu11.50.19-ca-jdk11.0.12-linux_x64.tar.gz",
        ],
        version = "11",
    )

    remote_java_repository(
        name = "remotejdk11_linux_aarch64",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "61254688067454d3ccf0ef25993b5dcab7b56c8129e53b73566c28a8dd4d48fb",
        strip_prefix = "zulu11.50.19-ca-jdk11.0.12-linux_aarch64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.50.19-ca-jdk11.0.12/zulu11.50.19-ca-jdk11.0.12-linux_aarch64.tar.gz",
        ],
        version = "11",
    )

    remote_java_repository(
        name = "remotejdk11_linux_ppc64le",
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

    remote_java_repository(
        name = "remotejdk11_linux_s390x",
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

    remote_java_repository(
        name = "remotejdk11_macos",
        exec_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "0b8c8b7cf89c7c55b7e2239b47201d704e8d2170884875b00f3103cf0662d6d7",
        strip_prefix = "zulu11.50.19-ca-jdk11.0.12-macosx_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.50.19-ca-jdk11.0.12/zulu11.50.19-ca-jdk11.0.12-macosx_x64.tar.gz",
        ],
        version = "11",
    )

    remote_java_repository(
        name = "remotejdk11_macos_aarch64",
        exec_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "e908a0b4c0da08d41c3e19230f819b364ff2e5f1dafd62d2cf991a85a34d3a17",
        strip_prefix = "zulu11.50.19-ca-jdk11.0.12-macosx_aarch64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.50.19-ca-jdk11.0.12/zulu11.50.19-ca-jdk11.0.12-macosx_aarch64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu11.50.19-ca-jdk11.0.12-macosx_aarch64.tar.gz",
        ],
        version = "11",
    )

    remote_java_repository(
        name = "remotejdk11_win",
        exec_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "42ae65e75d615a3f06a674978e1fa85fdf078cad94e553fee3e779b2b42bb015",
        strip_prefix = "zulu11.50.19-ca-jdk11.0.12-win_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.50.19-ca-jdk11.0.12/zulu11.50.19-ca-jdk11.0.12-win_x64.zip",
        ],
        version = "11",
    )

def remote_jdk15_repos():
    """Imports OpenJDK 15 repositories."""
    remote_java_repository(
        name = "remotejdk15_linux",
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

    remote_java_repository(
        name = "remotejdk15_macos",
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

    remote_java_repository(
        name = "remotejdk15_macos_aarch64",
        exec_compatible_with = [
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

    remote_java_repository(
        name = "remotejdk15_win",
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

def remote_jdk16_repos():
    """Imports OpenJDK 16 repositories."""
    remote_java_repository(
        name = "remotejdk16_linux",
        exec_compatible_with = [
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

    remote_java_repository(
        name = "remotejdk16_macos",
        exec_compatible_with = [
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

    remote_java_repository(
        name = "remotejdk16_macos_aarch64",
        exec_compatible_with = [
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

    remote_java_repository(
        name = "remotejdk16_win",
        exec_compatible_with = [
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
    remote_java_repository(
        name = "remotejdk17_linux",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "37c4f8e48536cceae8c6c20250d6c385e176972532fd35759fa7d6015c965f56",
        strip_prefix = "zulu17.28.13-ca-jdk17.0.0-linux_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.28.13-ca-jdk17.0.0-linux_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu17.28.13-ca-jdk17.0.0-linux_x64.tar.gz",
        ],
        version = "17",
    )

    remote_java_repository(
        name = "remotejdk17_macos",
        exec_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "6029b1fe6853cecad22ab99ac0b3bb4fb8c903dd2edefa91c3abc89755bbd47d",
        strip_prefix = "zulu17.28.13-ca-jdk17.0.0-macosx_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.28.13-ca-jdk17.0.0-macosx_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu17.28.13-ca-jdk17.0.0-macosx_x64.tar.gz",
        ],
        version = "17",
    )

    remote_java_repository(
        name = "remotejdk17_macos_aarch64",
        exec_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "6b17f01f767ee7abf4704149ca4d86423aab9b16b68697b7d36e9b616846a8b0",
        strip_prefix = "zulu17.28.13-ca-jdk17.0.0-macosx_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.28.13-ca-jdk17.0.0-macosx_aarch64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu17.28.13-ca-jdk17.0.0-macosx_aarch64.tar.gz",
        ],
        version = "17",
    )

    remote_java_repository(
        name = "remotejdk17_win",
        exec_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "f4437011239f3f0031c794bb91c02a6350bc941d4196bdd19c9f157b491815a3",
        strip_prefix = "zulu17.28.13-ca-jdk17.0.0-win_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.28.13-ca-jdk17.0.0-win_x64.zip",
            "https://cdn.azul.com/zulu/bin/zulu17.28.13-ca-jdk17.0.0-win_x64.zip",
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

    # TODO: load this will break compatibility with Bazel 4.2.1
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
