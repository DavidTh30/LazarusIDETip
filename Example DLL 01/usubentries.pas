unit usubentries;
{   uSubEntries defines and implements a business object for use in
    subtitle resync'ing.
    copyright (C) 2008-2011 cdbc.dk / Benny Christensen
}
{$define bds}
{.$define fpc}

{$ifdef fpc}
  {$mode objfpc}{$H+}
{$endif}
interface

uses
  Classes, SysUtils{$ifdef fpc},FileUtil{$endif};

const
  Version = {$ifdef bds}
              'Library libSubResync,'+
            {$else}
              'Subtitle Resync,'+
            {$endif}' Vers.:  10.20.02.2011, copyright (c) 2009-2011 cdbc.dk';

type
  { TSubFormat }
  TSubFormat = (sfSRT,sfSUB,sfNone);
  { TSubEntry }
  TSubEntry = class
  private
    fDone: TDateTime;
    fDuration: TDateTime;
    fId: integer;
    fSeparator: ansistring;
    fStart: TDateTime;
    fText: TStrings;
  protected
    function CorrectBrokenTimeline(var aString: string): boolean;  
    function get_AsString: ansistring;
    function get_Done: TDateTime;
    function get_DoneAsString: ansistring;
    function get_Duration: TDateTime;
    function get_Start: TDateTime;
    function get_StartAsMSecs: integer;
    function get_StartAsString: ansistring;
    function get_DurationAsString: ansistring;
    procedure set_AsString(const AValue: ansistring);
    procedure set_Done(const AValue: TDateTime);
    procedure set_DoneAsString(const AValue: ansistring);
    procedure set_Duration(const AValue: TDateTime);
    procedure set_Start(const AValue: TDateTime);
    procedure set_StartAsString(const AValue: ansistring);
    function get_IdAsString: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SlideByFactor(const aFactor: integer); // accepts negatives
    procedure SetTextAsString(aText: ansistring); { ex: 'string1|string2|string3' }
    property Id: integer read fId write fId;
    property IdAsString: string read get_IdAsString;
    property Start: TDateTime read get_Start write set_Start;
    property StartAsMSecs: integer read get_StartAsMSecs;
    property Done: TDateTime read get_Done write set_Done;
    property Duration: TDateTime read get_Duration write set_Duration;
    property Separator: ansistring read fSeparator write fSeparator;
    property Text: TStrings read fText write fText;
    property StartAsString: ansistring read get_StartAsString write set_StartAsString;
    property DoneAsString: ansistring read get_DoneAsString write set_DoneAsString;
    property DurationAsString: ansistring read get_DurationAsString;
    property AsString: ansistring read get_AsString write set_AsString;
  end; { TSubEntry }

  ISubEntriesEnumerator = interface ['{1FDF0FAD-69EC-419D-8F19-2117C826D44A}']
    function GetCurrent: TSubEntry;
    function MoveNext: Boolean;
    property Current: TSubEntry read GetCurrent;
  end;

  TSubEntries = class;
  TSubEntriesEnumerator = class(TInterfacedObject,ISubEntriesEnumerator)
  private
    fIndex: integer;
    fSubEntries: TSubEntries;
  public
    constructor Create(aList: TSubEntries);
    function GetCurrent: TSubEntry;
    function MoveNext: Boolean;
    property Current: TSubEntry read GetCurrent;
  end;

  { TSubEntries }
  TSubEntries = class
  private
    fFormat: TSubFormat;
    fList: TList;
    fMerging: boolean;
    fModified: boolean;
    fStrings: TStrings;
    fRecreateIds: boolean;
  protected
    function CheckFilename(const aFilename: ansistring): ansistring;
    function CheckForNullEntries: boolean;
    function OpenFromStream(const aFilename: ansistring): boolean; { 20.02.2011 }
    function get_Count: integer;
    function get_Entries(Index: integer): TSubEntry;
    procedure Parse_SRT_Format;
    procedure Parse_SUB_Format;
    procedure set_Entries(Index: integer; const AValue: TSubEntry);
    procedure Save_SRT_Format(const aFilename: ansistring);
    procedure Save_SUB_Format(const aFilename: ansistring);
    function get_Enumerator: ISubEntriesEnumerator;
  public
    constructor Create;
    destructor Destroy; override;
    function GetEnumerator: TSubEntriesEnumerator; { bds support for the 'for .. in' constuct }
    function GetEntryFromId(anId: integer): TSubEntry; { support for editing entries, returns nil if not found }
    procedure ClearEntries;
    function NewEntry: TSubEntry;
    function AddEntry(anEntry: TSubEntry): boolean;
    function LoadFromFile(const aFilename: ansistring;aFormat: TSubFormat): boolean;
    procedure Resync(const aFactor,IdEntrypoint,IdExitpoint: integer);// positive => forwards, negative => backwards
    procedure SaveToFile(const aFilename: ansistring;aFormat: TSubFormat);
    procedure Merge(const aFilename1,aFilename2: ansistring;aFormat: TSubFormat);
    property Count: integer read get_Count;
    property Entries[Index: integer]: TSubEntry read get_Entries write set_Entries; default;
    property Merging: boolean read fMerging write fMerging;
    property RecreateIds: boolean read fRecreateIds write fRecreateIds; { ææ 05.10.2010 }
    property Modified: boolean read fModified write fModified;
    property Enumerator: ISubEntriesEnumerator read get_Enumerator; { fpc doesn't support 'for in' constuct }
  end;

function GetFirstFieldToken(var S: ansistring; aToken: ansichar; out aResult: ansistring): boolean;

implementation
{ utility function }
function GetFirstFieldToken(var S: ansistring; aToken: ansichar; out aResult: ansistring): boolean;
var I: integer;
begin
  if length(S) > 0 then begin
    I:= 1;
    if S[Length(S)] <> aToken then S:= S + aToken; { append token for last field }
    while ((I < length(S)) and (S[I] <> aToken)) do inc(I);
    aResult:= copy(S,1,I-1);
    delete(S,1,I);
    Result:= true;
  end else Result:= false;
end; { GetFirstFieldToken }


{ TSubEntry }
function TSubEntry.get_Done: TDateTime;
begin
  Result:= fDone;
end;

function TSubEntry.get_DoneAsString: ansistring;
var
  h,m,s,ms: word;
  st: ansistring;
begin
  DecodeTime(fDone,h,m,s,ms);
  if h < 10 then st:= '0'+inttostr(h) else st:= inttostr(h);
  Result:= st+':';

  if m < 10 then st:= '0'+inttostr(m) else st:= inttostr(m);
  Result:= Result + st + ':';

  if s < 10 then st:= '0'+inttostr(s) else st:= inttostr(s);

  if ms < 10 then Result:= Result + st + ',00' + IntToStr(ms)
  else if ms < 100 then Result:= Result + st + ',0' + IntToStr(ms)
  else Result:= Result + st + ',' + IntToStr(ms);
end;

function TSubEntry.get_AsString: ansistring;
begin
  Result:= StartAsString + Separator + DoneAsString;
end;

function TSubEntry.get_Duration: TDateTime;
begin
  Result:= fDuration;
end;

function TSubEntry.get_Start: TDateTime;
begin
  Result:= fStart;
end;

function TSubEntry.get_StartAsMSecs: integer;
var
  h,m,s,ms: word;
begin
  DecodeTime(fStart,h,m,s,ms);
  Result:= ((h*3600000) + (m*60000) + (s*1000) + ms);
end;

// msecs per day = 86.400.000 -> 24 * 60 * 60 * 1000
// secs per day  =     86.400 -> 24 * 60 * 60
// mins per day  =      1.440 -> 24 * 60
// hours per day =         24
function TSubEntry.get_StartAsString: ansistring;
var
  h,m,s,ms: word;
  st: ansistring;
begin
  DecodeTime(fStart,h,m,s,ms);
  if h < 10 then st:= '0'+inttostr(h) else st:= inttostr(h);
  Result:= st+':';

  if m < 10 then st:= '0'+inttostr(m) else st:= inttostr(m);
  Result:= Result + st + ':';

  if s < 10 then st:= '0'+inttostr(s) else st:= inttostr(s);

  if ms < 10 then Result:= Result + st + ',00' + IntToStr(ms)
  else if ms < 100 then Result:= Result + st + ',0' + IntToStr(ms)
  else Result:= Result + st + ',' + IntToStr(ms);
end;

procedure TSubEntry.SetTextAsString(aText: ansistring);
var S: string;
begin
  Text.Clear;
  while GetFirstFieldToken(aText,'|',S) do begin
    Text.Add(trim(S));
  end;
end;

function TSubEntry.get_DurationAsString: ansistring;
var
  h,m,s,ms: word;
  st: ansistring;
begin
  DecodeTime(fDuration,h,m,s,ms);
  if h < 10 then st:= '0'+inttostr(h) else st:= inttostr(h);
  Result:= st+':';

  if m < 10 then st:= '0'+inttostr(m) else st:= inttostr(m);
  Result:= Result + st + ':';

  if s < 10 then st:= '0'+inttostr(s) else st:= inttostr(s);

  if ms < 10 then Result:= Result + st + ',00' + IntToStr(ms)
  else if ms < 100 then Result:= Result + st + ',0' + IntToStr(ms)
  else Result:= Result + st + ',' + IntToStr(ms);
end;

function TSubEntry.get_IdAsString: string;
begin
  Result:= IntToStr(fId);
end;

procedure TSubEntry.set_AsString(const AValue: ansistring);
begin
  StartAsString:= AValue;
  DoneAsString:= AValue;
end;

procedure TSubEntry.set_Done(const AValue: TDateTime);
begin
  fDone:= AValue;
  fDuration:= fDone - fStart;
end;

{ timeline
00:00:11,647 --> 00:01:20,647
broken line
00:09:00,190 --> 00:09:1,390
}
procedure TSubEntry.set_DoneAsString(const AValue: ansistring);
var
  h,m,s,ms: word;
  Tmp: TDateTime;
  St: string;
begin
  try
    h:= strtoint(copy(AValue,18,2));
    m:= strtoint(copy(AValue,21,2));
    s:= strtoint(copy(AValue,24,2));
    ms:= strtoint(copy(AValue,27,3));
  except
    St:= AValue;
    if CorrectBrokenTimeline(St) then begin
      h:= strtoint(copy(St,18,2));
      m:= strtoint(copy(St,21,2));
      s:= strtoint(copy(St,24,2));
      ms:= strtoint(copy(St,27,3));
    end;
  end;
  if not TryEncodeTime(h,m,s,ms,Tmp) then raise exception.Create('Error in "DoneAsString": Could not convert time!');
  Done:= Tmp;
end;

procedure TSubEntry.set_Duration(const AValue: TDateTime);
begin
  fDuration:= AValue;
end;

procedure TSubEntry.set_Start(const AValue: TDateTime);
begin
  fStart:= AValue;
end;

{ timeline
00:00:11,647 --> 00:01:20,647
broken line
00:09:00,190 --> 00:09:1,390
}
procedure TSubEntry.set_StartAsString(const AValue: ansistring);
var
  h,m,s,ms : word;
  Tmp: TDateTime;
  St: string;  
begin
  try
    h:= strtoint(copy(AValue,1,2));
    m:= strtoint(copy(AValue,4,2));
    s:= strtoint(copy(AValue,7,2));
    ms:= strtoint(copy(AValue,10,3));
  except
    St:= AValue;
    if CorrectBrokenTimeline(St) then begin
      h:= strtoint(copy(St,1,2));
      m:= strtoint(copy(St,4,2));
      s:= strtoint(copy(St,7,2));
      ms:= strtoint(copy(St,10,3));
    end;
  end;
  if not TryEncodeTime(h,m,s,ms,Tmp) then raise exception.Create('Error in "StartAsString": Could not convert time!');
  Start:= Tmp;
end;

function TSubEntry.CorrectBrokenTimeline(var aString: string): boolean;
const
  Digits = ['0','1','2','3','4','5','6','7','8','9'];
  Separators = [':',',','.','-','>',' '];
var
  St,Tmp: string;
begin
  Tmp:= ''; Result:= false;
  GetFirstFieldToken(aString,':',St);
  if length(St) = 2 then Tmp:= Tmp + St + ':' else Tmp:= Tmp + '0'+ St + ':'; { start-hour }
  GetFirstFieldToken(aString,':',St);
  if length(St) = 2 then Tmp:= Tmp + St + ':' else Tmp:= Tmp + '0'+ St + ':'; { start-minutes }
  GetFirstFieldToken(aString,',',St);
  if length(St) = 2 then Tmp:= Tmp + St + ',' else Tmp:= Tmp + '0'+ St + ','; { start-seconds }
  GetFirstFieldToken(aString,' ',St);
  if length(St) = 3 then Tmp:= Tmp + St + ' ' else Tmp:= Tmp + '0'+ St + ' '; { start-msec }
  Tmp:= Tmp + '--> '; { add separator }
  GetFirstFieldToken(aString,' ',St); { eat the separator }
  GetFirstFieldToken(aString,':',St);
  if length(St) = 2 then Tmp:= Tmp + St + ':' else Tmp:= Tmp + '0'+ St + ':'; { done-hour }
  GetFirstFieldToken(aString,':',St);
  if length(St) = 2 then Tmp:= Tmp + St + ':' else Tmp:= Tmp + '0'+ St + ':'; { done-minutes }
  GetFirstFieldToken(aString,',',St);
  if length(St) = 2 then Tmp:= Tmp + St + ',' else Tmp:= Tmp + '0'+ St + ','; { done-seconds }
  GetFirstFieldToken(aString,':',St);
  if length(St) = 3 then Tmp:= Tmp + St else Tmp:= Tmp + '0'+ St;             { done-msec }
  aString:= Tmp;
  Result:= true;
end;

constructor TSubEntry.Create;
begin
  inherited Create;
  fSeparator:= ' --> ';
  fText:= TStringList.Create;
end;

destructor TSubEntry.Destroy;
begin
  fText.Clear;
  fText.Free;
  inherited Destroy;
end;

// Time:=(Hour*3600000+Min*60000+Sec*1000+MSec)/MSecsPerDay;
// msecs:= Time * MSecsPerDay
procedure TSubEntry.SlideByFactor(const aFactor: integer);
begin
  Start:= fStart + (aFactor/MSecsPerDay);
  Done:= fDone + (aFactor/MSecsPerDay);
end;

{ TSubEntries }
(*
  scan through the entire file.
  If we hit an empty line, we are in state => smNew,
  smNew:  If we have a valid object, add it to the list of entries. Create a new entry.
          Move to state => smId.
  smId:	  We read the integer on that line into object.Id field. Move to state => smTime.
  smTime: We read the two time entries into object.Start and object.Done fields. Calculate object.Duration.
    	    Move to state => smText.
  smText: We read the line we're at into the object.Text.Add(Line).
    	    Stay in smText state.
*)
procedure TSubEntries.Parse_SRT_Format;
type
  TState = (smNone,smNew,smId,smTime,smText);
var
  State: TState;
  I,Id: integer;
  S: ansistring;
  Se: TSubEntry;
begin
  try if fStrings[fStrings.Count-1] <> '' then fStrings.Add(''); except end;
  try { try to figure out if we've got id's or not }
    Id:= 1;
    for I:= 0 to 99 do begin
      if length(trim(fStrings[I])) = 1 then inc(Id);
      if Id >= 9 then break;
    end;
    if Id = 1 then RecreateIds:= true; { well obviously not, we'll create id's }    
  except end;
  { special case for 1. st entry }
  if RecreateIds then State:= smTime else State:= smId;
  Se:= NewEntry;
  for I:= 0 to fStrings.Count-1 do begin
    S:= trim(fStrings[I]); // 'trim' returns widestring
    if S = '' then State:= smNew;
    case State of
      smNew:  begin
                if assigned(Se) then begin
                  AddEntry(Se);
                  if (Merging or RecreateIds) then Se.Id:= Count; // refit id's for merging ææ
                end;
                Se:= NewEntry;
                if RecreateIds then State:= smTime else State:= smId; { ææ 05.10.2010 }
              end;
      smId:   begin
                Se.Id:= strtoint(trim(S));
                State:= smTime;
              end;
      smTime: begin
                Se.AsString:= S;
                State:= smText;
              end;
      smText: begin
                Se.Text.Add(S);
              end;
    end;
  end;
  CheckForNullEntries;
end;

function TSubEntries.CheckFilename(const aFilename: ansistring): ansistring;
var I: integer;
begin
  Result:= aFilename;
  // 1. remove double backslashes
  I:= pos('\\',Result);
  while I <> 0 do begin
    delete(Result,I,1);
    I:= pos('\\',Result);
  end;
end;

function TSubEntries.CheckForNullEntries: boolean;
var
  I: integer;
  Se: TSubEntry;
begin { check sublist entries for null-values and remove them }
  for I:= fList.Count-1 downto 0 do begin
    Se:= TSubEntry(fList.Items[I]);
    if ((Se.Id = 0) and
        (Se.Start = 0.0) and
        (Se.Done = 0.0) and
        (Se.Text.Count = 0)) then begin
      FreeAndNil(Se);
      fList.Delete(I);
    end;
  end;
  Result:= true;
end;

function TSubEntries.get_Count: integer;
begin
  Result:= fList.Count;
end;

function TSubEntries.get_Entries(Index: integer): TSubEntry;
begin
  Result:= TSubEntry(fList.Items[Index]);
end;

function TSubEntries.get_Enumerator: ISubEntriesEnumerator;
begin
  Result:= TSubEntriesEnumerator.Create(Self);
end;

procedure TSubEntries.Parse_SUB_Format;
begin
  { TODO 1 -obc -cCleanUp : This will have to be done next }
end;

procedure TSubEntries.set_Entries(Index: integer; const AValue: TSubEntry);
begin
  // throw away for now...
end;

procedure TSubEntries.Save_SRT_Format(const aFilename: ansistring);
var
  I,Tc: integer;
  Sl: TStrings;
  Se: TSubEntry;
begin
  Sl:= TStringList.Create;
  try
    for I:= 0 to fList.Count-1 do begin
      Se:= TSubEntry(fList.Items[I]);
      Sl.Add(inttostr(Se.Id));
      Sl.Add(Se.AsString);
      if Se.Text.Count > 0 then for Tc:= 0 to Se.Text.Count-1 do Sl.Add(Se.Text[Tc]);
      Sl.Add('');
    end;
    // avoid multiple empty lines at the end of file
    I:= Sl.Count-1;
    while Sl[I] = '' do dec(I);
    while (Sl.Count-1) > I do Sl.Delete(Sl.Count-1);
    Sl.SaveToFile(aFilename);
    fModified:= false;
  finally
    Sl.Free;
  end;
end;

procedure TSubEntries.Save_SUB_Format(const aFilename: ansistring);
begin
  // ...
end;

constructor TSubEntries.Create;
begin
  inherited Create;
  fList:= TList.Create;
  fStrings:= TStringList.Create;
  fStrings.Add('');
  fModified:= false;
end;

destructor TSubEntries.Destroy;
begin
  ClearEntries;
  fStrings.Free;
  fList.Free;
  inherited Destroy;
end;

function TSubEntries.GetEntryFromId(anId: integer): TSubEntry;
var
  E: TSubEntry;
  {$ifndef bds} I: integer; {$endif}
begin
  Result:= nil;
{$ifdef bds}
  for E in Self do if E.Id = anId then begin
    Result:= E;
    break;
  end;
{$else}
  for I:= 0 to fList.Count-1 do begin
    E:= TSubEntry(fList[I]);
    if E.Id = anId then begin
      Result:= E;
      break;
    end;
  end;
{$endif}
end;

function TSubEntries.GetEnumerator: TSubEntriesEnumerator;
begin
  Result:= TSubEntriesEnumerator.Create(Self); { for .. in  support }
end;

procedure TSubEntries.ClearEntries;
var
  I: integer;
  Obj: TSubEntry;
begin
  for I:= fList.Count-1 downto 0 do begin
    Obj:= TSubEntry(fList[I]);
    FreeAndNil(Obj);
    fList.Delete(I);
  end;
  fList.Clear;
  fModified:= false;
end;

function TSubEntries.NewEntry: TSubEntry;
begin
  Result:= TSubEntry.Create;
end;

function TSubEntries.OpenFromStream(const aFilename: ansistring): boolean;
const
  Utf8_Bom = #$EF#$BB#$BF; { byte-order-mark added by notepad.exe f.ex. }
  Wide_Bom = #$FF#$FE;     { byte-order-mark for widestrings or Utf-16 } 
var
  Src: TStream;
  Utf8Bom: array[0..2] of char;
  aSize: int64;    
begin
  Result:= false;
  Src:= TFileStream.Create(aFilename,fmOpenRead or fmShareDenyNone);
  try
    Src.Position:= 0;
    Src.Read(Utf8Bom,3);
    if Utf8Bom = Utf8_Bom then begin
      { utf-8 encoded, leave stream position after bom marker }
      aSize:= Src.Size-3;
    end else begin { ansi encoded, reset stream position }
      Src.Position:= 0;
      aSize:= Src.Size;
    end;
    fStrings.LoadFromStream(Src);
    Result:= true;
  finally FreeAndNil(Src); end; 
end;

function TSubEntries.AddEntry(anEntry: TSubEntry): boolean;
begin
  fList.Add(anEntry);
  Result:= true;
  fModified:= true;
end;

function TSubEntries.LoadFromFile(const aFilename: ansistring;
                                  aFormat: TSubFormat): boolean;
begin
  Result:= false;
  if not Merging then ClearEntries;
  fFormat:= aFormat;
  fStrings.Clear;
//  fStrings.LoadFromFile(CheckFilename(aFilename)); { only ansi-support }
  if OpenFromStream(CheckFilename(aFilename)) then begin
    case aFormat of
      sfSRT: Parse_SRT_Format;
      sfSUB: Parse_SUB_Format;
    end;
    fStrings.Clear;
    fModified:= false;
    Result:= true;
  end;
end;

// positive factor => forwards, negative factor => backwards
// IdEntrypoint allows for mid-file resync'ing
// IdExitPoint = -1 means the whole file
procedure TSubEntries.Resync(const aFactor,IdEntrypoint,IdExitpoint: integer);
var I: integer;
begin
  if ((aFactor <> 0) and (IdEntrypoint < fList.Count) and (IdExitpoint = -1)) then
    for I:= IdEntrypoint to fList.Count-1 do TSubEntry(fList[I]).SlideByFactor(aFactor)
  else for I:= IdEntrypoint to IdExitpoint do TSubEntry(fList[I]).SlideByFactor(aFactor);
  fModified:= true;
end;

procedure TSubEntries.SaveToFile(const aFilename: ansistring; aFormat: TSubFormat);
begin
  case aFormat of
    sfSRT: Save_SRT_Format(aFilename);
    sfSUB: Save_SUB_Format(aFilename);
  end;
  fModified:= false;
end;

procedure TSubEntries.Merge(const aFilename1,
                                  aFilename2: ansistring;
                                  aFormat: TSubFormat);
var
  SaveId,SaveTime: integer;
begin
  Merging:= true; { bc 22.09.2009 relieves user of the task }
  LoadFromFile(aFilename1,aFormat);
  SaveId:= Count;
  SaveTime:= Entries[SaveId-1].StartAsMSecs; // in miliseconds
  LoadFromFile(aFilename2,aFormat);
  Resync(SaveTime,SaveId,-1); // resync second half.
  fModified:= true;
  Merging:= false; { bc 22.09.2009 relieves user of the task }
end;

{ TSubEntriesEnumerator }

constructor TSubEntriesEnumerator.Create(aList: TSubEntries);
begin
  inherited Create;
  fIndex:= -1;
  fSubEntries:= aList;
end;

function TSubEntriesEnumerator.GetCurrent: TSubEntry;
begin
  Result:= fSubEntries.Entries[fIndex];
end;

function TSubEntriesEnumerator.MoveNext: boolean;
begin
  Result:= fIndex < fSubEntries.Count-1;
  if Result then Inc(fIndex);
end;

end.

