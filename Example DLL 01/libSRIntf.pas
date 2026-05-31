unit libSRIntf; { (C) 2009 - 2012 cdbc.dk/Benny Christensen ~ www.cdbc.dk }
interface
{$define fpc}

{$ifdef fpc}
  {$mode objfpc}{$H+}
{$endif}
uses
  SysUtils,
  Classes
  {$ifdef fpc},dynlibs{$endif};

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
  { enumerator callback event, if result = false then break loop }
  Tsr_CallBack = function(SubItem: PSubItem;OwnerData,aHandle:pointer): boolean;
{ TEnumerateEvent = function(SubItem: PSubItem;OwnerData,aHandle:pointer): boolean of object; }
  TEnumerateEvent = procedure(aSubItem: PSubItem;var aCancel: boolean) of object;

  { function prototypes }
  Tsr_Init = function(var aHandle: pointer): boolean;
  Tsr_Version = function: pansichar;
  Tsr_LoadFromFile = function(aHandle: pointer;aFilename: pansichar;aFormat: integer): boolean;
  Tsr_MergeFiles = function(aHandle: pointer;aFilename1,aFilename2: pansichar;aFormat: integer): boolean;
  Tsr_Resync = function(aHandle: pointer;aFactor,IdEntrypoint,IdExitpoint: integer): boolean;
  Tsr_Edit_Entry = function(aHandle:pointer; anEntry: PSubItem): boolean;
  Tsr_Enumerate = function(aHandle,OwnerData:pointer;CallBack: Tsr_CallBack): boolean;
  Tsr_SaveToFile = function(aHandle: pointer;aFilename: pansichar;aFormat: integer): boolean;
  Tsr_Clear = function(aHandle: pointer): boolean;
  Tsr_Modified = function(aHandle: pointer): boolean; { property }
  Tsr_Count = function(aHandle: pointer): integer; { property }
  Tsr_Exit = function(var aHandle: pointer): boolean;

  { subtitle interface }
  ISubtitleResync = interface ['{A04810C3-FF43-48D9-B853-0F29BB6E2401}']
    function get_Count: cardinal;
    function get_Modified: boolean;
    function get_Version: string;
    function get_EnumerateEvent: TEnumerateEvent;
    procedure set_EnumerateEvent(const Value: TEnumerateEvent);
    function Clear: boolean;
    function LoadFromFile(const aFilename: ansistring;aFormat: integer): boolean;
    function Merge(const aFilename1,aFilename2: ansistring;aFormat: integer): boolean;
    function Resync(const aFactor,IdEntrypoint,IdExitpoint: integer): boolean;// positive => forwards, negative => backwards
    function Edit_Entry(anEntry: PSubItem): boolean;
    procedure Enumerate;
    procedure SaveToFile(const aFilename: ansistring;aFormat: integer);
    property OnEnumerate: TEnumerateEvent read get_EnumerateEvent write set_EnumerateEvent;
    property Modified: boolean read get_Modified;
    property Count: cardinal read get_Count;
    property Version: string read get_Version;
  end;

  TSubtitleResync = class(TInterfacedObject,ISubtitleResync)
  private
    fhLib: THandle;
    fhObj: pointer;
    fEnumerateEvent: TEnumerateEvent;
    fLibName: string;
    fInit: Tsr_Init;            { library functions }
    fLibVersion: Tsr_Version;
    fLoadFromFile: Tsr_LoadFromFile;
    fMergeFiles: Tsr_MergeFiles;
    fResync: Tsr_Resync;
    fEdit_Entry: Tsr_Edit_Entry; { edit one entry at a time }
    fEnumerate: Tsr_Enumerate; { enumerator }
    fSaveToFile: Tsr_SaveToFile;
    fClear: Tsr_Clear;
    fModified: Tsr_Modified; { property }
    fCount: Tsr_Count; { property }
    fExit: Tsr_Exit;
  protected
    function get_Count: cardinal;
    function get_Modified: boolean;
    function get_Version: string;
    function get_EnumerateEvent: TEnumerateEvent;
    procedure set_EnumerateEvent(const Value: TEnumerateEvent);
  public
    constructor Create(aLibraryPath: string);
    destructor Destroy; override;
    function Clear: boolean;
    function LoadFromFile(const aFilename: ansistring;aFormat: integer): boolean;
    function Merge(const aFilename1,aFilename2: ansistring;aFormat: integer): boolean;
    function Resync(const aFactor,IdEntrypoint,IdExitpoint: integer): boolean;// positive => forwards, negative => backwards
    function Edit_Entry(anEntry: PSubItem): boolean;
    procedure Enumerate;
    procedure SaveToFile(const aFilename: ansistring;aFormat: integer);
    property OnEnumerate: TEnumerateEvent read get_EnumerateEvent write set_EnumerateEvent;
    property Modified: boolean read get_Modified;
    property Count: cardinal read get_Count;
    property Version: string read get_Version;
  end;

