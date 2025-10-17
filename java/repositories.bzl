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
    "version": "v16.0",
    "release": "true",
    "artifacts": {
        "java_tools_linux": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v16.0/java_tools_linux-v16.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v16.0/java_tools_linux-v16.0.zip",
            "sha": "7c360c60da9b9079e31f18de198f23a22555dfb7b6e91e3c6a7103127b1a8538",
        },
        "java_tools_windows": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v16.0/java_tools_windows-v16.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v16.0/java_tools_windows-v16.0.zip",
            "sha": "b41faa85fceeb2f852e48d51d000d3bf4f29da86ee61d0fc8cca46d297bccf22",
        },
        "java_tools_darwin_x86_64": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v16.0/java_tools_darwin_x86_64-v16.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v16.0/java_tools_darwin_x86_64-v16.0.zip",
            "sha": "a41de64afb663bb4880af52b55886098241b9222ee8ec1a0f6258d006ba247fb",
        },
        "java_tools_darwin_arm64": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v16.0/java_tools_darwin_arm64-v16.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v16.0/java_tools_darwin_arm64-v16.0.zip",
            "sha": "b79900dccca7c26fbae9a38c4da80987445e07194517ec53e169c45f1a88c7be",
        },
        "java_tools": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v16.0/java_tools-v16.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v16.0/java_tools-v16.0.zip",
            "sha": "d8b126078705e91677db67b05f7b25ad6fa8865949e2dd38ff85e0553bfb0be2",
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
        sha256 = "7f3a4f6a24f764259db98c69e759bf7cae95ce957dadd74117ed5d6037fcfcc7",
        strip_prefix = "zulu8.88.0.19-ca-jdk8.0.462-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.88.0.19-ca-jdk8.0.462-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.88.0.19-ca-jdk8.0.462-linux_aarch64.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "af194163bd9c870321f06b134f447869daafe6aef5b92b49d15b2fbc03a3b999",
        strip_prefix = "zulu8.88.0.19-ca-jdk8.0.462-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.88.0.19-ca-jdk8.0.462-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.88.0.19-ca-jdk8.0.462-linux_x64.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "abfb45c587b80646eedc679f5fd1c47f1851fd682a043adf5c46c0f55e4d2321",
        strip_prefix = "zulu8.88.0.19-ca-jdk8.0.462-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.88.0.19-ca-jdk8.0.462-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.88.0.19-ca-jdk8.0.462-macosx_aarch64.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "e39adde0283ff1cb5c82193654c15688ea5ea4e6f38336d001c43d81d26c102c",
        strip_prefix = "zulu8.88.0.19-ca-jdk8.0.462-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.88.0.19-ca-jdk8.0.462-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.88.0.19-ca-jdk8.0.462-macosx_x64.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_windows",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "4811dd4bb476f7484d132cb6393ca58344c45d43b9547f4251b15c5b8d1fd580",
        strip_prefix = "zulu8.88.0.19-ca-jdk8.0.462-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.88.0.19-ca-jdk8.0.462-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.88.0.19-ca-jdk8.0.462-win_x64.zip"],
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
        sha256 = "f90d9eb822f68cacd536144660b43402fc8a8e922358d67e84609d7828070e6b",
        strip_prefix = "zulu11.82.19-ca-jdk11.0.28-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.82.19-ca-jdk11.0.28-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.82.19-ca-jdk11.0.28-linux_aarch64.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "b34a75da63dab5f61ac342290000c1a51de3023049e2b30da89393f5f0b79759",
        strip_prefix = "zulu11.82.19-ca-jdk11.0.28-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.82.19-ca-jdk11.0.28-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.82.19-ca-jdk11.0.28-linux_x64.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "5b104e96bb41dc38b1605d701e4482003acffbe48e25e15ba0cb7a1611821aa7",
        strip_prefix = "zulu11.82.19-ca-jdk11.0.28-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.82.19-ca-jdk11.0.28-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.82.19-ca-jdk11.0.28-macosx_aarch64.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "11c3a142f82ad10cd9e2bfc0884c36ee66de0ac1b3ed9c018e746345813f80c8",
        strip_prefix = "zulu11.82.19-ca-jdk11.0.28-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.82.19-ca-jdk11.0.28-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.82.19-ca-jdk11.0.28-macosx_x64.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "728dbb971dc41be992aae950b89139e5d582f2ee7d918a06a69749fea6143fce",
        strip_prefix = "zulu11.82.19-ca-jdk11.0.28-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.82.19-ca-jdk11.0.28-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.82.19-ca-jdk11.0.28-win_x64.zip"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_linux_ppc64le",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:ppc64le"],
        sha256 = "42c63651125a149cee2ba781300d75ffa67a25032f95038d50ee6d6177cb2e41",
        strip_prefix = "jdk-11.0.26+4",
        urls = ["https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.26+4/OpenJDK11U-jdk_ppc64le_linux_hotspot_11.0.26_4.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.26+4/OpenJDK11U-jdk_ppc64le_linux_hotspot_11.0.26_4.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_linux_s390x",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:s390x"],
        sha256 = "0da13d990da34ecc666399cf0efa72a4b4e295f05c0686ea25a4a173a6f4414b",
        strip_prefix = "jdk-11.0.26+4",
        urls = ["https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.26+4/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.26_4.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.26+4/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.26_4.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "1d10cf760e4e011e830ef18ab28453a742ac84c046e4e77759e81b58716e6a8b",
        strip_prefix = "jdk-11.0.26+4",
        urls = ["https://aka.ms/download-jdk/microsoft-jdk-11.0.26-windows-aarch64.zip", "https://mirror.bazel.build/aka.ms/download-jdk/microsoft-jdk-11.0.26-windows-aarch64.zip"],
        version = "11",
    ),
    struct(
        name = "remotejdk17_linux_aarch64",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:aarch64"],
        sha256 = "1cbb51dc9400814b8fbb79252762af5eba1f556e558128f2a4fca906b2ed04c8",
        strip_prefix = "zulu17.60.17-ca-jdk17.0.16-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.60.17-ca-jdk17.0.16-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.60.17-ca-jdk17.0.16-linux_aarch64.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "e70822e4b77a9ffd57015b55f4bb645bba97b8f5247a792eceb95dbc7a5a55ab",
        strip_prefix = "zulu17.60.17-ca-jdk17.0.16-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.60.17-ca-jdk17.0.16-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.60.17-ca-jdk17.0.16-linux_x64.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "1e23895f8edddd86dbc20a2820b1bd11695e7a6ac37f1bcee90492341aa5b32d",
        strip_prefix = "zulu17.60.17-ca-jdk17.0.16-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.60.17-ca-jdk17.0.16-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.60.17-ca-jdk17.0.16-macosx_aarch64.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "6578d84c961b23f27bc7d504cb2fc45a47296bce382927d6485d404753a8a51a",
        strip_prefix = "zulu17.60.17-ca-jdk17.0.16-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.60.17-ca-jdk17.0.16-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.60.17-ca-jdk17.0.16-macosx_x64.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "2415163925968bfcc882e919e97f48c08eaf555947bb1b0b27291fd3fae1d462",
        strip_prefix = "zulu17.60.17-ca-jdk17.0.16-win_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.60.17-ca-jdk17.0.16-win_aarch64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.60.17-ca-jdk17.0.16-win_aarch64.zip"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "c51781710ff93fc7694668fe701c6b813aabda4e9dad6227a7d6734425b3b3ff",
        strip_prefix = "zulu17.60.17-ca-jdk17.0.16-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.60.17-ca-jdk17.0.16-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.60.17-ca-jdk17.0.16-win_x64.zip"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_linux_ppc64le",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:ppc64le"],
        sha256 = "f4cb9ee5906a44d110fa381310cd7181d95498d27087d449e7e9b74bddd9def2",
        strip_prefix = "jdk-17.0.14+7",
        urls = ["https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.14+7/OpenJDK17U-jdk_ppc64le_linux_hotspot_17.0.14_7.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.14+7/OpenJDK17U-jdk_ppc64le_linux_hotspot_17.0.14_7.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_linux_s390x",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:s390x"],
        sha256 = "3a1d896eb3a737020e5ec95ec3206b1ca36cb365538382289d3fb46d14303648",
        strip_prefix = "jdk-17.0.14+7",
        urls = ["https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.14+7/OpenJDK17U-jdk_s390x_linux_hotspot_17.0.14_7.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.14+7/OpenJDK17U-jdk_s390x_linux_hotspot_17.0.14_7.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk21_linux_aarch64",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:aarch64"],
        sha256 = "ff7f2edd1d5c153cb6cb493a3aa3523453e29a05ec513b25c24aa1477ec0c722",
        strip_prefix = "zulu21.44.17-ca-jdk21.0.8-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.44.17-ca-jdk21.0.8-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.44.17-ca-jdk21.0.8-linux_aarch64.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "63f56bbb46958cf57352fba08f2755e0953799195e5545acc0c8a92920beff1e",
        strip_prefix = "zulu21.44.17-ca-jdk21.0.8-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.44.17-ca-jdk21.0.8-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.44.17-ca-jdk21.0.8-linux_x64.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "d22ce05fea3e3f28c8c59f2c348bc78ee967bf1289a4fb28796cc0177ff6c8db",
        strip_prefix = "zulu21.44.17-ca-jdk21.0.8-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.44.17-ca-jdk21.0.8-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.44.17-ca-jdk21.0.8-macosx_aarch64.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "2af080500b5cc286a6353187c7c59b5aafcb3edc29c1c87d1fd71ba2d6a523f1",
        strip_prefix = "zulu21.44.17-ca-jdk21.0.8-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.44.17-ca-jdk21.0.8-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.44.17-ca-jdk21.0.8-macosx_x64.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "76379d799e766fb7ea1cdaacc67aa87f75a118f863cc68ffe32c251be94ab4f4",
        strip_prefix = "zulu21.44.17-ca-jdk21.0.8-win_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.44.17-ca-jdk21.0.8-win_aarch64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.44.17-ca-jdk21.0.8-win_aarch64.zip"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "f47dbd00384cb759f86a066be7545e467e5764f4653a237c32c07da96dc1c43b",
        strip_prefix = "zulu21.44.17-ca-jdk21.0.8-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.44.17-ca-jdk21.0.8-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.44.17-ca-jdk21.0.8-win_x64.zip"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_linux_ppc64le",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:ppc64le"],
        sha256 = "163724b70b86d5a8461f85092165a9cc5a098ed900fee90d1b0c0be9607ae3d2",
        strip_prefix = "jdk-21.0.6+7",
        urls = ["https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.6+7/OpenJDK21U-jdk_ppc64le_linux_hotspot_21.0.6_7.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.6+7/OpenJDK21U-jdk_ppc64le_linux_hotspot_21.0.6_7.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_linux_riscv64",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:riscv64"],
        sha256 = "203796e4ba2689aa921b5e0cdc9e02984d88622f80fcb9acb05a118b05007be8",
        strip_prefix = "jdk-21.0.6+7",
        urls = ["https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.6+7/OpenJDK21U-jdk_riscv64_linux_hotspot_21.0.6_7.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.6+7/OpenJDK21U-jdk_riscv64_linux_hotspot_21.0.6_7.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_linux_s390x",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:s390x"],
        sha256 = "5ba742c87d48fcf564def56812699f6499a1cfd3535ae43286e94e74b8165faf",
        strip_prefix = "jdk-21.0.6+7",
        urls = ["https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.6+7/OpenJDK21U-jdk_s390x_linux_hotspot_21.0.6_7.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.6+7/OpenJDK21U-jdk_s390x_linux_hotspot_21.0.6_7.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk25_linux_aarch64",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:aarch64"],
        sha256 = "b60eb9d54c97ba4159547834a98cc5d016281dd2b3e60e7475cba4911324bcb4",
        strip_prefix = "zulu25.28.85-ca-jdk25.0.0-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-linux_aarch64.tar.gz"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "164d901e5a240b8c18516f5ab55bc11fc9689ab6e829045aea8467356dcdb340",
        strip_prefix = "zulu25.28.85-ca-jdk25.0.0-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-linux_x64.tar.gz"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "73f64f6bad7c3df31fba740fbcbbbef7c1a5cedeffbb5df386dd79bc72aba9b6",
        strip_prefix = "zulu25.28.85-ca-jdk25.0.0-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-macosx_aarch64.tar.gz"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "c2cde1d313d904b793c3760214eefa207ecca7df04e7c4084abdf1f6bbebc27a",
        strip_prefix = "zulu25.28.85-ca-jdk25.0.0-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-macosx_x64.tar.gz"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "f5f6d8a913695649e8e2607fe0dc79c81953b2583013ac1fb977c63cb4935bfb",
        strip_prefix = "zulu25.28.85-ca-jdk25.0.0-win_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-win_aarch64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-win_aarch64.zip"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "5efcf4e6a613cae06c8041de8a3695b7346aad0307d397b66bf55281cf1a5cb6",
        strip_prefix = "zulu25.28.85-ca-jdk25.0.0-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-win_x64.zip"],
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
