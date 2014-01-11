package javax.swing;

import java.util.Scanner;
import java.awt.Component;

/**
 * This is a fake JOptionPane class. It overrides the two most commonly-used
 * JOptionPane-based functions for IO (#showInputDialog and #showMessageDialog)
 * and has them simply use System.in and System.out.
 *
 * @author Ulysse Carion
 */
public class JOptionPane {
  private static Scanner scanner;

  static {
    scanner = new Scanner(System.in);
  }

  public static String showInputDialog(Object message) {
    if (!scanner.hasNextLine()) {
      return null;
    }

    return scanner.nextLine();
  }

  public static void showMessageDialog(Component parentComponent, Object message) {
    System.out.println(message);
  }
}
