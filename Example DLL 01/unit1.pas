unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

procedure zum; stdcall; external 'project1.dll' name 'test';
procedure zum2(AMessage: PChar); stdcall; external 'project1.dll' name 'ShowDllMessage';
function MiFuncion(x_: double; y_: PChar): PChar; external 'project1.dll';
function MiFuncion2(x_: double; y_: ansistring): ansistring; external 'project1.dll';
function AddNumbers(a, b: Integer): Integer; {$ifdef win32} Stdcall;{$endif}  external 'project1.dll';
var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  s:string;
  s2:PChar;
begin
  zum;
  zum2('Jorge');
  s2:='ff';
  s:=MiFuncion(23.54, s2);
  showmessage(s);
  showmessage(MiFuncion2(23.54, 'hjk'));
  showmessage(AddNumbers(100,23).ToString);
end;

end.

