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

# visible for tests
JAVA_TOOLS_CONFIG = {
    "version": "v22.0",
    "source_revision": "c9b10ec53b5fa49a1bb9c593f08f73ff52f60d95",
    "release": "true",
    "artifacts": {
        "java_tools_linux": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v22.0/java_tools_linux-v22.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v22.0/java_tools_linux-v22.0.zip",
            "sha": "b0b3c2873f30c1123cdd77a74f89fcc4d4debc09a70c8619a4fe8e322f7fda96",
        },
        "java_tools_linux_aarch64": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v22.0/java_tools_linux_aarch64-v22.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v22.0/java_tools_linux_aarch64-v22.0.zip",
            "sha": "f0899527a8784ea0510801a3ee27b3276e2bb78e599473999fe88585a505ddd3",
        },
        "java_tools_windows": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v22.0/java_tools_windows-v22.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v22.0/java_tools_windows-v22.0.zip",
            "sha": "1b302daf293b9ec15eaa2705581976e8c5fd91153fabc6a939a043e6c3d9cf90",
        },
        "java_tools_darwin_x86_64": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v22.0/java_tools_darwin_x86_64-v22.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v22.0/java_tools_darwin_x86_64-v22.0.zip",
            "sha": "fd5d51572f9e2911ae1564849e011805b328f982587e3aaed034f363d646452f",
        },
        "java_tools_darwin_arm64": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v22.0/java_tools_darwin_arm64-v22.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v22.0/java_tools_darwin_arm64-v22.0.zip",
            "sha": "0c78a0d00f09867d56a5064857c936370dab257e5d29dc8d875825509460a456",
        },
        "java_tools": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v22.0/java_tools-v22.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v22.0/java_tools-v22.0.zip",
            "sha": "b13ee1eaa8681d3ec4faffab4251902a0c1b5135b1f5c718831fc5798db82f9b",
        },
    },
}

def java_tools_repos():
    """ Declares the remote java_tools repositories """
    for name, config in JAVA_TOOLS_CONFIG["artifacts"].items():
        maybe(
            http_archive,
            name = "remote_" + name,
            sha256 = config["sha"],
            urls = [
                config["mirror_url"],
                config["github_url"],
            ],
            build_file = config.get("build_file"),
        )

def local_jdk_repo():
    maybe(
        local_java_repository,
        name = "local_jdk",
        build_file_content = JDK_BUILD_TEMPLATE,
    )

