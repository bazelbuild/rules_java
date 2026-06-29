load("@com_google_protobuf//bazel:java_proto_library.bzl", "java_proto_library")
load("@com_google_protobuf//bazel:proto_library.bzl", "proto_library")

proto_library(
    name = "deps_proto",
    srcs = ["deps.proto"],
    visibility = ["//visibility:public"],
)

java_proto_library(
    name = "deps_java_proto",
    deps = [":deps_proto"],
    visibility = ["//visibility:public"],
)

proto_library(
    name = "java_compilation_proto",
    srcs = ["java_compilation.proto"],
    visibility = ["//visibility:public"],
)

java_proto_library(
    name = "java_compilation_java_proto",
    deps = [":java_compilation_proto"],
    visibility = ["//visibility:public"],
)

proto_library(
    name = "worker_protocol_proto",
    srcs = ["worker_protocol.proto"],
    visibility = ["//visibility:public"],
)

java_proto_library(
    name = "worker_protocol_java_proto",
    deps = [":worker_protocol_proto"],
    visibility = ["//visibility:public"],
)
