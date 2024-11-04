#!/usr/bin/env bash

cd ../../
bazel build //distro:all //test/testdata:my_jar
cp -f bazel-bin/distro/rules_java-*.tar.gz /tmp/rules_java-HEAD.tar.gz
cp -f bazel-bin/test/testdata/libmy_jar.jar /tmp/my_jar.jar