# DO NOT MANUALLY UPDATE! Update java/bazel/repositories_util.bzl instead and
# build the java/bazel:dump_remote_jdk_configs target to generate this list
_REMOTE_JDK_CONFIGS_LIST = [
    struct(
        name = "remote_jdk8_linux_aarch64",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:aarch64"],
        sha256 = "f8ee45a8b0e9c63e16324ea71721dc8bed060ecbf523f9d5ed7fa9f9a447f26c",
        strip_prefix = "zulu8.98.0.107-ca-jdk8.0.512-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.98.0.107-ca-jdk8.0.512-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.98.0.107-ca-jdk8.0.512-linux_aarch64.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "f82a4cb00bbac1ddaa4e578cd6221361a45ee0e4ce51969c4109451750e5164e",
        strip_prefix = "zulu8.98.0.107-ca-jdk8.0.512-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.98.0.107-ca-jdk8.0.512-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.98.0.107-ca-jdk8.0.512-linux_x64.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "f26e2a91062542cf22ef2171b2556e1c3f42cf87cf174258b3df7840365892aa",
        strip_prefix = "zulu8.98.0.107-ca-jdk8.0.512-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.98.0.107-ca-jdk8.0.512-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.98.0.107-ca-jdk8.0.512-macosx_aarch64.tar.gz"],
        version = "8",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remote_jdk8_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "1f784fdee4a70970a102262fd34e6da8ab1d9755b3477a2c45906ddd8d290914",
        strip_prefix = "zulu8.98.0.107-ca-jdk8.0.512-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.98.0.107-ca-jdk8.0.512-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.98.0.107-ca-jdk8.0.512-macosx_x64.tar.gz"],
        version = "8",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remote_jdk8_windows",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "9284148d71bff3b34d678a5159bb5688a062f5084ef14abb3daea0a173bb0bf2",
        strip_prefix = "zulu8.98.0.107-ca-jdk8.0.512-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.98.0.107-ca-jdk8.0.512-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.98.0.107-ca-jdk8.0.512-win_x64.zip"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_linux_s390x",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:s390x"],
        sha256 = "276a431c79b7e94bc1b1b4fd88523383ae2d635ea67114dfc8a6174267f8fb2c",
        strip_prefix = "jdk8u292-b10",
        urls = ["https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u292-b10/OpenJDK8U-jdk_s390x_linux_hotspot_8u292b10.tar.gz", "https://mirror.bazel.build/github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u292-b10/OpenJDK8U-jdk_s390x_linux_hotspot_8u292b10.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remotejdk11_linux_aarch64",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:aarch64"],
        sha256 = "abed984a694d4da40662ec0bdfd2ecbe798bab1b8ce784d4f02d00479d53e802",
        strip_prefix = "zulu11.92.109-ca-jdk11.0.33-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.92.109-ca-jdk11.0.33-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.92.109-ca-jdk11.0.33-linux_aarch64.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "64658a2be5140c2ffd571c0e09ac3b505a2be0d4654e09957b584b54b4dac8b5",
        strip_prefix = "zulu11.92.109-ca-jdk11.0.33-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.92.109-ca-jdk11.0.33-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.92.109-ca-jdk11.0.33-linux_x64.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "4947b01fcb220ee69710dbf63375f4628688d84750fccd289f5a6d62b494aa94",
        strip_prefix = "zulu11.92.109-ca-jdk11.0.33-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.92.109-ca-jdk11.0.33-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.92.109-ca-jdk11.0.33-macosx_aarch64.tar.gz"],
        version = "11",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk11_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "ae69ef573c3ad76294f079026775b3b5c70a5fa94fd2f4fccacfaf4b80ed7c13",
        strip_prefix = "zulu11.92.109-ca-jdk11.0.33-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.92.109-ca-jdk11.0.33-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.92.109-ca-jdk11.0.33-macosx_x64.tar.gz"],
        version = "11",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk11_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "fdc77ff97cca003a15b680d0782f0de9063199bbb37b6a645e20bc3ccfcda323",
        strip_prefix = "zulu11.92.109-ca-jdk11.0.33-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.92.109-ca-jdk11.0.33-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.92.109-ca-jdk11.0.33-win_x64.zip"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_linux_ppc64le",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:ppc64le"],
        sha256 = "bb84dc99346d66d5acd3610c4289b5d7c944559efe0d7a0004f9921866b16c97",
        strip_prefix = "jdk-11.0.32.1+1",
        urls = ["https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.32.1+1/OpenJDK11U-jdk_ppc64le_linux_hotspot_11.0.32.1_1.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.32.1+1/OpenJDK11U-jdk_ppc64le_linux_hotspot_11.0.32.1_1.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_linux_s390x",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:s390x"],
        sha256 = "4f51e08f4b0faa3c114c76ee4999bec81457713362b3c7208469e8c08cfbf89d",
        strip_prefix = "jdk-11.0.32.1+1",
        urls = ["https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.32.1+1/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.32.1_1.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.32.1+1/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.32.1_1.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "0187e3f41565ab568ad72c7c2f55b603a47359b545a5980fa055c6470fc3a6b2",
        strip_prefix = "jdk-11.0.32+9",
        urls = ["https://aka.ms/download-jdk/microsoft-jdk-11.0.32-windows-aarch64.zip", "https://mirror.bazel.build/aka.ms/download-jdk/microsoft-jdk-11.0.32-windows-aarch64.zip"],
        version = "11",
    ),
    struct(
        name = "remotejdk17_linux_aarch64",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:aarch64"],
        sha256 = "07389f688d8fe0b77ad754824c09d0be1be19cd4e9f863195d6d545a3c37e988",
        strip_prefix = "zulu17.70.111-ca-jdk17.0.21-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.70.111-ca-jdk17.0.21-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.70.111-ca-jdk17.0.21-linux_aarch64.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "730ac4f645f601d3005bcdc8736c7e0630d402382e332c11d61ac2494436587f",
        strip_prefix = "zulu17.70.111-ca-jdk17.0.21-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.70.111-ca-jdk17.0.21-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.70.111-ca-jdk17.0.21-linux_x64.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "8e51495d34f4d5a5b023e2e525c65afb3fb139e40507fcbc3dcf949ca13ce550",
        strip_prefix = "zulu17.70.111-ca-jdk17.0.21-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.70.111-ca-jdk17.0.21-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.70.111-ca-jdk17.0.21-macosx_aarch64.tar.gz"],
        version = "17",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk17_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "2af1c17d9b2ba530328e52946fe3d4864c0670844918a1dbfb644eb2e2e3e08e",
        strip_prefix = "zulu17.70.111-ca-jdk17.0.21-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.70.111-ca-jdk17.0.21-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.70.111-ca-jdk17.0.21-macosx_x64.tar.gz"],
        version = "17",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk17_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "638c96ff424c380c235f38a9523971040619de08979c7fc27ce6c60c9120430a",
        strip_prefix = "zulu17.70.111-ca-jdk17.0.21-win_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.70.111-ca-jdk17.0.21-win_aarch64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.70.111-ca-jdk17.0.21-win_aarch64.zip"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "ed209ff4293ff581c81d3b4268faf108fbe610e6ed43883de9e5f04308d68a72",
        strip_prefix = "zulu17.70.111-ca-jdk17.0.21-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.70.111-ca-jdk17.0.21-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.70.111-ca-jdk17.0.21-win_x64.zip"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_linux_ppc64le",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:ppc64le"],
        sha256 = "7e3abe98a131e1e914d0cf50f3435f92c1723e4583377edb5cf8e63c8d125ca8",
        strip_prefix = "jdk-17.0.20.1+1",
        urls = ["https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.20.1+1/OpenJDK17U-jdk_ppc64le_linux_hotspot_17.0.20.1_1.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.20.1+1/OpenJDK17U-jdk_ppc64le_linux_hotspot_17.0.20.1_1.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_linux_s390x",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:s390x"],
        sha256 = "f3710814283eea156d1397dc399957789d022b899a791f18bc6805b55b82207f",
        strip_prefix = "jdk-17.0.20.1+1",
        urls = ["https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.20.1+1/OpenJDK17U-jdk_s390x_linux_hotspot_17.0.20.1_1.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.20.1+1/OpenJDK17U-jdk_s390x_linux_hotspot_17.0.20.1_1.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk21_linux_aarch64",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:aarch64"],
        sha256 = "783460592bc66c9290b14c32a537b29da812bd62ad53bf6cb565355bca7ea563",
        strip_prefix = "zulu21.54.107-ca-jdk21.0.13-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.54.107-ca-jdk21.0.13-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.54.107-ca-jdk21.0.13-linux_aarch64.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "dd8cf0628cfb8c369b7d4fe96783e2b516482b37d2b3e140b208c91deabf1169",
        strip_prefix = "zulu21.54.107-ca-jdk21.0.13-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.54.107-ca-jdk21.0.13-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.54.107-ca-jdk21.0.13-linux_x64.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "7682fcbbc3a164352d36c09c96b2aa91841c8bbafdb9a9a7f5f04db6d290a624",
        strip_prefix = "zulu21.54.107-ca-jdk21.0.13-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.54.107-ca-jdk21.0.13-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.54.107-ca-jdk21.0.13-macosx_aarch64.tar.gz"],
        version = "21",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk21_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "a6211ef2de128e72519556ea24c7ecb316ec5589b6ed705aef81c889b4233581",
        strip_prefix = "zulu21.54.107-ca-jdk21.0.13-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.54.107-ca-jdk21.0.13-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.54.107-ca-jdk21.0.13-macosx_x64.tar.gz"],
        version = "21",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk21_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "bbca4b1de2caba87ae219cd955c469f93f69da315a4b9c4f4d629dd05eb10950",
        strip_prefix = "zulu21.54.107-ca-jdk21.0.13-win_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.54.107-ca-jdk21.0.13-win_aarch64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.54.107-ca-jdk21.0.13-win_aarch64.zip"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "69e9fd7afafe0d70235884f8d9ab15cf8a4b43215b27900d710841e1fb3c7126",
        strip_prefix = "zulu21.54.107-ca-jdk21.0.13-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.54.107-ca-jdk21.0.13-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.54.107-ca-jdk21.0.13-win_x64.zip"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_linux_ppc64le",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:ppc64le"],
        sha256 = "042482fa372f12741ceb721397e277b4e69672182aaa45a1bf7af55d9ba876d6",
        strip_prefix = "jdk-21.0.12.1+1",
        urls = ["https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.12.1+1/OpenJDK21U-jdk_ppc64le_linux_hotspot_21.0.12.1_1.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.12.1+1/OpenJDK21U-jdk_ppc64le_linux_hotspot_21.0.12.1_1.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_linux_riscv64",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:riscv64"],
        sha256 = "e6cac9a9f74a001bd21644461697be1ad0d06c9c69076b51984dc9f3b1bb2478",
        strip_prefix = "jdk-21.0.12.1+1",
        urls = ["https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.12.1+1/OpenJDK21U-jdk_riscv64_linux_hotspot_21.0.12.1_1.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.12.1+1/OpenJDK21U-jdk_riscv64_linux_hotspot_21.0.12.1_1.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_linux_s390x",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:s390x"],
        sha256 = "806bb29b0d408eb6312cda0a1e756bc91e554ef9ed6a5863f6004e502f6c789a",
        strip_prefix = "jdk-21.0.12.1+1",
        urls = ["https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.12.1+1/OpenJDK21U-jdk_s390x_linux_hotspot_21.0.12.1_1.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.12.1+1/OpenJDK21U-jdk_s390x_linux_hotspot_21.0.12.1_1.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk25_linux_aarch64",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:aarch64"],
        sha256 = "9c78bc3418fe350861ae45af936cf86898b22f11306266b0499d14700ee22c79",
        strip_prefix = "zulu25.38.107-ca-jdk25.0.5-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.38.107-ca-jdk25.0.5-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.38.107-ca-jdk25.0.5-linux_aarch64.tar.gz"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "9980dfa804c16b9a8cac843b5f4201910d1a46d94633f559ce283b07617a3b99",
        strip_prefix = "zulu25.38.107-ca-jdk25.0.5-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.38.107-ca-jdk25.0.5-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.38.107-ca-jdk25.0.5-linux_x64.tar.gz"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "80e23f202d1815e989c980102e9b9f34cbcd40df9a5c98ac8f0a0aa6f4a45776",
        strip_prefix = "zulu25.38.107-ca-jdk25.0.5-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.38.107-ca-jdk25.0.5-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.38.107-ca-jdk25.0.5-macosx_aarch64.tar.gz"],
        version = "25",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk25_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "d9e9bc4cbe0872e8f71db818d6874878115efebdbd1a93f38542c521353bc81d",
        strip_prefix = "zulu25.38.107-ca-jdk25.0.5-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.38.107-ca-jdk25.0.5-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.38.107-ca-jdk25.0.5-macosx_x64.tar.gz"],
        version = "25",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk25_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "06dbd2134870ea3ca1722cb336558a15403b2ac5f91b6fd4675f824de511bf51",
        strip_prefix = "zulu25.38.107-ca-jdk25.0.5-win_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.38.107-ca-jdk25.0.5-win_aarch64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.38.107-ca-jdk25.0.5-win_aarch64.zip"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "636341b426cbeb02b4a30f5fe073a44d0ef64a2f91d077855e8d20f807471bf8",
        strip_prefix = "zulu25.38.107-ca-jdk25.0.5-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.38.107-ca-jdk25.0.5-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.38.107-ca-jdk25.0.5-win_x64.zip"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_linux_ppc64le",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:ppc64le"],
        sha256 = "b508ca140557322c73da4278d21004b22480b894ffdc67a8795d7814afd8775c",
        strip_prefix = "jdk-25.0.4.1+1",
        urls = ["https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.4.1+1/OpenJDK25U-jdk_ppc64le_linux_hotspot_25.0.4.1_1.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.4.1+1/OpenJDK25U-jdk_ppc64le_linux_hotspot_25.0.4.1_1.tar.gz"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_linux_riscv64",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:riscv64"],
        sha256 = "8dbef2b12ceaecec9b5f00d7f568309b7e3525137777736abfc65900c054ccf9",
        strip_prefix = "jdk-25.0.4.1+1",
        urls = ["https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.4.1+1/OpenJDK25U-jdk_riscv64_linux_hotspot_25.0.4.1_1.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.4.1+1/OpenJDK25U-jdk_riscv64_linux_hotspot_25.0.4.1_1.tar.gz"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_linux_s390x",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:s390x"],
        sha256 = "012d4fe2be909a80c64675ab579877dd9b1db1eff6c7b327eed87b907706f819",
        strip_prefix = "jdk-25.0.4.1+1",
        urls = ["https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.4.1+1/OpenJDK25U-jdk_s390x_linux_hotspot_25.0.4.1_1.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.4.1+1/OpenJDK25U-jdk_s390x_linux_hotspot_25.0.4.1_1.tar.gz"],
        version = "25",
    ),
]

