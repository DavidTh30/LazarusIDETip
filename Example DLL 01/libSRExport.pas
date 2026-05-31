(*  18.10.2009 bc changed typecast in 'Load', 'Merge' and 'Save' to ansistring
                  parameters are pansichar...
    28.10.2009 bc added support for editing entries by 'Id'.
    20.02.2011 bc added support for utf-8 bom (byte-order-marker) in
                  'OpenFromStream'.
    20.02.2011 bc added ability to recover from broken timelines,
                  rudimentary for now.

*)
unit libSRExport;
interface
{$define bds}
{.$define fpc}

{$ifdef fpc}
  {$mode objfpc}{$H+}
{$endif}
uses
  SysUtils,
  Classes,
  usubentries;

const
  SRT = 0;    { ~ TSubFormat }
  SUB = 1;
  None = 2;

type
  { callback data structure }
  PSubItem = ^TSubItem;
  TSubItem = record
    Id: pansichar;
    StartAsString: pansichar;
    DoneAsString: pansichar;
    DurationAsString: pansichar;
    Text: pansichar;
  end;
  { function prototype }
  TCallBack_SR = function(SubItem: PSubItem;OwnerData,aHandle:pointer): boolean; stdcall; { if false then break loop }

{ exported functions }

function sr_Init(var aHandle: pointer): boolean; stdcall;
function sr_Version: pansichar; stdcall;
function sr_LoadFromFile(aHandle: pointer;aFilename: pansichar;aFormat: integer): boolean; stdcall;
function sr_MergeFiles(aHandle: pointer;aFilename1,aFilename2: pansichar;aFormat: integer): boolean; stdcall;
function sr_Resync(aHandle: pointer;aFactor,IdEntrypoint,IdExitpoint: integer): boolean; stdcall;
function sr_Edit_Entry(aHandle:pointer; anEntry: PSubItem): boolean; stdcall;
function sr_Enumerate(aHandle,OwnerData:pointer;CallBack: TCallBack_SR): boolean; stdcall;
function sr_SaveToFile(aHandle: pointer;aFilename: pansichar;aFormat: integer): boolean; stdcall;
function sr_Clear(aHandle: pointer): boolean; stdcall;
function sr_Modified(aHandle: pointer): boolean; stdcall; { property }
function sr_Count(aHandle: pointer): integer; stdcall; { property }
function sr_Exit(var aHandle: pointer): boolean; stdcall;

implementation

function sr_Init(var aHandle: pointer): boolean; stdcall;
begin
  try
    usubentries.TSubEntries(aHandle):= usubentries.TSubEntries.Create;
    Result:= true; 
  except
    Result:= false;
    aHandle:= nil;
  end;
end;

function sr_Version: pansichar; stdcall;
begin
  Result:= pansichar(usubentries.Version);
end;

function sr_LoadFromFile(aHandle: pointer;aFilename: pansichar;aFormat: integer): boolean; stdcall;
begin
  try
    Result:= usubentries.TSubEntries(aHandle).LoadFromFile(ansistring(aFilename),TSubFormat(aFormat));
  except
    Result:= false;
  end;
end;

function sr_MergeFiles(aHandle: pointer;aFilename1,aFilename2: pansichar;aFormat: integer): boolean; stdcall;
begin
  try
    usubentries.TSubEntries(aHandle).Merge(ansistring(aFilename1),ansistring(aFilename2),TSubFormat(aFormat));
    Result:= true;
  except
    Result:= false;
  end;
end;

function sr_Resync(aHandle: pointer;aFactor,IdEntrypoint,IdExitpoint: integer): boolean; stdcall;
begin
  try
    usubentries.TSubEntries(aHandle).Resync(aFactor,IdEntrypoint,IdExitpoint);
    Result:= true;
  except
    Result:= false;
  end;
end;

function sr_Edit_Entry(aHandle:pointer; anEntry: PSubItem): boolean; stdcall;
var
  lId: integer;
  Entry: TSubEntry;
begin
  if assigned(anEntry) then begin
    lId:= strtoint(ansistring(anEntry^.Id));
    Entry:= usubentries.TSubEntries(aHandle).GetEntryFromId(lId); { get a reference to it }
    if assigned(Entry) then begin
      Entry.StartAsString:= ansistring(anEntry^.StartAsString);
      Entry.DoneAsString:= '                 ' + ansistring(anEntry^.DoneAsString); { timeline: 00:00:11,647 --> 00:01:20,647 }
      Entry.SetTextAsString(ansistring(anEntry^.Text));
      usubentries.TSubEntries(aHandle).Modified:= true;
      Result:= true;
    end else Result:= false;
  end else Result:= false;
end;

function sr_Enumerate(aHandle,OwnerData: pointer;CallBack: TCallBack_SR): boolean; stdcall;
var
  I,tc: integer;
  S: ansistring;
  SI: PSubItem;
begin
  Result:= true; {$ifdef fpc} SI:= nil; {$endif}
  getmem(SI,sizeof(TSubItem));
  fillchar(SI^,sizeof(TSubItem),0);
  try
    for I := 0 to  usubentries.TSubEntries(aHandle).Count-1 do begin
      SI^.Id:= pansichar(inttostr(usubentries.TSubEntries(aHandle)[I].Id));
      SI^.StartAsString:= pansichar(usubentries.TSubEntries(aHandle)[I].StartAsString);
      SI^.DoneAsString:= pansichar(usubentries.TSubEntries(aHandle)[I].DoneAsString);
      SI^.DurationAsString:= pansichar(usubentries.TSubEntries(aHandle)[I].DurationAsString);
      S:= '';
      if usubentries.TSubEntries(aHandle)[I].Text.Count > 0 then
        for tc:= 0 to usubentries.TSubEntries(aHandle)[I].Text.Count-1 do S:= S + usubentries.TSubEntries(aHandle)[I].Text[tc] + '|';
      S:= copy(S,1,length(S)-1); { skip the last pipe | }
      SI^.Text:= pansichar(S);
      if assigned(CallBack) then if not CallBack(SI,OwnerData,aHandle) then begin
        Result:= false;
        break;
      end;
      fillchar(SI^,sizeof(TSubItem),0);
    end;
  finally
    freemem(SI);
  end;
end;

function sr_SaveToFile(aHandle: pointer;aFilename: pansichar;aFormat: integer): boolean; stdcall;
begin
  try
    usubentries.TSubEntries(aHandle).SaveToFile(ansistring(aFilename),TSubFormat(aFormat));
    usubentries.TSubEntries(aHandle).Modified:= false;
    Result:= true;
  except
    Result:= false;
  end;
end;

function sr_Clear(aHandle: pointer): boolean; stdcall;
begin
  try
    usubentries.TSubEntries(aHandle).ClearEntries;
    Result:= true;
  except
    Result:= false;
  end;
end;

function sr_Modified(aHandle: pointer): boolean; stdcall; { property }
begin
  Result:= usubentries.TSubEntries(aHandle).Modified;
end;

function sr_Count(aHandle: pointer): integer; stdcall; { property }
begin
  Result:= usubentries.TSubEntries(aHandle).Count;
end;

function sr_Exit(var aHandle: pointer): boolean; stdcall;
begin
  try
    usubentries.TSubEntries(aHandle).Free;
    aHandle:= nil;
    Result:= true;
  except
    Result:= false;
  end;
end;

end.
