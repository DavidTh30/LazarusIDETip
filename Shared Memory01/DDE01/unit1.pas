unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Windows, Messages;

type

  { TForm1 }

  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

const
  APPCMD_CLIENTONLY = $00000010;
  CBF_FAIL_ALLSVRXACTIONS =$0003f000;
  DMLERR_NO_ERROR = $0;

var
  Form1: TForm1;
  InstId: DWORD;
  ResultCode: UINT;

  hszString: HSZ;
  Buffer: array[0..255] of AnsiChar;
  Length: DWORD;
  ResultString: string;

  g_hszAppName, g_hszTopicName, g_hszItemName: HSZ;

  hConv_: HCONV;

implementation

{$R *.lfm}

{ TForm1 }

// DDE Callback function
function DdeCallback(uType, uFmt: UINT; hConv: HCONV; hsz1, hsz2: HSZ;
  hData: HDDEDATA; dwData1, dwData2: DWORD): HDDEDATA; stdcall;
begin
  Result := 0;
  // Handle transactions here
  case uType of
    XTYP_CONNECT: Result := 1; // Return 1 to allow connection
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  //  // Initialize DDEML
  //ResultCode := DdeInitialize(
  //  @InstId,                     // Pointer to instance ID
  //  @DdeCallback,                // Callback function pointer
  //  APPCLASS_STANDARD or         // Application type flags
  //  CBF_FAIL_ALLSVRXACTIONS,     // Filter flags (example)
  //  0                            // Reserved
  //);
  ResultCode := DdeInitialize(@InstId, @DdeCallback, APPCLASS_STANDARD or APPCMD_CLIENTONLY, 0);  //APPCMD_TARGETONLY

   if ResultCode <> DMLERR_NO_ERROR then
   begin
     //WriteLn('DdeInitialize failed! Error code: ', IntToHex(ResultCode, 8));
     showmessage('DdeInitialize failed! Error code:');
   end;

    // Create string handles
  g_hszAppName := DdeCreateStringHandle(InstId, PAnsiChar('MyServerApp'), CP_WINANSI);
  g_hszTopicName := DdeCreateStringHandle(InstId, PAnsiChar('MyTopic'), CP_WINANSI);
  g_hszItemName := DdeCreateStringHandle(InstId, PAnsiChar('MyItem'), CP_WINANSI);

   // 'hszString' represents the string handle you obtained previously
  Length := DdeQueryString(InstId, hszString, Buffer, SizeOf(Buffer), CP_WINANSI);

  if Length > 0 then
  begin
    ResultString := string(Buffer);
    // ResultString now contains the string value
    showmessage('ResultString: '+ResultString);
  end;

  Length := DdeQueryString(InstId, g_hszAppName, Buffer, SizeOf(Buffer), CP_WINANSI);

  if Length > 0 then
  begin
    ResultString := string(Buffer);
    // ResultString now contains the string value
    showmessage('ResultString: '+ResultString);
  end;

  Length := DdeQueryString(InstId, g_hszTopicName, Buffer, SizeOf(Buffer), CP_WINANSI);

  if Length > 0 then
  begin
    ResultString := string(Buffer);
    // ResultString now contains the string value
    showmessage('ResultString: '+ResultString);
  end;

  Length := DdeQueryString(InstId, g_hszItemName, Buffer, SizeOf(Buffer), CP_WINANSI);

  if Length > 0 then
  begin
    ResultString := string(Buffer);
    // ResultString now contains the string value
    showmessage('ResultString: '+ResultString);
  end;

  hConv_ := DdeConnect(InstId, g_hszAppName, g_hszTopicName, nil);

  if hConv_ = 0 then
    ShowMessage('Connect bad')
  else
    ShowMessage('Connect OK Handle: ' + IntToStr(hConv_));

  //Free dde
  DdeFreeStringHandle(InstId, g_hszAppName);
  DdeFreeStringHandle(InstId, g_hszTopicName);
end;

end.

