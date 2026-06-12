unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  BGRAVirtualScreen, BGRABitmap, BGRABitmapTypes, BGRAScene3D, BGRAOpenGL3D, BCTypes;

//Rendering 3D Scene with loaded 3D object
//https://forum.lazarus.freepascal.org/index.php?topic=32691.0

type

  { T3DGraphic }

  T3DGraphic = class(TBGLScene3D)
  public
    constructor Create;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    BGRAVirtualScreen1: TBGRAVirtualScreen;
    Timer1: TTimer;
    procedure BGRAVirtualScreen1Redraw(Sender: TObject; Bitmap: TBGRABitmap);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    scene: T3DGraphic;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ T3DGraphic }

constructor T3DGraphic.Create;
begin
  inherited Create;
  LoadObjectFromFile('object.obj', True);
end;

{ TForm1 }

procedure TForm1.BGRAVirtualScreen1Redraw(Sender: TObject; Bitmap: TBGRABitmap);
begin
  scene.RenderingOptions.AntialiasingMode := am3dResample;
  scene.RenderingOptions.AntialiasingResampleLevel := 2;
  scene.RenderingOptions.MinZ := 1;
  scene.Surface := Bitmap;
  scene.Render;
  scene.Surface := nil;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  scene := T3DGraphic.Create;
  if scene.Object3DCount > 0 then
  begin
    // Perfectly aligned with Blender 'Front view'
    scene.Object3D[0].MainPart.RotateZDeg(180, False);
    scene.Object3D[0].MainPart.RotateYDeg(180, False);
  end;
  scene.Camera.ViewPoint := Point3D(0,0,-10);
  //scene.Zoom := scene.Zoom * 1.5;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  scene.Free;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  scene.Object3D[0].MainPart.RotateYDeg(-1, False);
  BGRAVirtualScreen1.DiscardBitmap;
end;

end.

