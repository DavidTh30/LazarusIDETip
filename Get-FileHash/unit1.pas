unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  DCPcrypt2, DCPsha256, md5, HMAC, crc;

type

  { TForm1 }

  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  FullExecPath: String;
  ExecFileName: String;
  WorkDir:string;

  FileHashSHA256_ :string;
  FileHash: string;
  HmacSha1_:string;

  Digest: TMD5Digest;
  HexHash: String;

  FileCardinal: Cardinal;
  FileHexCRC32:string;

  MyArray: array[0..3] of Integer = (1,2,3,4);
  Checksum: Cardinal;

implementation

{$R *.lfm}
function CalculateCRC32(const Data: array of Integer): Cardinal;
var
  i, j: Integer;
  BytePtr: PByte;
  TotalBytes: Integer;
  CRC: Cardinal;
begin
  CRC := $FFFFFFFF;
  TotalBytes := Length(Data) * SizeOf(Integer);
  BytePtr := PByte(@Data[0]);

  for i := 0 to TotalBytes - 1 do
  begin
    CRC := CRC xor BytePtr^;
    for j := 0 to 7 do
    begin
      if (CRC and 1) <> 0 then
        CRC := (CRC shr 1) xor $EDB88320
      else
        CRC := CRC shr 1;
    end;
    Inc(BytePtr);
  end;

  Result := not CRC;
end;

function GetFileHashSHA256(const AFileName: String): String;
var
  SHA256: TDCP_sha256;
  Buffer: array[0..1024*64] of Byte; // 64KB buffer
  BytesRead: Integer;
  Stream: TFileStream;
  Digest: array[0..31] of Byte; // 32 bytes for SHA256
  i: Integer;
begin
  Result := '';
  Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  SHA256 := TDCP_sha256.Create(nil);
  try
    SHA256.Init;
    repeat
      BytesRead := Stream.Read(Buffer, SizeOf(Buffer));
      if BytesRead > 0 then
        SHA256.Update(Buffer, BytesRead);
    until BytesRead = 0;
    SHA256.Final(Digest);

    // Convert binary digest to Hex string
    for i := 0 to SizeOf(Digest) - 1 do
      Result := Result + IntToHex(Digest[i], 2);
  finally
    SHA256.Free;
    Stream.Free;
  end;
end;

function GetFileCRC32(const FileName: string): Cardinal;
var
  F: File;
  Buffer: array[1..4096] of Byte; // 4KB buffer for efficient file streaming
  BytesRead: Integer;
  CrcValue: Cardinal;
begin
  CrcValue := crc32(0, nil, 0); // Initialize CRC32 checksum

  AssignFile(F, FileName);
  Reset(F, 1); // Open file with a record size of 1 byte
  try
    repeat
      BlockRead(F, Buffer, SizeOf(Buffer), BytesRead); // Stream chunks
      if BytesRead > 0 then
        CrcValue := crc32(CrcValue, @Buffer[1], BytesRead); // Update hash incrementally
    until BytesRead = 0;
  finally
    CloseFile(F);
  end;

  Result := CrcValue;
end;


{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  FileTarget:string;
begin
  // Get the full path and name of the executable
  FullExecPath := ParamStr(0);

  // Extract just the file name (e.g., 'program.exe')
  ExecFileName := ExtractFileName(FullExecPath);

  //Current Working Directory
  WorkDir := GetCurrentDir;
  WorkDir := IncludeTrailingPathDelimiter(WorkDir);
  //showmessage(IncludeTrailingPathDelimiter(WorkDir));

  FileHashSHA256_:=GetFileHashSHA256(FullExecPath);
  FileHash:=MD5Print(MD5File(FullExecPath));

  HmacSha1_:=HMACSHA1Print(HMACSHA1Digest('', FullExecPath));

  // 1. Calculate the MD5 digest
  Digest := MD5String(FullExecPath);
  // 2. Convert the 16-byte binary digest into a 32-character Hex string
  HexHash := MD5Print(Digest);

  FileTarget:=WorkDir+'project1.ico';

  FileHexCRC32:=IntToHex(0, 8);
  if FileExists(FileTarget) then FileCardinal:= GetFileCRC32(FileTarget);
  if FileExists(FileTarget) then FileHexCRC32:=IntToHex(FileCardinal, 8);

  Checksum := CalculateCRC32(MyArray);
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  self.Canvas.TextOut(5,5,'HashSHA256: '+FileHashSHA256_);
  self.Canvas.TextOut(5,20,'FileHash: '+FileHash);
  self.Canvas.TextOut(5,35,'HmacSha1: '+HmacSha1_);
  self.Canvas.TextOut(5,50,'HexHash: '+HexHash);
  self.Canvas.TextOut(5,65,'FileCRC32: '+FileHexCRC32);
  self.Canvas.TextOut(5,80,'Checksum: '+IntToHex(Checksum, 8));
end;

end.

