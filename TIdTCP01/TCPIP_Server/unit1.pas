unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  IdTCPServer, IdContext, IdCustomTCPServer;

type

  { TForm1 }

  TForm1 = class(TForm)
    IdTCPServer1: TIdTCPServer;
    Memo1: TMemo;
    procedure IdTCPServer1Execute(AContext: TIdContext);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.IdTCPServer1Execute(AContext: TIdContext);
var
  ReceivedString: string;
begin
  // Read the string passed over TCP
  ReceivedString := AContext.Connection.IOHandler.ReadLn;
  if ReceivedString <> '' then
  begin
      Memo1.Lines.Add(ReceivedString);
  end;

  ReceivedString := AContext.Connection.Socket.ReadLn;

  if ReceivedString <> '' then
  begin
      Memo1.Lines.Add(ReceivedString);
  end;
end;

end.

