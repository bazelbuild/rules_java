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
        sha256 = "2a8b15fcccadfc7b5c2904f078ef2de56aeb76aae661b95ab527ffeadf0cd592",
        strip_prefix = "zulu8.98.0.201-ca-jdk8.0.514-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.98.0.201-ca-jdk8.0.514-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.98.0.201-ca-jdk8.0.514-linux_aarch64.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "16a4c55c3061ee41e94edb109f5aea1c55a2952d37e25e215d478b8347350860",
        strip_prefix = "zulu8.98.0.201-ca-jdk8.0.514-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.98.0.201-ca-jdk8.0.514-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.98.0.201-ca-jdk8.0.514-linux_x64.tar.gz"],
        version = "8",
    ),
    struct(
        name = "remote_jdk8_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "792935f732653f5c4fd4cdc68e3ade65cb1fa1fda6b6769fc5dd8098b330b298",
        strip_prefix = "zulu8.98.0.201-ca-jdk8.0.514-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.98.0.201-ca-jdk8.0.514-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.98.0.201-ca-jdk8.0.514-macosx_aarch64.tar.gz"],
        version = "8",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remote_jdk8_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "49fc194f8ed1c7d1757ede4d7055f32afa4544b613e3b595d38441419002f759",
        strip_prefix = "zulu8.98.0.201-ca-jdk8.0.514-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.98.0.201-ca-jdk8.0.514-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.98.0.201-ca-jdk8.0.514-macosx_x64.tar.gz"],
        version = "8",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remote_jdk8_windows",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "ab833a2af66a80e003dacc97c598eaa8fa1a54c2be441e661ef80214eba99a97",
        strip_prefix = "zulu8.98.0.201-ca-jdk8.0.514-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu8.98.0.201-ca-jdk8.0.514-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu8.98.0.201-ca-jdk8.0.514-win_x64.zip"],
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
        sha256 = "b348c48a53d9f96f0968a20d8c4d65a29a23c36c16461622aa3e18f6db8df772",
        strip_prefix = "zulu11.92.201-ca-jdk11.0.33.1-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.92.201-ca-jdk11.0.33.1-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.92.201-ca-jdk11.0.33.1-linux_aarch64.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "9394707fa2ede9929cee172bc0ac5b7cfe9f6af35e5768bf974515a3faa39c67",
        strip_prefix = "zulu11.92.201-ca-jdk11.0.33.1-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.92.201-ca-jdk11.0.33.1-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.92.201-ca-jdk11.0.33.1-linux_x64.tar.gz"],
        version = "11",
    ),
    struct(
        name = "remotejdk11_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "86c26aecc85bb83245a7d837543342d1635733f5c5d44c1ae274f0ac7c2fccaf",
        strip_prefix = "zulu11.92.201-ca-jdk11.0.33.1-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.92.201-ca-jdk11.0.33.1-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.92.201-ca-jdk11.0.33.1-macosx_aarch64.tar.gz"],
        version = "11",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk11_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "3266ce5ba9e3a275134238621c1482ba785f897e1f379dca0266bcbaeae6c72a",
        strip_prefix = "zulu11.92.201-ca-jdk11.0.33.1-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.92.201-ca-jdk11.0.33.1-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.92.201-ca-jdk11.0.33.1-macosx_x64.tar.gz"],
        version = "11",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk11_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "0d31b8bee79e662ba51093a1adf1fe8f5ffe80cfb47e7a81cb4b938653dda302",
        strip_prefix = "zulu11.92.201-ca-jdk11.0.33.1-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu11.92.201-ca-jdk11.0.33.1-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu11.92.201-ca-jdk11.0.33.1-win_x64.zip"],
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
        sha256 = "bf8a41fb9d469e6d645cd64d9bd4726a35d496ff821e812c42046e6fe77b4587",
        strip_prefix = "zulu17.70.201-ca-jdk17.0.21.1-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.70.201-ca-jdk17.0.21.1-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.70.201-ca-jdk17.0.21.1-linux_aarch64.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "2837aee74267e02106ee6006809bb0de23ccfa43bf5005621517194b79975695",
        strip_prefix = "zulu17.70.201-ca-jdk17.0.21.1-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.70.201-ca-jdk17.0.21.1-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.70.201-ca-jdk17.0.21.1-linux_x64.tar.gz"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "098dbf65069d8e0886aaa7f1fd90adc8d8e41e4b80a1bca8d88e308f3c91f97c",
        strip_prefix = "zulu17.70.201-ca-jdk17.0.21.1-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.70.201-ca-jdk17.0.21.1-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.70.201-ca-jdk17.0.21.1-macosx_aarch64.tar.gz"],
        version = "17",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk17_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "7390536cc1fc2105d26885e0a8f272ebe8e7f975f68dace4c6d0924895cff3ec",
        strip_prefix = "zulu17.70.201-ca-jdk17.0.21.1-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.70.201-ca-jdk17.0.21.1-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.70.201-ca-jdk17.0.21.1-macosx_x64.tar.gz"],
        version = "17",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk17_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "023bddb8cde87e8c44f5573c3187568692f869f51147967e855ee16b71cdfa43",
        strip_prefix = "zulu17.70.201-ca-jdk17.0.21.1-win_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.70.201-ca-jdk17.0.21.1-win_aarch64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.70.201-ca-jdk17.0.21.1-win_aarch64.zip"],
        version = "17",
    ),
    struct(
        name = "remotejdk17_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "78865bdbc82b1164e475c36d471f53880250a768385bc8e4132598d75b58bc36",
        strip_prefix = "zulu17.70.201-ca-jdk17.0.21.1-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu17.70.201-ca-jdk17.0.21.1-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.70.201-ca-jdk17.0.21.1-win_x64.zip"],
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
        sha256 = "7a4683412f5eeee90261ac7eda8d7a96076d794656cb5078d8f0fb38bf2db554",
        strip_prefix = "zulu21.54.201-ca-jdk21.0.13.1-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.54.201-ca-jdk21.0.13.1-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.54.201-ca-jdk21.0.13.1-linux_aarch64.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "510696f7da795e08b48432268173b060a49a6a3b05430690e776b5f3ddecac5e",
        strip_prefix = "zulu21.54.201-ca-jdk21.0.13.1-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.54.201-ca-jdk21.0.13.1-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.54.201-ca-jdk21.0.13.1-linux_x64.tar.gz"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "f6422095eb0d21b6d974cb5af85c121728dfe4bbda0108b1420978e793575adc",
        strip_prefix = "zulu21.54.201-ca-jdk21.0.13.1-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.54.201-ca-jdk21.0.13.1-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.54.201-ca-jdk21.0.13.1-macosx_aarch64.tar.gz"],
        version = "21",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk21_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "1a70bba2c5c1d47752cfffb4149d426009944dee6beceac1bfd6d5c13f89a82f",
        strip_prefix = "zulu21.54.201-ca-jdk21.0.13.1-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.54.201-ca-jdk21.0.13.1-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.54.201-ca-jdk21.0.13.1-macosx_x64.tar.gz"],
        version = "21",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk21_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "904e945c83627646b44e00a7a7152e5fe50d33dd00775f60e6167e9916f8da40",
        strip_prefix = "zulu21.54.201-ca-jdk21.0.13.1-win_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.54.201-ca-jdk21.0.13.1-win_aarch64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.54.201-ca-jdk21.0.13.1-win_aarch64.zip"],
        version = "21",
    ),
    struct(
        name = "remotejdk21_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "14e7a0395df4f09b508d50aa65a858650d59eb8d2221df57b4742d0830f3a3a0",
        strip_prefix = "zulu21.54.201-ca-jdk21.0.13.1-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu21.54.201-ca-jdk21.0.13.1-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.54.201-ca-jdk21.0.13.1-win_x64.zip"],
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
        sha256 = "7f0c356813de315dbac44d1a2a2d61a5cab9d6ac8f2cdff6e32c994be5c02da1",
        strip_prefix = "zulu25.38.201-ca-jdk25.0.5.1-linux_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.38.201-ca-jdk25.0.5.1-linux_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.38.201-ca-jdk25.0.5.1-linux_aarch64.tar.gz"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_linux",
        target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        sha256 = "fc7a3d9396b443134666b9cf7cd946b532dc1781f5350c725849ac50d16a7198",
        strip_prefix = "zulu25.38.201-ca-jdk25.0.5.1-linux_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.38.201-ca-jdk25.0.5.1-linux_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.38.201-ca-jdk25.0.5.1-linux_x64.tar.gz"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_macos_aarch64",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:aarch64"],
        sha256 = "249d560d50703f71ae7c4f90c872a6e9c691e6207845786d5b18fd28d30b8fa3",
        strip_prefix = "zulu25.38.201-ca-jdk25.0.5.1-macosx_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.38.201-ca-jdk25.0.5.1-macosx_aarch64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.38.201-ca-jdk25.0.5.1-macosx_aarch64.tar.gz"],
        version = "25",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk25_macos",
        target_compatible_with = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        sha256 = "3f73b7ca70425d79fb9c5c697b92248731a13d43ff96d41bc74a56778e25e846",
        strip_prefix = "zulu25.38.201-ca-jdk25.0.5.1-macosx_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.38.201-ca-jdk25.0.5.1-macosx_x64.tar.gz", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.38.201-ca-jdk25.0.5.1-macosx_x64.tar.gz"],
        version = "25",
        patch_cmds = ["ln -s Contents/Home/* ."],
    ),
    struct(
        name = "remotejdk25_win_arm64",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:arm64"],
        sha256 = "c37778de9e4bbb05aa5357251b36430e371c3ed001784f3792fe4cd4defcefdd",
        strip_prefix = "zulu25.38.201-ca-jdk25.0.5.1-win_aarch64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.38.201-ca-jdk25.0.5.1-win_aarch64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.38.201-ca-jdk25.0.5.1-win_aarch64.zip"],
        version = "25",
    ),
    struct(
        name = "remotejdk25_win",
        target_compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        sha256 = "01c1c4cfe8c0e04a22a46d3cd1ddd18b9db9fb2a1b0a88ffd90e0aa57420845e",
        strip_prefix = "zulu25.38.201-ca-jdk25.0.5.1-win_x64",
        urls = ["https://cdn.azul.com/zulu/bin/zulu25.38.201-ca-jdk25.0.5.1-win_x64.zip", "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu25.38.201-ca-jdk25.0.5.1-win_x64.zip"],
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
