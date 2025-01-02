#include <iostream>

int my_number();

int main() {
  int actual = my_number();
  if (actual != 42) {
    std::cerr << "Expected my_number() to return 42, got " << actual << std::endl;
    return 1;
  }
  return 0;
}
