unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  BGRAOpenGL, BGRABitmap, BGRAScene3D, BGLVirtualScreen,
  BGRAOpenGL3D;

type

  { TForm1 }

  TForm1 = class(TForm)
    BGLVirtualScreen1: TBGLVirtualScreen;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    procedure BGLVirtualScreen1Redraw(Sender: TObject; BGLContext: TBGLContext);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    scene: TBGLScene3D;
    obj3D: IBGRAObject3D;
    procedure DrawPyramid(rotX, rotY, rotZ: integer);
  public

  end;

var
  Form1: TForm1;

implementation

uses
  BGRABitmapTypes;

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormShow(Sender: TObject);
begin
  self.Caption := 'TBGLVirtualScreen test';
  scene := TBGLScene3D.Create;
  Timer1.Enabled := True;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Timer1.Enabled := False;
  if Assigned(scene) then
    FreeAndNil(scene);
  if Assigned(obj3D) then
    FreeAndNil(obj3D);
end;

procedure TForm1.BGLVirtualScreen1Redraw(Sender: TObject;
  BGLContext: TBGLContext);
begin
  scene.RenderGL(BGLContext.Canvas);
  BGLContext.Canvas.WaitForGPU(wfgFinishAllCommands);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
const
  x: integer = 0;
  y: integer = 0;
  z: integer = 0;
  start: Qword = 0;
begin
  Timer1.Enabled := False;

  // Update display with previous values
  StatusBar1.Panels[3].Text := IntToStr(x) + 'º';
  StatusBar1.Panels[5].Text := IntToStr(y) + 'º';
  StatusBar1.Panels[7].Text := IntToStr(z) + 'º';

  start := GetTickCount64;
  DrawPyramid(x, y, z);
  BGLVirtualScreen1.Invalidate;
  Application.ProcessMessages;
  StatusBar1.Panels[1].Text := IntToStr(GetTickCount64 - start) + ' ms';

  // Simulate some motion
  Inc(x, 1);
  if x > 360 then
    x := x - 360;

  Inc(y, 3);
  if y > 360 then
    y := y - 360;

  Inc(z, 4);
  if z > 360 then
    z := z - 360;

  Timer1.Enabled := True;
end;

procedure TForm1.DrawPyramid(rotX, rotY, rotZ: integer);
var
  base: array of IBGRAVertex3D;
  topV: IBGRAVertex3D;
begin
  scene.Clear;

  //create a pyramid
  obj3D := scene.CreateObject(BGRA(255, 240, 128));
  with obj3D do
  begin
    //create vertices
    topV := MainPart.Add(0, -50, 0);
    //pyramid base is in a clockwise order if we look at the pyramid from below
    base := MainPart.Add([-20, 25, -20, 20, 25, -20, 20, 25, 20, -20, 25, 20]);

    AddFace(base, BGRA(127, 127, 127));
    //add four faces, the three vertices are in a clockwise order
    AddFace([base[0], topV, base[1]], BGRA(255, 0, 0));
    AddFace([base[1], topV, base[2]], BGRA(0, 255, 0));
    AddFace([base[2], topV, base[3]], BGRA(0, 0, 255));
    AddFace([base[3], topV, base[0]]);
    topV := nil;
    base := nil;
  end;
  obj3D.MainPart.RotateYDeg(rotY);
  obj3D.MainPart.RotateXDeg(rotX);
  obj3D.MainPart.RotateZDeg(rotZ);
end;

end.
