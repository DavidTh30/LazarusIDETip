unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, BGRAVirtualScreen,
  BGRABitmap, BCTypes, BGRABitmapTypes;

type

  { TForm1 }

  TForm1 = class(TForm)
    BGRAVirtualScreen1: TBGRAVirtualScreen;
    BGRAVirtualScreen2: TBGRAVirtualScreen;
    BGRAVirtualScreen3: TBGRAVirtualScreen;
    procedure BGRAVirtualScreen1Redraw(Sender: TObject; Bitmap: TBGRABitmap);
    procedure BGRAVirtualScreen2MouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure BGRAVirtualScreen2MouseLeave(Sender: TObject);
    procedure BGRAVirtualScreen2MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure BGRAVirtualScreen2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BGRAVirtualScreen2Redraw(Sender: TObject; Bitmap: TBGRABitmap);
    procedure BGRAVirtualScreen3Redraw(Sender: TObject; Bitmap: TBGRABitmap);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  Points: array of TPointF;
  Virtual2MouseDown:boolean;
  Virtual2OldX:integer;
  Virtual2OldY:integer;
  VirtualIndex:integer;
  image_: TBGRABitmap;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.BGRAVirtualScreen1Redraw(Sender: TObject; Bitmap: TBGRABitmap);
begin
  // Example: Fill background with white
  Bitmap.Fill(BGRAWhite);

  // Example: Draw an anti-aliased red circle
  Bitmap.FillEllipseAntialias(100, 100, 50, 50, BGRA(255, 0, 0, 255)); //clTransparent

  // Example: Draw some text
  Bitmap.TextOut(10, 10, 'Hello BGRA!', BGRA(0, 0, 0, 255));

  Bitmap.FillPolyAntialias([PointF(0, 0), PointF(100, 0), PointF(100, 100)], BGRAWhite);
end;

procedure TForm1.BGRAVirtualScreen2MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i:integer;
  r:integer;
begin
  r:=5;
  Virtual2MouseDown:=false;
  VirtualIndex:=-1;

  for i := 0 to high(Points) do
  begin
    if ((X>=Points[i].X) and (X<=Points[i].X+r)) or ((X<=Points[i].X) and (X>=Points[i].X-r)) then
    begin
      if ((Y>=Points[i].Y) and (Y<=Points[i].Y+r)) or ((Y<=Points[i].Y) and (Y>=Points[i].Y-r)) then
      begin
        Virtual2MouseDown:=true;
        Virtual2OldX:=X;
        Virtual2OldY:=Y;
        VirtualIndex:=i;
      end
      else
      begin

      end;
    end
    else
    begin

    end;
  end;
end;

procedure TForm1.BGRAVirtualScreen2MouseLeave(Sender: TObject);
begin
  Screen.Cursor := crDefault;
end;

procedure TForm1.BGRAVirtualScreen2MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  i:integer;
  r:integer;
  MouseActive:boolean;
begin
  r:=5;
  MouseActive:=false;

  if (Virtual2MouseDown and (VirtualIndex>=0)) then
  begin
    if ((X <> Virtual2OldX) or (Y <> Virtual2OldY)) then
    begin
      Points[VirtualIndex].X:= Points[VirtualIndex].X+(X-Virtual2OldX);
      Virtual2OldX:=X;
      Points[VirtualIndex].Y:= Points[VirtualIndex].Y+(Y-Virtual2OldY);
      Virtual2OldY:=Y;
      MouseActive:=true;
    end;
  end;

  if (MouseActive) then BGRAVirtualScreen2.RedrawBitmap;

  MouseActive:=false;
  for i := 0 to high(Points) do
  begin
    if ((X>=Points[i].X) and (X<=Points[i].X+r)) or ((X<=Points[i].X) and (X>=Points[i].X-r)) then
    begin
      if ((Y>=Points[i].Y) and (Y<=Points[i].Y+r)) or ((Y<=Points[i].Y) and (Y>=Points[i].Y-r)) then
      begin
        MouseActive:=true;
      end
      else
      begin

      end;
    end
    else
    begin

    end;
  end;

  if ((MouseActive) and (Screen.Cursor = crDefault)) then Screen.Cursor := crSizeAll;
  if ((Not MouseActive) and (Screen.Cursor = crSizeAll)) then Screen.Cursor := crDefault;
end;

procedure TForm1.BGRAVirtualScreen2MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Virtual2MouseDown:=false;
  Virtual2OldX:=0;
  Virtual2OldY:=0;
  //VirtualIndex:=-1;
end;

