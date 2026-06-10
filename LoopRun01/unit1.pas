unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs;

type

  { TForm1 }

  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    procedure OnIdle(Sender: TObject; var Done: boolean);
  public

  end;

var
  Form1: TForm1;
  CurrentTime: LongInt;

implementation

{$R *.lfm}

{ TForm1 }
procedure TForm1.OnIdle(Sender: TObject; var Done: boolean);
begin
  Done := False;
  CurrentTime := GetTickCount;
  Form1.Canvas.TextOut(0,0,CurrentTime.ToString);

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Application.OnIdle := @OnIdle;
end;

end.

