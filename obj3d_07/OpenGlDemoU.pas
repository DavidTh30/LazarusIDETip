// ****************************************************
// ***** Template for creating OpenGL Programs    *****
// ****************************************************

unit OpenGlDemoU;

{$mode objfpc}{$H+}

interface

uses
{$IFDEF UNIX}
   cthreads,
{$ENDIF}
Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, OpenGLContext, gl, glu,
LazFileUtils, LazUTF8, IntfGraphics, FPImage,
BGRABitmap, BGRABitmapTypes;

//OpenGL Demo Revisited
//https://forum.lazarus.freepascal.org/index.php/topic,66354.0.html

const
  NumPart = 2000;
type

  { TParticle }
TParticle = class
  x, y, z: GLfloat;
  vx, vy, vz: GLfloat;
  life: single;
end; // TParticle

{ TParticleEngine }
TParticleEngine = class
  xspawn: GLfloat;
  Particle: array [0..2000] of TParticle;
 	direction: boolean;
  procedure MoveParticles;
  procedure DrawParticles;
  procedure Start;
public
  constructor Create;
  destructor Destroy; override;
private
  procedure RespawnParticle(i: integer);
end; // TParticleEngine

type

{ TOpenGlDemoForm }
TOpenGlDemoForm = class(TForm)
	BBlend: TButton;
	BPartBlend: TButton;
	BRotCube: TButton;
BRotBack: TButton;
BPartSpawn: TButton;
BExit: TButton;
BLighting: TButton;
Frame3D: TOpenGLControl;
LDebug: TLabel;
procedure BBlendClick(Sender: TObject);
procedure BExitClick(Sender: TObject);
procedure BLightingClick(Sender: TObject);

procedure BRotBackClick(Sender: TObject);
procedure BRotCubeClick(Sender: TObject);
procedure BPartBlendClick(Sender: TObject);
procedure BPartSpawnClick(Sender: TObject);

procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
procedure FormCreate(Sender: TObject);
procedure FormResize(Sender: TObject);

procedure Frame3DPaint(Sender: TObject);

procedure LoadTextures;

procedure WorldInit();

private

public
 procedure IdleFunc(Sender: TObject; var Done: Boolean);
private

 AreaInitialized: boolean;
 FrameCount: integer;
 LastFrameTicks: integer;
public
 	rx, ry, rz, rrx, rry, rrz: single;
 	checked, blended, lighted, ParticleBlended, MoveCube, MoveBackground: boolean;
end; // TOpenGlDemoForm

// ****************************
// ***** Global Variables *****
// ****************************
var
	LightAmbient : array [0..3] of GLfloat;

	textures       : array [0..2] of GLuint;    // Storage For 3 Textures
	lightamb, lightdif, lightpos, light2pos, light2dif,
	light3pos, light3dif, light4pos, light4dif, fogcolor: array [0..3] of GLfloat;
	ParticleEngine: TParticleEngine;
	ParticleList, CubeList, BackList: GLuint;

	timer: single;
	LastMsecs: integer;

 TexturesA: Array[0..2] of TBGRABitmap;

	OpenGlDemoForm: TOpenGlDemoForm;

const
  GL_CLAMP_TO_EDGE = $812F;
		GLInitialized: boolean = false;

implementation

{$R *.lfm}

{ TParticleEngine }

// **************************
// ***** Move Particles *****
// **************************
procedure TParticleEngine.MoveParticles;
var i: integer;
begin
	for i:=0 to 2000 do begin
	 if Particle[i].life > 0 then
  begin
	  Particle[i].life := Particle[i].life-0.01 * (timer/10);
	  Particle[i].x := Particle[i].x+Particle[i].vx * (timer/10);

	  Particle[i].vy := Particle[i].vy-0.00035 * (timer/10); // gravity
	  Particle[i].y := Particle[i].y+Particle[i].vy * (timer/10);

	  Particle[i].z := Particle[i].z+Particle[i].vz * (timer/10);
	 end
  else begin
	  RespawnParticle(i);
	 end;
	end;
end;

// **************************
// ***** Draw Particles *****
// **************************
procedure TParticleEngine.DrawParticles;
var
	i: integer;
