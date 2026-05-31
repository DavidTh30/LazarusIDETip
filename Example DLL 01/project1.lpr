library  project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Classes, SysUtils, Forms, Dialogs;

{$R *.res}

procedure test; export;
begin
  Showmessage('test');
end;

procedure ShowDllMessage(AMessage: PChar); stdcall;
begin
  // Initialize Application context (crucial if DLL is called from non-VCL/LCL apps)
  //if not Assigned(Application) then
  //  Application.Initialize;

  // Show the message
  ShowMessage(AMessage);
end;

function MiFuncion(x_: double; y_: PChar): PChar;
var
  s :ansistring;
  //s: string; //puede ser asi tambien
begin

  // Initialize Application context (crucial if DLL is called from non-VCL/LCL apps)
  //if not Assigned(Application) then
  //  Application.Initialize;

  ShowMessage(y_);
  s := 'Hello ' + FloatToStr(x_) + ' ' + y_ + '!';
  result := PChar(s);
end;

function MiFuncion2(x_: double; y_: ansistring): ansistring;
var
  s :ansistring;
  //s: string; //puede ser asi tambien
begin

  // Initialize Application context (crucial if DLL is called from non-VCL/LCL apps)
  //if not Assigned(Application) then
  //  Application.Initialize;

  ShowMessage(y_);
  s := 'Hello ' + FloatToStr(x_) + ' ' + y_ + '!';
  result := s;
end;

function AddNumbers(a, b: Integer): Integer; {$ifdef win32} Stdcall;{$endif}
begin
  Result := a + b;
end;

exports
  {Work}
  //test, ShowDllMessage name 'ShowDllMessage';

  MiFuncion, test, ShowDllMessage, MiFuncion2, AddNumbers;
begin
      Application.Initialize;
end.


