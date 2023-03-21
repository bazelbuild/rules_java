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

"""Development and production dependencies of rules_java."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//toolchains:local_java_repository.bzl", "local_java_repository")
load("//toolchains:remote_java_repository.bzl", "remote_java_repository")

def java_tools_repos():
    """ Declares the remote java_tools repositories """
    maybe(
        http_archive,
        name = "remote_java_tools",
        sha256 = "6efab6ca6e16e02c90e62bbd08ca65f61527984ab78564ea7ad7a2692b2ffdbb",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v12.0/java_tools-v12.0.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v12.0/java_tools-v12.0.zip",
        ],
    )

    maybe(
        http_archive,
        name = "remote_java_tools_linux",
        sha256 = "4b8366b780387fc5ce69527ed287f2b444ee429d3325305ad062c92ac43c7fb6",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v12.0/java_tools_linux-v12.0.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v12.0/java_tools_linux-v12.0.zip",
        ],
    )

    maybe(
        http_archive,
        name = "remote_java_tools_windows",
        sha256 = "7b938f0c67d9d390f10489b1b9a4dabb51e39ecc94532c3acdf8c4c16900457f",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v12.0/java_tools_windows-v12.0.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v12.0/java_tools_windows-v12.0.zip",
        ],
    )

    maybe(
        http_archive,
        name = "remote_java_tools_darwin",
        sha256 = "abc434be713ee9e1fd6525d7a7bd9d7cdff6e27ae3ca9d96420490e7ff6e28a3",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v12.0/java_tools_darwin_x86_64-v12.0.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v12.0/java_tools_darwin_x86_64-v12.0.zip",
        ],
    )

    maybe(
        http_archive,
        name = "remote_java_tools_darwin_x86_64",
        sha256 = "abc434be713ee9e1fd6525d7a7bd9d7cdff6e27ae3ca9d96420490e7ff6e28a3",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v12.0/java_tools_darwin_x86_64-v12.0.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v12.0/java_tools_darwin_x86_64-v12.0.zip",
        ],
    )

    maybe(
        http_archive,
        name = "remote_java_tools_darwin_arm64",
        sha256 = "24a47a5557ee2ccdacd10a54fe4c15d627c6aeaf7596a5dccf2e11a866a5a32a",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v12.0/java_tools_darwin_arm64-v12.0.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v12.0/java_tools_darwin_arm64-v12.0.zip",
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

def remote_jdk19_repos():
    """Imports OpenJDK 19 repositories."""
    maybe(
        remote_java_repository,
        name = "remotejdk19_linux",
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "4a994aded1d9b35258d543a59d4963d2687a1094a818b79a21f00273fbbc5bca",
        strip_prefix = "zulu19.32.13-ca-jdk19.0.2-linux_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu19.32.13-ca-jdk19.0.2-linux_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu19.32.13-ca-jdk19.0.2-linux_x64.tar.gz",
        ],
        version = "19",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk19_macos",
        target_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "2804575ae9ac63e39caa910e57610bf52b0f9e2d671928a98d18e2fcc9f62ac1",
        strip_prefix = "zulu19.32.13-ca-jdk19.0.2-macosx_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu19.32.13-ca-jdk19.0.2-macosx_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu19.32.13-ca-jdk19.0.2-macosx_x64.tar.gz",
        ],
        version = "19",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk19_macos_aarch64",
        target_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "177d058d968b2fbe7a5ff5eceb18cdc16f6376ce291004f1a3139e78b2fb6391",
        strip_prefix = "zulu19.32.13-ca-jdk19.0.2-macosx_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu19.32.13-ca-jdk19.0.2-macosx_aarch64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu19.32.13-ca-jdk19.0.2-macosx_aarch64.tar.gz",
        ],
        version = "19",
    )
    maybe(
        remote_java_repository,
        name = "remotejdk19_win",
        target_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "d6c768c5ec3252f936bd0562c25458f7c753c62835ca3e91166f975f7a5fe9f1",
        strip_prefix = "zulu19.32.13-ca-jdk19.0.2-win_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu19.32.13-ca-jdk19.0.2-win_x64.zip",
            "https://cdn.azul.com/zulu/bin/zulu19.32.13-ca-jdk19.0.2-win_x64.zip",
        ],
        version = "19",
    )

def rules_java_dependencies():
    """An utility method to load all dependencies of rules_java.

    Loads the remote repositories used by default in Bazel.
    """

    local_jdk_repo()
    remote_jdk11_repos()
    remote_jdk17_repos()
    java_tools_repos()

def rules_java_toolchains(name = "toolchains"):
    """An utility method to load all Java toolchains.

    Args:
        name: The name of this macro (not used)
    """
    JDK_VERSIONS = ["11", "17", "19"]
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
