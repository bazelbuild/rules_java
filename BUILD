licenses(["notice"])

exports_files([
    "LICENSE",
    "WORKSPACE",
])

filegroup(
    name = "distribution",
    srcs = [
        "AUTHORS",
        "BUILD",
        "LICENSE",
        "MODULE.bazel",
        "//java:srcs",
        "//toolchains:srcs",
    ],
    visibility = ["//distro:__pkg__"],
)
