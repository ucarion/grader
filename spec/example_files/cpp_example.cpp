#include <iostream>

int main() {
  int input;

  while ((std::cin >> input) > 0) {
    std::cout << input * input << "\n";
  }
}
