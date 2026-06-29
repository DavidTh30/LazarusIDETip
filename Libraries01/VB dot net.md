'A simple VB.NET app

'Copy and save this VB.NET code to file TestLib.vb: 

Imports System
Imports System.Runtime.InteropServices

Public Class TestLib

  Const SimpLibName = "simplelib.dll"

   'Declare external functions using the DllImport attribute.
  <DllImport(SimpLibName, EntryPoint:="MySucc", _
             CallingConvention:=CallingConvention.StdCall)> _
             Public Shared Function Succ(ByVal AVal As Long) As Long
    End Function

  <DllImport(SimpLibName, EntryPoint:="MyPred", _
             CallingConvention:=CallingConvention.StdCall)> _
             Public Shared Function Pred(ByVal AVal As Long) As Long
    End Function

  Public Shared Sub Main()
  
    Dim TestVal As Long

    Try
      TestVal = 123
      Console.WriteLine("Value is " & TestVal)
      Console.WriteLine("Successor is " & Succ(TestVal))
      Console.WriteLine("Predecessor is " & Pred(TestVal))
    Catch e As Exception
      Console.WriteLine(e)
    End Try

  End Sub  'Main

End Class  'TestLib