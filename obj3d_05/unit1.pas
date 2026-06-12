unit Unit1;

{$mode objfpc}{$H+}

// Use TOpenGLControl by enabling the define below:
{$define UseOpenGL}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls
  {$ifdef UseOpenGL}, OpenGLContext{$endif};

type

  { TForm1 }

  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    {$ifdef UseOpenGL}
    OpenGLCtrl: TOpenGLControl;
    {$endif}
    procedure DrawPyramid(rotX, rotY, rotZ: integer);
  public

  end;

var
  Form1: TForm1;

implementation

uses
  BGRAScene3D, BGRABitmap, BGRABitmapTypes {$ifdef UseOpenGL}, BGRAOpenGL{$endif};

{$R *.lfm}

{ TForm1 }
var
  scene: TBGRAScene3D;
  obj3D: IBGRAObject3D;
  bmp: {$ifdef UseOpenGL}TBGLBitmap {$else}TBGRABitmap{$endif};

procedure TForm1.FormShow(Sender: TObject);
begin
  {$ifdef UseOpenGL}
  bmp := TBGLBitmap.Create(OpenGLCtrl.Width, OpenGLCtrl.Height, BGRABlack);
  self.Caption := 'TBGLBitmap/TOpenGLControl test';
  {$else}
  bmp := TBGRABitmap.Create(ClientWidth, ClientHeight, BGRABlack);
  self.Caption := 'TBGRABitmap/TCanvas test';
  {$endif}
  scene := TBGRAScene3D.Create(bmp);
  Timer1.Enabled := true;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Timer1.Enabled := false;
  if Assigned(scene) then
    FreeAndNil(scene);
  if Assigned(obj3D) then
    FreeAndNil(obj3D);
  if Assigned(bmp) then
    FreeAndNil(bmp);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  {$ifdef UseOpenGL}
  OpenGLCtrl := TOpenGLControl.Create(self);
  OpenGLCtrl.Parent := self;
  OpenGLCtrl.Top := 0;
  OpenGLCtrl.Left := 0;
  OpenGLCtrl.Align := alClient;
  OpenGLCtrl.AutoResizeViewport := true;
  {$endif}
end;

procedure TForm1.Timer1Timer(Sender: TObject);
const
  x: integer = 0;
  y: integer = 0;
  z: Integer = 0;
var
  start: Qword;
begin
  Timer1.Enabled := false;

  // Update display with previous values
  StatusBar1.Panels[3].Text := IntToStr(x) + 'º';
  StatusBar1.Panels[5].Text := IntToStr(y) + 'º';
  StatusBar1.Panels[7].Text := IntToStr(z) + 'º';

  start := GetTickCount64;
  DrawPyramid(x, y, z);
  StatusBar1.Panels[1].Text := IntToStr(GetTickCount64-start)+' ms';
  // Else there may not be enough time to process the form's paint message
  Application.ProcessMessages;

  // Simulate some motion
  inc(x, 3);
  if x > 360 then
    x := x - 360;

  inc(y, 5);
  if y > 360 then
    y := y - 360;

  inc(z, 7);
  if z > 360 then
    z := z - 360;

  Timer1.Enabled := true;
end;

procedure TForm1.DrawPyramid(rotX, rotY, rotZ: integer);
var
  base: array of IBGRAVertex3D;
  topV: IBGRAVertex3D;
begin
  // Delete previous image
  bmp.Canvas.Brush.Color := clBlack;
  bmp.Canvas.FillRect(0, 0, ClientWidth, ClientHeight);
  scene.Clear;

  //create a pyramid
  obj3D := scene.CreateObject(BGRA(255,240,128));
  with obj3D do
  begin
    //create vertices
    topV := MainPart.Add(0,-50,0);
    //pyramid base is in a clockwise order if we look at the pyramid from below
    base := MainPart.Add([-20,25,-20,  20,25,-20,  20,25,20,  -20,25,20]);

    AddFace(base, BGRA(127,127,127));
    //add four faces, the three vertices are in a clockwise order
    AddFace([base[0],topV,base[1]], BGRA(255, 0, 0));
    AddFace([base[1],topV,base[2]], BGRA(0, 255, 0));
    AddFace([base[2],topV,base[3]], BGRA(0, 0, 255));
    AddFace([base[3],topV,base[0]]);
    topV := nil;
    base := nil;
  end;
  obj3D.MainPart.RotateYDeg(rotY);  // Rotate around vertical axis, + = clockwise as viewed from top
  obj3D.MainPart.RotateXDeg(rotX);  // vertical, - tilt top away from viewer
  obj3D.MainPart.RotateZDeg(rotZ);  // vertical, - tilt top clockwise in front of viewer

  scene.Render;
  {$ifdef UseOpenGL}
  BGLViewPort(OpenGLCtrl.Width, OpenGLCtrl.Height, BGRABlack);
  BGLCanvas.PutImage(0, 0, bmp.Texture);
  OpenGLCtrl.SwapBuffers;
  {$else}
  bmp.Draw(Form1.Canvas, 0, 0);
  {$endif}
end;

end.