function CreateSubtitleResync(const LibraryPath: string): ISubtitleResync;

implementation
{ factory function }
function CreateSubtitleResync(const LibraryPath: string): ISubtitleResync;
begin
  Result:= TSubtitleResync.Create(LibraryPath);
end;

{ links callback and interface event together }
function OnSubEntry(SubItem: PSubItem;OwnerData,aHandle:pointer): boolean;
var SR: TSubtitleResync;
begin
  Result:= true;
  SR:= TSubtitleResync(OwnerData);
  if assigned(SR.fEnumerateEvent) then begin
    SR.fEnumerateEvent(SubItem,Result);
    Result:= not Result;
  end else Result:= false;
end;

{ TSubtitleResync }
function TSubtitleResync.Clear: boolean;
begin
  Result:= fClear(fhObj);
end;

constructor TSubtitleResync.Create(aLibraryPath: string);
begin
  inherited Create;
  fLibName:= aLibraryPath + 'libsubresync.so';
  fhLib:= LoadLibrary(fLibName);  // pchar()
  if (fhLib <> 0) then begin // NilHandle
    pointer(fInit):=         GetProcedureAddress(fhLib,'sr_Init');
    pointer(fLibVersion):=   GetProcedureAddress(fhLib,'sr_Version');
    pointer(fLoadFromFile):= GetProcedureAddress(fhLib,'sr_LoadFromFile');
    pointer(fMergeFiles):=   GetProcedureAddress(fhLib,'sr_MergeFiles');
    pointer(fResync):=       GetProcedureAddress(fhLib,'sr_Resync');
    pointer(fEdit_Entry):=   GetProcedureAddress(fhLib,'sr_Edit_Entry');
    pointer(fEnumerate):=    GetProcedureAddress(fhLib,'sr_Enumerate');
    pointer(fSaveToFile):=   GetProcedureAddress(fhLib,'sr_SaveToFile');
    pointer(fClear):=        GetProcedureAddress(fhLib,'sr_Clear');
    pointer(fModified):=     GetProcedureAddress(fhLib,'sr_Modified');
    pointer(fCount):=        GetProcedureAddress(fhLib,'sr_Count');
    pointer(fExit):=         GetProcedureAddress(fhLib,'sr_Exit');
  end;
  fEnumerateEvent:= nil;
  fInit(fhObj);
end;

destructor TSubtitleResync.Destroy;
begin
  if (fhLib <> 0) then begin
    fExit(fhObj); { destroy the object, ref gets nil'ed in library }
    UnloadLibrary(fhLib); { tear down the lot }
    fhLib:= 0;
  end;
  inherited;
end;

function TSubtitleResync.Edit_Entry(anEntry: PSubItem): boolean;
begin
  Result:= fEdit_Entry(fhObj,anEntry);
end;

procedure TSubtitleResync.Enumerate;
begin
  fEnumerate(fhObj,pointer(Self),@OnSubEntry);
end;

function TSubtitleResync.get_Count: cardinal;
begin
  Result:= fCount(fhObj);
end;

function TSubtitleResync.get_EnumerateEvent: TEnumerateEvent;
begin
  Result:= fEnumerateEvent;
end;

function TSubtitleResync.get_Modified: boolean;
begin
  Result:= fModified(fhObj);
end;

function TSubtitleResync.get_Version: string;
begin
  Result:= fLibVersion();
end;

function TSubtitleResync.LoadFromFile(const aFilename: ansistring;aFormat: integer): boolean;
begin
  Result:= fLoadFromFile(fhObj,pansichar(aFilename),aFormat);
end;

function TSubtitleResync.Merge(const aFilename1, aFilename2: ansistring;aFormat: integer): boolean;
begin
  Result:= fMergeFiles(fhObj,pansichar(aFilename1),pansichar(aFilename2),aFormat);
end;

function TSubtitleResync.Resync(const aFactor, IdEntrypoint,IdExitpoint: integer): boolean;
begin
  Result:= fResync(fhObj,aFactor,IdEntrypoint,IdExitpoint);
end;

procedure TSubtitleResync.SaveToFile(const aFilename: ansistring;aFormat: integer);
begin
  fSaveToFile(fhObj,pansichar(aFilename),aFormat);
end;

procedure TSubtitleResync.set_EnumerateEvent(const Value: TEnumerateEvent);
begin
  fEnumerateEvent:= Value;
end;

end.