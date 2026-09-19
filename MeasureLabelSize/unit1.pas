unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, types;

type

  { TForm1 }

  TForm1 = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure Edit1EditingDone(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Edit1EditingDone(Sender: TObject);
var
  W : integer;
  H : integer;
  aSize :TSize;
begin
  Label1.Caption:=Edit1.Text;
  W := Label1.Canvas.TextWidth(Label1.Caption);
  H := Label1.Canvas.TextHeight(Label1.Caption);
  Label2.Caption:='W := '+W.ToString;
  Label3.Caption:='H := '+H.ToString;
  aSize := Canvas.TextExtent('Your Text');
  Clientwidth := aSize.cx;
end;

end.