def _make_version_to_remote_jdks():
    result = {}
    for cfg in _REMOTE_JDK_CONFIGS_LIST:
        result.setdefault(cfg.version, [])
        result[cfg.version].append(cfg)
    return result

# visible for testing
REMOTE_JDK_CONFIGS = _make_version_to_remote_jdks()

def _remote_jdk_repos_for_version(version):
    for item in REMOTE_JDK_CONFIGS[version]:
        maybe(
            remote_java_repository,
            name = item.name,
            target_compatible_with = item.target_compatible_with,
            sha256 = item.sha256,
            strip_prefix = item.strip_prefix,
            urls = item.urls,
            version = item.version,
            patch_cmds = getattr(item, "patch_cmds", []),
        )

def remote_jdk8_repos(name = ""):
    """Imports OpenJDK 8 repositories.

    Args:
        name: The name of this macro (not used)
    """
    _remote_jdk_repos_for_version("8")

def remote_jdk11_repos():
    """Imports OpenJDK 11 repositories."""
    _remote_jdk_repos_for_version("11")

def remote_jdk17_repos():
    """Imports OpenJDK 17 repositories."""
    _remote_jdk_repos_for_version("17")

def remote_jdk21_repos():
    """Imports OpenJDK 21 repositories."""
    _remote_jdk_repos_for_version("21")

def remote_jdk25_repos():
    """Imports OpenJDK 25 repositories."""
    _remote_jdk_repos_for_version("25")

def rules_java_dependencies():
    """DEPRECATED: No-op, kept for backwards compatibility"""
    print("DEPRECATED: use rules_java_dependencies() from rules_java_deps.bzl")  # buildifier: disable=print

def rules_java_toolchains(name = "toolchains"):
    """An utility method to load all Java toolchains.

    Args:
        name: The name of this macro (not used)
    """
    local_jdk_repo()
    remote_jdk8_repos()
    remote_jdk11_repos()
    remote_jdk17_repos()
    remote_jdk21_repos()
    remote_jdk25_repos()
    java_tools_repos()

    native.register_toolchains(
        "//toolchains:all",
        "@local_jdk//:runtime_toolchain_definition",
        "@local_jdk//:bootstrap_runtime_toolchain_definition",
    )
    for items in REMOTE_JDK_CONFIGS.values():
        for item in items:
            native.register_toolchains(
                "@" + item.name + "_toolchain_config_repo//:toolchain",
                "@" + item.name + "_toolchain_config_repo//:bootstrap_runtime_toolchain",
            )
