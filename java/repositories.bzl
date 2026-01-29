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
    "version": "v18.1",
    "release": "true",
    "artifacts": {
        "java_tools_linux": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v18.1/java_tools_linux-v18.1.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v18.1/java_tools_linux-v18.1.zip",
            "sha": "e22cbb2600249576c6a0a02af3f78e26537a89b6be11ef3826c01f9019faaa61",
        },
        "java_tools_linux_aarch64": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v18.1/java_tools_linux_aarch64-v18.1.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v18.1/java_tools_linux_aarch64-v18.1.zip",
            "sha": "4f75420bafb8c6554105c90ed05db3d7ff5942dbc1633459c20d2dcc06eff6ac",
        },
        "java_tools_windows": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v18.1/java_tools_windows-v18.1.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v18.1/java_tools_windows-v18.1.zip",
            "sha": "fe6dccef1b290b9e2a539cecfd57d924f719480ac04e55d03fdca5533272cd04",
        },
        "java_tools_darwin_x86_64": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v18.1/java_tools_darwin_x86_64-v18.1.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v18.1/java_tools_darwin_x86_64-v18.1.zip",
            "sha": "68f6b540a28ff1d98acd9313900c50560d52022ee2399627b9c92b1bb2c5d466",
        },
        "java_tools_darwin_arm64": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v18.1/java_tools_darwin_arm64-v18.1.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v18.1/java_tools_darwin_arm64-v18.1.zip",
            "sha": "07026303be4662462733d00eaf8e956cd9589493e104934862f0b53e76758d88",
        },
        "java_tools": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v18.1/java_tools-v18.1.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v18.1/java_tools-v18.1.zip",
            "sha": "27cab59ba5ff8ee7cf3071971fe2587a295daefe82531f27b4f061111276163d",
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
        sha256 = "c372fb26480c052537125013cb0ba7336c404e5190ea8f6e2de247b676432a67",
        strip_prefix = "zulu8.90.0.19-ca-jdk8.0.472-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.90.0.19-ca-jdk8.0.472-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.90.0.19-ca-jdk8.0.472-linux_aarch64.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "6f9e3fa773829ac2553411fb0cdeb394980627c47c9ab8f8892d4b917b70e2dd",
        strip_prefix = "zulu8.90.0.19-ca-jdk8.0.472-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.90.0.19-ca-jdk8.0.472-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.90.0.19-ca-jdk8.0.472-linux_x64.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "823d547ab9508e3a2b8abd3c5de66a39a50a254dc5835747cf3c2617fbe55600",
        strip_prefix = "zulu8.90.0.19-ca-jdk8.0.472-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.90.0.19-ca-jdk8.0.472-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.90.0.19-ca-jdk8.0.472-macosx_aarch64.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "96fb7bc3a2babd7f807484b1b8f1dfb8cf2c61ea27b2d0630e2237088b0a5100",
        strip_prefix = "zulu8.90.0.19-ca-jdk8.0.472-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.90.0.19-ca-jdk8.0.472-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.90.0.19-ca-jdk8.0.472-macosx_x64.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_windows",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "ff90484103d3fdb9808f737af027586c8dbfa1aa8a310ce99b0b5e0517567aee",
        strip_prefix = "zulu8.90.0.19-ca-jdk8.0.472-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.90.0.19-ca-jdk8.0.472-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.90.0.19-ca-jdk8.0.472-win_x64.zip"],
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
        sha256 = "5a225a0fe0a92bc6c04c8c5aeb03c697c6fd114465829f23e494a2ad44fa1cc0",
        strip_prefix = "zulu11.84.17-ca-jdk11.0.29-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.84.17-ca-jdk11.0.29-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.84.17-ca-jdk11.0.29-linux_aarch64.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "681b2e4bf7fedf4d20666fc2a954b83ff5675ccfb916c867267d29c85c2ee310",
        strip_prefix = "zulu11.84.17-ca-jdk11.0.29-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.84.17-ca-jdk11.0.29-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.84.17-ca-jdk11.0.29-linux_x64.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "09ed1734c2d88fadcb75fdbec1ba5467d32e7fa2b10894541aa8e3d3ce78dc2d",
        strip_prefix = "zulu11.84.17-ca-jdk11.0.29-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.84.17-ca-jdk11.0.29-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.84.17-ca-jdk11.0.29-macosx_aarch64.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "b7f5a37c47ed94af1c8ecf631b1dc6dec990958f3afd4222a7dd27d6ca1084bd",
        strip_prefix = "zulu11.84.17-ca-jdk11.0.29-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.84.17-ca-jdk11.0.29-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.84.17-ca-jdk11.0.29-macosx_x64.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "f4002a8090662ff66bf9f3248604be0f9d226e964085bd59bbea4b8535df3de1",
        strip_prefix = "zulu11.84.17-ca-jdk11.0.29-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.84.17-ca-jdk11.0.29-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.84.17-ca-jdk11.0.29-win_x64.zip"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_linux_ppc64le",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:ppc64le"],
        sha256 = "e272abd162b3de68093630929453feba3e63a5ab1bbb912379f6a4aa968ef06a",
        strip_prefix = "jdk-11.0.28+6",
        urls = ["https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.28+6/OpenJDK11U-jdk_ppc64le_linux_hotspot_11.0.28_6.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.28+6/OpenJDK11U-jdk_ppc64le_linux_hotspot_11.0.28_6.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_linux_s390x",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:s390x"],
        sha256 = "ac3f94fdcc5372e90f44fad9cd03ec0e3fd3535fea06c120f85e4a7534c6de04",
        strip_prefix = "jdk-11.0.28+6",
        urls = ["https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.28+6/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.28_6.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.28+6/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.28_6.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "1e7bfad513a1c2930000db1af19c813460c7a788503c39a7f1f27375310880f8",
        strip_prefix = "jdk-11.0.28+6",
        urls = ["https://aka.ms/download-jdk/microsoft-jdk-11.0.28-windows-aarch64.zip", "https://mirror.bazel.build/aka.ms/download-jdk/microsoft-jdk-11.0.28-windows-aarch64.zip"],
        version = "11",
    ),
    struct(
        name = "remotejdk17_linux_aarch64",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:aarch64"],
        sha256 = "527b76fbd60e8f9644f6b70800d15160cdbd3344bc6fbf30d42e905f540a770c",
        strip_prefix = "zulu17.62.17-ca-jdk17.0.17-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.62.17-ca-jdk17.0.17-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.62.17-ca-jdk17.0.17-linux_aarch64.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "1dcbbed73e95dc35f5c60402a84936f6830ff43c2a0dc0037a5657dbc25472c1",
        strip_prefix = "zulu17.62.17-ca-jdk17.0.17-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.62.17-ca-jdk17.0.17-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.62.17-ca-jdk17.0.17-linux_x64.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "5558f7efe6297ecb20f422f31471555cd43e9499beb304b8f3ddc68796d2874b",
        strip_prefix = "zulu17.62.17-ca-jdk17.0.17-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.62.17-ca-jdk17.0.17-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.62.17-ca-jdk17.0.17-macosx_aarch64.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "e6b2fb0cd3f929225a179c2fb2813abd1834f839a3b4c8cdcb36067aa16b6f83",
        strip_prefix = "zulu17.62.17-ca-jdk17.0.17-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.62.17-ca-jdk17.0.17-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.62.17-ca-jdk17.0.17-macosx_x64.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "c1bba9148907348da93b0de2c9abd56bd180efcb6b1f35068ab9785015fcd74b",
        strip_prefix = "zulu17.62.17-ca-jdk17.0.17-win_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.62.17-ca-jdk17.0.17-win_aarch64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.62.17-ca-jdk17.0.17-win_aarch64.zip"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "bd8a942bb543f109a28d3eadf3ec2f29a3ee28ab53506e31d2858292f63c6949",
        strip_prefix = "zulu17.62.17-ca-jdk17.0.17-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.62.17-ca-jdk17.0.17-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.62.17-ca-jdk17.0.17-win_x64.zip"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_linux_ppc64le",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:ppc64le"],
        sha256 = "eb020f74e00870379522be0b44fc6322c2214e77971c258400c8b5af704d5c0a",
        strip_prefix = "jdk-17.0.16+8",
        urls = ["https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16+8/OpenJDK17U-jdk_ppc64le_linux_hotspot_17.0.16_8.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16+8/OpenJDK17U-jdk_ppc64le_linux_hotspot_17.0.16_8.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_linux_s390x",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:s390x"],
        sha256 = "03dd99d34d2d1b88395765df3acbec2cb81de286f64b1d9e6df3682bee365168",
        strip_prefix = "jdk-17.0.16+8",
        urls = ["https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16+8/OpenJDK17U-jdk_s390x_linux_hotspot_17.0.16_8.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16+8/OpenJDK17U-jdk_s390x_linux_hotspot_17.0.16_8.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk21_linux_aarch64",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:aarch64"],
        sha256 = "a826a93c18d4388ec8d5d4057f5bb1b5c60f00ffc875ed299dea17aa947555ee",
        strip_prefix = "zulu21.46.19-ca-jdk21.0.9-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.46.19-ca-jdk21.0.9-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.46.19-ca-jdk21.0.9-linux_aarch64.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "67e810b31427ac0ff1c249473595066a00bdf0f9265df186c32905d5f75c93b8",
        strip_prefix = "zulu21.46.19-ca-jdk21.0.9-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.46.19-ca-jdk21.0.9-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.46.19-ca-jdk21.0.9-linux_x64.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "b56112ad12d3dfe62802840655ecf198fe4ca48729824c939d65a69e803536c7",
        strip_prefix = "zulu21.46.19-ca-jdk21.0.9-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.46.19-ca-jdk21.0.9-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.46.19-ca-jdk21.0.9-macosx_aarch64.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "3d870d823e3e101189b00ad975188c0321e31056ac8ca8b487bcf4454f3b5cfe",
        strip_prefix = "zulu21.46.19-ca-jdk21.0.9-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.46.19-ca-jdk21.0.9-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.46.19-ca-jdk21.0.9-macosx_x64.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "1210b169db7b40d7305a94d41ab3eb87aaee51108b43f8f7f36f0c2865107790",
        strip_prefix = "zulu21.46.19-ca-jdk21.0.9-win_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.46.19-ca-jdk21.0.9-win_aarch64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.46.19-ca-jdk21.0.9-win_aarch64.zip"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "0c9812c0fe527b59f48c70cb527035c8a7abe620b31f776b4ddc21bddc1cd067",
        strip_prefix = "zulu21.46.19-ca-jdk21.0.9-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.46.19-ca-jdk21.0.9-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.46.19-ca-jdk21.0.9-win_x64.zip"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_linux_ppc64le",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:ppc64le"],
        sha256 = "a24e869b8e563fd7b9f7776f6686ca5d737c8d1c3c33c9b72836935709b44a34",
        strip_prefix = "jdk-21.0.8+9",
        urls = ["https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.8+9/OpenJDK21U-jdk_ppc64le_linux_hotspot_21.0.8_9.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.8+9/OpenJDK21U-jdk_ppc64le_linux_hotspot_21.0.8_9.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_linux_riscv64",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:riscv64"],
        sha256 = "8171d95189e675e297b5cb96c7ac6247ab4e9f48da82b13f491fc46ef5d97836",
        strip_prefix = "jdk-21.0.8+9",
        urls = ["https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.8+9/OpenJDK21U-jdk_riscv64_linux_hotspot_21.0.8_9.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.8+9/OpenJDK21U-jdk_riscv64_linux_hotspot_21.0.8_9.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_linux_s390x",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:s390x"],
        sha256 = "a84e3cbf8bb5f8a313e06b790c7bc388687ba00262e981f5e33432ebd4d34356",
        strip_prefix = "jdk-21.0.8+9",
        urls = ["https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.8+9/OpenJDK21U-jdk_s390x_linux_hotspot_21.0.8_9.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.8+9/OpenJDK21U-jdk_s390x_linux_hotspot_21.0.8_9.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk25_linux_aarch64",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:aarch64"],
        sha256 = "8c5321f16d9f1d8149f83e4e9ff8ca5d9e94320b92d205e6db42a604de3d1140",
        strip_prefix = "zulu25.30.17-ca-jdk25.0.1-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.30.17-ca-jdk25.0.1-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.30.17-ca-jdk25.0.1-linux_aarch64.tar.gz"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "471b3e62bdffaed27e37005d842d8639f10d244ccce1c7cdebf7abce06c8313e",
        strip_prefix = "zulu25.30.17-ca-jdk25.0.1-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.30.17-ca-jdk25.0.1-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.30.17-ca-jdk25.0.1-linux_x64.tar.gz"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "126061d6046b0c0df0472b361ca7895951d34fef1dd522f222f2c7d8738a39d8",
        strip_prefix = "zulu25.30.17-ca-jdk25.0.1-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.30.17-ca-jdk25.0.1-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.30.17-ca-jdk25.0.1-macosx_aarch64.tar.gz"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "0154482b317aa63d5158a358e2fab7f0fd6c3c0ba2000b05655c3bcbdd202584",
        strip_prefix = "zulu25.30.17-ca-jdk25.0.1-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.30.17-ca-jdk25.0.1-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.30.17-ca-jdk25.0.1-macosx_x64.tar.gz"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "4883cf39e8d83679c8a051ace4dd72759d97195a72aaa6727a83bd4bcb97b022",
        strip_prefix = "zulu25.30.17-ca-jdk25.0.1-win_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.30.17-ca-jdk25.0.1-win_aarch64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.30.17-ca-jdk25.0.1-win_aarch64.zip"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "72844ba8dddf9259ab9cfda9d515d0c850179705f74278a75973d73f0c5b2d2b",
        strip_prefix = "zulu25.30.17-ca-jdk25.0.1-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.30.17-ca-jdk25.0.1-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.30.17-ca-jdk25.0.1-win_x64.zip"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_linux_ppc64le",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:ppc64le"],
        sha256 = "b262b735b215173003766da36588d5f717dceada0286db41b439f93fb2ada468",
        strip_prefix = "jdk-25.0.2+10",
        urls = ["https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.2+10/OpenJDK25U-jdk_ppc64le_linux_hotspot_25.0.2_10.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.2+10/OpenJDK25U-jdk_ppc64le_linux_hotspot_25.0.2_10.tar.gz"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_linux_riscv64",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:riscv64"],
        sha256 = "168119e4fba350f4e6b3ca92450a2b90a8502b89a235a04415e9adf9f5d3164e",
        strip_prefix = "jdk-25.0.2+10",
        urls = ["https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.2+10/OpenJDK25U-jdk_riscv64_linux_hotspot_25.0.2_10.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.2+10/OpenJDK25U-jdk_riscv64_linux_hotspot_25.0.2_10.tar.gz"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_linux_s390x",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:s390x"],
        sha256 = "15e5cbcadcf3d43623c31b825063cdc2817b9f1ba840b51dc6ef70e5d33c84e3",
        strip_prefix = "jdk-25.0.2+10",
        urls = ["https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.2+10/OpenJDK25U-jdk_s390x_linux_hotspot_25.0.2_10.tar.gz", "https://mirror.bazel.build/github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.2+10/OpenJDK25U-jdk_s390x_linux_hotspot_25.0.2_10.tar.gz"],
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
