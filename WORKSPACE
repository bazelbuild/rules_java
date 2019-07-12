workspace(name = "rules_java")


load("@rules_java//java:repositories.bzl", "rules_java_dependencies", "rules_java_toolchains")
rules_java_dependencies()
rules_java_toolchains()

# The latest java_tools releases supported by default in Bazel.
http_archive(
    name = "remote_java_tools_linux",
    sha256 = "10d6f00c72e42b6fda378ad506cc93b1dc92e1aec6e2a490151032244b8b8df5",
    urls = [
        "https://mirror.bazel.build/bazel_java_tools/releases/javac11/v3.0/java_tools_javac11_linux-v3.0.zip",
    ],
)

http_archive(
    name = "remote_java_tools_windows",
    sha256 = "b688155d81245b4d1ee52cac447aae5444b1c59dc77158fcbde05554a6bab48b",
    urls = [
        "https://mirror.bazel.build/bazel_java_tools/releases/javac11/v3.0/java_tools_javac11_windows-v3.0.zip",
    ],
)

http_archive(
    name = "remote_java_tools_darwin",
    sha256 = "28989f78b1ce437c92dd27bb4943b2211ba4db916ccbb3aef83696a8f9b43724",
    urls = [
        "https://mirror.bazel.build/bazel_java_tools/releases/javac11/v3.0/java_tools_javac11_darwin-v3.0.zip",
    ],
)

register_toolchains(
    "@rules_java//java/toolchains:javac_linux_toolchain",
    "@rules_java//java/toolchains:javac_windows_toolchain",
    "@rules_java//java/toolchains:javac_darwin_toolchain",
)
