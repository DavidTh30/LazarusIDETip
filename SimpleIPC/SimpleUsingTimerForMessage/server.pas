unit server;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, simpleipc, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, dbugmsg, dbugintf;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Memo1: TMemo;
    SimpleIPCServer1: TSimpleIPCServer;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Edit1EditingDone(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SimpleIPCServer1Message(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

const
  SERVER_ID = 'ipc_server_123';

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  s: String;
begin
  if not SimpleIPCServer1.Active then begin
    SimpleIPCServer1.Active := true;
    Button1.Caption := 'Stop server';
    s := 'running';
    Timer1.Enabled := true;
  end else
  if SimpleIPCServer1.Active then begin
    Timer1.Enabled := false;
    SimpleIPCServer1.Active := false;
    s := 'stopped';
    Button1.Caption := 'Start server';
  end;
  Caption := Format('IPC server [ID: %s] - %s', [SimpleIPCServer1.ServerID, s]);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  //DebugServerID : string = ’fpcdebugserver’
  dbugmsg.DebugMessageName(1);
   SendDebug('Application started successfully.');
   SendDebugFmt('User logged in with ID: %d', [1045]);

end;

procedure TForm1.Edit1EditingDone(Sender: TObject);
begin
  SimpleIPCServer1.Active := false;
  SimpleIPCServer1.StopServer;
  SimpleIPCServer1.ServerID:=Edit1.Text;
  SimpleIPCServer1.StartServer;
  SimpleIPCServer1.Active := true;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  s: String;
begin
  SimpleIPCServer1.Global := true;
  SimpleIPCServer1.ServerID := SERVER_ID;
  Caption := Format('IPC Server [ID: %s]', [SimpleIPCServer1.ServerID]);
  Memo1.Clear;
end;

procedure TForm1.SimpleIPCServer1Message(Sender: TObject);
begin
  Memo1.Lines.Add(SimpleIPCServer1.StringMessage);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if SimpleIPCServer1.Active then
    SimpleIPCServer1.PeekMessage(100, true);
end;

end.

