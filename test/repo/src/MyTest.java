import static org.junit.Assert.assertEquals;

import mypackage.MyLib;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

@RunWith(JUnit4.class)
public class MyTest {
  @Test
  public void main() {
    assertEquals(MyLib.myStr(), "my_string");
  }
}

