// Copyright 2018 The Bazel Authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package com.google.devtools.build.runfiles;

import static com.google.common.truth.Truth.assertThat;
import static org.junit.Assert.assertThrows;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;
import javax.annotation.Nullable;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

/** Unit tests for {@link Runfiles}. */
@RunWith(JUnit4.class)
public final class RunfilesTest {

  @Rule
  public TemporaryFolder tempDir = new TemporaryFolder(new File(System.getenv("TEST_TMPDIR")));

  private static final String MAIN_REPO_CANONICAL_NAME = "";

  private static boolean isWindows() {
    return File.separatorChar == '\\';
  }

  private void assertRlocationArg(Runfiles runfiles, String path, @Nullable String error) {
    IllegalArgumentException e =
        assertThrows(IllegalArgumentException.class, () -> runfiles.rlocation(path));
    if (error != null) {
      assertThat(e).hasMessageThat().contains(error);
    }
  }

  @Test
  public void testRlocationArgumentValidation() throws Exception {
    Path dir =
        Files.createTempDirectory(
            FileSystems.getDefault().getPath(System.getenv("TEST_TMPDIR")), null);

    Runfiles r = Runfiles.create(ImmutableMap.of("RUNFILES_DIR", dir.toString()));
    assertRlocationArg(r, null, null);
    assertRlocationArg(r, "", null);
    assertRlocationArg(r, "../foo", "is not normalized");
    assertRlocationArg(r, "foo/..", "is not normalized");
    assertRlocationArg(r, "foo/../bar", "is not normalized");
    assertRlocationArg(r, "./foo", "is not normalized");
    assertRlocationArg(r, "foo/.", "is not normalized");
    assertRlocationArg(r, "foo/./bar", "is not normalized");
    assertRlocationArg(r, "//foobar", "is not normalized");
    assertRlocationArg(r, "foo//", "is not normalized");
    assertRlocationArg(r, "foo//bar", "is not normalized");
    assertRlocationArg(r, "\\foo", "path is absolute without a drive letter");
  }

  @Test
  public void testCreatesManifestBasedRunfiles() throws Exception {
    Path mf = tempFile("foo.runfiles_manifest", ImmutableList.of("a/b c/d"));
    Runfiles r =
        Runfiles.create(
            ImmutableMap.of(
                "RUNFILES_MANIFEST_ONLY", "1",
                "RUNFILES_MANIFEST_FILE", mf.toString(),
                "RUNFILES_DIR", "ignored when RUNFILES_MANIFEST_ONLY=1",
                "JAVA_RUNFILES", "ignored when RUNFILES_DIR has a value",
                "TEST_SRCDIR", "should always be ignored"));
    assertThat(r.rlocation("a/b")).isEqualTo("c/d");
    assertThat(r.rlocation("foo")).isNull();

    if (isWindows()) {
      assertThat(r.rlocation("c:/foo")).isEqualTo("c:/foo");
      assertThat(r.rlocation("c:\\foo")).isEqualTo("c:\\foo");
    } else {
      assertThat(r.rlocation("/foo")).isEqualTo("/foo");
    }
  }

  @Test
  public void testCreatesDirectoryBasedRunfiles() throws Exception {
    Path dir =
        Files.createTempDirectory(
            FileSystems.getDefault().getPath(System.getenv("TEST_TMPDIR")), null);

    Runfiles r =
        Runfiles.create(
            ImmutableMap.of(
                "RUNFILES_MANIFEST_FILE", "ignored when RUNFILES_MANIFEST_ONLY is not set to 1",
                "RUNFILES_DIR", dir.toString(),
                "JAVA_RUNFILES", "ignored when RUNFILES_DIR has a value",
                "TEST_SRCDIR", "should always be ignored"));
    assertThat(r.rlocation("a/b")).endsWith("/a/b");
    assertThat(r.rlocation("foo")).endsWith("/foo");

    r =
        Runfiles.create(
            ImmutableMap.of(
                "RUNFILES_MANIFEST_FILE", "ignored when RUNFILES_MANIFEST_ONLY is not set to 1",
                "RUNFILES_DIR", "",
                "JAVA_RUNFILES", dir.toString(),
                "TEST_SRCDIR", "should always be ignored"));
    assertThat(r.rlocation("a/b")).endsWith("/a/b");
    assertThat(r.rlocation("foo")).endsWith("/foo");
  }

  @Test
  public void testIgnoresTestSrcdirWhenJavaRunfilesIsUndefinedAndJustFails() throws Exception {
    Path dir =
        Files.createTempDirectory(
            FileSystems.getDefault().getPath(System.getenv("TEST_TMPDIR")), null);

    Runfiles.create(
        ImmutableMap.of(
            "RUNFILES_DIR", dir.toString(),
            "RUNFILES_MANIFEST_FILE", "ignored when RUNFILES_MANIFEST_ONLY is not set to 1",
            "TEST_SRCDIR", "should always be ignored"));

    Runfiles.create(
        ImmutableMap.of(
            "JAVA_RUNFILES", dir.toString(),
            "RUNFILES_MANIFEST_FILE", "ignored when RUNFILES_MANIFEST_ONLY is not set to 1",
            "TEST_SRCDIR", "should always be ignored"));

    IOException e =
        assertThrows(
            IOException.class,
            () ->
                Runfiles.create(
                    ImmutableMap.of(
                        "RUNFILES_DIR",
                        "",
                        "JAVA_RUNFILES",
                        "",
                        "RUNFILES_MANIFEST_FILE",
                        "ignored when RUNFILES_MANIFEST_ONLY is not set to 1",
                        "TEST_SRCDIR",
                        "should always be ignored")));
    assertThat(e).hasMessageThat().contains("$RUNFILES_DIR and $JAVA_RUNFILES");
  }

