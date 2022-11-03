# Releasing rules_java

1. Update version in [java/defs.bzl](/java/defs.bzl),
   [MODULE.bazel](/MODULE.bazel) and merge it
2. Build the release running `bazel build //distro:rules_java-{version}`
3. Prepare release notes running `bazel build //distro:relnotes`
4. Create a new release on GitHub
5. Copy/paste the produced `relnotes.txt` into the notes. Adjust as needed.
6. Upload the produced tar.gz file as an artifact.