procedure TForm1.BGRAVirtualScreen2Redraw(Sender: TObject; Bitmap: TBGRABitmap);
var
   Mask, BlurTemp: TBGRABitmap;
   //image: TBGRABitmap;
   //Bitmap: TBGRABitmap;
   i:integer;
begin
  //image := TBGRABitmap.Create('p.jpg');
  //Bitmap := TBGRABitmap.Create(clientwidth, clientheight, BGRAWhite);
  BlurTemp := image_.Resample(Bitmap.Width, Bitmap.Height) as TBGRABitmap;

  Bitmap.PutImage(0, 0, BlurTemp, dmDrawWithTransparency);
  Mask := TBGRABitmap.Create(Bitmap.Width, Bitmap.Height, BGRABlack);
  Mask.FillPolyAntialias(Mask.ComputeOpenedSpline(Points, ssOutside), BGRAWhite);

  BlurTemp.ApplyMask(Mask);
  Mask.Free;

  BlurTemp := BlurTemp.FilterBlurRadial(5, rbfast) as TBGRABitmap;

  Bitmap.PutImage(0, 0, BlurTemp, dmDrawWithTransparency);

  Bitmap.DrawPolyLineAntialias(Bitmap.ComputeOpenedSpline(Points, ssOutside), BGRAWhite, 2);

  for i := 0 to high(Points) do
    Bitmap.FillEllipseAntialias(Points[i].x, Points[i].y, 5, 5, BGRABlack);

  if (VirtualIndex>=0) then
  begin
    Bitmap.TextOut(Points[VirtualIndex].x-10, Points[VirtualIndex].y-5, Points[VirtualIndex].x.ToString + ',' + Points[VirtualIndex].y.ToString , BGRA(255, 255, 255, 255));
  end;

  BlurTemp.Free;
  //Bitmap.draw(Canvas, 0, 0);
  //Bitmap.Free;
end;

procedure TForm1.BGRAVirtualScreen3Redraw(Sender: TObject; Bitmap: TBGRABitmap);
var
  Mask, BlurTemp: TBGRABitmap;
  //image: TBGRABitmap;
  //Bitmap: TBGRABitmap;
begin
  //image := TBGRABitmap.Create('p.jpg');
  //Bitmap := TBGRABitmap.Create(clientwidth, clientheight, BGRAWhite);
  BlurTemp := image_.Resample(Bitmap.Width, Bitmap.Height) as TBGRABitmap;

  Bitmap.PutImage(0, 0, BlurTemp, dmDrawWithTransparency);
  Mask := TBGRABitmap.Create(Bitmap.Width, Bitmap.Height, BGRABlack);
  Mask.FillPolyAntialias(Mask.ComputeOpenedSpline(Points, ssOutside), BGRAWhite);

  BlurTemp.ApplyMask(Mask);
  Mask.Free;
  BlurTemp := BlurTemp.FilterBlurRadial(5, rbfast) as TBGRABitmap;
  Bitmap.PutImage(0, 0, BlurTemp, dmDrawWithTransparency);

  Bitmap.DrawPolyLineAntialias(Bitmap.ComputeOpenedSpline(Points, ssOutside),
    BGRAWhite, 2);
  BlurTemp.Free;
  //Bitmap.draw(Canvas, 0, 0);
  //Bitmap.Free;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  image_.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Virtual2MouseDown:=false;
  Virtual2OldX:=0;
  Virtual2OldY:=0;
  VirtualIndex:=-1;
  setlength(Points, 10);
  //Points[0] := PointF(20, round(clientheight / 6));
  //Points[1] := Points[0] + pointF(50, 75);
  //Points[2] := Points[1] + pointF(50, 50);
  //Points[3] := Points[2] + pointF(50, -30);
  //Points[4] := Points[3] + pointF(50, -50);
  //Points[5] := Points[4] + pointF(50, 10);
  //Points[6] := PointF(round(ClientWidth/2), round(clientheight / 6));
  //Points[7] := PointF(round(ClientWidth/2), round(clientheight/4));
  //Points[8] := PointF(10, round(clientheight/3));
  //Points[9] := PointF(10, round(clientheight / 6));

  Points[0] := PointF(164,142);
  Points[1] := PointF(173,106);
  Points[2] := PointF(193,72);
  Points[3] := PointF(213,45);
  Points[4] := PointF(316,47);
  Points[5] := PointF(375,71);
  Points[6] := PointF(392,98);
  Points[7] := PointF(384,150);
  Points[8] := PointF(256,208);
  Points[9] := PointF(177,169);

  image_ := TBGRABitmap.Create('p.jpg');
end;

end.

