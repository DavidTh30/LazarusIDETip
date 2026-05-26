unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TfMain }

  TfMain = class(TForm)
    bShow: TButton;
    procedure bShowClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    EEFileName: String;
  public

  end;

var
  fMain: TfMain;

implementation

uses ExeUnit, process;

{$R *.lfm}

{ TfMain }

procedure TfMain.bShowClick(Sender: TObject);
var
  EEStr: AnsiString;
  AProcess: TProcess;
begin
  EEStr := ReadStringFromExe(Application.ExeName);
  if EEStr = '' then
  begin
    MessageDlg('Cannot extract easter egg!', mtInformation, [mbOK], 0);
    Exit;
  end;

  if not StringToFile(EESTr, EEFileName) then
  begin
    MessageDlg('Cannot save easter egg to file!', mtInformation, [mbOK], 0);
    Exit;
  end;

  AProcess := TProcess.Create(nil);
  try
    AProcess.Executable:= EEFileName;
    AProcess.Options := AProcess.Options + [poWaitOnExit];
    AProcess.Execute;
  finally
    AProcess.Free;
  end;
  DeleteFile(EEFileName);
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  {$IFDEF WINDOWS}
    EEFileName := ExtractFilePath(Application.ExeName) + 'EE.exe';
  {$ELSE}
    EEFileName := ExtractFilePath(Application.ExeName) + 'EE';
  {$ENDIF}
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  if FileExists(EEFileName) then
    DeleteFile(EEFileName);
end;

end.

