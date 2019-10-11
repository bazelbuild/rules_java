package(default_visibility = ["//visibility:public"])

# TODO(aiuto): Find a way to strip this rule from the distribution tarball.
filegroup(
    name = "distribution",
    srcs = glob([
        "**",
    ]) + [
        "//java/constraints:srcs",
    ],
    visibility = [
        "@//distro:__pkg__",
        "@rules_java//distro:__pkg__",
    ],
)
