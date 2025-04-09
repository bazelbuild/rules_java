package(default_applicable_licenses = ["@rules_java//:license"])

alias(
    name = "runfiles",
    actual = "//java/runfiles/src/main/java/com/google/devtools/build/runfiles",
    visibility = ["//visibility:public"],
)

filegroup(
    name = "srcs",
    srcs = glob(["**"]) + [
        "//java/runfiles/src/main/java/com/google/devtools/build/runfiles:srcs",
    ],
    visibility = ["//java:__pkg__"],
)
