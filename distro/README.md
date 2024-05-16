# Releasing rules_java

1. Update version in [MODULE.bazel](/MODULE.bazel) and merge it
2. Build the release running `bazel build //distro:rules_java-{version}`
3. Prepare release notes running `bazel build //distro:relnotes`
4. Create a new release on GitHub
5. Copy/paste the produced `relnotes.txt` into the notes. Adjust as needed.
6. Upload the produced tar.gz file as an artifact.

------

**Note:** Steps 2-6 have been automated. Trigger a new build of the [rules_java release pipeline](https://buildkite.com/bazel-trusted/rules-java-release/). Set the message to "rules_java [version]" (or anything else), and leave the commit and branch fields as is.

A new release will be created [here](https://github.com/bazelbuild/rules_java/releases) -- edit the description as needed. A PR will be submitted against the [bazel-central-registry](https://github.com/bazelbuild/bazel-central-registry) repo.

rules_java 6.5.0 example:

- Build: https://buildkite.com/bazel-trusted/rules-java-release/builds/1
- Release: https://github.com/bazelbuild/rules_java/releases/tag/6.5.0
- BCR PR: bazelbuild/bazel-central-registry#818