  @Test
  public void testFailsToCreateManifestBasedBecauseManifestDoesNotExist() {
    IOException e =
        assertThrows(
            IOException.class,
            () ->
                Runfiles.create(
                    ImmutableMap.of(
                        "RUNFILES_MANIFEST_ONLY", "1",
                        "RUNFILES_MANIFEST_FILE", "non-existing path")));
    assertThat(e).hasMessageThat().contains("non-existing path");
  }

  @Test
  public void testManifestBasedEnvVars() throws Exception {
    Path mf = tempFile("MANIFEST", ImmutableList.of());
    Map<String, String> envvars =
        Runfiles.create(
                ImmutableMap.of(
                    "RUNFILES_MANIFEST_ONLY", "1",
                    "RUNFILES_MANIFEST_FILE", mf.toString(),
                    "RUNFILES_DIR", "ignored when RUNFILES_MANIFEST_ONLY=1",
                    "JAVA_RUNFILES", "ignored when RUNFILES_DIR has a value",
                    "TEST_SRCDIR", "should always be ignored"))
            .getEnvVars();
    assertThat(envvars.keySet())
        .containsExactly(
            "RUNFILES_MANIFEST_ONLY", "RUNFILES_MANIFEST_FILE", "RUNFILES_DIR", "JAVA_RUNFILES");
    assertThat(envvars.get("RUNFILES_MANIFEST_ONLY")).isEqualTo("1");
    assertThat(envvars.get("RUNFILES_MANIFEST_FILE")).isEqualTo(mf.toString());
    assertThat(envvars.get("RUNFILES_DIR")).isEqualTo(tempDir.getRoot().toString());
    assertThat(envvars.get("JAVA_RUNFILES")).isEqualTo(tempDir.getRoot().toString());

    Path rfDir = tempDir.getRoot().toPath().resolve("foo.runfiles");
    Files.createDirectories(rfDir);
    mf = tempFile("foo.runfiles_manifest", ImmutableList.of());
    envvars =
        Runfiles.create(
                ImmutableMap.of(
                    "RUNFILES_MANIFEST_ONLY", "1",
                    "RUNFILES_MANIFEST_FILE", mf.toString(),
                    "RUNFILES_DIR", "ignored when RUNFILES_MANIFEST_ONLY=1",
                    "JAVA_RUNFILES", "ignored when RUNFILES_DIR has a value",
                    "TEST_SRCDIR", "should always be ignored"))
            .getEnvVars();
    assertThat(envvars.get("RUNFILES_MANIFEST_ONLY")).isEqualTo("1");
    assertThat(envvars.get("RUNFILES_MANIFEST_FILE")).isEqualTo(mf.toString());
    assertThat(envvars.get("RUNFILES_DIR")).isEqualTo(rfDir.toString());
    assertThat(envvars.get("JAVA_RUNFILES")).isEqualTo(rfDir.toString());
  }

  @Test
  public void testDirectoryBasedEnvVars() throws Exception {
    Map<String, String> envvars =
        Runfiles.create(
                ImmutableMap.of(
                    "RUNFILES_MANIFEST_FILE",
                    "ignored when RUNFILES_MANIFEST_ONLY is not set to 1",
                    "RUNFILES_DIR",
                    tempDir.getRoot().toString(),
                    "JAVA_RUNFILES",
                    "ignored when RUNFILES_DIR has a value",
                    "TEST_SRCDIR",
                    "should always be ignored"))
            .getEnvVars();
    assertThat(envvars.keySet()).containsExactly("RUNFILES_DIR", "JAVA_RUNFILES");
    assertThat(envvars.get("RUNFILES_DIR")).isEqualTo(tempDir.getRoot().toString());
    assertThat(envvars.get("JAVA_RUNFILES")).isEqualTo(tempDir.getRoot().toString());
  }

  @Test
  public void testDirectoryBasedRlocation() throws IOException {
    // The DirectoryBased implementation simply joins the runfiles directory and the runfile's path
    // on a "/". DirectoryBased does not perform any normalization, nor does it check that the path
    // exists.
    File dir = new File(System.getenv("TEST_TMPDIR"), "mock/runfiles");
    assertThat(dir.mkdirs()).isTrue();
    Runfiles r = Runfiles.createDirectoryBasedForTesting(dir.toString()).withSourceRepository("");
    // Escaping for "\": once for string and once for regex.
    assertThat(r.rlocation("arg")).matches(".*[/\\\\]mock[/\\\\]runfiles[/\\\\]arg");
  }

  @Test
  public void testManifestBasedRlocation() throws Exception {
    Path mf =
        tempFile(
            "MANIFEST",
            ImmutableList.of(
                "Foo/runfile1 C:/Actual Path\\runfile1",
                "Foo/Bar/runfile2 D:\\the path\\run file 2.txt",
                "Foo/Bar/Dir E:\\Actual Path\\bDirectory",
                " h/\\si F:\\bjk",
                " dir\\swith\\sspaces F:\\bj k\\bdir with spaces",
                " h/\\s\\n\\bi F:\\bjk\\nb"));
    Runfiles r = Runfiles.createManifestBasedForTesting(mf.toString()).withSourceRepository("");
    assertThat(r.rlocation("Foo/runfile1")).isEqualTo("C:/Actual Path\\runfile1");
    assertThat(r.rlocation("Foo/Bar/runfile2")).isEqualTo("D:\\the path\\run file 2.txt");
    assertThat(r.rlocation("Foo/Bar/Dir")).isEqualTo("E:\\Actual Path\\bDirectory");
    assertThat(r.rlocation("Foo/Bar/Dir/File")).isEqualTo("E:\\Actual Path\\bDirectory/File");
    assertThat(r.rlocation("Foo/Bar/Dir/Deeply/Nested/File"))
        .isEqualTo("E:\\Actual Path\\bDirectory/Deeply/Nested/File");
    assertThat(r.rlocation("Foo/Bar/Dir/Deeply/Nested/File With Spaces"))
        .isEqualTo("E:\\Actual Path\\bDirectory/Deeply/Nested/File With Spaces");
    assertThat(r.rlocation("h/ i")).isEqualTo("F:\\jk");
    assertThat(r.rlocation("h/ \n\\i")).isEqualTo("F:\\jk\nb");
    assertThat(r.rlocation("dir with spaces")).isEqualTo("F:\\j k\\dir with spaces");
    assertThat(r.rlocation("dir with spaces/file")).isEqualTo("F:\\j k\\dir with spaces/file");
    assertThat(r.rlocation("unknown")).isNull();
  }

