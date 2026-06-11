unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  BGRAScene3D, BGRABitmap, BGRABitmapTypes, BGRASceneTypes, BGRAMatrix3D,
  BGRARenderer3D;

type

  { TBGRARenderer3DWireFrame }

  TBGRARenderer3DWireFrame = class(TBGRARenderer3D)
    EdgeColor: TBGRAPixel;
    EdgeWidth: single;
    function RenderFace(var ADescription: TFaceRenderingDescription;
          AComputeCoordinate: TComputeProjectionFunc): boolean; override;
  end;

type

  { TForm1 }

  TForm1 = class(TForm)
    procedure FormPaint(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

//TBGRAScene3D : how to color edges of each face ?
//https://forum.lazarus.freepascal.org/index.php?topic=72873.0

{$R *.lfm}
procedure DrawEdges(scene: TBGRAScene3D;
  bmp: TBGRABitmap; edgeColor: TBGRAPixel; edgeWidth: single);
var
  i, j, k: Integer;
  obj: IBGRAObject3D;
  face: IBGRAFace3D;
  v1, v2: IBGRAVertex3D;

begin
  // iterate over objects
  for i := 0 to scene.Object3DCount-1 do
  begin
    obj := scene.Object3D[i];
    // iterate over faces
    for j := 0 to obj.FaceCount-1 do
    begin
      face := obj.Face[j];
      // iterate over vertices
      for k := 0 to face.VertexCount-1 do
      begin
        v1 := face.Vertex[k];
        v2 := face.Vertex[(k+1) mod face.VertexCount];
        bmp.DrawLineAntialias(v1.ProjectedCoord.X, v1.ProjectedCoord.Y,
          v2.ProjectedCoord.X, v2.ProjectedCoord.Y, edgeColor, edgeWidth, false);
      end;
    end;
  end;
end;

{ TBGRARenderer3DWireFrame }

function TBGRARenderer3DWireFrame.RenderFace(
  var ADescription: TFaceRenderingDescription;
  AComputeCoordinate: TComputeProjectionFunc): boolean;
var
  v1, v2: TPointF;
  i: Integer;
begin
  Result:=inherited RenderFace(ADescription, AComputeCoordinate);
  FOutputSurface.DrawPolygonAntialias(
    slice(ADescription.Projections, ADescription.NbVertices),
    EdgeColor, EdgeWidth);
end;

{ TForm1 }

procedure TForm1.FormPaint(Sender: TObject);
var
  myScene: TBGRAScene3D;
  bmp: TBGRABitmap;
  base: array of IBGRAVertex3D;
  topV: IBGRAVertex3D;
  lights: TList;
  myRenderer: TBGRARenderer3DWireFrame;

begin
  bmp := TBGRABitmap.Create(ClientWidth,ClientHeight,BGRABlack);

  myScene := TBGRAScene3D.Create(bmp);
  //create a pyramid
  with myScene.CreateObject(BGRA(255,240,128)) do
  begin
    //create vertices
    topV := MainPart.Add(0,-15,0);
    //pyramid base is in a clockwise order if we look at the pyramid from below
    base := MainPart.Add([-20,15,-20, 20,15,-20, 20,15,20, -20,15,20]);

    AddFace(base);
    //add four faces, the three vertices are in a clockwise order
    AddFace([base[0],topV,base[1]]);
    AddFace([base[1],topV,base[2]]);
    AddFace([base[2],topV,base[3]]);
    AddFace([base[3],topV,base[0]]);
    topV := nil;
    base := nil;

    // scale and rotate the pyramid
    MainPart.Scale(1.3);
    MainPart.RotateYDeg(30);
    MainPart.RotateXDeg(20);
    MainPart.Translate(0,-5,0);

    //set ambiant lightness to dark (1 is normal lightness, 2 is complete whiteness)
    myScene.AmbiantLightness := 0.5;
    //add a directional light from top-left, maximum lightness will be 0.5 + 1 = 1.5
    myScene.AddDirectionalLight(Point3D(1,1,1), 1);
  end;

  ////////////////////////////////////////////////////////
  //// render the scene normally
  //myScene.Render;
  //// draw the edges using custom procedure
  //DrawEdges(myScene, bmp, CSSGreen, 4);
  ////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////
  // set up custom renderer
  lights := myScene.MakeLightList;
  myRenderer := TBGRARenderer3DWireFrame.Create(bmp, myScene.RenderingOptions,
    myScene.AmbiantLightColorF, lights);
  myRenderer.EdgeColor := CSSGreen;
  myRenderer.EdgeWidth := 3;
  // render the scene using custom renderer
  myScene.Render(myRenderer);
  lights.Free;
  myRenderer.Free;
  ////////////////////////////////////////////////////////

  myScene.Free;

  bmp.Draw(Canvas,0,0);
  bmp.Free;
end;

end.

