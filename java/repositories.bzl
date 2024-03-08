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
load("//toolchains:jdk_build_file.bzl", "JDK_BUILD_TEMPLATE")
load("//toolchains:local_java_repository.bzl", "local_java_repository")
load("//toolchains:remote_java_repository.bzl", "remote_java_repository")

_JAVA_TOOLS_CONFIG = {
    "version": "v13.4",
    "release": "true",
    "artifacts": {
        "java_tools_linux": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v13.4/java_tools_linux-v13.4.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v13.4/java_tools_linux-v13.4.zip",
            "sha": "ba10f09a138cf185d04cbc807d67a3da42ab13d618c5d1ce20d776e199c33a39",
        },
        "java_tools_windows": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v13.4/java_tools_windows-v13.4.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v13.4/java_tools_windows-v13.4.zip",
            "sha": "fe2f88169696d6c6fc6e90ba61bb46be7d0ae3693cbafdf336041bf56679e8d1",
        },
        "java_tools_darwin_x86_64": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v13.4/java_tools_darwin_x86_64-v13.4.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v13.4/java_tools_darwin_x86_64-v13.4.zip",
            "sha": "4523aec4d09c587091a2dae6f5c9bc6922c220f3b6030e5aba9c8f015913cc65",
        },
        "java_tools_darwin_arm64": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v13.4/java_tools_darwin_arm64-v13.4.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v13.4/java_tools_darwin_arm64-v13.4.zip",
            "sha": "076a7e198ad077f8c7d997986ef5102427fae6bbfce7a7852d2e080ed8767528",
        },
        "java_tools": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v13.4/java_tools-v13.4.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v13.4/java_tools-v13.4.zip",
            "sha": "e025fd260ac39b47c111f5212d64ec0d00d85dec16e49368aae82fc626a940cf",
        },
    },
}

def java_tools_repos():
    """ Declares the remote java_tools repositories """
    for name, config in _JAVA_TOOLS_CONFIG["artifacts"].items():
        maybe(
            http_archive,
            name = "remote_" + name,
            sha256 = config["sha"],
            urls = [
                config["mirror_url"],
                config["github_url"],
            ],
        )

def local_jdk_repo():
    maybe(
        local_java_repository,
        name = "local_jdk",
        build_file_content = JDK_BUILD_TEMPLATE,
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
        name = "remote_jdk8_linux_s390x",
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:s390x",
        ],
        sha256 = "276a431c79b7e94bc1b1b4fd88523383ae2d635ea67114dfc8a6174267f8fb2c",
        strip_prefix = "jdk8u292-b10",
        urls = [
            "https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u292-b10/OpenJDK8U-jdk_s390x_linux_hotspot_8u292b10.tar.gz",
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
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.62.0.19-ca-jdk8.0.332-macosx_aarch64.tar.gz",
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
        "remote_jdk8_linux_s390x",
        "remote_jdk8_linux",
        "remote_jdk8_macos_aarch64",
        "remote_jdk8_macos",
        "remote_jdk8_windows",
    ]
    for name in REMOTE_JDK8_REPOS:
        native.register_toolchains(
            "@" + name + "_toolchain_config_repo//:toolchain",
            "@" + name + "_toolchain_config_repo//:bootstrap_runtime_toolchain",
        )