  @Test
  public void testManifestBasedRlocationWithRepoMapping_fromMain() throws Exception {
    Path rm =
        tempFile(
            "foo.repo_mapping",
            ImmutableList.of(
                ",config.json,config.json+1.2.3",
                ",my_module,_main",
                ",my_protobuf,protobuf+3.19.2",
                ",my_workspace,_main",
                "protobuf+3.19.2,config.json,config.json+1.2.3",
                "protobuf+3.19.2,protobuf,protobuf+3.19.2"));
    Path mf =
        tempFile(
            "foo.runfiles_manifest",
            ImmutableList.of(
                "_repo_mapping " + rm,
                "config.json /etc/config.json",
                "protobuf+3.19.2/foo/runfile C:/Actual Path\\protobuf\\runfile",
                "_main/bar/runfile /the/path/./to/other//other runfile.txt",
                "protobuf+3.19.2/bar/dir E:\\Actual Path\\Directory"));
    Runfiles r = Runfiles.createManifestBasedForTesting(mf.toString()).withSourceRepository("");

    assertThat(r.rlocation("my_module/bar/runfile"))
        .isEqualTo("/the/path/./to/other//other runfile.txt");
    assertThat(r.rlocation("my_workspace/bar/runfile"))
        .isEqualTo("/the/path/./to/other//other runfile.txt");
    assertThat(r.rlocation("my_protobuf/foo/runfile"))
        .isEqualTo("C:/Actual Path\\protobuf\\runfile");
    assertThat(r.rlocation("my_protobuf/bar/dir")).isEqualTo("E:\\Actual Path\\Directory");
    assertThat(r.rlocation("my_protobuf/bar/dir/file"))
        .isEqualTo("E:\\Actual Path\\Directory/file");
    assertThat(r.rlocation("my_protobuf/bar/dir/de eply/nes ted/fi+le"))
        .isEqualTo("E:\\Actual Path\\Directory/de eply/nes ted/fi+le");

    assertThat(r.rlocation("protobuf/foo/runfile")).isNull();
    assertThat(r.rlocation("protobuf/bar/dir")).isNull();
    assertThat(r.rlocation("protobuf/bar/dir/file")).isNull();
    assertThat(r.rlocation("protobuf/bar/dir/dir/de eply/nes ted/fi+le")).isNull();

    assertThat(r.rlocation("_main/bar/runfile"))
        .isEqualTo("/the/path/./to/other//other runfile.txt");
    assertThat(r.rlocation("protobuf+3.19.2/foo/runfile"))
        .isEqualTo("C:/Actual Path\\protobuf\\runfile");
    assertThat(r.rlocation("protobuf+3.19.2/bar/dir")).isEqualTo("E:\\Actual Path\\Directory");
    assertThat(r.rlocation("protobuf+3.19.2/bar/dir/file"))
        .isEqualTo("E:\\Actual Path\\Directory/file");
    assertThat(r.rlocation("protobuf+3.19.2/bar/dir/de eply/nes  ted/fi+le"))
        .isEqualTo("E:\\Actual Path\\Directory/de eply/nes  ted/fi+le");

    assertThat(r.rlocation("config.json")).isEqualTo("/etc/config.json");
    assertThat(r.rlocation("_main")).isNull();
    assertThat(r.rlocation("my_module")).isNull();
    assertThat(r.rlocation("protobuf")).isNull();
  }

  @Test
  public void testManifestBasedRlocationUnmapped() throws Exception {
    Path rm =
        tempFile(
            "foo.repo_mapping",
            ImmutableList.of(
                ",config.json,config.json+1.2.3",
                ",my_module,_main",
                ",my_protobuf,protobuf+3.19.2",
                ",my_workspace,_main",
                "protobuf+3.19.2,config.json,config.json+1.2.3",
                "protobuf+3.19.2,protobuf,protobuf+3.19.2"));
    Path mf =
        tempFile(
            "foo.runfiles_manifest",
            ImmutableList.of(
                "_repo_mapping " + rm,
                "config.json /etc/config.json",
                "protobuf+3.19.2/foo/runfile C:/Actual Path\\protobuf\\runfile",
                "_main/bar/runfile /the/path/./to/other//other runfile.txt",
                "protobuf+3.19.2/bar/dir E:\\Actual Path\\Directory"));
    Runfiles r = Runfiles.createManifestBasedForTesting(mf.toString()).unmapped();

    assertThat(r.rlocation("my_module/bar/runfile")).isNull();
    assertThat(r.rlocation("my_workspace/bar/runfile")).isNull();
    assertThat(r.rlocation("my_protobuf/foo/runfile")).isNull();
    assertThat(r.rlocation("my_protobuf/bar/dir")).isNull();
    assertThat(r.rlocation("my_protobuf/bar/dir/file")).isNull();
    assertThat(r.rlocation("my_protobuf/bar/dir/de eply/nes ted/fi+le")).isNull();

    assertThat(r.rlocation("protobuf/foo/runfile")).isNull();
    assertThat(r.rlocation("protobuf/bar/dir")).isNull();
    assertThat(r.rlocation("protobuf/bar/dir/file")).isNull();
    assertThat(r.rlocation("protobuf/bar/dir/dir/de eply/nes ted/fi+le")).isNull();

    assertThat(r.rlocation("_main/bar/runfile"))
        .isEqualTo("/the/path/./to/other//other runfile.txt");
    assertThat(r.rlocation("protobuf+3.19.2/foo/runfile"))
        .isEqualTo("C:/Actual Path\\protobuf\\runfile");
    assertThat(r.rlocation("protobuf+3.19.2/bar/dir")).isEqualTo("E:\\Actual Path\\Directory");
    assertThat(r.rlocation("protobuf+3.19.2/bar/dir/file"))
        .isEqualTo("E:\\Actual Path\\Directory/file");
    assertThat(r.rlocation("protobuf+3.19.2/bar/dir/de eply/nes  ted/fi+le"))
        .isEqualTo("E:\\Actual Path\\Directory/de eply/nes  ted/fi+le");

    assertThat(r.rlocation("config.json")).isEqualTo("/etc/config.json");
    assertThat(r.rlocation("_main")).isNull();
    assertThat(r.rlocation("my_module")).isNull();
    assertThat(r.rlocation("protobuf")).isNull();
  }

