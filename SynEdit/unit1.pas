unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, SynEdit, SynEditMiscClasses;

type

  { TForm1 }

  TForm1 = class(TForm)
    SynEdit1: TSynEdit;
    procedure FormCreate(Sender: TObject);
  private

  public
    procedure LogLineColor(Sender: TObject; Line: integer; var Special: boolean; Markup: TSynSelectedColor);
  end;

var
  Form1: TForm1;
  FFGCol: TColor;

implementation

{$R *.lfm}

{ TForm1 }
function Mix(CA, CB: TColor; Ratio: Byte): TColor;
var
  R, G, B: Byte;
  Ratio_: Byte;
begin
  CA := ColorToRGB(CA);
  CB := ColorToRGB(CB);
  Ratio_ := 100 - Ratio;
  R := (Ratio_ * Red(CA)   + Ratio * Red(CB)) div 100;
  G := (Ratio_ * Green(CA) + Ratio * Green(CB)) div 100;
  B := (Ratio_ * Blue(CA)  + Ratio * Blue(CB)) div 100;
  Result := RGBToColor(R, G, B);
end;

procedure TForm1.LogLineColor(Sender: TObject; Line: integer; var Special: boolean; Markup: TSynSelectedColor);
var
  S: String;
begin
  S := SynEdit1.Lines[Line - 1];
  if Pos('[Server]', S) = 1 then begin
    Special := True;
    Markup.Foreground := FFGCol;
    Markup.Background := clNone;
  end;
  if Pos('[Client]', S) = 1 then begin
    Special := True;
    Markup.Foreground := $000000;
    Markup.Background := clNone;
  end;
  if Pos('[Alarm]', S) = 1 then begin
    Special := True;
    Markup.Foreground := $FF;
    Markup.Background := clNone;
  end;
  if Pos('[Warning]', S) = 1 then begin
    Special := True;
    Markup.Foreground := $FFFF;
    Markup.Background := clNone;
  end;
  if Pos('[Succeed] ', S) = 1 then begin
    Special := True;
    Markup.Foreground := $A000;
    Markup.Background := clNone;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FFGCol := Mix(SynEdit1.Color, SynEdit1.Font.Color, 40);
  SynEdit1.OnSpecialLineMarkup := @LogLineColor;
end;

end.

