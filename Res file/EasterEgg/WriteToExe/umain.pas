unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TfMain }

  TfMain = class(TForm)
    bTargetExe: TButton;
    bEasterEgg: TButton;
    bWrite: TButton;
    edTargetExe: TEdit;
    edEasterEgg: TEdit;
    lbTargetExe: TLabel;
    lbEasterEgg: TLabel;
    OD: TOpenDialog;
    procedure bTargetExeClick(Sender: TObject);
    procedure bWriteClick(Sender: TObject);
  private

  public

  end;

var
  fMain: TfMain;

implementation

uses ExeUnit;

{$R *.lfm}

{ TfMain }

procedure TfMain.bTargetExeClick(Sender: TObject);
begin
  if OD.Execute then
  case TButton(Sender).Tag of
    0: edTargetExe.Text := OD.FileName;
    1: edEasterEgg.Text := OD.FileName;
  end;
end;

procedure TfMain.bWriteClick(Sender: TObject);
var
  EEStr: AnsiString;
begin
  if not FileExists(edTargetExe.Text) then
  begin
    MessageDlg('Target exe not found!', mtInformation, [mbOk], 0);
    Exit;
  end;

  EEStr := FileToString(edEasterEgg.Text);
  if EEStr = '' then
  begin
    MessageDlg('Cannot convert easter egg to string!', mtInformation, [mbOk], 0);
    Exit;
  end;

  if WriteStringToExe(edTargetExe.Text, EEStr) then
    MessageDlg('Easter egg successfully written to exe file!', mtInformation, [mbOk], 0)
  else
    MessageDlg('Cannot write easter egg to exe file!', mtInformation, [mbOk], 0);
end;


end.