def remote_jdk11_repos():
    """Imports OpenJDK 11 repositories."""
    maybe(
        remote_java_repository,
        name = "remotejdk11_linux",
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "a34b404f87a08a61148b38e1416d837189e1df7a040d949e743633daf4695a3c",
        strip_prefix = "zulu11.66.15-ca-jdk11.0.20-linux_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.66.15-ca-jdk11.0.20-linux_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu11.66.15-ca-jdk11.0.20-linux_x64.tar.gz",
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
        sha256 = "54174439f2b3fddd11f1048c397fe7bb45d4c9d66d452d6889b013d04d21c4de",
        strip_prefix = "zulu11.66.15-ca-jdk11.0.20-linux_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.66.15-ca-jdk11.0.20-linux_aarch64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu11.66.15-ca-jdk11.0.20-linux_aarch64.tar.gz",
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
        sha256 = "bcaab11cfe586fae7583c6d9d311c64384354fb2638eb9a012eca4c3f1a1d9fd",
        strip_prefix = "zulu11.66.15-ca-jdk11.0.20-macosx_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.66.15-ca-jdk11.0.20-macosx_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu11.66.15-ca-jdk11.0.20-macosx_x64.tar.gz",
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
        sha256 = "7632bc29f8a4b7d492b93f3bc75a7b61630894db85d136456035ab2a24d38885",
        strip_prefix = "zulu11.66.15-ca-jdk11.0.20-macosx_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.66.15-ca-jdk11.0.20-macosx_aarch64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu11.66.15-ca-jdk11.0.20-macosx_aarch64.tar.gz",
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
        sha256 = "43408193ce2fa0862819495b5ae8541085b95660153f2adcf91a52d3a1710e83",
        strip_prefix = "zulu11.66.15-ca-jdk11.0.20-win_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.66.15-ca-jdk11.0.20-win_x64.zip",
            "https://cdn.azul.com/zulu/bin/zulu11.66.15-ca-jdk11.0.20-win_x64.zip",
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
        sha256 = "b9482f2304a1a68a614dfacddcf29569a72f0fac32e6c74f83dc1b9a157b8340",
        strip_prefix = "zulu17.44.53-ca-jdk17.0.8.1-linux_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.44.53-ca-jdk17.0.8.1-linux_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu17.44.53-ca-jdk17.0.8.1-linux_x64.tar.gz",
        ],
        version = "17",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk17_linux_aarch64",
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "6531cef61e416d5a7b691555c8cf2bdff689201b8a001ff45ab6740062b44313",
        strip_prefix = "zulu17.44.53-ca-jdk17.0.8.1-linux_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.44.53-ca-jdk17.0.8.1-linux_aarch64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu17.44.53-ca-jdk17.0.8.1-linux_aarch64.tar.gz",
        ],
        version = "17",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk17_linux_s390x",
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:s390x",
        ],
        sha256 = "ffacba69c6843d7ca70d572489d6cc7ab7ae52c60f0852cedf4cf0d248b6fc37",
        strip_prefix = "jdk-17.0.8.1+1",
        urls = [
            "https://mirror.bazel.build/github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.8.1%2B1/OpenJDK17U-jdk_s390x_linux_hotspot_17.0.8.1_1.tar.gz",
            "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.8.1%2B1/OpenJDK17U-jdk_s390x_linux_hotspot_17.0.8.1_1.tar.gz",
        ],
        version = "17",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk17_linux_ppc64le",
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:ppc",
        ],
        sha256 = "00a4c07603d0218cd678461b5b3b7e25b3253102da4022d31fc35907f21a2efd",
        strip_prefix = "jdk-17.0.8.1+1",
        urls = [
            "https://mirror.bazel.build/github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.8.1%2B1/OpenJDK17U-jdk_ppc64le_linux_hotspot_17.0.8.1_1.tar.gz",
            "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.8.1%2B1/OpenJDK17U-jdk_ppc64le_linux_hotspot_17.0.8.1_1.tar.gz",
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
        sha256 = "640453e8afe8ffe0fb4dceb4535fb50db9c283c64665eebb0ba68b19e65f4b1f",
        strip_prefix = "zulu17.44.53-ca-jdk17.0.8.1-macosx_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.44.53-ca-jdk17.0.8.1-macosx_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu17.44.53-ca-jdk17.0.8.1-macosx_x64.tar.gz",
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
        sha256 = "314b04568ec0ae9b36ba03c9cbd42adc9e1265f74678923b19297d66eb84dcca",
        strip_prefix = "zulu17.44.53-ca-jdk17.0.8.1-macosx_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.44.53-ca-jdk17.0.8.1-macosx_aarch64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu17.44.53-ca-jdk17.0.8.1-macosx_aarch64.tar.gz",
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
        sha256 = "192f2afca57701de6ec496234f7e45d971bf623ff66b8ee4a5c81582054e5637",
        strip_prefix = "zulu17.44.53-ca-jdk17.0.8.1-win_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.44.53-ca-jdk17.0.8.1-win_x64.zip",
            "https://cdn.azul.com/zulu/bin/zulu17.44.53-ca-jdk17.0.8.1-win_x64.zip",
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
        sha256 = "6802c99eae0d788e21f52d03cab2e2b3bf42bc334ca03cbf19f71eb70ee19f85",
        strip_prefix = "zulu17.44.53-ca-jdk17.0.8.1-win_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.44.53-ca-jdk17.0.8.1-win_aarch64.zip",
            "https://cdn.azul.com/zulu/bin/zulu17.44.53-ca-jdk17.0.8.1-win_aarch64.zip",
        ],
        version = "17",
    )