begin
	for i := 0 to 2000 do
 begin

	 glPushMatrix;
	 glTranslatef(Particle[i].x, Particle[i].y, Particle[i].z);
	 glCallList(ParticleList);
	 glPopMatrix;
	end;
end;

// ***************************
// ***** Start Particles *****
// ***************************
procedure TParticleEngine.Start;
var i: integer;
begin
	for i := 0 to 2000 do
	begin
	 RespawnParticle(i);
	end;
end;

// ****************************
// ***** Create Particles *****
// ****************************
constructor TParticleEngine.Create;
var
	i: integer;
begin
	for i := 0 to 2000 do Particle[i] := TParticle.Create;
	xspawn := 0;
 direction := True;
end;

// *****************************
// ***** Destroy Particles *****
// *****************************
destructor TParticleEngine.Destroy;
var
	i: integer;
begin
  for i := 0 to 2000 do FreeAndNil(Particle[i]);
end;


// *****************************
// ***** Respawn Particles *****
// *****************************
procedure TParticleEngine.RespawnParticle(i: integer);
begin
	if (xspawn > 2) and (direction = true) then direction := false;
	if (xspawn < -2) and (direction = false) then direction := true;
	if direction then
	 xspawn := xspawn + 0.0002 * (timer / 10)
	else
	 xspawn := xspawn - 0.0002 * (timer / 10);
	Particle[i].x := xspawn;
	Particle[i].y := -0.5;
	Particle[i].z := 0;
	Particle[i].vx := -0.005+GLFloat(random(2000))/200000;
	Particle[i].vy := 0.035+GLFloat(random(750))/100000;
	Particle[i].vz := -0.005+GLFloat(random(2000))/200000;
	Particle[i].life := GLFloat(random(1250))/1000+1;
end;

{ TOpenGlDemoForm }

// ***********************
// ***** Create Form *****
// ***********************
procedure TOpenGlDemoForm.FormCreate(Sender: TObject);
begin

 Application.OnIdle:=@IdleFunc;
 ParticleEngine := TParticleEngine.Create;

 LoadTextures;
 WorldInit();
end;

// ***********************
// ***** Resize Form *****
// ***********************
procedure TOpenGlDemoForm.FormResize(Sender: TObject);
begin

end;

// **********************
// ***** Close Form *****
// **********************
procedure TOpenGlDemoForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
 i: Integer;
begin

	for i := 0 to 2 do
  if(TexturesA[i] <> nil) then TexturesA[i].Destroy;
 ParticleEngine.Destroy;
end;

// ****************************
// ***** Repaint 3D Frame *****
// ****************************
procedure TOpenGlDemoForm.Frame3DPaint(Sender: TObject);
var
	CurTime: TDateTime;
	MSecs: integer;
begin
	if not GLInitialized then exit;
	inc(FrameCount);
	inc(LastFrameTicks, Frame3D.FrameDiffTimeInMSecs);
	if (LastFrameTicks >= 1000) then
	begin
		LDebug.Caption := 'Frames per second: ' + FrameCount.ToString;
	 dec(LastFrameTicks, 1000);
	 FrameCount := 0;
	end;

	if Frame3D.MakeCurrent then
	begin
	 if not AreaInitialized then
	 begin
	  WorldInit;
	  glMatrixMode (GL_PROJECTION);    { prepare for and then }
	  glLoadIdentity ();               { define the projection }
	  glFrustum (-1.0, 1.0, -1.0, 1.0, 1.5, 20.0); { transformation }
	  glMatrixMode (GL_MODELVIEW);  { back to modelview matrix }
	  glViewport (0, 0, Frame3D.Width, Frame3D.Height);
	                                { define the viewport }
	  AreaInitialized := true;
	 end;

	 CurTime := Now;
	 MSecs := round(CurTime*86400*1000) mod 1000;
	 if MSecs<0 then MSecs := 1000+MSecs;
	 timer := msecs-LastMsecs;
	 if timer<0 then timer := 1000+timer;
	 LastMsecs := MSecs;

	 ParticleEngine.MoveParticles;

	 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
	 glLoadIdentity;             { clear the matrix }
	 glTranslatef (0.0, 0.0,-3.0);  // -2.5); { viewing transformation }
	 {rotate}

	 glPushMatrix;

	 if MoveBackground then
	 begin
	  rrx := rrx-0.6*(timer/10);
	  rry := rry-0.5*(timer/10);
	  rrz := rrz-0.3*(timer/10);
	 end;

	 glRotatef(rrx,1.0,0.0,0.0);
	 glRotatef(rry,0.0,1.0,0.0);
	 glRotatef(rrz,0.0,0.0,1.0);

	 // draw background
	 if blended then
	 begin
	  glEnable(GL_BLEND);
	  glDisable(GL_DEPTH_TEST);
	 end;
	 glCallList(BackList);

	 glPopMatrix;

	 glPushMatrix;

	 if MoveCube then
	 begin
	  rx := rx+0.5*(timer/10);
	  ry := ry+0.25*(timer/10);
	  rz := rz+0.8*(timer/10);
	 end;

	 glRotatef(rx,1.0,0.0,0.0);
	 glRotatef(ry,0.0,1.0,0.0);
	 glRotatef(rz,0.0,0.0,1.0);

	 // draw cube
	 glCallList(CubeList);
	 if blended then
	 begin
	  glDisable(GL_BLEND);
	  glEnable(GL_DEPTH_TEST);
	 end;

	 glPopMatrix;

	 if ParticleBlended then glEnable(GL_BLEND);
	 ParticleEngine.DrawParticles;
	 if ParticleBlended then glDisable(GL_BLEND);
	 //glFlush;
	 //glFinish;
	 // Swap backbuffer to front
	 Frame3D.SwapBuffers;
	end;
