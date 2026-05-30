unit unit01;

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
    Label1: TLabel;
    Memo1: TMemo;
    SimpleIPCClient1: TSimpleIPCClient;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure FindActiveServers();
  end;

var
  Form1: TForm1;

implementation
var
  i: integer;

{$R *.lfm}

{ TForm1 }

procedure TForm1.FindActiveServers();
var
  IPCClient: TSimpleIPCClient;
  CandidateIDs: array[0..3] of string;// Or array of string for older FPC versions
  SrvID: string;
begin
  // List of IDs you expect or want to test for
  //CandidateIDs := ['ServerOne', 'ServerTwo', 'AppInstance_123', 'MyServerID'];
  CandidateIDs[0]:='ServerOne';
  CandidateIDs[1]:='ipcTest1';
  CandidateIDs[2]:='AppInstance_123';
  CandidateIDs[3]:='MyServerID';

  IPCClient := TSimpleIPCClient.Create(nil);
  try
    for SrvID in CandidateIDs do
    begin
      IPCClient.ServerID := SrvID;
      //IPCClient.Global := True; // Match the Global setting of your servers

      if IPCClient.ServerRunning then
      begin
        Memo1.Append('Active server found with ID: '+ SrvID);
        //Writeln('Active server found with ID: ', SrvID);
        // You can now connect or send messages to this specific SrvID
      end;
    end;
  finally
    IPCClient.Free;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  SimpleIPCClient1.ServerID:='ipcTest1';
  if SimpleIPCClient1.ServerRunning then
  begin
    SimpleIPCClient1.Connect;
    inc(i);
    Label1.Caption:=IntToStr(i);
    SimpleIPCClient1.SendStringMessage(IntToStr(i)+': Test message from client');
    Memo1.Append('ServerInstance: '+SimpleIPCClient1.ServerInstance);
    SimpleIPCClient1.Disconnect;
  end
  else
  begin
    Memo1.Append('No server found.');
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  FindActiveServers();
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Memo1.Append('ServerInstance: '+SimpleIPCClient1.ServerInstance);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  i:=0;
  Label1.Caption:='';
end;

end.

