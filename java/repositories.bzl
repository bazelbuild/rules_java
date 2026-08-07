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
    "version": "v19.0",
    "source_revision": "61972bfd7fb6f587fc4576b5114e20758b501806",
    "release": "true",
    "artifacts": {
        "java_tools_linux": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v19.0/java_tools_linux-v19.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v19.0/java_tools_linux-v19.0.zip",
            "sha": "7d5b0c01f99ea5596b7901a7e5f9173f3ae3c4f0b480378e87567eaf97d75d25",
        },
        "java_tools_linux_aarch64": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v19.0/java_tools_linux_aarch64-v19.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v19.0/java_tools_linux_aarch64-v19.0.zip",
            "sha": "34b14fdfe8d6e32ed7f80e7c4d34ce79f4006e0d4b621552f507e51b9d6a3d7d",
        },
        "java_tools_windows": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v19.0/java_tools_windows-v19.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v19.0/java_tools_windows-v19.0.zip",
            "sha": "86c5a58ccefdb9e704fddd325f5fbc7867b2cdd128fb8b9abfdf607a75d2ae71",
        },
        "java_tools_darwin_x86_64": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v19.0/java_tools_darwin_x86_64-v19.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v19.0/java_tools_darwin_x86_64-v19.0.zip",
            "sha": "78ff8ec7038ab5f9cd261cdf9ff75ea0eb2af7579f9aeef9d658459ee37fabac",
        },
        "java_tools_darwin_arm64": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v19.0/java_tools_darwin_arm64-v19.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v19.0/java_tools_darwin_arm64-v19.0.zip",
            "sha": "86f15280dd0ce121a22f061e2e301ecf746597caa4938cf56852b3d311b830d8",
        },
        "java_tools": {
            "mirror_url": "https://mirror.bazel.build/bazel_java_tools/releases/java/v19.0/java_tools-v19.0.zip",
            "github_url": "https://github.com/bazelbuild/java_tools/releases/download/java_v19.0/java_tools-v19.0.zip",
            "sha": "d21d4aad1a18062512bcf4e8f7a09a4f5a042c760daa779e0ddda6e41b170507",
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
        sha256 = "b23296caf10d0c3db054d4a58b9dd168976991472f2203335d7c4820f98c4a4e",
        strip_prefix = "zulu8.96.0.19-ca-jdk8.0.502-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.96.0.19-ca-jdk8.0.502-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.96.0.19-ca-jdk8.0.502-linux_aarch64.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "5923daaf12fd0b87e60e437aaae7b2e5b257846cdb8ac15065258fb59a1da70a",
        strip_prefix = "zulu8.96.0.19-ca-jdk8.0.502-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.96.0.19-ca-jdk8.0.502-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.96.0.19-ca-jdk8.0.502-linux_x64.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "9f9e5038c638e415e507e8b5118a774822f553a56e76bdf4b042c3fbe7b69083",
        strip_prefix = "zulu8.96.0.19-ca-jdk8.0.502-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.96.0.19-ca-jdk8.0.502-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.96.0.19-ca-jdk8.0.502-macosx_aarch64.tar.gz"],
        version = "8",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remote_jdk8_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "b29088ddb00f81db1e01d6d5bfddd44a58e46ef44b50c372cff3eb1bf5b23173",
        strip_prefix = "zulu8.96.0.19-ca-jdk8.0.502-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.96.0.19-ca-jdk8.0.502-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.96.0.19-ca-jdk8.0.502-macosx_x64.tar.gz"],
        version = "8",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remote_jdk8_windows",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "0d64e817ba56962d447339040f9e7bd1119f98b813d0a968e3485aab0c530a47",
        strip_prefix = "zulu8.96.0.19-ca-jdk8.0.502-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.96.0.19-ca-jdk8.0.502-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.96.0.19-ca-jdk8.0.502-win_x64.zip"],
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
        sha256 = "31fb32a1c9d842f96e8e79c683996e217d087b3aeac0cc6bfc39f028eb860146",
        strip_prefix = "zulu11.90.19-ca-jdk11.0.32-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.90.19-ca-jdk11.0.32-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.90.19-ca-jdk11.0.32-linux_aarch64.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "d4832d97886444346ed75fd1059c68c5e38795098e3273e4a0929fe2eb2abf76",
        strip_prefix = "zulu11.90.19-ca-jdk11.0.32-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.90.19-ca-jdk11.0.32-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.90.19-ca-jdk11.0.32-linux_x64.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "a552338385fa27026ced01a3c56a3b3a2de048ed4b79907d876e99be80547551",
        strip_prefix = "zulu11.90.19-ca-jdk11.0.32-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.90.19-ca-jdk11.0.32-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.90.19-ca-jdk11.0.32-macosx_aarch64.tar.gz"],
        version = "11",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk11_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "5ba1b39cc08999645944bcfd54da48dd6c9a0891785d56cff95e92324fa841f6",
        strip_prefix = "zulu11.90.19-ca-jdk11.0.32-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.90.19-ca-jdk11.0.32-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.90.19-ca-jdk11.0.32-macosx_x64.tar.gz"],
        version = "11",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk11_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "700a42d5764b5f41ab43adbfe3e03deac329cc10886f2312a5908fd5a3c78d46",
        strip_prefix = "zulu11.90.19-ca-jdk11.0.32-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.90.19-ca-jdk11.0.32-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.90.19-ca-jdk11.0.32-win_x64.zip"],
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
        sha256 = "46f1dc7678760d37d38699c5a5a34dea8ed451dcdf6d27890a7b61f025e7ff60",
        strip_prefix = "zulu17.68.17-ca-jdk17.0.20-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.68.17-ca-jdk17.0.20-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.68.17-ca-jdk17.0.20-linux_aarch64.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "32c5efedf69f4a95635ea2923f6a6ee90ce6ca83df0bd43ba55dd662d5af429a",
        strip_prefix = "zulu17.68.17-ca-jdk17.0.20-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.68.17-ca-jdk17.0.20-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.68.17-ca-jdk17.0.20-linux_x64.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "0da52534760b74ba8a42660384b2f4e44311a47ae52faa45fcbd829b2797b244",
        strip_prefix = "zulu17.68.17-ca-jdk17.0.20-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.68.17-ca-jdk17.0.20-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.68.17-ca-jdk17.0.20-macosx_aarch64.tar.gz"],
        version = "17",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk17_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "b5bace4a346a7af0fe4f50904c46770e66d4b465800b038693c35e5d5b9bd52a",
        strip_prefix = "zulu17.68.17-ca-jdk17.0.20-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.68.17-ca-jdk17.0.20-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.68.17-ca-jdk17.0.20-macosx_x64.tar.gz"],
        version = "17",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk17_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "e125b3b64c9b5a0a2f2737e4a94ba275b541d8cc85d61c95ff875a3463ce0d8e",
        strip_prefix = "zulu17.68.17-ca-jdk17.0.20-win_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.68.17-ca-jdk17.0.20-win_aarch64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.68.17-ca-jdk17.0.20-win_aarch64.zip"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "d207d8cec299f4d216bef1c7c081ba9504e79ba1cbc740de312d4a91b2d46436",
        strip_prefix = "zulu17.68.17-ca-jdk17.0.20-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.68.17-ca-jdk17.0.20-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.68.17-ca-jdk17.0.20-win_x64.zip"],
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
        sha256 = "dc7ed9ab7dfd33f2ddb1cd8311d3b00738497961a420533d81088051eac3f195",
        strip_prefix = "zulu21.52.15-ca-jdk21.0.12-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.52.15-ca-jdk21.0.12-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.52.15-ca-jdk21.0.12-linux_aarch64.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "b1a9df12e798770d1b2db43b402a80f1e6080cff6d5d1d1fbe5c768fb4225f6a",
        strip_prefix = "zulu21.52.15-ca-jdk21.0.12-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.52.15-ca-jdk21.0.12-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.52.15-ca-jdk21.0.12-linux_x64.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "84d38c4bf04f73d585bd319b949758d00abde50149a9522c2d9deef46b9a3ec6",
        strip_prefix = "zulu21.52.15-ca-jdk21.0.12-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.52.15-ca-jdk21.0.12-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.52.15-ca-jdk21.0.12-macosx_aarch64.tar.gz"],
        version = "21",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk21_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "14e05cb1299c27cd26d3c5c6815723f63018df548dc7278c810767607902b4f4",
        strip_prefix = "zulu21.52.15-ca-jdk21.0.12-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.52.15-ca-jdk21.0.12-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.52.15-ca-jdk21.0.12-macosx_x64.tar.gz"],
        version = "21",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk21_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "d75658d371e025bb6378231551b4d53d1f5312cb0fccf7aa3b039d91ce1f0b7e",
        strip_prefix = "zulu21.52.15-ca-jdk21.0.12-win_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.52.15-ca-jdk21.0.12-win_aarch64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.52.15-ca-jdk21.0.12-win_aarch64.zip"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "3c06e6693fd6fa725b985e66798a6a8293c75f52b793490754ad3c54d3d8b5a6",
        strip_prefix = "zulu21.52.15-ca-jdk21.0.12-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.52.15-ca-jdk21.0.12-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.52.15-ca-jdk21.0.12-win_x64.zip"],
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
        sha256 = "ae04e25b16116ddd0f72cb387742d5122bb29c4b94f0fed08ff2bccc395f9daa",
        strip_prefix = "zulu25.36.15-ca-jdk25.0.4-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.36.15-ca-jdk25.0.4-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.36.15-ca-jdk25.0.4-linux_aarch64.tar.gz"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "e476f5c98952cb365ca77a814dbe3c74341e71ae76d1a87d1c0a69c7d2b1b2d0",
        strip_prefix = "zulu25.36.15-ca-jdk25.0.4-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.36.15-ca-jdk25.0.4-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.36.15-ca-jdk25.0.4-linux_x64.tar.gz"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "c422f22713510992c764a7d577ae4f5add223529ab356993f38f8df2d4b247bd",
        strip_prefix = "zulu25.36.15-ca-jdk25.0.4-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.36.15-ca-jdk25.0.4-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.36.15-ca-jdk25.0.4-macosx_aarch64.tar.gz"],
        version = "25",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk25_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "63273c6b9e2d9b250a0009ffdaa6d9f27af6ba98772516c391276106fb9f2820",
        strip_prefix = "zulu25.36.15-ca-jdk25.0.4-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.36.15-ca-jdk25.0.4-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.36.15-ca-jdk25.0.4-macosx_x64.tar.gz"],
        version = "25",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk25_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "2e8468229aea447152343fff87dbebe5c339e1fbab143a8f227f6b2f388c0a8c",
        strip_prefix = "zulu25.36.15-ca-jdk25.0.4-win_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.36.15-ca-jdk25.0.4-win_aarch64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.36.15-ca-jdk25.0.4-win_aarch64.zip"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "a91265f0f0fb40155befe8f1cae7d1a0ae2ab4b7760f52733160d206637b50d1",
        strip_prefix = "zulu25.36.15-ca-jdk25.0.4-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.36.15-ca-jdk25.0.4-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.36.15-ca-jdk25.0.4-win_x64.zip"],
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