  @Test
  public void testManifestBasedRlocationWithRepoMapping_fromOtherRepo() throws Exception {
    Path rm =
        tempFile(
            "foo.repo_mapping",
            ImmutableList.of(
                ",config.json,config.json+1.2.3",
                ",my_module,_main",
                ",my_protobuf,protobuf+3.19.2",
                ",my_workspace,_main",
                "protobuf+3.19.2,config.json,config.json+1.2.3",
                "protobuf+3.19.2,protobuf,protobuf+3.19.2"));
    Path mf =
        tempFile(
            "foo.runfiles/MANIFEST",
            ImmutableList.of(
                "_repo_mapping " + rm,
                "config.json /etc/config.json",
                "protobuf+3.19.2/foo/runfile C:/Actual Path\\protobuf\\runfile",
                "_main/bar/runfile /the/path/./to/other//other runfile.txt",
                "protobuf+3.19.2/bar/dir E:\\Actual Path\\Directory"));
    Runfiles r =
        Runfiles.createManifestBasedForTesting(mf.toString())
            .withSourceRepository("protobuf+3.19.2");

    assertThat(r.rlocation("protobuf/foo/runfile")).isEqualTo("C:/Actual Path\\protobuf\\runfile");
    assertThat(r.rlocation("protobuf/bar/dir")).isEqualTo("E:\\Actual Path\\Directory");
    assertThat(r.rlocation("protobuf/bar/dir/file")).isEqualTo("E:\\Actual Path\\Directory/file");
    assertThat(r.rlocation("protobuf/bar/dir/de eply/nes  ted/fi+le"))
        .isEqualTo("E:\\Actual Path\\Directory/de eply/nes  ted/fi+le");

    assertThat(r.rlocation("my_module/bar/runfile")).isNull();
    assertThat(r.rlocation("my_protobuf/foo/runfile")).isNull();
    assertThat(r.rlocation("my_protobuf/bar/dir")).isNull();
    assertThat(r.rlocation("my_protobuf/bar/dir/file")).isNull();
    assertThat(r.rlocation("my_protobuf/bar/dir/de eply/nes  ted/fi+le")).isNull();

    assertThat(r.rlocation("_main/bar/runfile"))
        .isEqualTo("/the/path/./to/other//other runfile.txt");
    assertThat(r.rlocation("protobuf+3.19.2/foo/runfile"))
        .isEqualTo("C:/Actual Path\\protobuf\\runfile");
    assertThat(r.rlocation("protobuf+3.19.2/bar/dir")).isEqualTo("E:\\Actual Path\\Directory");
    assertThat(r.rlocation("protobuf+3.19.2/bar/dir/file"))
        .isEqualTo("E:\\Actual Path\\Directory/file");
    assertThat(r.rlocation("protobuf+3.19.2/bar/dir/de eply/nes  ted/fi+le"))
        .isEqualTo("E:\\Actual Path\\Directory/de eply/nes  ted/fi+le");

    assertThat(r.rlocation("config.json")).isEqualTo("/etc/config.json");
    assertThat(r.rlocation("_main")).isNull();
    assertThat(r.rlocation("my_module")).isNull();
    assertThat(r.rlocation("protobuf")).isNull();
  }

  @Test
  public void testDirectoryBasedRlocationWithRepoMapping_fromMain() throws Exception {
    Path dir = tempDir.newFolder("foo.runfiles").toPath();
    Path unused =
        tempFile(
            dir.resolve("_repo_mapping").toString(),
            ImmutableList.of(
                ",config.json,config.json+1.2.3",
                ",my_module,_main",
                ",my_protobuf,protobuf+3.19.2",
                ",my_workspace,_main",
                "protobuf+3.19.2,config.json,config.json+1.2.3",
                "protobuf+3.19.2,protobuf,protobuf+3.19.2"));
    Runfiles r = Runfiles.createDirectoryBasedForTesting(dir.toString()).withSourceRepository("");

    assertThat(r.rlocation("my_module/bar/runfile")).isEqualTo(dir + "/_main/bar/runfile");
    assertThat(r.rlocation("my_workspace/bar/runfile")).isEqualTo(dir + "/_main/bar/runfile");
    assertThat(r.rlocation("my_protobuf/foo/runfile"))
        .isEqualTo(dir + "/protobuf+3.19.2/foo/runfile");
    assertThat(r.rlocation("my_protobuf/bar/dir")).isEqualTo(dir + "/protobuf+3.19.2/bar/dir");
    assertThat(r.rlocation("my_protobuf/bar/dir/file"))
        .isEqualTo(dir + "/protobuf+3.19.2/bar/dir/file");
    assertThat(r.rlocation("my_protobuf/bar/dir/de eply/nes ted/fi+le"))
        .isEqualTo(dir + "/protobuf+3.19.2/bar/dir/de eply/nes ted/fi+le");

    assertThat(r.rlocation("protobuf/foo/runfile")).isEqualTo(dir + "/protobuf/foo/runfile");
    assertThat(r.rlocation("protobuf/bar/dir/dir/de eply/nes ted/fi+le"))
        .isEqualTo(dir + "/protobuf/bar/dir/dir/de eply/nes ted/fi+le");

    assertThat(r.rlocation("_main/bar/runfile")).isEqualTo(dir + "/_main/bar/runfile");
    assertThat(r.rlocation("protobuf+3.19.2/foo/runfile"))
        .isEqualTo(dir + "/protobuf+3.19.2/foo/runfile");
    assertThat(r.rlocation("protobuf+3.19.2/bar/dir")).isEqualTo(dir + "/protobuf+3.19.2/bar/dir");
    assertThat(r.rlocation("protobuf+3.19.2/bar/dir/file"))
        .isEqualTo(dir + "/protobuf+3.19.2/bar/dir/file");
    assertThat(r.rlocation("protobuf+3.19.2/bar/dir/de eply/nes  ted/fi+le"))
        .isEqualTo(dir + "/protobuf+3.19.2/bar/dir/de eply/nes  ted/fi+le");

    assertThat(r.rlocation("config.json")).isEqualTo(dir + "/config.json");
  }

