unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Edit1Enter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  //SetCaretBlinkTime(200);
end;

procedure TForm1.Edit1Enter(Sender: TObject);
begin
  //Edit1.Cursor:=crArrow;
  //inherited; // Process standard focus first
  HideCaret(Edit1.Handle);
  //ShowCaret(Edit1.Handle);

end;

procedure TForm1.Button1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to Pred(ControlCount) do
    Controls[I].Cursor := crNone; // crDefault would show it again
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  I: Integer;
begin
for I := 0 to Application.ComponentCount - 1 do
    if Application.Components[I] is TForm then
      with Application.Components[I] as TForm do
        Cursor := crNone;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if Self.Showing then halt;

end;


end.

