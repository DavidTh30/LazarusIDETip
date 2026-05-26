unit ExeUnit;

interface

uses SysUtils, Classes;

  function FileToString(const AFileName: string): AnsiString;
  function StringToFile(const AStr: AnsiString; const AFileName: String): Boolean;
  function WriteStringToExe(const AFileName, AValue: AnsiString): Boolean;
  function ReadStringFromExe(const AFileName: String): AnsiString;

implementation

const
  Signature = '@#$%^';

type
  TData = record
    OriginalSize : Integer;
    Signature : Array[0..4] of char;
  end;

  TBuffer = array of char;

function FileToString(const AFileName: string): AnsiString;
var
  fs: TFileStream;
begin
  Result := '';
  if not FileExists(AFileName) then
    Exit;

  fs := TFileStream.Create(AFileName, fmOpenRead);
  try
    SetLength(Result, fs.Size);
    fs.Read(Pointer(Result)^, fs.Size);
  finally
    fs.Free;
  end;
end;

function StringToFile(const AStr: AnsiString; const AFileName: String): boolean;
var
  FS: TFileStream;
begin
  Result := False;
  FS := TFileStream.Create(AFileName, fmCreate or fmOpenWrite);
  try
    FS.Write(Pointer(AStr)^, Length(AStr));
    Result := FileExists(AFileName) and (FS.Size > 0);
  finally
    FS.Free;
  end;
end;

function SetExeData(FileName: AnsiString; Buffer: TBuffer): boolean;
var
  F: File;
  BufferSize, OriginalSize: Integer;
  Data: TData;
begin
  Result := True;
  AssignFile(F, FileName);
  Reset(F, 1);
  try
    try
      OriginalSize := FileSize(F);
      Seek(F, OriginalSize);
      BufferSize := Length(Buffer);
      BlockWrite(F, Pointer(Buffer)^, BufferSize);
      FillChar({%H-}Data, SizeOf(Data), 0);
      Data.OriginalSize := OriginalSize;
      Data.Signature := Signature;
      BlockWrite(F, Data, Sizeof(Data));
    except
      Result := False;
    end;
  finally
    CloseFile(F);
  end;
end;

function GetExeData(ExeName : AnsiString; var Buffer : TBuffer): boolean;
var
  F: File;
  CurrentSize, BufSize: Int64;
  OldFileMode: Int64;
  Data: TData;
begin
  Result := True;
  AssignFile(F, ExeName);
  OldFileMode := FileMode;
  FileMode := 0;
  try
    Reset(F, 1);
    try
      CurrentSize := FileSize(F);
      Seek(F, CurrentSize - SizeOf(Data));
      BlockRead(F, {%H-}Data, Sizeof(Data));
      if Data.Signature <> Signature then
        Result := False;
      if Result then
      begin
        BufSize := CurrentSize - Data.OriginalSize - SizeOf(Data);
        SetLength(Buffer, BufSize);
        Seek(F, Data.OriginalSize);
        BlockRead(F, Pointer(Buffer)^, BufSize);
      end;
    finally
      CloseFile(F);
    end;
  finally
    FileMode := OldFileMode;
  end;
end;

procedure StringToBuffer(const S: AnsiString; var Buffer: TBuffer);
begin
  SetLength(Buffer, Length(S)*SizeOf(Char));
  Move(Pointer(S)^, Pointer(Buffer)^, Length(S)*SizeOf(Char));
end;

function BufferToString(const Buffer: TBuffer): AnsiString;
begin
  SetLength(Result, Length(Buffer) div SizeOf(Char));
  Move(Pointer(Buffer)^, Pointer(Result)^, Length(Buffer)*SizeOf(Char));
end;

function WriteStringToExe(const AFileName, AValue: AnsiString): Boolean;
var
  Buffer: TBuffer;
begin
  if not FileExists(AFileName) then
  begin
    Result := False;
    Exit;
  end;

  StringToBuffer(AValue, {%H-}Buffer);
  Result := SetExeData(AFileName, Buffer);
end;

function ReadStringFromExe(const AFileName: AnsiString): AnsiString;
var
  Buffer: TBuffer;
begin
  if not FileExists(AFileName) then
  begin
    Result := '';
    Exit;
  end;

  if not GetExeData(AFileName, {%H-}Buffer) then
    Result := ''
  else
    Result := BufferToString(Buffer)
end;

end.