end;

// *************************
// ***** Load Textures *****
// *************************
procedure TOpenGlDemoForm.LoadTextures;
begin
 showmessage(ExtractFilePath(ParamStr(0)));
 TexturesA[0] := TBGRABitmap.Create;
 TexturesA[0].LoadFromFile('data/particle.png');
 {$IFDEF WINDOWS}
 		TexturesA[0].SwapRedBlue;
 {$ENDIF}

 TexturesA[1] := TBGRABitmap.Create;
 TexturesA[1].LoadFromFile('data/Arcania.jpg');
 {$IFDEF WINDOWS}
 		TexturesA[1].SwapRedBlue;
 {$ENDIF}

 TexturesA[2] := TBGRABitmap.Create;
 TexturesA[2].LoadFromFile('data/Danais.jpg');
 {$IFDEF WINDOWS}
 		TexturesA[2].SwapRedBlue;
 {$ENDIF}

end;

// **********************
// ***** Init World *****
// **********************
procedure TOpenGlDemoForm.WorldInit;
var
 i: Integer;
begin

 GLInitialized := true;
 {init lighting variables}
 {ambient color}
 lightamb[0] := 0.6;
 lightamb[1] := 0.6;
 lightamb[2] := 0.6;
 lightamb[3] := 1.0;
 {diffuse color}
 lightdif[0] := 0.8;
 lightdif[1] := 0.0;
 lightdif[2] := 0.5;
 lightdif[3] := 1.0;
 {diffuse position}
 lightpos[0] := 0.0;
 lightpos[1] := 0.0;
 lightpos[2] := 3.0;
 lightpos[3] := 1.0;
 {diffuse 2 color}
 light2dif[0] := 0.0;
 light2dif[1] := 1.0;
 light2dif[2] := 0.0;
 light2dif[3] := 1.0;
 {diffuse 2 position}
 light2pos[0] := 3.0;
 light2pos[1] := 0.0;
 light2pos[2] := 3.0;
 light2pos[3] := 1.0;
 {diffuse 3 color}
 light3dif[0] := 0.0;
 light3dif[1] := 0.0;
 light3dif[2] := 1.0;
 light3dif[3] := 1.0;
 {diffuse 3 position}
 light3pos[0] := -3.0;
 light3pos[1] := 0.0;
 light3pos[2] := 0.0;
 light3pos[3] := 1.0;
 {fog color}

 fogcolor[0] := 0.5;
 fogcolor[1] := 0.5;
 fogcolor[2] := 0.5;
 fogcolor[3] := 1.0;

 {setting lighting conditions}
 glLightfv(GL_LIGHT0,GL_AMBIENT,lightamb);
 glLightfv(GL_LIGHT1,GL_AMBIENT,lightamb);
 glLightfv(GL_LIGHT2,GL_DIFFUSE,lightdif);
 glLightfv(GL_LIGHT2,GL_POSITION,lightpos);
 glLightfv(GL_LIGHT3,GL_DIFFUSE,light2dif);
 glLightfv(GL_LIGHT3,GL_POSITION,light2pos);
 glLightfv(GL_LIGHT4,GL_POSITION,light3pos);
 glLightfv(GL_LIGHT4,GL_DIFFUSE,light3dif);
 glEnable(GL_LIGHT0);
 glEnable(GL_LIGHT1);
 glEnable(GL_LIGHT2);
 glEnable(GL_LIGHT3);
 glEnable(GL_LIGHT4);

 glGenTextures(3, @textures[0]);

 for i:=0 to 2 do begin
  glBindTexture(GL_TEXTURE_2D, Textures[i]);
  glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
  glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);

