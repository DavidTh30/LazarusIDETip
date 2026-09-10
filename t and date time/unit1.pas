unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public
    FStartTime: TDateTime;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  FStartTime:=Now;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  t: Double;
  t2:double;
  t3:double;
  MyDateTime: TDateTime;
begin
  t := (Now() - FStartTime) * SecsPerDay;
  t2 := (Now() - FStartTime);
  t3 := Now();
  MyDateTime:=t3;
  label1.Caption:='t= '+t.ToString;
  label2.Caption:=t2.ToString;
  label3.Caption:=t3.ToString;
  label4.Caption:=DateTimeToStr(MyDateTime);
end;

end.

