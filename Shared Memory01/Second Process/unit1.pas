unit Unit1;

{$mode objfpc}{$H+}

interface

//HANDLE CreateFileMappingA(
//  [in]           HANDLE                hFile,
//  [in, optional] LPSECURITY_ATTRIBUTES lpFileMappingAttributes,
//  [in]           DWORD                 flProtect,
//  [in]           DWORD                 dwMaximumSizeHigh,
//  [in]           DWORD                 dwMaximumSizeLow,
//  [in, optional] LPCSTR                lpName
//);

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, windows;

type
  //{$ScopedEnum On}
  TChars = (
    a, c, g, t
  );

  ch_array = array[TChars] of 1..4;

type

  { TForm1 }

  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

const
BUF_SIZE = 256;
MEMORY_SIZE = 1024; // 1 KB
MAP_NAME = 'MySharedMemoryObject';
szName  = 'Global//MyFileMappingObject';
// Can't use 'Global\\MyFileMappingObject'
//szName  = 'Global\\MyFileMappingObject';

//{$MACRO ON}
//{$DEFINE BUF_SIZE := 256}

var
  Form1: TForm1;
  ca: ch_array;
  //Can't use Dynamic array of char
  //szName: array of TCHAR = ('G','l','o','b','a','l','\','\','M','Y');//TEXT("Global\\MyFileMappingObject");
  szMsg: array of TCHAR = ('M','e','s','s','a','g','e',' ','f','r'); //TEXT("Message from first process.");
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  hMapFile: THandle;
  pBuf: PChar;
begin
  ca[TChars.a] := 3;

  // 1. Create a file mapping object backed by system paging file
   hMapFile := CreateFileMapping(
    INVALID_HANDLE_VALUE, // Use paging file instead of an actual file
    nil,                  // Default security
    PAGE_READWRITE,       // Read/write access
    0,                    // Maximum object size (high-order DWORD)
    MEMORY_SIZE,          // Maximum object size (low-order DWORD)
    szName              // Name of mapping object
  );

  if hMapFile = 0 then
  begin
    //Writeln('Could not create file mapping object. Error: ', GetLastError);
    showmessage('Could not create file mapping object. Error:');
    Exit;
  end;

    pBuf := PChar(MapViewOfFile(
    hMapFile,            // Handle to map object
    FILE_MAP_ALL_ACCESS, // Read/write permission
    0,
    0,
    MEMORY_SIZE
  ));

  // 2. Map the view of the file into the address space of the current process
  if pBuf = nil then
  begin
    //Writeln('Could not map view of file. Error: ', GetLastError);
    showmessage('Could not map view of file. Error:');
    CloseHandle(hMapFile);
    Exit;
  end;

  // 3. Write data to the shared memory
  StrCopy(pBuf, 'Hello from Pascal File Mapping!');

  // 4. Clean up resources
  UnmapViewOfFile(pBuf);
  CloseHandle(hMapFile);
  //Writeln('Execution completed successfully.');
  showmessage('Execution completed successfully.');
end;

end.

