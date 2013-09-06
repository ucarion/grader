import java.util.Scanner;

public class JavaExample {
  public static void main(String[] args) {
    Scanner in = new Scanner(System.in);

    while (in.hasNextInt()) {
      int i = in.nextInt();

      System.out.println(i * i);
    }
  }
}
