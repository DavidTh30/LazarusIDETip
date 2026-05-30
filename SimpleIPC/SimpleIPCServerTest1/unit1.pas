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
    Edit1: TEdit;
    Label2: TLabel;
    Memo1: TMemo;
    SimpleIPCServer1: TSimpleIPCServer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit1EditingDone(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SimpleIPCServer1Message(Sender: TObject);
    procedure SimpleIPCServer1MessageQueued(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.SimpleIPCServer1Message(Sender: TObject);
var
  s: string;
begin
  Memo1.Append('SimpleIPCServer1Message:');
  //s:=SimpleIPCServer1.StringMessage;
  //Label1.Caption:=s;
end;

procedure TForm1.SimpleIPCServer1MessageQueued(Sender: TObject);
var
  s: string;
begin
  Memo1.Append('SimpleIPCServer1MessageQueued:');
  SimpleIPCServer1.ReadMessage;
  s:=SimpleIPCServer1.StringMessage;
  Memo1.Append(s);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SimpleIPCServer1.ServerID:='ipcTest1';
  SimpleIPCServer1.Global:=true;
  SimpleIPCServer1.StartServer;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  if SimpleIPCServer1.Active then Label2.Caption:='Active';
  if not SimpleIPCServer1.Active then Label2.Caption:='not Active';
end;

procedure TForm1.Button1Click(Sender: TObject);
begin

  SimpleIPCServer1.Active:=not SimpleIPCServer1.Active;
  if SimpleIPCServer1.Active then Label2.Caption:='Active';
  if not SimpleIPCServer1.Active then Label2.Caption:='not Active';
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Memo1.Append(SimpleIPCServer1.InstanceID);
  //if (SimpleIPCServer1.Message.StringMessage=nil) then exit;
  //Memo1.Append(SimpleIPCServer1.Message.StringMessage);
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin

end;

procedure TForm1.Edit1EditingDone(Sender: TObject);
begin
  SimpleIPCServer1.Active := false;
  SimpleIPCServer1.StopServer;
  SimpleIPCServer1.ServerID:=Edit1.Text;
  SimpleIPCServer1.StartServer;
  SimpleIPCServer1.Active := true;
end;

end.