//  glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,MyglTextures[i].Width,MyglTextures[i].Height,0
//      ,GL_RGBA,GL_UNSIGNED_BYTE,MyglTextures[i].Data);
  glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,TexturesA[i].Width,TexturesA[i].Height,0
      ,GL_RGBA,GL_UNSIGNED_BYTE,TexturesA[i].Data);
 end;

 glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE, GL_MODULATE);
 {instead of GL_MODULATE you can try GL_DECAL or GL_BLEND}
 glEnable(GL_TEXTURE_2D);          // enables 2d textures
 glClearColor(0.0,0.0,0.0,1.0);    // sets background color
 glClearDepth(1.0);
 glDepthFunc(GL_LEQUAL);           // the type of depth test to do
 glEnable(GL_DEPTH_TEST);          // enables depth testing
 glShadeModel(GL_SMOOTH);          // enables smooth color shading
 {blending}
 glColor4f(1.0,1.0,1.0,0.5);       // Full Brightness, 50% Alpha ( NEW )
 glBlendFunc(GL_SRC_ALPHA, GL_ONE);
 glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER, GL_TRUE);
 {}
 glHint(GL_LINE_SMOOTH_HINT,GL_NICEST);
 glHint(GL_POLYGON_SMOOTH_HINT,GL_NICEST);
 glHint(GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST);

 // creating display lists

