unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    PaintBox1: TPaintBox;
    procedure FormCreate(Sender: TObject);
  private
    procedure OnIdle(Sender: TObject; var Done: boolean);
  public

  end;

var
  Form1: TForm1;
  CurrentTime: LongInt;
  StartTime, ElapsedTime: Cardinal;
  FBuffer:TBitmap;

implementation

{$R *.lfm}

{ TForm1 }
procedure TForm1.OnIdle(Sender: TObject; var Done: boolean);
var
  Origin: TPoint = (X:50; y:30);
  P1: TPoint = (X: 190; y:30);
  P2: TPoint = (X: 100; y:90);
begin
  ElapsedTime := GetTickCount64 - StartTime;
  Done := False;
  CurrentTime := GetTickCount;

  //Form1.Invalidate;
  Form1.Canvas.Brush.Color := clDefault;
  //Form1.Canvas.FillRect(Form1.ClientRect);
  Form1.Canvas.FillRect(0,0,100,40);
  //Form1.Canvas.Clear;
  //Form1.Refresh;
  Form1.Canvas.TextOut(0,0,CurrentTime.ToString);
  Form1.Canvas.TextOut(0,20,ElapsedTime.ToString);
  //Application.OnIdle := nil;

  FBuffer.Canvas.Clear;
  FBuffer.Canvas.TextOut(0,0,CurrentTime.ToString);
  FBuffer.Canvas.TextOut(0,20,ElapsedTime.ToString);
  FBuffer.Canvas.Pen.Width:=3;
  FBuffer.Canvas.Pen.Color:=clBlue;
  FBuffer.Canvas.MoveTo(Origin);
  FBuffer.Canvas.LineTo(P1);
  FBuffer.Canvas.LineTo(P2);
  FBuffer.Canvas.LineTo(Origin);
  PaintBox1.Canvas.Draw(0, 0, FBuffer);

  StartTime := GetTickCount64;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FBuffer := TBitmap.Create;
  FBuffer.SetSize(PaintBox1.Width, PaintBox1.Height);
  //FBuffer.Canvas.Brush.Color := clSilver;
  FBuffer.Canvas.Brush.Color := $00C8D0D4;
  FBuffer.Canvas.FillRect(0, 0, FBuffer.Width, FBuffer.Height);

  Application.OnIdle := @OnIdle;
end;

end.

