'Mono tips

using System;
using System.Windows.Forms;

public class MyForm: Form
{
  public MyForm ()
  {
    this.Text = "A .NET/Mono Windows Forms App";
    this.Width = 400;

    Button b = new Button();
    b.Left = 15;
    b.Top = 20;
    b.Width = this.Width-30;
    b.Height = 30;
    b.Text = "Click Me";
    b.Click += new EventHandler(button_Click);
    this.Controls.Add(b);
  }
  void button_Click(object sender, EventArgs e)
  {
    MessageBox.Show("Hello");
  }
}

public class MyApp
{
  public static void Main()
  {
    MyForm aForm = new MyForm();
    Application.Run(aForm);
  }
}