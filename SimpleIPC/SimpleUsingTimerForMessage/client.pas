unit client;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, simpleipc, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Bevel1: TBevel;
    Button1: TButton;
    BtnSend: TButton;
    EdMessage: TEdit;
    Label1: TLabel;
    SimpleIPCClient1: TSimpleIPCClient;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure BtnSendClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
begin
  if Button1.Caption = 'Connect' then begin
    if Not SimpleIPCClient1.ServerRunning then begin exit; end;
    SimpleIPCClient1.Connect;
    Button1.Caption := 'Disconnect';
    BtnSend.Enabled := true;
  end else begin
    SimpleIPCClient1.Disconnect;
    Button1.Caption := 'Connect';
    BtnSend.Enabled := false;
  end;
end;

procedure TForm1.BtnSendClick(Sender: TObject);
begin
  if SimpleIPCClient1.ServerRunning then
    SimpleIPCClient1.SendStringMessage(EdMessage.Text)
  else
    ShowMessage('Not connected to server');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SimpleIPCClient1.ServerID := SERVER_ID;
  Caption := Format('IPC client (Server ID: %s, inactive)', [SERVER_ID]);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  s: String;
begin
  if SimpleIPCClient1.ServerRunning then
    s := 'running'
  else
    s := 'stopped';
  Caption := Format('IPC client (Server ID: %s, %s)', [SERVER_ID, s]);
end;

end.

