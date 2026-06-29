unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type
  TMicro = class
  private

  public
    procedure Step; virtual; abstract;
  end;

  T65816Micro = class(TMicro)
    private
      procedure SetPort(AIndex: Integer; AValue: Byte);
    public
      procedure Step; override;
      property PA: Byte index 0 write SetPort;
      property PB: Byte index 1 write SetPort;
      property PC: Byte index 2 write SetPort;
  end;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  T6:T65816Micro;

implementation

{$R *.lfm}
procedure T65816Micro.SetPort(AIndex: Integer; AValue: Byte);
begin

end;

procedure T65816Micro.Step;
var
  b1:integer;
  b2:integer;
  fa:integer = 0;
  fb:integer = 0;
begin
  for b1 := $30 to $33 do
  begin
     for b2 := 0 to 255 do
     if (b2 <> $90) then
     begin
       if ((b2 and $8F) in [$88, $89, $8C, $8D, $8F]) then fa:=b2;
       if ((b2 and $8F) in [$89, $8D, $8F]) then fb:=b2;

     end;
  end;
  showmessage(fa.ToString);
  showmessage(fb.ToString);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  T6:=T65816Micro.Create;
  T6.PA:=$5f;

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  T6.Step;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  T6.Free;
end;

end.

