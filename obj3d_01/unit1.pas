unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, BGRAVirtualScreen,
  FileUtil, ExtCtrls,
  Spin, StdCtrls, BGRABitmap, BGRAScene3D, BCTypes;


type

  { TForm1 }

  TForm1 = class(TForm)
    BGRASurface: TBGRAVirtualScreen;
    procedure BGRASurfaceRedraw(Sender: TObject; Bitmap: TBGRABitmap);
    procedure SurfaceMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure BGRASurfaceMouseEnter(Sender: TObject);
    procedure SurfaceMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SurfaceMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public
    {$IFNDEF NO_OPENGL_SURFACE}
    BGLSurface: TBGLVirtualScreen;
    glFont: IBGLFont;
    scene: TBGLScene3D;
    {$ELSE}
    scene: TBGRAScene3D;
    scene02: TBGRAScene3D;
    {$ENDIF}
    moving: boolean;
    moveOrigin: TPoint;
    procedure AdjustSceneSize;
    procedure RedrawScene(Sender: TObject; var Done: boolean);
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}
uses ex1, BGRABitmapTypes;

{ TForm1 }

procedure TForm1.AdjustSceneSize;
begin
  {$IFNDEF NO_OPENGL_SURFACE}
  if ComboBox_Render.Text = 'BGRA' then
  begin
    if BGLSurface.Visible then
    begin
      BGRASurface.Visible := false;
      BGLSurface.Visible := false;

      BGRASurface.Visible := true;
      BGRASurface.Align := alClient;
    end;
  end else
  if ComboBox_Render.Text = 'OpenGL' then
  begin
    if BGRASurface.Visible then
    begin
      BGRASurface.Visible := false;
      BGLSurface.Visible := false;

      BGLSurface.Visible := true;
      BGLSurface.Align := alClient;
    end;
  end else //BGRA&OpenGL
  begin
    if not BGRASurface.Visible or not BGLSurface.Visible then
    begin
      BGRASurface.Visible := false;
      BGLSurface.Visible := false;

      BGRASurface.Visible := true;
      BGLSurface.Visible := true;
      BGRASurface.Align := alLeft;
      BGLSurface.Align := alClient;
    end;
    BGRASurface.Width := ClientWidth div 2;
  end;
  {$ENDIF}
end;

procedure TForm1.RedrawScene(Sender: TObject; var Done: boolean);
begin
  if Form1.BGRASurface.Visible then Form1.BGRASurface.DiscardBitmap;
  {$IFNDEF NO_OPENGL_SURFACE}
  if Assigned(BGLSurface) and BGLSurface.Visible then BGLSurface.Invalidate;
  {$ENDIF}
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  scene := nil;
  scene02 := nil;

  {$IFNDEF NO_OPENGL_SURFACE}
  BGLSurface := TBGLVirtualScreen.Create(self);
  BGLSurface.Color := clGray;
  BGLSurface.OnMouseEnter:= @BGLSurfaceMouseEnter;
  BGLSurface.OnMouseDown:= @SurfaceMouseDown;
  BGLSurface.OnMouseMove:= @SurfaceMouseMove;
  BGLSurface.OnMouseUp:= @SurfaceMouseUp;
  BGLSurface.OnRedraw:= @BGLSurfaceRedraw;
  BGLSurface.Align := alClient;
  BGLSurface.Parent := self;
  {$ELSE}
  BGRASurface.Align := alClient;
  //ComboBox_Render.Items.Clear;
  //ComboBox_Render.Items.Add('BGRA');
  //ComboBox_Render.ItemIndex := 0;
  {$ENDIF}

  FreeAndNil(scene);
  FreeAndNil(scene02);
  scene := TExample1.Create;
  scene.Object3D[0].MainPart.RotateYDeg(180,False);
  //scene.Object3D[0].MainPart.RotateXDeg(30,False);

  scene02 := TExample1.Create;

  Application.OnIdle:=@RedrawScene;
end;

procedure TForm1.BGRASurfaceRedraw(Sender: TObject; Bitmap: TBGRABitmap);
var h,cury: integer;

  procedure TextLine(str: string);
  var
    c: TBGRAPixel;
  begin
    c := Bitmap.GetPixel(0,cury+h div 2);
    if GetLightness(GammaExpansion(c)) > 32768 then
      c := BGRABlack else c := BGRAWhite;
    Bitmap.TextOut(0,cury,str,c);
    inc(cury, h);
  end;

begin
  if scene02 <> nil then
  begin
    scene02.RenderingOptions.AntialiasingMode := am3dResample;
    scene02.RenderingOptions.AntialiasingResampleLevel := 1;//SpinEdit_AA.Value;
    scene02.RenderingOptions.MinZ := 1;

    scene02.Surface := Bitmap;
    scene02.Render;
    scene02.Surface := nil;
  end;

  if scene <> nil then
  begin
    //timer.Clear;
    //timer.Start;

    scene.RenderingOptions.AntialiasingMode := am3dResample;
    scene.RenderingOptions.AntialiasingResampleLevel := 1;//SpinEdit_AA.Value;
    scene.RenderingOptions.MinZ := 1;

    scene.Surface := Bitmap;
    scene.Render;
    scene.Surface := nil;

    //timer.Stop;

    Bitmap.FontFullHeight := 20;
    Bitmap.FontQuality := fqSystemClearType;
    h := Bitmap.FontFullHeight;

    cury := 0;
    //TextLine(inttostr(round(timer.Elapsed*1000)) + ' ms');
    TextLine('2 scene in VirtualScreen option -dNO_OPENGL_SURFACE');
    TextLine(inttostr(scene.Object3DCount) + ' object(s)');
    TextLine(inttostr(scene.VertexCount) + ' vertices');
    TextLine(inttostr(scene.FaceCount) + ' faces');
    TextLine(inttostr(scene.RenderedFaceCount) + ' rendered');
    TextLine(inttostr(scene.LightCount) + ' light(s)');
    TextLine('Radius: '+scene.Object3D[0].MainPart.Radius.ToString);
    TextLine('ViewCenter: '+scene.ViewCenter.x.ToString+':'+scene.ViewCenter.y.ToString);
    TextLine('Camera: '+scene.Camera.ViewPoint.x.ToString+':'+scene.Camera.ViewPoint.y.ToString+':'+scene.Camera.ViewPoint.z.ToString);
    //Timer1.Enabled := true;
  end;
end;

procedure TForm1.SurfaceMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (button = mbLeft) and (scene <> nil) then
  begin
    moving := true;
    moveOrigin := point(x,y);
  end;
end;

procedure TForm1.BGRASurfaceMouseEnter(Sender: TObject);
begin
  //SpinEdit_AA.Enabled := false;
end;

procedure TForm1.SurfaceMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Done:boolean;
begin
  if moving then
  begin
    //if scene is TExample5 then
    //begin
    //  scene.LookRight(X-moveOrigin.X);
    //  scene.LookDown(Y-moveOrigin.Y);
    //end else
    if scene.Object3DCount > 0 then
    begin
      scene.Object3D[0].MainPart.RotateYDeg(-(X-moveOrigin.X),False);
      scene.Object3D[0].MainPart.RotateXDeg(Y-moveOrigin.Y,False);
    end;
    RedrawScene(Sender,Done);
    moveOrigin := point(x,y);
  end;
end;

procedure TForm1.SurfaceMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if button = mbLeft then moving := false;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(scene);
  FreeAndNil(scene02);
end;

end.

