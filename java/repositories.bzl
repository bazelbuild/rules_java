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
    "version": "v14.0",
    "release": "true",
    "artifacts": {
        "java_tools_linux": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v14.0/java_tools_linux-v14.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v14.0/java_tools_linux-v14.0.zip",
            "sha": "51ed941d6c62e432e59cc3b6ad3503639cc138ee7a02ed6bf0bbbb16ded418c9",
        },
        "java_tools_windows": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v14.0/java_tools_windows-v14.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v14.0/java_tools_windows-v14.0.zip",
            "sha": "3f918fb9c24b04bcd6088ed62c240cfbb1a4bb50376e394151d34d60e8e71cdf",
        },
        "java_tools_darwin_x86_64": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v14.0/java_tools_darwin_x86_64-v14.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v14.0/java_tools_darwin_x86_64-v14.0.zip",
            "sha": "94daf7d9586943261114de6bde97053597ce031bb8d76672688843b33b7ff610",
        },
        "java_tools_darwin_arm64": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v14.0/java_tools_darwin_arm64-v14.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v14.0/java_tools_darwin_arm64-v14.0.zip",
            "sha": "5f12ea12d0381058dac8aa85ad3656c3a7ab85b8c5d8cd98e4ab57bd8fbf8bee",
        },
        "java_tools": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v14.0/java_tools-v14.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v14.0/java_tools-v14.0.zip",
            "sha": "1c2074e3ffb8c5bd22d5e65964535f70ba7b1bcd4e688f5d89f79f72a1b625bf",
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
        sha256 = "3ae6b27727a308c0c262a99e20af29c87aad7910de423db2607c44551b598e57",
        strip_prefix = "zulu8.84.0.15-ca-jdk8.0.442-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.84.0.15-ca-jdk8.0.442-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.84.0.15-ca-jdk8.0.442-linux_aarch64.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "6e3bd4d911e6eb2d14e0b48e622b6909c76add0b51c51d11f5c2c3d2a045bcf3",
        strip_prefix = "zulu8.84.0.15-ca-jdk8.0.442-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.84.0.15-ca-jdk8.0.442-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.84.0.15-ca-jdk8.0.442-linux_x64.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "effa6d1bd4b6bce68328df66e063a97c2c4afeb0aa36fda4f85c434dd8246572",
        strip_prefix = "zulu8.84.0.15-ca-jdk8.0.442-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.84.0.15-ca-jdk8.0.442-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.84.0.15-ca-jdk8.0.442-macosx_aarch64.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "52131294512042dd6356426202e6a4116536477281fe76cfc0a3a15fe0d6ff44",
        strip_prefix = "zulu8.84.0.15-ca-jdk8.0.442-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.84.0.15-ca-jdk8.0.442-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.84.0.15-ca-jdk8.0.442-macosx_x64.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_windows",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "551c0df372a4b01754e214c52d2bdc2e22e1582274a3ea0e4a27d77db6a9cbea",
        strip_prefix = "zulu8.84.0.15-ca-jdk8.0.442-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.84.0.15-ca-jdk8.0.442-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.84.0.15-ca-jdk8.0.442-win_x64.zip"],
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
        sha256 = "f221d794325ab04382ba52250fc8fe8c4d384841a63bc2acd62d623a5bc53eb7",
        strip_prefix = "zulu11.78.15-ca-jdk11.0.26-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.78.15-ca-jdk11.0.26-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.78.15-ca-jdk11.0.26-linux_aarch64.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "fdf95b001d50b03bc3ce5f4fe7dc96bec9f94e561f9ec722a149bd7995600449",
        strip_prefix = "zulu11.78.15-ca-jdk11.0.26-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.78.15-ca-jdk11.0.26-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.78.15-ca-jdk11.0.26-linux_x64.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "3708badcc0c79fc1791e74b62478188a1f43c4f9a1e7d3e1bd4173da995479a3",
        strip_prefix = "zulu11.78.15-ca-jdk11.0.26-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.78.15-ca-jdk11.0.26-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.78.15-ca-jdk11.0.26-macosx_aarch64.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "bb3884619c6f09ec5ca3ce43810c61ade647bb896f4120a6cf076ec993b5a1a0",
        strip_prefix = "zulu11.78.15-ca-jdk11.0.26-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.78.15-ca-jdk11.0.26-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.78.15-ca-jdk11.0.26-macosx_x64.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "2f48346ba05d0d1a31a6797cd0fd27a0492c0df0c90730c9eeca7fc6952a075c",
        strip_prefix = "zulu11.78.15-ca-jdk11.0.26-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.78.15-ca-jdk11.0.26-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.78.15-ca-jdk11.0.26-win_x64.zip"],
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
        sha256 = "9fe5d08b20546e84af517cfefc7068f7a47e98473603782264e519f935977cb3",
        strip_prefix = "zulu17.56.15-ca-jdk17.0.14-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.56.15-ca-jdk17.0.14-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.56.15-ca-jdk17.0.14-linux_aarch64.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "37ab75b2f5da0ff0db973b31e9d9f14f729137a0a110abd6472ac8c6f2feabb6",
        strip_prefix = "zulu17.56.15-ca-jdk17.0.14-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.56.15-ca-jdk17.0.14-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.56.15-ca-jdk17.0.14-linux_x64.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "c3b9bfb0a6dbe4c5d9efce6c46d3a89c92d7b07ba1bd0afc944612298ac284ec",
        strip_prefix = "zulu17.56.15-ca-jdk17.0.14-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.56.15-ca-jdk17.0.14-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.56.15-ca-jdk17.0.14-macosx_aarch64.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "ee1a55b6b63d62d1a24d420b1550ef1736fda36db0e612893d9d26eb1d7f1611",
        strip_prefix = "zulu17.56.15-ca-jdk17.0.14-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.56.15-ca-jdk17.0.14-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.56.15-ca-jdk17.0.14-macosx_x64.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "dbf51756115f7591759b2ed6d9c0d79b3b770c1a13be476c99d64934a93ff422",
        strip_prefix = "zulu17.56.15-ca-jdk17.0.14-win_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.56.15-ca-jdk17.0.14-win_aarch64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.56.15-ca-jdk17.0.14-win_aarch64.zip"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "11dbe0051cea65fbfc94e0074fbb26d81897f5aff2df69fed3784f380d0d9ec9",
        strip_prefix = "zulu17.56.15-ca-jdk17.0.14-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.56.15-ca-jdk17.0.14-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.56.15-ca-jdk17.0.14-win_x64.zip"],
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
        sha256 = "2cab003bad25100a00b818ce229455d35ece03fc2e69be32c9c1c03f90b2eb89",
        strip_prefix = "zulu21.40.17-ca-jdk21.0.6-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.40.17-ca-jdk21.0.6-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.40.17-ca-jdk21.0.6-linux_aarch64.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "5daff61d307d18305a4022c56013cbaa8987a7dd103e310ebbeb75e0f3091a03",
        strip_prefix = "zulu21.40.17-ca-jdk21.0.6-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.40.17-ca-jdk21.0.6-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.40.17-ca-jdk21.0.6-linux_x64.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "1d6385f17ae2dc3b57a6d1b6fd6aeadafe1c7138bc744f62a767851eececd092",
        strip_prefix = "zulu21.40.17-ca-jdk21.0.6-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.40.17-ca-jdk21.0.6-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.40.17-ca-jdk21.0.6-macosx_aarch64.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "0b0f05e53e2b85f3881f1b8f5e3ef7e2e992796a1872afbc851b73127b16933d",
        strip_prefix = "zulu21.40.17-ca-jdk21.0.6-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.40.17-ca-jdk21.0.6-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.40.17-ca-jdk21.0.6-macosx_x64.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "57c568355b97d288f12b720760d802b1a19c55e9b0707a5c2ad76d34fd893db8",
        strip_prefix = "zulu21.40.17-ca-jdk21.0.6-win_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.40.17-ca-jdk21.0.6-win_aarch64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.40.17-ca-jdk21.0.6-win_aarch64.zip"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "a1360d2ab3ee9932b5cb20a2386d6b0fb1518a68c89a08739736c38a4debbdae",
        strip_prefix = "zulu21.40.17-ca-jdk21.0.6-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.40.17-ca-jdk21.0.6-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.40.17-ca-jdk21.0.6-win_x64.zip"],
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
