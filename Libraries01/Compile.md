compile the library with Free Pascal:
fpc -Sd SimpleLib.pas

compile oxygene app:
[pathto]oxygene TestLib.pas

compile VB.NET app:
[pathto]vbc TestLib.vb

compile VB.NET via Mono app:
vbnc TestLib.vb

C# .NET compile it as follows:
[pathto]csc TestLib.cs

compile C# .NET via Mono app:
mcs TestLib.cs

Value is 123
Successor is 124
Predecessor is 122


Compile this code on Mono as follows:
mcs -r:System.Windows.Forms MyForm.cs
Run the app as follows:
mono MyForm.exe
On macOS, you can also create a normal app bundle using the macpack utility:
macpack -n MyForm -m winforms MyForm.exe
