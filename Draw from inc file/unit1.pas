unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  FPImage, FPReadPNG, FPWritePNG; //TFPReaderJPEG     TLazIntfImage

{$include bytes.inc}
{$include char.inc}

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Edit1: TEdit;
    Image1: TImage;
    Image4: TImage;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Image4Paint(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  loop_:boolean;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormPaint(Sender: TObject);
var
  BackImage: TFPCustomImage = nil; // Or TPortableNetworkGraphic TJPEGImage, TBitmap, TGraphic ,TFPCustomImage
  BackImage2: TPortableNetworkGraphic;
  Reader: TFPCustomImageReader;
  imgLogo: TFPCustomImage;
  imgStream: TMemoryStream;
  imgReader: TFPReaderPNG;
  imgWriter: TFPWriterPNG;
  //IntfImg1: TLazIntfImage;
  bmp : TBitmap;
begin

  if (loop_ = false) then
  begin
    Application.ProcessMessages;
    //OutputDebugString(PChar(IntToStr(1)));
    exit;
  end;

  BackImage2 := TPortableNetworkGraphic.Create;
  try
    BackImage2.LoadFromFile('image.png');
    // Draw the image onto the form canvas behind the textbox
    Canvas.StretchDraw(Rect(Edit1.Left, Edit1.Top, Edit1.Left + Edit1.Width, Edit1.Top + Edit1.Height), BackImage2);
  finally
    BackImage2.Free;
  end;


  //BackImage := TBitmap.Create;
  //try
  //  BackImage.LoadFromFile('image.bmp');
  //  // Draw the image onto the form canvas behind the textbox
  //  Canvas.StretchDraw(ClientRect, BackImage);
  //  //Canvas.CopyRect(Canvas.ClipRect, MyBigPiture.Canvas, Canvas.ClipRect);
  //  //Canvas.StretchDraw(Rect(Edit1.Left, Edit1.Top, Edit1.Left + Edit1.Width, Edit1.Top + Edit1.Height), BackImage);
  //finally
  //  BackImage.Free;
  //end;

  BackImage := TFPCustomImage.Create(0,0);
  Reader := TFPReaderPNG.Create;
  //Reader := TFPReaderJPEG.Create;
  imgReader := TFPReaderPNG.Create;
  imgWriter := TFPWriterPNG.Create;
  imgStream := TMemoryStream.Create;

  imgStream.Write(bytes_logo,SizeOf(bytes_logo));
  imgStream.Position := 0;

  imgLogo := TFPMemoryImage.Create(0,0);
  imgLogo.LoadFromStream(imgStream,imgReader);

  //IntfImg1:=TLazIntfImage.Create(0,0);
  //IntfImg1.DataDescription := GetDescriptionFromDevice(0);

  imgWriter.UseAlpha := imgReader.UseAlpha;
  imgWriter.WordSized := imgReader.WordSized;
  //imgLogo.SaveToFile('stream.png',imgWriter);
  //imgStream.SaveToFile('original.png');

  bmp := TBitmap.create;
  bmp.setSize(10,10);
  bmp.canvas.brush.color := clWhite;
  bmp.canvas.FillRect(bmp.canvas.ClipRect);
  bmp.canvas.brush.color := clblack;
  bmp.canvas.Line(5,2,2,8);
  bmp.canvas.Line(2,8,8,8);
  bmp.canvas.Line(8,8,5,2);

  try

    //BackImage.LoadFromFile('image.png');
    //BackImage.LoadFromFile('image.png',Reader);
    //Edit1.Brush.Canvas.TextOut(0,0,'dd');
    //Edit1.Brush.Canvas.Arc(50,50,10,10,30,180);
    //Edit1.Brush.Bitmap.Canvas.Arc(50,50,10,10,30,180);
    //Edit1.Brush.Bitmap.Canvas.TextOut(0,0,'Test');
    //Edit1.Brush.Canvas.StretchDraw(Edit1.Left, Edit1.Top, Edit1.Width, Edit1.Height, imgLogo);
    //Edit1.Brush.Bitmap.Canvas.Brush.Bitmap :=bmp;
    //Edit1.Brush.Bitmap :=bmp;

    {Can't close application}
    //Image4.canvas.brush.Color := clWhite;
    //Image4.canvas.brush.Style := bsSolid;
    //Image4.canvas.FillRect(Image4.Canvas.ClipRect);
    //Image4.canvas.brush.Style:= bsPattern;  // add uses FPCanvas
    //Image4.canvas.brush.Bitmap := bmp;
    //Image4.canvas.Polygon([Point(10,10), Point(585,15), Point(600,350),Point(55,65)]);

  finally
    imgLogo.Free;
    BackImage.Free;
    Reader.Free;
    imgReader.Free;
    imgStream.Free;
    imgWriter.Free;
    bmp.free;
  end;


  Application.ProcessMessages;
end;

procedure TForm1.Image4Paint(Sender: TObject);
begin
  tImage(sender).Canvas.Ellipse(50,50,100,100);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  imgLogo: TFPCustomImage;
  imgStream: TMemoryStream;
  imgReader: TFPReaderPNG;
  imgWriter: TFPWriterPNG;
begin
  imgReader := TFPReaderPNG.Create;
  imgWriter := TFPWriterPNG.Create;
  imgStream := TMemoryStream.Create;

  imgStream.Write(bytes_logo,SizeOf(bytes_logo));
  imgStream.Position := 0;

  imgLogo := TFPMemoryImage.Create(0,0);
  imgLogo.LoadFromStream(imgStream,imgReader);

  imgWriter.UseAlpha := imgReader.UseAlpha;
  imgWriter.WordSized := imgReader.WordSized;
  imgLogo.SaveToFile('stream.png',imgWriter);
  imgStream.SaveToFile('original.png');

  imgLogo.Free;
  imgStream.Free;
  imgReader.Free;
  imgWriter.Free;

  showmessage('Finish process stream.png, original.png');
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  EmptyImage: TCustomImage;
begin
  Image4.Canvas.Brush.Style := bsSolid;
  Image4.Canvas.Brush.Color := clRed;
  Image4.Canvas.Ellipse(50,50,200,200);

  EmptyImage := TCustomImage.Create(Self);
  EmptyImage.Width := Image4.Width;
  EmptyImage.Height := Image4.Height;
  EmptyImage.Canvas.Brush.Style := bsClear;
  EmptyImage.Canvas.FillRect(0,0,Image4.Width,Image4.Height);
  Image4.Picture.Assign(EmptyImage.Picture);
  EmptyImage.Free;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Image4.Canvas.Brush.Style := bsSolid;
  Image4.Canvas.Brush.Color := clRed;
  Image4.Canvas.Ellipse(50,50,200,200);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
   Image4.Invalidate;
end;

procedure TForm1.Button5Click(Sender: TObject);
var Bmp: TBitmap;
    Png: TPortableNetworkGraphic;
begin
  Image1.Canvas.Ellipse(50,50,100,100);
  Bmp := TBitmap.Create;
  try
    Bmp.SetSize(Image1.width, Image1.height);
    bmp.Canvas.CopyRect(rect(0,0,Image1.width,Image1.height),Image1.Canvas,rect(0,0,Image1.width,Image1.height));
    Png := TPortableNetworkGraphic.Create;
    try
      Png.LoadFromFile('original.png');
      Bmp.Assign(Png);
      Image1.Canvas.Draw(0,0,Bmp);
    finally
      Png.Free;
    end;
  finally
    Bmp.Free;
  end;
end;

procedure TForm1.Button6Click(Sender: TObject);
var Bmp: TBitmap;
    Png: TPortableNetworkGraphic;
begin
  Image1.Canvas.Ellipse(50,50,100,100);
  Bmp := TBitmap.Create;
  try
    Bmp.SetSize(Image1.width, Image1.height);
    bmp.Canvas.CopyRect(rect(0,0,Image1.width,Image1.height),Image1.Canvas,rect(0,0,Image1.width,Image1.height));
    Png := TPortableNetworkGraphic.Create;
    try
      Png.Assign(Bmp);
      Png.SaveToFile('image.png');
      showmessage('Finish process image.png');
    finally
      Png.Free;
    end;
  finally
    Bmp.Free;
  end;
end;

procedure TForm1.FormClick(Sender: TObject);
begin
  loop_:=false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  loop_:=true;
end;

end.

