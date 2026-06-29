'A simple C# app

'Here's the equivalent C# code. Copy and save it to file TestLib.cs.

using System;
using System.Runtime.InteropServices;

public class TestLib {
  
  const string SimpLibName = "simplelib.dll";

   //Declare external functions using the DllImport attribute.
  [DllImport(SimpLibName, EntryPoint="MySucc",
             CallingConvention=CallingConvention.StdCall)]
             public static extern long Succ(long AVal);

  [DllImport(SimpLibName, EntryPoint="MyPred", 
             CallingConvention=CallingConvention.StdCall)] 
             public static extern long Pred(long AVal);

  public static void Main()
  {
    long TestVal;

    try
    {
      TestVal = 123;
      Console.WriteLine("Value is " + TestVal);
      Console.WriteLine("Successor is " + Succ(TestVal));
      Console.WriteLine("Predecessor is " + Pred(TestVal));
    }
    catch(Exception e)
    {
      Console.WriteLine(e);
    }
  }
}
