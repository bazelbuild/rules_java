# rules_java

* Postsubmit [![Build status](https://badge.buildkite.com/d4f950ef5f481b8ca066624ba06c238fa1446d84a057ddbf89.svg?branch=master)](https://buildkite.com/bazel/rules-java-java)
* Postsubmit + Current Bazel Incompatible Flags [![Build status](https://badge.buildkite.com/ef265d270238c02aff65106a0b861abb9265efacdf4af399c3.svg?branch=master)](https://buildkite.com/bazel/rules-java-plus-bazelisk-migrate)

Java Rules for Bazel https://bazel.build.

**Documentation**

For a quickstart tutorial, see https://bazel.build/start/java

For slightly more advanced usage, like setting up toolchains
or writing your own java-like rules,
see https://bazel.build/docs/bazel-and-java


***Core Java rules***

Add a load like:
```build
load("@rules_java//java:java_library.bzl", "java_library")
```
to your `BUILD` / `BUILD.bazel` / bzl` files

For detailed docs on the core rules, see https://bazel.build/reference/be/java
