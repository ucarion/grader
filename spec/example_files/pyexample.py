import sys

stdin = sys.stdin.read()
for num in stdin.split():
  print int(num) ** 2