  @Test
  public void testDirectoryBasedRlocationUnmapped() throws Exception {
    Path dir = tempDir.newFolder("foo.runfiles").toPath();
    Path unused =
        tempFile(
            dir.resolve("_repo_mapping").toString(),
            ImmutableList.of(
                ",config.json,config.json+1.2.3",
                ",my_module,_main",
                ",my_protobuf,protobuf+3.19.2",
                ",my_workspace,_main",
                "protobuf+3.19.2,config.json,config.json+1.2.3",
                "protobuf+3.19.2,protobuf,protobuf+3.19.2"));
    Runfiles r = Runfiles.createDirectoryBasedForTesting(dir.toString()).unmapped();

    assertThat(r.rlocation("my_module/bar/runfile")).isEqualTo(dir + "/my_module/bar/runfile");
    assertThat(r.rlocation("my_workspace/bar/runfile"))
        .isEqualTo(dir + "/my_workspace/bar/runfile");
    assertThat(r.rlocation("my_protobuf/foo/runfile")).isEqualTo(dir + "/my_protobuf/foo/runfile");
    assertThat(r.rlocation("my_protobuf/bar/dir")).isEqualTo(dir + "/my_protobuf/bar/dir");
    assertThat(r.rlocation("my_protobuf/bar/dir/file"))
        .isEqualTo(dir + "/my_protobuf/bar/dir/file");
    assertThat(r.rlocation("my_protobuf/bar/dir/de eply/nes ted/fi+le"))
        .isEqualTo(dir + "/my_protobuf/bar/dir/de eply/nes ted/fi+le");

    assertThat(r.rlocation("protobuf/foo/runfile")).isEqualTo(dir + "/protobuf/foo/runfile");
    assertThat(r.rlocation("protobuf/bar/dir/dir/de eply/nes ted/fi+le"))
        .isEqualTo(dir + "/protobuf/bar/dir/dir/de eply/nes ted/fi+le");

    assertThat(r.rlocation("_main/bar/runfile")).isEqualTo(dir + "/_main/bar/runfile");
    assertThat(r.rlocation("protobuf+3.19.2/foo/runfile"))
        .isEqualTo(dir + "/protobuf+3.19.2/foo/runfile");
    assertThat(r.rlocation("protobuf+3.19.2/bar/dir")).isEqualTo(dir + "/protobuf+3.19.2/bar/dir");
    assertThat(r.rlocation("protobuf+3.19.2/bar/dir/file"))
        .isEqualTo(dir + "/protobuf+3.19.2/bar/dir/file");
    assertThat(r.rlocation("protobuf+3.19.2/bar/dir/de eply/nes  ted/fi+le"))
        .isEqualTo(dir + "/protobuf+3.19.2/bar/dir/de eply/nes  ted/fi+le");

    assertThat(r.rlocation("config.json")).isEqualTo(dir + "/config.json");
  }

  @Test
  public void testDirectoryBasedRlocationWithRepoMapping_fromOtherRepo() throws Exception {
    Path dir = tempDir.newFolder("foo.runfiles").toPath();
    Path unused =
        tempFile(
            dir.resolve("_repo_mapping").toString(),
            ImmutableList.of(
                ",config.json,config.json+1.2.3",
                ",my_module,_main",
                ",my_protobuf,protobuf+3.19.2",
                ",my_workspace,_main",
                "protobuf+3.19.2,config.json,config.json+1.2.3",
                "protobuf+3.19.2,protobuf,protobuf+3.19.2"));
    Runfiles r =
        Runfiles.createDirectoryBasedForTesting(dir.toString())
            .withSourceRepository("protobuf+3.19.2");

    assertThat(r.rlocation("protobuf/foo/runfile")).isEqualTo(dir + "/protobuf+3.19.2/foo/runfile");
    assertThat(r.rlocation("protobuf/bar/dir")).isEqualTo(dir + "/protobuf+3.19.2/bar/dir");
    assertThat(r.rlocation("protobuf/bar/dir/file"))
        .isEqualTo(dir + "/protobuf+3.19.2/bar/dir/file");
    assertThat(r.rlocation("protobuf/bar/dir/de eply/nes  ted/fi+le"))
        .isEqualTo(dir + "/protobuf+3.19.2/bar/dir/de eply/nes  ted/fi+le");

    assertThat(r.rlocation("my_module/bar/runfile")).isEqualTo(dir + "/my_module/bar/runfile");
    assertThat(r.rlocation("my_protobuf/bar/dir/de eply/nes  ted/fi+le"))
        .isEqualTo(dir + "/my_protobuf/bar/dir/de eply/nes  ted/fi+le");

    assertThat(r.rlocation("_main/bar/runfile")).isEqualTo(dir + "/_main/bar/runfile");
    assertThat(r.rlocation("protobuf+3.19.2/foo/runfile"))
        .isEqualTo(dir + "/protobuf+3.19.2/foo/runfile");
    assertThat(r.rlocation("protobuf+3.19.2/bar/dir")).isEqualTo(dir + "/protobuf+3.19.2/bar/dir");
    assertThat(r.rlocation("protobuf+3.19.2/bar/dir/file"))
        .isEqualTo(dir + "/protobuf+3.19.2/bar/dir/file");
    assertThat(r.rlocation("protobuf+3.19.2/bar/dir/de eply/nes  ted/fi+le"))
        .isEqualTo(dir + "/protobuf+3.19.2/bar/dir/de eply/nes  ted/fi+le");

    assertThat(r.rlocation("config.json")).isEqualTo(dir + "/config.json");
  }

