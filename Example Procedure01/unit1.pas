unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private

  public

  end;

  TPoint3D = record
    // coordonnées world
    worldX, worldY, worldZ: Single;
    // coordonnées camera
    camX, camY, camZ: Single;
    // coordonnées écran / projection
    screenX, screenY, screenW: Single;
  end;

var
  Form1: TForm1;
  L_:integer;
  T_:TPoint3D;

implementation

{$R *.lfm}


procedure glProjectPoint(var p: TPoint3D; cameraX, cameraY, cameraZ, cameraDepth,
  screenW, screenH, roadW: Single; curve: Single = 0.0);
var
  scale: Single;
  curveOffset: Single;
begin
  // camera-space
  p.camX := p.worldX - cameraX;
  p.camY := p.worldY - cameraY;
  p.camZ := p.worldZ - cameraZ;

  // Appliquer la courbure (plus le segment est loin, plus la courbe est visible)
  curveOffset := curve * p.camZ * p.camZ * 0.0001; // facteur à ajuster
  p.camX := p.camX + curveOffset;

  if p.camZ <= 0.0001 then
  begin
    p.screenX := 0;
    p.screenY := 1e9;
    p.screenW := 0;
    Exit;
  end;

  scale := cameraDepth / p.camZ;
  p.screenW := scale * roadW * (screenW * 0.5);
  p.screenX := (screenW * 0.5) + (scale * p.camX * (screenW * 0.5));
  p.screenY := (screenH * 0.5) - (scale * p.camY * (screenH * 0.5));
end;

procedure ChangeObjectProperties01(LabelConfig: TLabel);
begin
  if Assigned(LabelConfig) then
    LabelConfig.Caption:='Config01';
end;

procedure ChangeObjectProperties02(LabelConfig: TLabel);
begin
  LabelConfig.Caption:='Config02';
end;

procedure ChangeValveProperties(var LabelInt: integer);
begin
  LabelInt:=01;
end;

procedure CanNotChangeValveProperties(LabelInt: integer);
begin
  LabelInt:=02;
end;

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  ChangeObjectProperties01(Label1);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ChangeObjectProperties02(Label1);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  L_:=5;
  ChangeValveProperties(L_);
  Label1.Caption:=L_.ToString;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  L_:=5;
  CanNotChangeValveProperties(L_);
  Label1.Caption:=L_.ToString;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  glProjectPoint(T_,1,1,1,500,500,800,0.3,1.1);
  Label1.Caption:=T_.camX.ToString;
end;

end.

