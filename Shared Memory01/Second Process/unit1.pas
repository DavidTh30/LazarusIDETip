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
  myString: String;
begin

  // 1. Create a file mapping object backed by system paging file
   hMapFile := OpenFileMapping(
    FILE_MAP_ALL_ACCESS,    // read/write access
    FALSE,                 // do not inherit the name
    szName               // name of mapping object
  );

  if hMapFile = 0 then
  begin
    //Writeln('Could not open file mapping object Error: ', GetLastError);
    showmessage('Could not open file mapping object Error:');
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

  if pBuf <> nil then
  begin
    myString := String(pBuf);
    //showmessage('Sender PID: '+ pBuf^.ProcessID);
    //showmessage('Message: '+ pBuf^.Message);
    showmessage('Message: '+myString);
    UnmapViewOfFile(pBuf);
  end;
  CloseHandle(hMapFile);

end;

end.

