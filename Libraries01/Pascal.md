//A simple Pascal app using Oxygene

//Copy and save this Pascal code to file TestLib.pas:

namespace TestLib;

interface

uses
  System.Runtime.InteropServices;
  
const
  SimpleLibName = 'simplelib.dll';

type
  TestLib = class
  private
    [DllImportAttribute(SimpleLibName, EntryPoint:='MySucc',
                        CallingConvention:=CallingConvention.StdCall)]
    class method Succ(AVal : Int64) : Int64; external;  

    [DllImportAttribute(SimpleLibName, EntryPoint:='MyPred',
                        CallingConvention:=CallingConvention.StdCall)]
    class method Pred(AVal : Int64) : Int64; external;  
  public
    class method Main;
  end;
    
implementation

class method TestLib.Main;
var
  TestVal : Int64;
begin
  try
    TestVal := 123;
    Console.WriteLine('Value is ' + TestVal);
    Console.WriteLine('Successor is ' + Succ(TestVal));
    Console.WriteLine('Predecessor is ' + Pred(TestVal));
  except
    on E: Exception do
      Console.WriteLine(E.Message);
  end;
end;

end.