// ***** Particules *****
 ParticleList := glGenLists(1);
 glNewList(ParticleList, GL_COMPILE);
  glBindTexture(GL_TEXTURE_2D, textures[0]);

  glBegin(GL_TRIANGLE_STRIP);
   glNormal3f( 0.0, 0.0, 1.0);
   glTexCoord2f( 1.0, 1.0);     glVertex3f(+0.025, +0.025, 0);
   glTexCoord2f( 0.0, 1.0);     glVertex3f(-0.025, +0.025, 0);
   glTexCoord2f( 1.0, 0.0);     glVertex3f(+0.025, -0.025, 0);
   glTexCoord2f( 0.0, 0.0);     glVertex3f(-0.025, -0.025, 0);
  glEnd;
 glEndList; // Particules

 // ***** Back Texture *****
 BackList := ParticleList+1;
 glNewList(BackList, GL_COMPILE);
  glBindTexture(GL_TEXTURE_2D, textures[2]);
  glBegin(GL_QUADS);
   {Front Face}
   glNormal3f( 0.0, 0.0, 1.0);
   glTexCoord2f( 1.0, 1.0);     glVertex3f( 2.5, 2.5, 2.5);
   glTexCoord2f( 0.0, 1.0);     glVertex3f(-2.5, 2.5, 2.5);
   glTexCoord2f( 0.0, 0.0);     glVertex3f(-2.5,-2.5, 2.5);
   glTexCoord2f( 1.0, 0.0);     glVertex3f( 2.5,-2.5, 2.5);
   {Back Face}
   glNormal3f( 0.0, 0.0,-1.0);
   glTexCoord2f( 0.0, 1.0);     glVertex3f( 2.5, 2.5,-2.5);
   glTexCoord2f( 0.0, 0.0);     glVertex3f( 2.5,-2.5,-2.5);
   glTexCoord2f( 1.0, 0.0);     glVertex3f(-2.5,-2.5,-2.5);
   glTexCoord2f( 1.0, 1.0);     glVertex3f(-2.5, 2.5,-2.5);
   {Left Face}
   glNormal3f(-1.0, 0.0, 0.0);
   glTexCoord2f( 1.0, 1.0);     glVertex3f(-2.5, 2.5, 2.5);
   glTexCoord2f( 0.0, 1.0);     glVertex3f(-2.5, 2.5,-2.5);
   glTexCoord2f( 0.0, 0.0);     glVertex3f(-2.5,-2.5,-2.5);
   glTexCoord2f( 1.0, 0.0);     glVertex3f(-2.5,-2.5, 2.5);
   {Right Face}
   glNormal3f( 1.0, 0.0, 0.0);
   glTexCoord2f( 1.0, 1.0);     glVertex3f( 2.5, 2.5,-2.5);
   glTexCoord2f( 0.0, 1.0);     glVertex3f( 2.5, 2.5, 2.5);
   glTexCoord2f( 0.0, 0.0);     glVertex3f( 2.5,-2.5, 2.5);
   glTexCoord2f( 1.0, 0.0);     glVertex3f( 2.5,-2.5,-2.5);
   {Top Face}
   glNormal3f( 0.0, 1.0, 0.0);
   glTexCoord2f( 1.0, 1.0);     glVertex3f( 2.5, 2.5,-2.5);
   glTexCoord2f( 0.0, 1.0);     glVertex3f(-2.5, 2.5,-2.5);
   glTexCoord2f( 0.0, 0.0);     glVertex3f(-2.5, 2.5, 2.5);
   glTexCoord2f( 1.0, 0.0);     glVertex3f( 2.5, 2.5, 2.5);
   {Bottom Face}
   glNormal3f( 0.0,-1.0, 0.0);
   glTexCoord2f( 1.0, 1.0);     glVertex3f(-2.5,-2.5,-2.5);
   glTexCoord2f( 0.0, 1.0);     glVertex3f( 2.5,-2.5,-2.5);
   glTexCoord2f( 0.0, 0.0);     glVertex3f( 2.5,-2.5, 2.5);
   glTexCoord2f( 1.0, 0.0);     glVertex3f(-2.5,-2.5, 2.5);

  glEnd;
 glEndList; // Back Texture

 // ***** Cube Texture *****
 CubeList := BackList+1;
 glNewList(CubeList, GL_COMPILE);
  glBindTexture(GL_TEXTURE_2D, textures[1]);
  glBegin(GL_QUADS);
   {Front Face}
   glNormal3f( 0.0, 0.0, 1.0);
   glTexCoord2f( 1.0, 1.0);     glVertex3f( 0.5, 0.5, 0.5);
   glTexCoord2f( 0.0, 1.0);     glVertex3f(-0.5, 0.5, 0.5);
   glTexCoord2f( 0.0, 0.0);     glVertex3f(-0.5,-0.5, 0.5);
   glTexCoord2f( 1.0, 0.0);     glVertex3f( 0.5,-0.5, 0.5);
   {Back Face}
   glNormal3f( 0.0, 0.0,-1.0);
   glTexCoord2f( 0.0, 1.0);     glVertex3f( 0.5, 0.5,-0.5);
   glTexCoord2f( 0.0, 0.0);     glVertex3f( 0.5,-0.5,-0.5);
   glTexCoord2f( 1.0, 0.0);     glVertex3f(-0.5,-0.5,-0.5);
   glTexCoord2f( 1.0, 1.0);     glVertex3f(-0.5, 0.5,-0.5);
  glEnd;
  glBindTexture(GL_TEXTURE_2D, textures[1]);
  glBegin(GL_QUADS);
   {Left Face}
   glNormal3f(-1.0, 0.0, 0.0);
   glTexCoord2f( 1.0, 1.0);     glVertex3f(-0.5, 0.5, 0.5);
   glTexCoord2f( 0.0, 1.0);     glVertex3f(-0.5, 0.5,-0.5);
   glTexCoord2f( 0.0, 0.0);     glVertex3f(-0.5,-0.5,-0.5);
   glTexCoord2f( 1.0, 0.0);     glVertex3f(-0.5,-0.5, 0.5);
   {Right Face}
   glNormal3f( 1.0, 0.0, 0.0);
   glTexCoord2f( 1.0, 1.0);     glVertex3f( 0.5, 0.5,-0.5);
   glTexCoord2f( 0.0, 1.0);     glVertex3f( 0.5, 0.5, 0.5);
   glTexCoord2f( 0.0, 0.0);     glVertex3f( 0.5,-0.5, 0.5);
   glTexCoord2f( 1.0, 0.0);     glVertex3f( 0.5,-0.5,-0.5);
  glEnd;
  glBindTexture(GL_TEXTURE_2D, textures[1]);
  glBegin(GL_QUADS);
   {Top Face}
   glNormal3f( 0.0, 1.0, 0.0);
   glTexCoord2f( 1.0, 1.0);     glVertex3f( 0.5, 0.5,-0.5);
   glTexCoord2f( 0.0, 1.0);     glVertex3f(-0.5, 0.5,-0.5);
   glTexCoord2f( 0.0, 0.0);     glVertex3f(-0.5, 0.5, 0.5);
   glTexCoord2f( 1.0, 0.0);     glVertex3f( 0.5, 0.5, 0.5);
   {Bottom Face}
   glNormal3f( 0.0,-1.0, 0.0);
   glTexCoord2f( 1.0, 1.0);     glVertex3f(-0.5,-0.5,-0.5);
   glTexCoord2f( 0.0, 1.0);     glVertex3f( 0.5,-0.5,-0.5);
   glTexCoord2f( 0.0, 0.0);     glVertex3f( 0.5,-0.5, 0.5);
   glTexCoord2f( 1.0, 0.0);     glVertex3f(-0.5,-0.5, 0.5);
  glEnd;
 glEndList; // Cube Texture

