licenses(["notice"])

exports_files(["LICENSE"])

filegroup(
    name = "distribution",
    srcs = glob([
        "BUILD",
        "LICENSE",
        "*.bzl",
    ]),
    visibility = ["@//distro:__pkg__"],
)
