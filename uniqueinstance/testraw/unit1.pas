unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  UniqueInstance;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButCrashApp: TButton;
    Label1: TLabel;
    Label2: TLabel;
    UniqueInstance1: TUniqueInstance;
    procedure ButCrashAppClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UniqueInstance1OtherInstance(Sender: TObject;
      ParamCount: Integer; const Parameters: array of String);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

{$R *.lfm}

{$ifdef unix}
uses
  BaseUnix;
{$endif}

{$ifdef windows}
uses
  Windows;
{$endif}

{ TForm1 }

procedure TForm1.ButCrashAppClick(Sender: TObject);
begin
  {$ifdef unix}
  FpKill(FpGetpid, 9);
  {$endif}
  {$ifdef windows}
  TerminateProcess(GetCurrentProcess, 0);
  {$endif}
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Label1.Caption:='Last Active: '+TimeToStr(Time);
end;

procedure TForm1.UniqueInstance1OtherInstance(Sender: TObject;
  ParamCount: Integer; const Parameters: array of String);
begin
  showmessage('sdfsdf');
  Label1.Caption:='Last Active: '+TimeToStr(Time);
  BringToFront;
  //hack to force app bring to front
  FormStyle := fsSystemStayOnTop;
  FormStyle := fsNormal;
end;

initialization

end.

