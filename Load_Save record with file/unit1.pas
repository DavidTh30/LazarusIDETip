unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, uPSComponent,
  uPSCompiler, uPSRuntime, uPSComponent_DB, uPSComponent_Default, uPSComponent_StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private

  public
    procedure ExecuteDynamicScript(ScriptCode: String);
  end;

type
  TMyData = record
    Age: Integer;
    Score: Double;
    vector: array [0..25] of extended;
  end;

var
  Form1: TForm1;
  DataFile: file of TMyData;
  MyVar: TMyData;

implementation

{$R *.lfm}

{ TForm1 }

//https://wiki.freepascal.org/Pascal_Script_Examples
procedure TForm1.ExecuteDynamicScript(ScriptCode: String);
var
  Compiler: TPSPascalCompiler;
  Exec: TPSExec;
  ByteCode: string;
begin
  Compiler := TPSPascalCompiler.Create;
  Exec := TPSExec.Create;

  // 1. Register standard system functions
  // RIRegister_std(Compiler); // Register standard library

  // 2. Compile the dynamic code
  if Compiler.Compile(ScriptCode) then
  begin
    //ByteCode := Compiler.GetByteCode;
    Exec.LoadData(ScriptCode); //Exec.Data := Compiler.GetCompiledData;
    Exec.RunScript; //Exec.Run; // Executes the new code at runtime
  end
  else
    ShowMessage(Compiler.Msg[0].MessageToString);   //Compiler.GetErrorMessages   Compiler.CompilerMessages[0].Message

  Exec.Free;
  Compiler.Free;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  // Save variable
  AssignFile(DataFile, 'data.dat');
  Rewrite(DataFile);
  MyVar.Age := 25;
  MyVar.Score := 95.5;
  MyVar.vector[0]:=1.1;
  MyVar.vector[1]:=2.12;
  MyVar.vector[3]:=4.132;
  Write(DataFile, MyVar);
  CloseFile(DataFile);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  // Load variable
  if not FileExists('data.dat') then begin showmessage('File data.dat not Exists'); exit end;
  AssignFile(DataFile, 'data.dat');
  Reset(DataFile);
  Read(DataFile, MyVar);
  CloseFile(DataFile);
  showmessage(MyVar.vector[3].ToString);
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  MyString: string;
  Stream: TMemoryStream;

begin
  MyString := 'Hello Pascal';
  Stream := TMemoryStream.Create;

  try
    // Save variable (length + string data)
    Stream.Write(MyString[1], Length(MyString) * SizeOf(Char));
    Stream.SaveToFile('mystring.bin');
  finally
    Stream.Free;
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  ExecuteDynamicScript('var i:integer; begin  end.');
end;

end.

