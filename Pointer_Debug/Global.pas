unit Global;

{$mode ObjFPC}{$H+}

interface
uses
  Classes, SysUtils, StdCtrls, Dialogs, Math, Windows, Messages;

Type
  Reorganize = Record
    ComponentStoryNumber_:string;
    StoreCodeNumber_:string;
    Fault_:boolean;
    GetTotal:integer;
    Found_:boolean;
    end;

generic procedure abcd();
function BoolToInt(State:boolean):Integer;
function IntToBool(State:Integer):boolean;
Function StrToBoolV2(BoolS_:string):boolean;
Function ErrorEvenToBoolean(ErrorEven:string):string;
Function ErrorEvenToCode(ErrorEven:string):string;
Function BoolS_CodeToErrorEven(BoolS_:string;Code_:string):string;
Function Bool_CodeToErrorEven(Bool_:boolean;Code_:string):string;
procedure ComputerStatus(Debug_:TMemo);
//----------------------------------------------------------------

type
  StoreSimulation = class
    //procedure SaveAs1ButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure Init_();
    procedure InitialTypeOfFlag();
    procedure InitialHeader();

  end;


var
    g_lInstID : Long;
    g_hService : Long;
    g_hService2 : Long;
    g_hTopic : Long;
    g_hTopic2 : Long;
    g_hItem : Long;
    g_hDDEConv : Long;
    g_hDDEConvList : Long;
    g_hDDEPrevConv : Long;


implementation

generic procedure abcd();
begin
  Showmessage('abcd');
end;

function BoolToInt(State:boolean):Integer;
begin
  result:=0;
  if(State)then result:=1;
  if(not State)then result:=0;
end;

function IntToBool(State:Integer):boolean;
begin
  result:=false;
  if(State>0)then result:=true;
  if(State<=0)then result:=false;
end;

Function StrToBoolV2(BoolS_:string):boolean;
begin
  //[Remark boolean as string]
  //input 1.) 'true'
  //input 2.) '1'
  //input 2.) '-1'
  //result:= true/false
  if((LowerCase(BoolS_)='true')or(LowerCase(BoolS_)='1')or(LowerCase(BoolS_)='-1')) then
  result:= true
  else
  result:= false;
end;

Function ErrorEvenToBoolean(ErrorEven:string):string;
begin
  //[Remark error events]
  //input 1.) '[1]YYYYMMDDhhnnss' =3+14
  //input 2.) '[0]YYYYMMDDhhnnss' =3+14
  //input 3.) '[1]0' =3+1
  //input 4.) '[0]0' =3+1
  //input 5.) ''
  //result:= 'true','false','YYYYMMDDhhnnss','','error'

  result:= 'error';
  if((length(ErrorEven)<>17)and(length(ErrorEven)<>4)and(ErrorEven<>'0')and(ErrorEven<>'1')and(ErrorEven<>'-1')and(ErrorEven<>''))then exit;
  if(ErrorEven='')then begin result:='false'; exit; end;
  if(ErrorEven='0')then begin result:='false'; exit; end;
  if(ErrorEven='1')then begin result:='true'; exit; end;
  if(ErrorEven='-1')then begin result:='true'; exit; end;
  if((length(ErrorEven)=17)or(length(ErrorEven)=4))then
  begin
    if((LeftStr(ErrorEven,1)<>'[') or (RightStr(LeftStr(ErrorEven,3),1)<>']'))then exit;
    if ((RightStr(LeftStr(ErrorEven,2),1)='1') or (RightStr(LeftStr(ErrorEven,3),2)='-1')) then result:= 'true'  else result:= 'false';
  end;
end;

Function ErrorEvenToCode(ErrorEven:string):string;
begin
  //[Remark error events]
  //input 1.) '[1]YYYYMMDDhhnnss' =3+14
  //input 2.) '[0]YYYYMMDDhhnnss' =3+14
  //input 3.) '[1]0' =3+1
  //input 4.) '[0]0' =3+1
  //input 5.) ''
  //result:= 'true','false','YYYYMMDDhhnnss','','error'

  result:= 'error';
  if((length(ErrorEven)<>17)and(length(ErrorEven)<>4)and(ErrorEven<>''))then exit;
  if((ErrorEven='')or(length(ErrorEven)=4))then begin result:=''; exit; end;
  if(length(ErrorEven)=17)then
  begin
    if((LeftStr(ErrorEven,1)<>'[') or (RightStr(LeftStr(ErrorEven,3),1)<>']'))then exit;
    result:= RightStr(ErrorEven,14);
  end;
end;