def remote_jdk21_repos():
    """Imports OpenJDK 21 repositories."""
    maybe(
        remote_java_repository,
        name = "remotejdk21_linux",
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "5ad730fbee6bb49bfff10bf39e84392e728d89103d3474a7e5def0fd134b300a",
        strip_prefix = "zulu21.32.17-ca-jdk21.0.2-linux_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.32.17-ca-jdk21.0.2-linux_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu21.32.17-ca-jdk21.0.2-linux_x64.tar.gz",
        ],
        version = "21",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk21_linux_aarch64",
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "ce7df1af5d44a9f455617c4b8891443fbe3e4b269c777d8b82ed66f77167cfe0",
        strip_prefix = "zulu21.32.17-ca-jdk21.0.2-linux_aarch64",
        urls = [
            "https://cdn.azul.com/zulu/bin/zulu21.32.17-ca-jdk21.0.2-linux_aarch64.tar.gz",
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.32.17-ca-jdk21.0.2-linux_aarch64.tar.gz",
        ],
        version = "21",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk21_macos",
        target_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "3ad8fe288eb57d975c2786ae453a036aa46e47ab2ac3d81538ebae2a54d3c025",
        strip_prefix = "zulu21.32.17-ca-jdk21.0.2-macosx_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.32.17-ca-jdk21.0.2-macosx_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu21.32.17-ca-jdk21.0.2-macosx_x64.tar.gz",
        ],
        version = "21",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk21_macos_aarch64",
        target_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "e8260516de8b60661422a725f1df2c36ef888f6fb35393566b00e7325db3d04e",
        strip_prefix = "zulu21.32.17-ca-jdk21.0.2-macosx_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.32.17-ca-jdk21.0.2-macosx_aarch64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu21.32.17-ca-jdk21.0.2-macosx_aarch64.tar.gz",
        ],
        version = "21",
    )
    maybe(
        remote_java_repository,
        name = "remotejdk21_win",
        target_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "f7cc15ca17295e69c907402dfe8db240db446e75d3b150da7bf67243cded93de",
        strip_prefix = "zulu21.32.17-ca-jdk21.0.2-win_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.32.17-ca-jdk21.0.2-win_x64.zip",
            "https://cdn.azul.com/zulu/bin/zulu21.32.17-ca-jdk21.0.2-win_x64.zip",
        ],
        version = "21",
    )

def rules_java_dependencies():
    """An utility method to load all dependencies of rules_java.

    Loads the remote repositories used by default in Bazel.
    """

    local_jdk_repo()
    remote_jdk11_repos()
    remote_jdk17_repos()
    remote_jdk21_repos()
    java_tools_repos()

def rules_java_toolchains(name = "toolchains"):
    """An utility method to load all Java toolchains.

    Args:
        name: The name of this macro (not used)
    """
    JDKS = {
        # Must match JDK repos defined in remote_jdk11_repos()
        "11": ["linux", "linux_aarch64", "linux_ppc64le", "linux_s390x", "macos", "macos_aarch64", "win", "win_arm64"],
        # Must match JDK repos defined in remote_jdk17_repos()
        "17": ["linux", "linux_aarch64", "linux_ppc64le", "linux_s390x", "macos", "macos_aarch64", "win", "win_arm64"],
        # Must match JDK repos defined in remote_jdk21_repos()
        "21": ["linux", "linux_aarch64", "macos", "macos_aarch64", "win"],
    }

    REMOTE_JDK_REPOS = [("remotejdk" + version + "_" + platform) for version in JDKS for platform in JDKS[version]]

    native.register_toolchains(
        "//toolchains:all",
        "@local_jdk//:runtime_toolchain_definition",
        "@local_jdk//:bootstrap_runtime_toolchain_definition",
    )
    for name in REMOTE_JDK_REPOS:
        native.register_toolchains(
            "@" + name + "_toolchain_config_repo//:toolchain",
            "@" + name + "_toolchain_config_repo//:bootstrap_runtime_toolchain",
        )
