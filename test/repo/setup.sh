#!/usr/bin/env bash

cd ../../
bazel build //distro:all
cp -f bazel-bin/distro/rules_java-*.tar.gz /tmp/rules_java-HEAD.tar.gz