Function BoolS_CodeToErrorEven(BoolS_:string;Code_:string):string;
begin
  //[Remark error events]
  //input 1.) '[1]YYYYMMDDhhnnss' =3+14
  //input 2.) '[0]YYYYMMDDhhnnss' =3+14
  //input 3.) '[1]0' =3+1
  //input 4.) '[0]0' =3+1
  //input 5.) ''
  //result:= 'true','false','YYYYMMDDhhnnss','','error'

  result:= 'error';
  if((length(BoolS_)=2)and(BoolS_='-1'))then BoolS_:='1';
  if((length(BoolS_)<>3)and(length(BoolS_)<>1))then exit;
  if((length(Code_)<>14)and(length(Code_)<>1)and(Code_<>''))then exit;
  if((length(Code_)=1)and(Code_<>'0'))then exit;
  if((length(BoolS_)=1)and(BoolS_<>'0')and(BoolS_<>'1'))then exit;
  if((length(BoolS_)=3)and(LeftStr(BoolS_,1)<>'[') or (RightStr(BoolS_,1)<>']'))then exit;
  if((length(BoolS_)=3)and(RightStr(LeftStr(BoolS_,2),1)<>'1')and(RightStr(LeftStr(BoolS_,2),1)<>'0'))then exit;
  if((length(BoolS_)=3)and(length(Code_)=14))then result:= BoolS_+Code_;
  if((length(BoolS_)=3)and(Code_='0'))then result:= '['+BoolS_+']0';
  if((length(BoolS_)=3)and(Code_=''))then result:= '['+BoolS_+']0';
  if((length(BoolS_)=1)and(length(Code_)=14))then result:= '['+BoolS_+']'+Code_;
  if((length(BoolS_)=1)and(length(Code_)=1))then result:= '['+BoolS_+']0';
  if((length(BoolS_)=1)and(Code_=''))then result:= '['+BoolS_+']0';
end;

Function Bool_CodeToErrorEven(Bool_:boolean;Code_:string):string;
begin
  //[Remark error events]
  //input 1.) '[1]YYYYMMDDhhnnss' =3+14
  //input 2.) '[0]YYYYMMDDhhnnss' =3+14
  //input 3.) '[1]0' =3+1
  //input 4.) '[0]0' =3+1
  //input 5.) ''
  //result:= 'true','false','YYYYMMDDhhnnss','','error'

  result:= 'error';
  if((length(Code_)<>14)and(length(Code_)<>1)and(Code_<>''))then exit;
  if((length(Code_)=1)and(Code_<>'0'))then exit;
  if ((Bool_)and(length(Code_)=14)) then result:= '[1]'+Code_;
  if ((not Bool_)and(length(Code_)=14)) then result:= '[0]'+Code_;
  if ((Bool_)and((length(Code_)=1) or (Code_=''))) then result:= '[1]0';
  if ((not Bool_)and((length(Code_)=1) or (Code_=''))) then result:= '[0]0';
end;

procedure StoreSimulation.Init_();
begin

end;

procedure StoreSimulation.InitialTypeOfFlag();
var
  C_FNAME: string;
  //Directory:string;
  tfOut: TextFile;
  i: integer;
  MyFile: File;
begin

end;

procedure StoreSimulation.InitialHeader();
var
  C_FNAME: string;
  //Directory:string;
  tfOut: TextFile;
  i: integer;
  FileSize_:integer;
  MyFile: File;
begin

end;

procedure ComputerStatus(Debug_:TMemo);
begin
  //LineEnding =  CRLF, #13#10
  //Lazarus: Get current Line Index from Memo
  //Line   := Debug_.Perform(EM_LINEFROMCHAR, Memo1.SelStart, 0) ;
  //Column := Debug_.SelStart - Memo1.Perform(EM_LINEINDEX, Line, 0) ;
  //Line   := Debug_.CaretPos.Y;
  //Column := Debug_.CaretPos.X;

  Debug_.Append({$I %line%} + ' CURRENTROUTINE:'+{$I %CURRENTROUTINE%});
  Debug_.Append({$I %line%} + ' DATE:' + {$I %DATE%});
  Debug_.Append({$I %line%} + ' DATEYEAR-DATEMONTH-DATEDAY:' + IntToStr({$I %DATEYEAR%}) +'-'+ IntToStr({$I %DATEMONTH%}) +'-'+ IntToStr({$I %DATEDAY%}));
  Debug_.Append({$I %line%} + ' FPCTARGET:' + {$I %FPCTARGET%});
  Debug_.Append({$I %line%} + ' FPCTARGETCPU:' + {$I %FPCTARGETCPU%});
  Debug_.Append({$I %line%} + ' FPCTARGETOS:' + {$I %FPCTARGETOS%});
  Debug_.Append({$I %line%} + ' FPCVERSION :' + {$I %FPCVERSION%});
  Debug_.Append({$I %line%} + ' FILE:' + {$I %FILE%});
  Debug_.Append({$I %line%} + ' TIME:' + {$I %TIME%});
  Debug_.Append({$I %line%} + ' TIMEHOUR-TIMEMINUTE-TIMESECOND :' + IntToStr({$I %TIMEHOUR%}) +'-'+ IntToStr({$I %TIMEMINUTE%}) +'-'+ IntToStr({$I %TIMESECOND%}));

end;

end.


