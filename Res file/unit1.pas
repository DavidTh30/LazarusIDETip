unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Unit2;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public
    procedure ExtractResFile(const ResName, OutputFilePath: string);
  end;

var
  Form1: TForm1;

const RT_RCDATA = MAKEINTRESOURCE(10);


implementation

{$R *.lfm}

procedure TForm1.ExtractResFile(const ResName, OutputFilePath: string);
var
  ResStream: TResourceStream;
  FileStream: TFileStream;
begin
  // Load the resource (replace 'RT_RCDATA' with your resource type if different)
  ResStream := TResourceStream.Create(HINSTANCE, ResName, RT_RCDATA);
  try
    // Create the destination file stream and save the resource content
    FileStream := TFileStream.Create(OutputFilePath, fmCreate);
    try
      FileStream.CopyFrom(ResStream, ResStream.Size);
    finally
      FileStream.Free;
    end;
  finally
    ResStream.Free;
  end;
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.Button1Click(Sender: TObject);
var
  ResStream: TResourceStream;
  MyDataList: TStringList;
begin
  ResStream := TResourceStream.Create(HINSTANCE, 'TEXTFILE', RT_RCDATA);
  MyDataList := TStringList.Create;
  try
    // 1. Load data from the resource
    MyDataList.LoadFromStream(ResStream);

    // 2. Modify data
    MyDataList.Add('Adding new line after loading');

    // 3. Save to a new file on the disk
    MyDataList.SaveToFile('SavedFile.txt');
  finally
    MyDataList.Free;
    ResStream.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Output: TFileStream;
  Resource: TResourceStream;
var
  Colorization: TProcess;
begin
  Output := TFileStream.Create('colorization.exe', fmCreate);
  Resource := TResourceStream.Create(HINSTANCE, 'COLORIZATION', RT_RCDATA);
  try
    Output.CopyFrom(Resource, Resource.Size);
  finally
    Output.Free();
    Resource.Free();
  end;

  Colorization := TProcess.Create(nil);
  try
    Colorization.Executable := 'colorization.exe';
    Colorization.Execute();
  finally
    Colorization.Free();
  end;
end;


end.

