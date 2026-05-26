unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  LCLIntf;

type

  { TfMain }

  TfMain = class(TForm)
    bOk: TButton;
    tmColor: TTimer;
    procedure bOkClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure tmColorTimer(Sender: TObject);
  private

  public

  end;

var
  fMain: TfMain;

implementation

{$R *.lfm}

{ TfMain }

procedure TfMain.bOkClick(Sender: TObject);
begin
  MessageDlg('Hi I''m the easter egg!', mtInformation, [mbOk], 0);
end;

function GetRandomColor: TColor;
begin
  Result := RGB(Random(255), Random(255), Random(255));
end;

procedure TfMain.FormPaint(Sender: TObject);
begin
  Canvas.Brush.Color := GetRandomColor;
  Canvas.FillRect(GetClientRect);
end;

procedure TfMain.tmColorTimer(Sender: TObject);
begin
  Self.Invalidate;
end;

end.

