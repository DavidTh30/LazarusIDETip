unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  IdTCPClient;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
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
  TcpClient: TIdTCPClient;
begin
  TcpClient := TIdTCPClient.Create(nil);
  try
    TcpClient.Host := '127.0.0.1'; // IP of the receiving Pascal app
    TcpClient.Port := 6000;
    TcpClient.Connect;
  try
    // Pass the DDE string you captured into the TCP stream
    TcpClient.IOHandler.WriteLn('DDE_Data_Payload_Here');
    // Read the response
      Memo1.Lines.Add(TcpClient.IOHandler.ReadLn);
  finally
    TcpClient.Disconnect;
    TcpClient.Free;
  end;
  except
    on E: Exception do
    begin
      ShowMessage('Error: ' + E.Message);
    end;

  end;
end;

end.