  @Test
  public void testDirectoryBasedCtorArgumentValidation() throws IOException {
    assertThrows(
        IllegalArgumentException.class,
        () -> Runfiles.createDirectoryBasedForTesting(null).withSourceRepository(""));

    assertThrows(
        IllegalArgumentException.class,
        () -> Runfiles.createDirectoryBasedForTesting("").withSourceRepository(""));

    assertThrows(
        IllegalArgumentException.class,
        () ->
            Runfiles.createDirectoryBasedForTesting("non-existent directory is bad")
                .withSourceRepository(""));

    Runfiles unused =
        Runfiles.createDirectoryBasedForTesting(System.getenv("TEST_TMPDIR"))
            .withSourceRepository("");
  }

  // --- Tests for getCanonicalRepositoryName with prefix mapping ---

  private Runfiles createRunfilesForRepoMappingTest(
      String sourceRepository, Path runfilesRoot, String... repoMappingLines) throws IOException {
    // Helper to create ManifestBased runfiles for testing getCanonicalRepositoryName.
    // The runfilesRoot is used to place the MANIFEST and _repo_mapping file.
    // e.g. runfilesRoot = tempDir.newFolder("mytest.runfiles").toPath();
    Path repoMappingFile =
        tempFile(
            runfilesRoot.resolve("_repo_mapping").toString(), ImmutableList.copyOf(repoMappingLines));
    Path manifestFile =
        tempFile(
            runfilesRoot.resolve("MANIFEST").toString(),
            ImmutableList.of("_repo_mapping " + repoMappingFile.toString().replace('\\', '/')));
    return Runfiles.createManifestBasedForTesting(manifestFile.toString())
        .withSourceRepository(sourceRepository);
  }

  @Test
  public void testGetCanonical_exactMatch() throws Exception {
    Path runfilesRoot = tempDir.newFolder("test_exact_match.runfiles").toPath();
    Runfiles r =
        createRunfilesForRepoMappingTest(
            "source_exact", runfilesRoot, "source_exact,apparent_name,target_exact_A");
    assertThat(r.getCanonicalRepositoryName("apparent_name")).isEqualTo("target_exact_A");
  }

  @Test
  public void testGetCanonical_prefixMatchSimple() throws Exception {
    Path runfilesRoot = tempDir.newFolder("test_prefix_simple.runfiles").toPath();
    Runfiles r =
        createRunfilesForRepoMappingTest(
            "source_prefix_plus_suffix",
            runfilesRoot,
            "source_prefix,apparent_name,target_prefix_B");
    assertThat(r.getCanonicalRepositoryName("apparent_name")).isEqualTo("target_prefix_B");
  }

  @Test
  public void testGetCanonical_longestPrefixWins() throws Exception {
    Path runfilesRoot = tempDir.newFolder("test_longest_prefix.runfiles").toPath();
    Runfiles r =
        createRunfilesForRepoMappingTest(
            "source_longer_prefix_plus_suffix",
            runfilesRoot,
            "source_short_prefix,apparent_name,target_short_C",
            "source_longer_prefix,apparent_name,target_longer_D");
    assertThat(r.getCanonicalRepositoryName("apparent_name")).isEqualTo("target_longer_D");

    // Test with different order in file to ensure sorting by length (and then alphabetically) works
    Path runfilesRoot2 = tempDir.newFolder("test_longest_prefix_order2.runfiles").toPath();
    r =
        createRunfilesForRepoMappingTest(
            "source_longer_prefix_plus_suffix",
            runfilesRoot2,
            "source_longer_prefix,apparent_name,target_longer_D",
            "source_short_prefix,apparent_name,target_short_C");
    assertThat(r.getCanonicalRepositoryName("apparent_name")).isEqualTo("target_longer_D");
  }

  @Test
  public void testGetCanonical_noMatchingPrefix() throws Exception {
    Path runfilesRoot = tempDir.newFolder("test_no_prefix_match.runfiles").toPath();
    Runfiles r =
        createRunfilesForRepoMappingTest(
            "source_unrelated", runfilesRoot, "source_other_prefix,apparent_name,target_E");
    assertThat(r.getCanonicalRepositoryName("apparent_name")).isEqualTo("apparent_name");
  }

  @Test
  public void testGetCanonical_noMatchingApparentName() throws Exception {
    Path runfilesRoot = tempDir.newFolder("test_no_apparent_match.runfiles").toPath();
    Runfiles r =
        createRunfilesForRepoMappingTest(
            "source_prefix_plus_suffix",
            runfilesRoot,
            "source_prefix,apparent_name_X,target_F");
    assertThat(r.getCanonicalRepositoryName("apparent_name_Y")).isEqualTo("apparent_name_Y");
  }

