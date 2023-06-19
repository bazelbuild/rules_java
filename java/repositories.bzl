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

def java_tools_repos():
    """ Declares the remote java_tools repositories """
    maybe(
        http_archive,
        name = "remote_java_tools",
        sha256 = "cbb62ecfef61568ded46260a8e8e8430755db7ec9638c0c7ff668a656f6c042f",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v12.3/java_tools-v12.3.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v12.3/java_tools-v12.3.zip",
        ],
    )

    maybe(
        http_archive,
        name = "remote_java_tools_linux",
        sha256 = "32157b5218b151009f5b99bf5e2f65e28823d269dfbba8cd57e7da5e7cdd291d",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v12.3/java_tools_linux-v12.3.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v12.3/java_tools_linux-v12.3.zip",
        ],
    )

    maybe(
        http_archive,
        name = "remote_java_tools_windows",
        sha256 = "ec6f91387d2353eacb0ca0492f35f68c5c7b0e7a80acd1fb825088b4b069fab1",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v12.3/java_tools_windows-v12.3.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v12.3/java_tools_windows-v12.3.zip",
        ],
    )

    maybe(
        http_archive,
        name = "remote_java_tools_darwin_x86_64",
        sha256 = "3c3fb1967a0f35c73ff509505de53ca4611518922a6b7c8c22a468aa7503132c",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v12.3/java_tools_darwin_x86_64-v12.3.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v12.3/java_tools_darwin_x86_64-v12.3.zip",
        ],
    )

    maybe(
        http_archive,
        name = "remote_java_tools_darwin_arm64",
        sha256 = "29aa0c2de4e3cf45bc55d2995ba803ecbd1173a8d363860abbc309551db7931b",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v12.3/java_tools_darwin_arm64-v12.3.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v12.3/java_tools_darwin_arm64-v12.3.zip",
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
        sha256 = "20c91a922eec795f3181eaa70def8b99d8eac56047c9a14bfb257c85b991df1b",
        strip_prefix = "zulu17.38.21-ca-jdk17.0.5-linux_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.38.21-ca-jdk17.0.5-linux_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu17.38.21-ca-jdk17.0.5-linux_x64.tar.gz",
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
        sha256 = "dbc6ae9163e7ff469a9ab1f342cd1bc1f4c1fb78afc3c4f2228ee3b32c4f3e43",
        strip_prefix = "zulu17.38.21-ca-jdk17.0.5-linux_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.38.21-ca-jdk17.0.5-linux_aarch64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu17.38.21-ca-jdk17.0.5-linux_aarch64.tar.gz",
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
        sha256 = "fdc82f4b06c880762503b0cb40e25f46cf8190d06011b3b768f4091d3334ef7f",
        strip_prefix = "jdk-17.0.4.1+1",
        urls = [
            "https://mirror.bazel.build/github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.4.1%2B1/OpenJDK17U-jdk_s390x_linux_hotspot_17.0.4.1_1.tar.gz",
            "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.4.1%2B1/OpenJDK17U-jdk_s390x_linux_hotspot_17.0.4.1_1.tar.gz",
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
        sha256 = "cbedd0a1428b3058d156e99e8e9bc8769e0d633736d6776a4c4d9136648f2fd1",
        strip_prefix = "jdk-17.0.4.1+1",
        urls = [
            "https://mirror.bazel.build/github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.4.1%2B1/OpenJDK17U-jdk_ppc64le_linux_hotspot_17.0.4.1_1.tar.gz",
            "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.4.1%2B1/OpenJDK17U-jdk_ppc64le_linux_hotspot_17.0.4.1_1.tar.gz",
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
        sha256 = "e6317cee4d40995f0da5b702af3f04a6af2bbd55febf67927696987d11113b53",
        strip_prefix = "zulu17.38.21-ca-jdk17.0.5-macosx_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.38.21-ca-jdk17.0.5-macosx_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu17.38.21-ca-jdk17.0.5-macosx_x64.tar.gz",
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
        sha256 = "515dd56ec99bb5ae8966621a2088aadfbe72631818ffbba6e4387b7ee292ab09",
        strip_prefix = "zulu17.38.21-ca-jdk17.0.5-macosx_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.38.21-ca-jdk17.0.5-macosx_aarch64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu17.38.21-ca-jdk17.0.5-macosx_aarch64.tar.gz",
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
        sha256 = "9972c5b62a61b45785d3d956c559e079d9e91f144ec46225f5deeda214d48f27",
        strip_prefix = "zulu17.38.21-ca-jdk17.0.5-win_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.38.21-ca-jdk17.0.5-win_x64.zip",
            "https://cdn.azul.com/zulu/bin/zulu17.38.21-ca-jdk17.0.5-win_x64.zip",
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
        sha256 = "bc3476f2161bf99bc9a243ff535b8fc033b34ce9a2fa4b62fb8d79b6bfdc427f",
        strip_prefix = "zulu17.38.21-ca-jdk17.0.5-win_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu17.38.21-ca-jdk17.0.5-win_aarch64.zip",
            "https://cdn.azul.com/zulu/bin/zulu17.38.21-ca-jdk17.0.5-win_aarch64.zip",
        ],
        version = "17",
    )

def remote_jdk20_repos():
    """Imports OpenJDK 20 repositories."""
    maybe(
        remote_java_repository,
        name = "remotejdk20_linux",
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "0386418db7f23ae677d05045d30224094fc13423593ce9cd087d455069893bac",
        strip_prefix = "zulu20.28.85-ca-jdk20.0.0-linux_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu20.28.85-ca-jdk20.0.0-linux_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu20.28.85-ca-jdk20.0.0-linux_x64.tar.gz",
        ],
        version = "20",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk20_linux_aarch64",
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "47ce58ead9a05d5d53b96706ff6fa0eb2e46755ee67e2b416925e28f5b55038a",
        strip_prefix = "zulu20.28.85-ca-jdk20.0.0-linux_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu20.28.85-ca-jdk20.0.0-linux_aarch64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu20.28.85-ca-jdk20.0.0-linux_aarch64.tar.gz",
        ],
        version = "20",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk20_macos",
        target_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "fde6cc17a194ea0d9b0c6c0cb6178199d8edfc282d649eec2c86a9796e843f86",
        strip_prefix = "zulu20.28.85-ca-jdk20.0.0-macosx_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu20.28.85-ca-jdk20.0.0-macosx_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu20.28.85-ca-jdk20.0.0-macosx_x64.tar.gz",
        ],
        version = "20",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk20_macos_aarch64",
        target_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "a2eff6a940c2df3a2352278027e83f5959f34dcfc8663034fe92be0f1b91ce6f",
        strip_prefix = "zulu20.28.85-ca-jdk20.0.0-macosx_aarch64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu20.28.85-ca-jdk20.0.0-macosx_aarch64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu20.28.85-ca-jdk20.0.0-macosx_aarch64.tar.gz",
        ],
        version = "20",
    )
    maybe(
        remote_java_repository,
        name = "remotejdk20_win",
        target_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "ac5f6a7d84dbbb0bb4d376feb331cc4c49a9920562f2a5e85b7a6b4863b10e1e",
        strip_prefix = "zulu20.28.85-ca-jdk20.0.0-win_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu20.28.85-ca-jdk20.0.0-win_x64.zip",
            "https://cdn.azul.com/zulu/bin/zulu20.28.85-ca-jdk20.0.0-win_x64.zip",
        ],
        version = "20",
    )

def rules_java_dependencies():
    """An utility method to load all dependencies of rules_java.

    Loads the remote repositories used by default in Bazel.
    """

    local_jdk_repo()
    remote_jdk11_repos()
    remote_jdk17_repos()
    remote_jdk20_repos()
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
        # Must match JDK repos defined in remote_jdk20_repos()
        "20": ["linux", "linux_aarch64", "macos", "macos_aarch64", "win"],
    }

    REMOTE_JDK_REPOS = [("remotejdk" + version + "_" + platform) for version in JDKS for platform in JDKS[version]]

    native.register_toolchains("//toolchains:all")
    native.register_toolchains("@local_jdk//:runtime_toolchain_definition")
    for name in REMOTE_JDK_REPOS:
        native.register_toolchains("@" + name + "_toolchain_config_repo//:toolchain")
