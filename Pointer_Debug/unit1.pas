unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Global,
  dbugintf, Windows, Messages, LazLogger ;

type
  TMyProc = procedure;
  BOOL = boolean;
  INT = integer;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure HelloWorld;
begin
  Form1.Memo1.Append('Hello!');
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  ComputerStatus(Memo1);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  SendDebug('Initialize Success.');
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  //Default log file
  DebugLn('default output Code: '+ IntToHex(35, 8));

  //New log file
  DebugLogger.LogName:='debug1.log';
  DebugLn('in debug1.log file');
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  MY_LOG_GROUP: PLazLoggerLogGroup;
begin
  //initialization DebugLogger Register
  MY_LOG_GROUP := DebugLogger.FindOrRegisterLogGroup('grpname' {$IFDEF MY_LOG_GROUP_ON_BY_DEFAULT} , True {$ENDIF} );

  //Enable DebugLogger Register
  DebugLogger.FindOrRegisterLogGroup('grpname', True);

  //If Register  Enable
  debugln(MY_LOG_GROUP, 'log this text');
  debugln(MY_LOG_GROUP, ['a=',1,' b=',2]); // a,b must be basic types: integer, byte, ansistring. See types available for "array of const"
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  ProcPtr: TMyProc;
  Number: Integer;
  Ptr: ^Integer; // Pointer to an integer
  i:INT;
  myValue: Integer;
  myPointer: ^Integer; // Declare a pointer to an Integer

  adr1,adr2: pointer;

  p: pointer;             //valid to hold [Integer,Real,Boolean,Anytype] address
  ptrToInt  : PInteger;  // PInteger is a pointer type declared in the RTL
                         // which can only point to Integer value/variab
  ptrToInt2 : ^Integer;  // the general format for declaring a pointer type

  //PSmallInt           = ^Smallint;
  //PShortInt           = ^Shortint;
  //PInteger            = ^Integer;
  //PByte               = ^Byte;
  //PWord               = ^word;
  //PDWord              = ^DWord;
  //PLongWord           = ^LongWord;
  //PLongint            = ^Longint;
  //PCardinal           = ^Cardinal;
  //PQWord              = ^QWord;
  //PBoolean            = ^Boolean;

  s: string;

  Arr : Array[1..5] Of Integer;
begin
  ProcPtr := @HelloWorld; // Assigns address of procedure
  ProcPtr();             // Calls the procedure via pointer

  Number := 42;
  i:=5;
  Ptr := @Number;
  Memo1.Append('i: '+ i.ToString);
  Memo1.Append('Address Ptr: '+ HexStr(Ptr));
  Ptr := Addr(i);  // same Ptr := @i;
  Memo1.Append('Address Ptr: '+ HexStr(Ptr));
  Ptr := @i;   // same Ptr := Addr(i);
  Ptr^ := 12345;
  Memo1.Append('i: '+ i.ToString);
  Memo1.Append('Address Ptr: '+ HexStr(Ptr));

  Memo1.Append('---------------');
  myValue := 46;
  Memo1.Append(myValue.ToString);
  myPointer := @myValue;
  myPointer^ := 100;
  Memo1.Append(myValue.ToString);

  s:='asd';
  p := @Number;
  adr1:= @myValue;
  adr2 := @s;
  Memo1.Append('---------------');
  Memo1.Append('Address p: '+ HexStr(p));
  Memo1.Append('Address adr1: '+ HexStr(adr1));
  Memo1.Append('Address adr2: '+ HexStr(adr2));
  move(p,adr1,sizeof(adr1));
  Memo1.Append('---------------');
  Memo1.Append('Address p: '+ HexStr(p));
  Memo1.Append('Address adr1: '+ HexStr(adr1));
  Memo1.Append('Address adr2: '+ HexStr(adr2));
  move(p,adr2,sizeof(adr2));
  Memo1.Append('---------------');
  Memo1.Append('Address p: '+ HexStr(p));
  Memo1.Append('Address adr1: '+ HexStr(adr1));
  Memo1.Append('Address adr2: '+ HexStr(adr2));

  s:='';
  For i := 1 To 5 Do
  Begin
        Arr[i]:= 0;
        s:=s+Arr[i].ToString;
  End;
  Memo1.Append('---------------');
  Memo1.Append('Address s: '+ s);
  s:='';
  Ptr := @Arr[1];
  For i := 1 To 5 Do
  Begin
        Ptr^ := i;
        Inc(Ptr);
        s:=s+Arr[i].ToString;
  End;
  Memo1.Append('Address s: '+ s);

  Memo1.Append('---------------');
  p := @Number;
  Ptr := @Number;
  ptrToInt:= @Number;
  ptrToInt2:= @Number;
  Memo1.Append('Address p: '+ HexStr(p));
  Memo1.Append('Address Ptr: '+ HexStr(Ptr));
  Memo1.Append('Address ptrToInt: '+ HexStr(ptrToInt));
  Memo1.Append('Address ptrToInt2: '+ HexStr(ptrToInt2));
  //ptr^ // Error: Can't read or write variables of this type
  Memo1.Append('PInteger(ptr)^: '+IntToStr(PInteger(ptr)^));
  Memo1.Append('ptrToInt^: '+IntToStr(ptrToInt^));
  Memo1.Append('ptrToInt2^: '+IntToStr(ptrToInt2^));
  New(ptrToInt2);
  Memo1.Append('Address New(ptrToInt2): '+ HexStr(ptrToInt2));
  ptrToInt2^ := 5;
  //After you are done with the pointer, you must deallocate the memory space
  Dispose(ptrToInt2);
  Memo1.Append('Address New(ptrToInt2): '+ HexStr(ptrToInt2));
end;

end.