  @Test
  public void testGetCanonical_mainRepositoryAsSource() throws Exception {
    Path runfilesRoot = tempDir.newFolder("test_main_repo_source.runfiles").toPath();
    Runfiles r =
        createRunfilesForRepoMappingTest(
            MAIN_REPO_CANONICAL_NAME, runfilesRoot, ",apparent_name,target_main_G"); // Empty string for source repo
    assertThat(r.getCanonicalRepositoryName("apparent_name")).isEqualTo("target_main_G");
  }

  @Test
  public void testGetCanonical_mainRepositorySourceWithPrefixFallback_mainShouldWin()
      throws Exception {
    Path runfilesRoot = tempDir.newFolder("test_main_with_prefix_fallback.runfiles").toPath();
    Runfiles r =
        createRunfilesForRepoMappingTest(
            MAIN_REPO_CANONICAL_NAME,
            runfilesRoot,
            ",apparent_name,target_main_H", // Main repo entry
            "prefix,apparent_name,target_prefix_I" // Other prefix entry
            );
    assertThat(r.getCanonicalRepositoryName("apparent_name")).isEqualTo("target_main_H");
  }

  @Test
  public void testGetCanonical_prefixMatchWhenSourceIsMain_shouldNotMatchPrefix() throws Exception {
    Path runfilesRoot = tempDir.newFolder("test_prefix_when_main.runfiles").toPath();
    Runfiles r =
        createRunfilesForRepoMappingTest(
            MAIN_REPO_CANONICAL_NAME, runfilesRoot, "some_prefix,apparent_name,target_J");
    assertThat(r.getCanonicalRepositoryName("apparent_name")).isEqualTo("apparent_name");
  }

  @Test
  public void testGetCanonical_emptyRepoMappingFile() throws Exception {
    Path runfilesRoot = tempDir.newFolder("test_empty_repo_mapping.runfiles").toPath();
    Runfiles r =
        createRunfilesForRepoMappingTest("any_source", runfilesRoot /* no mapping lines */);
    assertThat(r.getCanonicalRepositoryName("any_apparent")).isEqualTo("any_apparent");
  }

  @Test
  public void testGetCanonical_repoMappingFileDoesNotExist() throws Exception {
    Path runfilesRoot = tempDir.newFolder("test_no_repo_mapping_file.runfiles").toPath();
    // Create a manifest that refers to a non-existent _repo_mapping file
    Path manifestFile =
        tempFile(
            runfilesRoot.resolve("MANIFEST").toString(),
            ImmutableList.of(
                "_repo_mapping "
                    + runfilesRoot.resolve("non_existent_repo_mapping").toString().replace('\\', '/')));

    Runfiles r =
        Runfiles.createManifestBasedForTesting(manifestFile.toString())
            .withSourceRepository("any_source");
    assertThat(r.getCanonicalRepositoryName("any_apparent")).isEqualTo("any_apparent");
  }

  @Test
  public void testGetCanonical_specificEntryForRepoAndMainRepoMapping() throws Exception {
    Path runfilesRoot = tempDir.newFolder("test_specific_and_main.runfiles").toPath();
    Runfiles rSpecific =
        createRunfilesForRepoMappingTest(
            "my_specific_repo",
            runfilesRoot,
            ",apparent_name_main,target_for_main", // Mapping for main repo
            "my_specific_repo,apparent_name_specific,target_for_specific" // Mapping for specific repo
            );

    assertThat(rSpecific.getCanonicalRepositoryName("apparent_name_specific"))
        .isEqualTo("target_for_specific");
    assertThat(rSpecific.getCanonicalRepositoryName("apparent_name_main")).isEqualTo("apparent_name_main");

    Runfiles rMain =
        createRunfilesForRepoMappingTest(
            MAIN_REPO_CANONICAL_NAME,
            runfilesRoot, // Same mapping file, different source repo context
            ",apparent_name_main,target_for_main",
            "my_specific_repo,apparent_name_specific,target_for_specific");

    assertThat(rMain.getCanonicalRepositoryName("apparent_name_main")).isEqualTo("target_for_main");
    assertThat(rMain.getCanonicalRepositoryName("apparent_name_specific"))
        .isEqualTo("apparent_name_specific");
  }

  @Test
  public void testGetCanonical_prefixMatchDoesNotOverstepParentDirectory() throws Exception {
    Path runfilesRoot = tempDir.newFolder("test_prefix_parent_overstep.runfiles").toPath();
    Runfiles r =
        createRunfilesForRepoMappingTest(
            "foo_bar_baz", // Current repository
            runfilesRoot,
            "foo,apparent,target_foo",
            "foo_bar,apparent,target_foo_bar" // Longer prefix
            );
    assertThat(r.getCanonicalRepositoryName("apparent")).isEqualTo("target_foo_bar");
  }

