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
load("@bazel_tools//tools/jdk:remote_java_repository.bzl", "remote_java_repository")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def java_tools_repos():
    maybe(
        http_archive,
        name = "remote_java_tools",
        sha256 = "12cffbb7c87622a6bd6e9231e81ecb9efdb118afbdd6e047ef06eeb3d72a7dc3",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v11.1/java_tools-v11.1.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v11.1/java_tools-v11.1.zip",
        ],
    )

    # This must be kept in sync with the top-level WORKSPACE file.
    maybe(
        http_archive,
        name = "remote_java_tools_linux",
        sha256 = "a0dea21d348c8be94d06fde5a6c18d7691aa659cd56c3f1f932f0a28ae943a23",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v11.1/java_tools_linux-v11.1.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v11.1/java_tools_linux-v11.1.zip",
        ],
    )

    # This must be kept in sync with the top-level WORKSPACE file.
    maybe(
        http_archive,
        name = "remote_java_tools_windows",
        sha256 = "ac4d22ce9b10a1d5e46cbae0beb63221d96043d1f3543a729482005481e3e51a",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v11.1/java_tools_windows-v11.1.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v11.1/java_tools_windows-v11.1.zip",
        ],
    )

    # This must be kept in sync with the top-level WORKSPACE file.
    maybe(
        http_archive,
        name = "remote_java_tools_darwin",
        sha256 = "72a2f34806e7f83b111601495c3bd401b96ea1794daa259608481fd4f6a60629",
        urls = [
            "https://mirror.bazel.build/bazel_java_tools/releases/java/v11.1/java_tools_darwin-v11.1.zip",
            "https://github.com/bazelbuild/java_tools/releases/download/java_v11.1/java_tools_darwin-v11.1.zip",
        ],
    )

def remote_jdk9_repos():
    """OpenJDK distributions that should only be downloaded on demand.

    E.g. when building a java_library or a genrule that uses java make
    variables).  This will allow us to stop bundling the full JDK with Bazel.
    Note that while these are currently the same as the openjdk_* rules in
    Bazel's WORKSPACE file, but they don't have to be the same.

    The source-code for this OpenJDK can be found at:
    https://openjdk.linaro.org/releases/jdk9-src-1708.tar.xz
    """
    maybe(
        remote_java_repository,
        name = "remote_jdk9_linux_aarch64",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "72e7843902b0395e2d30e1e9ad2a5f05f36a4bc62529828bcbc698d54aec6022",
        strip_prefix = "jdk9-server-release-1708",
        urls = [
            # When you update this, also update the link to the source-code above.
            "https://mirror.bazel.build/openjdk.linaro.org/releases/jdk9-server-release-170bazel_skylib8.tar.xz",
            "http://openjdk.linaro.org/releases/jdk9-server-release-1708.tar.xz",
        ],
        version = "9",
    )

    maybe(
        remote_java_repository,
        name = "remote_jdk9_linux",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "45f2dfbee93b91b1468cf81d843fc6d9a47fef1f831c0b7ceff4f1eb6e6851c8",
        strip_prefix = "zulu9.0.7.1-jdk9.0.7-linux_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu-9.0.7.1-jdk9.0.7/zulu9.0.7.1-jdk9.0.7-linux_x64.tar.gz",
        ],
        version = "9",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk9_macos",
        exec_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        strip_prefix = "zulu9.0.7.1-jdk9.0.7-macosx_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu-9.0.7.1-jdk9.0.7/zulu9.0.7.1-jdk9.0.7-macosx_x64.tar.gz",
        ],
        version = "9",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk9_windows",
        exec_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        strip_prefix = "zulu9.0.7.1-jdk9.0.7-win_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu-9.0.7.1-jdk9.0.7/zulu9.0.7.1-jdk9.0.7-win_x64.zip",
        ],
        version = "9",
    )

def remote_jdk10_repos():
    # The source-code for this OpenJDK can be found at:
    # https://openjdk.linaro.org/releases/jdk10-src-1804.tar.xz
    maybe(
        remote_java_repository,
        name = "remote_jdk10_linux_aarch64",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "b7098b7aaf6ee1ffd4a2d0371a0be26c5a5c87f6aebbe46fe9a92c90583a84be",
        strip_prefix = "jdk10-server-release-1804",
        urls = [
            # When you update this, also update the link to the source-code above.
            "https://mirror.bazel.build/openjdk.linaro.org/releases/jdk10-server-release-1804.tar.xz",
            "http://openjdk.linaro.org/releases/jdk10-server-release-1804.tar.xz",
        ],
        version = "10",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk10_linux",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "b3c2d762091a615b0c1424ebbd05d75cc114da3bf4f25a0dec5c51ea7e84146f",
        strip_prefix = "zulu10.2+3-jdk10.0.1-linux_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu10.2+3-jdk10.0.1/zulu10.2+3-jdk10.0.1-linux_x64.tar.gz",
        ],
        version = "10",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk10_macos",
        exec_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        strip_prefix = "zulu10.2+3-jdk10.0.1-macosx_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu10.2+3-jdk10.0.1/zulu10.2+3-jdk10.0.1-macosx_x64.tar.gz",
        ],
        version = "10",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk10_windows",
        exec_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        strip_prefix = "zulu10.2+3-jdk10.0.1-win_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu10.2+3-jdk10.0.1/zulu10.2+3-jdk10.0.1-win_x64.zip",
        ],
        version = "10",
    )

