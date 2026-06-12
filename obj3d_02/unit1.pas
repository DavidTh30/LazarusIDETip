unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  FileUtil, ExtCtrls,
  BGRAVirtualScreen, BGRABitmap, BGRABitmapTypes, BGRAScene3D, BGRAOpenGL3D, BCTypes;

type
  { T3DGraphic }

  T3DGraphic = class(TBGLScene3D)
  private
    bitmap: TBGRABitmap;
  protected
    function FetchTexture({%H-}AName: string; out texSize: TPointF): IBGRAScanner; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    BGRASurface: TBGRAVirtualScreen;
    Timer1: TTimer;
    procedure BGRASurfaceRedraw(Sender: TObject; Bitmap: TBGRABitmap);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public
    scene: T3DGraphic;
    bitmap: TBGRABitmap;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ T3DGraphic }

function T3DGraphic.FetchTexture(AName: string; out texSize: TPointF
  ): IBGRAScanner;
begin
  bitmap := TBGRABitmap.Create(AName);
  result := bitmap;
  texSize := PointF(256,256);
end;

constructor T3DGraphic.Create;
begin
  inherited Create;
  LoadMaterialsFromFile('greek_vase.mtl');
  LoadObjectFromFile('greek_vase.obj', True);
end;

destructor T3DGraphic.Destroy;
begin
  FreeAndNil(bitmap);
  inherited Destroy;
end;

{ TForm1 }

procedure TForm1.BGRASurfaceRedraw(Sender: TObject; Bitmap: TBGRABitmap);
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
  scene.Camera.ViewPoint := Point3D(-2,-2,-2);
  //scene.Zoom := scene.Zoom*(2);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Timer1.Enabled:=False;
  scene.Free;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  scene.Object3D[0].MainPart.RotateYDeg(-1, False);
  BGRASurface.DiscardBitmap;
end;

end.