  @Test
  public void testGetCanonical_tieBreakByAlphabeticalOrder() throws Exception {
    Path runfilesRoot = tempDir.newFolder("test_tie_break_alpha.runfiles").toPath();
    // Two prefixes of the same length "repo_a" and "repo_b" for "repo_a_suffix"
    // "repo_a" should win due to alphabetical sorting as a secondary criterion.
    Runfiles r =
        createRunfilesForRepoMappingTest(
            "repo_a_suffix",
            runfilesRoot,
            "repo_b,apparent,target_repo_b", // Same length as repo_a
            "repo_a,apparent,target_repo_a"  // Same length as repo_b
            );
    // The sorting is: longest first, then alphabetical.
    // Here, lengths are equal, so "repo_a" comes before "repo_b".
    // When matching "repo_a_suffix", "repo_a" is a prefix. "repo_b" is not.
    // This test actually tests prefix matching more than tie-breaking for identical prefixes.
    // Let's refine to test actual tie-breaking for identical length prefixes if both match.
    // The current implementation picks the *first* matching prefix after sorting.
    // If sourceRepoCanonicalName are "aa" and "ab", and sourceRepository is "aax", "aa" matches.
    // If sourceRepository is "abx", "ab" matches.
    // The sorting ensures that if we had "a" and "aa", "aa" comes first.
    // This specific test as written will have "repo_a" as a match and "repo_b" not.
    assertThat(r.getCanonicalRepositoryName("apparent")).isEqualTo("target_repo_a");

    // A better test for tie-breaking: two prefixes of same length, both are prefixes.
    // This shouldn't happen with current logic as sourceRepoCanonicalName is unique per entry.
    // The sorting is by length (desc) then name (asc).
    // The lookup iterates and takes the first `sourceRepository.startsWith(entry.sourceRepoCanonicalName)`.
    // So, if we have "repo_a" and "repo_c" (same length) in mapping, and source is "repo_a_x",
    // "repo_a" will be checked first (due to alphabetical sort on name for tie-break on length) and match.
    Path runfilesRoot2 = tempDir.newFolder("test_tie_break_alpha2.runfiles").toPath();
     r = createRunfilesForRepoMappingTest(
            "common_prefix_specific", // current repo
            runfilesRoot2,
            // two entries with source "common_prefix", but different apparent names
            // This is not what the tie-breaking refers to.
            // Tie-breaking is for multiple mapping entries whose sourceRepoCanonicalName
            // are of the same length AND are prefixes of the current sourceRepository.
            // Example: repo_mapping has "foo_a,app,target_A" and "foo_b,app,target_B".
            // If current source is "foo_a_bar", "foo_a" matches.
            // The sorting `sourceRepoCanonicalName.compareTo` makes this deterministic if lengths are equal.
            "common_prefix,apparent1,target_common_1",
            "common_prefix,apparent2,target_common_2"
            // If we are in "common_prefix", these are exact matches, not prefix length tie-breaks.
            );
     assertThat(r.getCanonicalRepositoryName("apparent1")).isEqualTo("target_common_1");
     assertThat(r.getCanonicalRepositoryName("apparent2")).isEqualTo("target_common_2");
  }


  // --- End of tests for getCanonicalRepositoryName ---

  @Test
  public void testManifestBasedCtorArgumentValidation() throws Exception {
    assertThrows(
        IllegalArgumentException.class,
        () -> Runfiles.createManifestBasedForTesting(null).withSourceRepository(""));

    assertThrows(
        IllegalArgumentException.class,
        () -> Runfiles.createManifestBasedForTesting("").withSourceRepository(""));

    Path mf = tempFile("foobar", ImmutableList.of("a b"));
    Runfiles unused = Runfiles.createManifestBasedForTesting(mf.toString()).withSourceRepository("");
  }

  @Test
  public void testInvalidRepoMapping() throws Exception {
    Path rm = tempFile("foo.repo_mapping", ImmutableList.of("a,b,c,d"));
    Path runfilesDir = tempDir.newFolder("invalid_mapping_test.runfiles").toPath();
    Path mf =
        tempFile(
            runfilesDir.resolve("MANIFEST").toString(),
            ImmutableList.of("_repo_mapping " + rm.toString().replace('\\', '/')));
    IllegalArgumentException e =
        assertThrows(
            IllegalArgumentException.class,
            () -> Runfiles.createManifestBasedForTesting(mf.toString()).withSourceRepository(""));
    assertThat(e).hasMessageThat().contains("Invalid line in repository mapping: 'a,b,c,d'");
  }

  // Integration test for rlocation with prefix mapping
  @Test
  public void testRlocationWithPrefixMapping() throws Exception {
    Path runfilesRoot = tempDir.newFolder("rlocation_prefix_test.runfiles").toPath();
    String sourceRepoForTest = "my_repo_prefix_foo"; // Current repo context
    String apparentRepoName = "data_repo"; // Apparent name used in rlocation call
    String targetCanonicalRepoName = "actual_data_repo_v1"; // What apparent maps to for my_repo_prefix
    String filePathInRepo = "data/file.txt";
    String rlocationArg = apparentRepoName + "/" + filePathInRepo;
    String actualDiskPath = "/abs/path/to/" + targetCanonicalRepoName + "/" + filePathInRepo;

    // 1. Create _repo_mapping file
    Path repoMappingFile =
        tempFile(
            runfilesRoot.resolve("_repo_mapping").toString(),
            ImmutableList.of(
                "my_repo_prefix," + apparentRepoName + "," + targetCanonicalRepoName,
                "other_prefix,other_apparent,other_target" // Another entry
                ));

    // 2. Create MANIFEST file
    // It needs to map _repo_mapping itself, and the final path after canonicalization.
    Path manifestFile =
        tempFile(
            runfilesRoot.resolve("MANIFEST").toString(),
            ImmutableList.of(
                "_repo_mapping " + repoMappingFile.toString().replace('\\', '/'),
                targetCanonicalRepoName + "/" + filePathInRepo + " " + actualDiskPath));

    // 3. Create Runfiles instance
    Runfiles r =
        Runfiles.createManifestBasedForTesting(manifestFile.toString())
            .withSourceRepository(sourceRepoForTest);

    // 4. Test rlocation
    // rlocation(data_repo/data/file.txt) should become rlocation(actual_data_repo_v1/data/file.txt)
    // which then resolves to /abs/path/to/actual_data_repo_v1/data/file.txt
    assertThat(r.rlocation(rlocationArg)).isEqualTo(actualDiskPath);
  }

  private Path tempFile(String path, ImmutableList<String> lines) throws IOException {
    Path file = tempDir.getRoot().toPath().resolve(path.replace('/', File.separatorChar));
    Files.createDirectories(file.getParent());
    return Files.write(file, lines, StandardCharsets.UTF_8);
  }
}