def remote_jdk11_repos():
    # The source-code for this OpenJDK can be found at:
    # https://openjdk.linaro.org/releases/jdk10-src-1804.tar.xz
    maybe(
        remote_java_repository,
        name = "remote_jdk11_linux_aarch64",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
        sha256 = "3b0d91611b1bdc4d409afcf9eab4f0e7f4ae09f88fc01bd9f2b48954882ae69b",
        strip_prefix = "zulu11.31.15-ca-jdk11.0.3-linux_aarch64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.31.15-ca-jdk11.0.3/zulu11.31.15-ca-jdk11.0.3-linux_aarch64.tar.gz",
        ],
        version = "11",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk11_linux",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "232b1c3511f0d26e92582b7c3cc363be7ac633e371854ca2f2e9f2b50eb72a75",
        strip_prefix = "zulu11.2.3-jdk11.0.1-linux_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.2.3-jdk11.0.1/zulu11.2.3-jdk11.0.1-linux_x64.tar.gz",
        ],
        version = "11",
    )

    maybe(
        remote_java_repository,
        name = "remote_jdk11_macos",
        exec_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "1edf366ee821e5db8e348152fcb337b28dfd6bf0f97943c270dcc6747cedb6cb",
        strip_prefix = "zulu11.2.3-jdk11.0.1-macosx_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.2.3-jdk11.0.1/zulu11.2.3-jdk11.0.1-macosx_x64.tar.gz",
        ],
        version = "11",
    )

    maybe(
        remote_java_repository,
        name = "remote_jdk11_windows",
        exec_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "8e1e2b8347de6746f3fd1538840dd643201533ab113abc4ed93678e342d28aa3",
        strip_prefix = "zulu11.2.3-jdk11.0.1-win_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu11.2.3-jdk11.0.1/zulu11.2.3-jdk11.0.1-win_x64.zip",
        ],
        version = "11",
    )

    maybe(
        remote_java_repository,
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

    # This must be kept in sync with the top-level WORKSPACE file.
    maybe(
        remote_java_repository,
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

def remote_jdk12_repos():
    maybe(
        remote_java_repository,
        name = "remote_jdk12_linux",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        strip_prefix = "zulu12.2.3-ca-jdk12.0.1-linux_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu12.2.3-ca-jdk12.0.1/zulu12.2.3-ca-jdk12.0.1-linux_x64.tar.gz",
        ],
        version = "12",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk12_macos",
        exec_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        strip_prefix = "zulu12.2.3-ca-jdk12.0.1-macosx_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu12.2.3-ca-jdk12.0.1/zulu12.2.3-ca-jdk12.0.1-macosx_x64.tar.gz",
        ],
        version = "12",
    )
    maybe(
        remote_java_repository,
        name = "remote_jdk12_windows",
        exec_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        build_file_content = "java_runtime(name = 'runtime', srcs =  glob(['**']), visibility = ['//visibility:public'])",
        strip_prefix = "zulu12.2.3-ca-jdk12.0.1-win_x64",
        urls = [
            "https://mirror.bazel.build/openjdk/azul-zulu12.2.3-ca-jdk12.0.1/zulu12.2.3-ca-jdk12.0.1-win_x64.zip",
        ],
        version = "12",
    )

def remote_jdk14_repos():
    maybe(
        remote_java_repository,
        name = "remote_jdk14_linux",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "48bb8947034cd079ad1ef83335e7634db4b12a26743a0dc314b6b861480777aa",
        strip_prefix = "zulu14.28.21-ca-jdk14.0.1-linux_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu14.28.21-ca-jdk14.0.1-linux_x64.tar.gz",
        ],
        version = "14",
    )

    # This must be kept in sync with the top-level WORKSPACE file.
    maybe(
        remote_java_repository,
        name = "remote_jdk14_macos",
        exec_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "088bd4d0890acc9f032b738283bf0f26b2a55c50b02d1c8a12c451d8ddf080dd",
        strip_prefix = "zulu14.28.21-ca-jdk14.0.1-macosx_x64",
        urls = ["https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu14.28.21-ca-jdk14.0.1-macosx_x64.tar.gz"],
        version = "14",
    )

    # This must be kept in sync with the top-level WORKSPACE file.
    maybe(
        remote_java_repository,
        name = "remote_jdk14_win",
        exec_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "9cb078b5026a900d61239c866161f0d9558ec759aa15c5b4c7e905370e868284",
        strip_prefix = "zulu14.28.21-ca-jdk14.0.1-win_x64",
        urls = ["https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu14.28.21-ca-jdk14.0.1-win_x64.zip"],
        version = "14",
    )

def remote_jdk15_repos():
    maybe(
        remote_java_repository,
        name = "remote_jdk15_linux",
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

    maybe(
        remote_java_repository,
        name = "remote_jdk15_macos",
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

    maybe(
        remote_java_repository,
        name = "remote_jdk15_win",
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

def bazel_skylib():
    maybe(
        http_archive,
        name = "bazel_skylib",
        type = "tar.gz",
        url = "https://github.com/bazelbuild/bazel-skylib/releases/download/0.9.0/bazel_skylib-0.9.0.tar.gz",
        sha256 = "1dde365491125a3db70731e25658dfdd3bc5dbdfd11b840b3e987ecf043c7ca0",
    )

def rules_java_dependencies():
    """An utility method to load all dependencies of rules_java.

    Loads the remote repositories used by default in Bazel.
    """

    remote_jdk11_repos()
    java_tools_repos()
    bazel_skylib()

def rules_java_toolchains():
    """An utility method to load all Java toolchains.

    It doesn't do anything at the moment.
    """
    pass
