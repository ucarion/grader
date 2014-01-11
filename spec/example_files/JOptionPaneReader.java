import javax.swing.JOptionPane;

public class JOptionPaneReader {
  public static void main(String[] args) {
    String input = JOptionPane.showInputDialog("Give me input!");
    JOptionPane.showMessageDialog(null, input);
  }
}
