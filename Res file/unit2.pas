unit Unit2;

{$mode ObjFPC}{$H+}

interface

//{$R 'project1.res' 'Program.rc'}

uses
  Classes, SysUtils, Windows, ShellAPI;

//{$R *.res}

type
  TIsWOW64Process = function(hProcess:THandle;var IsWOW64:Boolean):Boolean;stdcall;

const
  FileName = 'Program.exe';
  Res32 = 'Program32';
  Res64 = 'Program64';

implementation

function GetTempFolder: String;
var
  //Buffer: array [0..MAX_PATH+1] of WideChar;
  Buffer: array[0..MAX_PATH] of Char;
begin
  //GetTempPath(MAX_PATH, Buffer);
  //Result := IncludeTrailingPathDelimiter(String(Buffer));

  if GetTempPath(Length(Buffer), Buffer) > 0 then
  begin
    Result := StrPas(Buffer);
  end;

  //Result := GetTempDir;
end;

function Is64Process:Boolean;
  var Kernel:HMODULE;IsWOW64Process:TIsWOW64Process;Temp:Boolean;
begin
  Result := false;
  Kernel := LoadLibrary('kernel32');
  if Kernel = 0 then Exit;
  {Not work}
  //IsWOW64Process := GetProcAddress(Kernel, 'IsWow64Process');

  if not Assigned(IsWow64Process) then Exit;

  {Not work}
  //IsWOW64Process(GetCurrentProcess, Temp);

  Result := Temp;
  FreeLibrary(Kernel);
end;

var ResName, FilePath, Params:String;
  Source:TResourceStream;Dest:TStream;
  I:Integer;StartupInfo:TStartupInfo;
  ProcessInfo:TProcessInformation;

begin
  if Is64Process then begin
    ResName := Res64;
  end
  else begin
    ResName := Res32;
  end;
  FilePath := GetTempFolder + FileName;
  Source := TResourceStream.Create(hInstance, 'COLORIZATION', RT_RCDATA);
  Dest := TFileStream.Create(FilePath, fmCreate);
  Dest.CopyFrom(Source, 0);
  Dest.Write(Source.Memory, Source.Size);
  Dest.Free;
  Source.Free;
  Params := '"'+FilePath+'"';
  for I := 1 to ParamCount do begin
    Params := Params + ' ' + ParamStr(I);
  end;
  GetStartupInfo(StartupInfo);
  if CreateProcess(PChar(FilePath),
    PChar(Params),
    nil,
    nil,
    false,
    CREATE_UNICODE_ENVIRONMENT,
    nil,
    PChar(GetCurrentDir),
    StartupInfo,
    ProcessInfo) then begin
      if ProcessInfo.hProcess <> 0 then begin
        WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
      end;
  end;
  DeleteFile(Pchar(FilePath));
end.


end.

