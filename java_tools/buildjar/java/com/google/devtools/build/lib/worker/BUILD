load("@rules_java//java:defs.bzl", "java_library")

java_library(
    name = "work_request_handlers",
    srcs = [
        "JsonWorkerMessageProcessor.java",
        "ProtoWorkerMessageProcessor.java",
        "WorkRequestHandler.java",
    ],
    javacopts = [
        "-source 21",
        "-target 21",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//java_tools/buildjar/protobuf:worker_protocol_java_proto",
        "//third_party:error_prone_annotations",
        "//third_party:gson",
        "//third_party:guava",
        "@com_google_protobuf//:protobuf_java",
        "@com_google_protobuf//:protobuf_java_util",
    ],
)
