#include "stdio.h"

int main(int argc, char *argv[]) {
  int input;

  while (scanf("%d", &input) > 0) {
    printf("%d\n", input * input);
  }
}
