unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  IdTCPClient;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Memo1: TMemo;
    SpinEdit1: TSpinEdit;
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
    TcpClient.Port := SpinEdit1.Value;
    TcpClient.Connect;
  try
    // Pass the DDE string you captured into the TCP stream
    TcpClient.IOHandler.WriteLn('DDE_Data_Payload_Here');
    // Read the response
    //Memo1.Lines.Add(TcpClient.IOHandler.ReadLn);
  finally
    TcpClient.Disconnect;
    Memo1.Lines.Add('TcpClient.Disconnect');
    TcpClient.Free;
    Memo1.Lines.Add('TcpClient.Free');
  end;
  except
    on E: Exception do
    begin
      //ShowMessage('Error: ' + E.Message);
      Memo1.Lines.Add('Error: ' + E.Message);
    end;

  end;
end;

end.

