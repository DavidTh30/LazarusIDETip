library SimpleLib;

{$mode objfpc}{$H+}

function MySucc(AVal : Int64) : Int64; stdcall;
begin
  Result := System.Succ(AVal);
end;

function MyPred(AVal : Int64) : Int64; stdcall;
begin
  Result := System.Pred(AVal);
end;

exports
  MySucc,
  MyPred;

end.
//Now compile the library with Free Pascal:
//fpc -Sd SimpleLib.pas

//Windows, this will create file simplelib.dll. On macOS, this will create file libsimplelib.dylib.
//On Linux, this will create file simplelib.so. On macOS and Linux, rename the compiled library file to simplelib.dll:
//mv libsimplelib.dylib simplelib.dll


