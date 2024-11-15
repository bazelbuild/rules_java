load("@rules_java//java:java_import.bzl", "java_import")
load("@rules_java//java:java_test.bzl", "java_test")

java_test(
    name = "RunfilesTest",
    srcs = ["RunfilesTest.java"],
    test_class = "com.google.devtools.build.runfiles.RunfilesTest",
    deps = [
        ":guava",
        ":truth",
        "//java/runfiles",
    ],
)

java_test(
    name = "UtilTest",
    srcs = ["UtilTest.java"],
    test_class = "com.google.devtools.build.runfiles.UtilTest",
    deps = [
        ":guava",
        ":truth",
        "//java/runfiles",
    ],
)

java_import(
    name = "guava",
    jars = ["@guava//file"],
)

java_import(
    name = "truth",
    jars = ["@truth//file"],
)
