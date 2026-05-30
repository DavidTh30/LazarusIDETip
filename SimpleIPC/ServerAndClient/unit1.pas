unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, simpleipc, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Edit1: TEdit;
    Memo1: TMemo;
    SimpleIPCClient1: TSimpleIPCClient;
    SimpleIPCServer1: TSimpleIPCServer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SimpleIPCServer1Message(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  i:integer;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  //SimpleIPCServer1.;
 i:=0;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  SimpleIPCServer1.ServerID:=Edit1.Text;
  SimpleIPCServer1.StartServer;
  SimpleIPCServer1.Active:=true;

  Memo1.Append('Server instanceID: '+SimpleIPCServer1.InstanceID);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  SimpleIPCClient1.ServerID:=Edit1.Text;
  if not SimpleIPCClient1.ServerRunning then  begin Memo1.Append('Can not connect to server');  exit; end;
  SimpleIPCClient1.Connect;
  SimpleIPCClient1.Active:=true;
  Memo1.Append('Connect to server: '+Edit1.Caption);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if not SimpleIPCClient1.ServerRunning then  begin Memo1.Append('Can not connect to server');  exit; end;
  SimpleIPCClient1.SendStringMessage('hello: '+i.ToString);
  i:=i+1;
  Memo1.Append('Message alaready send: '+Edit1.Caption);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Memo1.Append('PeekMessage: 100');
  if SimpleIPCServer1.PeekMessage(100,True) then
end;

procedure TForm1.SimpleIPCServer1Message(Sender: TObject);
begin
 Memo1.Append(SimpleIPCServer1.StringMessage);
end;

end.