end; // GLInit


procedure TOpenGlDemoForm.IdleFunc(Sender: TObject; var Done: Boolean);
begin
 Frame3D.Invalidate;
 Done := False; // tell lcl to handle messages and return immediatly
end;


// ****************************
// ***** Move Back Button *****
// ****************************
procedure TOpenGlDemoForm.BRotBackClick(Sender: TObject);
begin
 MoveBackground := not MoveBackground;
 if(MoveBackground) then BRotBack.Caption := 'Back Stop'
 else BRotBack.Caption := 'Rot. Back';
 Frame3D.Invalidate;
end;

// ****************************
// ***** Move Cube Button *****
// ****************************
procedure TOpenGlDemoForm.BRotCubeClick(Sender: TObject);
begin
 MoveCube := not MoveCube;
 if(MoveCube) then BRotCube.Caption := 'Cube Stop'
 else BRotCube.Caption := 'Rot. Cube';
 Frame3D.Invalidate;
end;

// ************************************
// ***** Particules Blend  Button *****
// ************************************
procedure TOpenGlDemoForm.BPartBlendClick(Sender: TObject);
begin
 ParticleBlended := not ParticleBlended;
 if(ParticleBlended) then BPartBlend.Caption := 'P.Blend Stop'
 else BPartBlend.Caption := 'Part. Blend';
 Frame3D.Invalidate;
end;

// ************************************
// ***** Particules Spawn  Button *****
// ************************************
procedure TOpenGlDemoForm.BPartSpawnClick(Sender: TObject);
begin
	ParticleEngine.Start;
	Frame3D.Invalidate;
end;

// ***************************
// ***** Lighting Button *****
// ***************************
procedure TOpenGlDemoForm.BLightingClick(Sender: TObject);
begin
	if lighted then glDisable(GL_LIGHTING) else glEnable(GL_LIGHTING);
	lighted := not lighted;
 if(lighted) then BLighting.Caption := 'Light Stop'
 else BLighting.Caption := 'Ligthing';
	Frame3D.Invalidate;
end;

// ************************
// ***** Blend Button *****
// ************************
procedure TOpenGlDemoForm.BBlendClick(Sender: TObject);
begin
	blended := not blended;
 if(blended) then BBlend.Caption := 'Blend Stop'
 else BBlend.Caption := 'Blend';
	Frame3D.Invalidate;
end;

// ***********************
// ***** Exit Button *****
// ***********************
procedure TOpenGlDemoForm.BExitClick(Sender: TObject);
begin
	Close;
end;

end.

