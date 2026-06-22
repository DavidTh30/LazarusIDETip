unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, pingsend, laz_synapse;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  myPingSend: TPingSend;
begin
   myPingSend := TPINGSend.Create;
  try
    myPingSend.Timeout := 2000; // 2 seconds timeout
    if myPingSend.Ping('google.com') = True then
      Label1.Caption:='Reply from ' + myPingSend.ReplyFrom + ' in: ' + IntToStr(myPingSend.PingTime) + ' ms'
    else
      Label1.Caption:='No response from host.';
  finally
    myPingSend.Free;
  end;

end;

procedure TForm1.Button2Click(Sender: TObject);
var
  myPingSend: TPingSend;
begin
   myPingSend := TPINGSend.Create;
  try
    myPingSend.Timeout := 2000; // 2 seconds timeout
    if myPingSend.Ping('127.0.0.1') = True then
      Label1.Caption:='Reply from ' + myPingSend.ReplyFrom + ' in: ' + IntToStr(myPingSend.PingTime) + ' ms'
    else
      Label1.Caption:='No response from host.';
  finally
    myPingSend.Free;
  end;

end;

procedure TForm1.Button3Click(Sender: TObject);
var
  myPingSend: TPingSend;
begin
   myPingSend := TPINGSend.Create;
  try
    myPingSend.Timeout := 2000; // 2 seconds timeout
    if myPingSend.Ping('0.0.0.0') = True then
      Label1.Caption:='Reply from ' + myPingSend.ReplyFrom + ' in: ' + IntToStr(myPingSend.PingTime) + ' ms'
    else
      Label1.Caption:='No response from host.';
  finally
    myPingSend.Free;
  end;

end;

end.

