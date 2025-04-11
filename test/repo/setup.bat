cd ../../
bazel build //distro:all //test/testdata:my_jar
cp -f ./bazel-bin/distro/*.tar.gz C:/b/rules_java-HEAD.tar.gz
cp -f bazel-bin/test/testdata/libmy_jar.jar C:/b/my_jar.jar
