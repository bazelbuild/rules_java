import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.beans.Transient;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.Path;

import mypackage.MyLib;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import com.google.devtools.build.runfiles.AutoBazelRepository;
import com.google.devtools.build.runfiles.Runfiles;

@RunWith(JUnit4.class)
@AutoBazelRepository
public class MyTest {
  @Test
  public void main() {
    assertEquals(MyLib.myStr(), "my_string");
  }

  @Transient
  public void runfiles() throws IOException {
    Runfiles runfiles = Runfiles.preload().withSourceRepository(AutoBazelRepository_MyTest.NAME);
    Path path = Paths.get(runfiles.rlocation("integration_test_repo/src/data.txt"));
    assertTrue(Files.exists(path));
  }
}

