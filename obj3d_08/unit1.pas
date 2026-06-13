unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Grids, GLScene, GLObjects, GLLCLViewer, GLBaseClasses, GLTeapot, Types, math;

// Perspective = orthogonal comparison
//https://forum.lazarus.freepascal.org/index.php/topic,49724.0.html

type

  { TForm1 }

  TForm1 = class(TForm)
    CheckBox1: TCheckBox;
    GLCamera1: TGLCamera;
    GLDummyCube1: TGLDummyCube;
    GLDummyCube2: TGLDummyCube;
    GLLightSource1: TGLLightSource;
    GLScene1: TGLScene;
    GLSceneViewer1: TGLSceneViewer;
    GLTeapot1: TGLTeapot;
    Panel1: TPanel;
    StringGrid1: TStringGrid;
    procedure CheckBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GLSceneViewer1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure StringGrid1SetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure UpdStg();
  private

  public
    SV: TGLSceneViewer;
    //PosZ, FLVal: Real;
    CamDTT: Real;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  SV:= GLSceneViewer1;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  if CheckBox1.Checked then
   begin
     sv.Camera.CameraStyle:= csOrthogonal;
     //SV.Camera.FocalLength:=;
     //PosZ:=
   end else
  begin
    sv.Camera.CameraStyle:= csPerspective;
    //SV.Camera.Position.Z;
    //FLVal:=
  end;

  UpdStg();
end;

procedure TForm1.GLSceneViewer1MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if GLCamera1.CameraStyle= csOrthogonal then
   begin
     CamDTT:=SV.Camera.FocalLength+
              (SV.Camera.FocalLength*WheelDelta/-1500);
     SV.Camera.FocalLength:=CamDTT;
   end else
  begin
    CamDTT:=Power(1.05, WheelDelta / 120);
    SV.Camera.AdjustDistanceToTarget(CamDTT);
  end;

  UpdStg();
end;

procedure TForm1.StringGrid1SetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
var A, B: Real;
begin
  with StringGrid1 do
   begin
      if (Col=1) or (Col=2) then TryStrToFloat(Cells[Col, 2], A);
       SV.Camera.FocalLength:= A;

      if (Col=1) or (Col=2) then TryStrToFloat(Cells[Col, 4], B);
       SV.Camera.Position.Z:= B;
   end;
end;

procedure TForm1.UpdStg();
begin
  with StringGrid1 do
   begin
     case GLCamera1.CameraStyle of
     csOrthogonal : Col:= 1;
     csPerspective: Col:= 2;
     end;
     Cells[Col,1]:= FloatToStr(SV.Camera.DepthOfView);
     Cells[Col,2]:= FloatToStr(SV.Camera.FocalLength);
     Cells[Col,3]:= FloatToStr(SV.Camera.SceneScale);
     Cells[Col,4]:= FloatToStr(SV.Camera.Position.Z);
   end;
end;

end.

