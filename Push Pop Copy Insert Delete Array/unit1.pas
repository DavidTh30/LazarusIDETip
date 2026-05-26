unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private

  public

  end;

  type
  TIntArray = array of Integer;

var
  Form1: TForm1;
  MyStack: TIntArray;

implementation

{$R *.lfm}

{ TForm1 }

procedure Push(var Arr: TIntArray; Value: Integer);
begin
  SetLength(Arr, Length(Arr) + 1); // Expand the array
  Arr[High(Arr)] := Value;         // High() returns the last index
end;

//function Pop(var Arr: TIntArray): Integer;
procedure Pop(var Arr: TIntArray);
begin
  if Length(Arr) = 0 then
    raise Exception.Create('Stack underflow: Array is empty');

  //Result := Arr[High(Arr)];        // Get the last item
  SetLength(Arr, Length(Arr) - 1); // Shrink the array
end;

procedure TForm1.Button1Click(Sender: TObject);
begin

  //for i := low(n) to high(n) do


  Push(MyStack, 10);
  Push(MyStack, 20);
  Memo1.Append('LastArray: '+ MyStack[High(MyStack)].ToString); // Outputs: 20
  Pop(MyStack);
  Memo1.Append('LastArray: '+ MyStack[High(MyStack)].ToString); // Outputs: 10
  Memo1.Append('Length: '+ Length(MyStack).ToString);
  Memo1.Append('High: '+ High(MyStack).ToString);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Insert(99, MyStack, 0); // Inserts 99 at index 0
  Memo1.Append('FirstArray: '+ MyStack[Low(MyStack)].ToString);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if Pointer(MyStack) = nil then begin Memo1.Append('Array: nil'); exit; end;
  if Length(MyStack)<=0 then begin Memo1.Append('Array: Nothing to delete'); exit; end;
  Delete(MyStack, Length(MyStack)-1, 1); // Removes 1 elements starting at last index
  Memo1.Append('Array: deleted');
  if Length(MyStack)<=0 then begin Memo1.Append('Array: None'); exit; end;
  Memo1.Append('LastArray: '+ MyStack[High(MyStack)].ToString);
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  slice1: TIntArray;
begin
  slice1 := Copy(MyStack, Low(MyStack), High(MyStack));
  if Length(slice1)<=0 then begin Memo1.Append('Array slice1: None'); exit; end;
  Memo1.Append('slice1 Length: '+ Length(MyStack).ToString);
  Memo1.Append('slice1 LastArray: '+ MyStack[High(slice1)].ToString);
  slice1:=nil;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  slice1: TIntArray;
begin
  {Not work}
  Move(MyStack, slice1, SizeOf(MyStack)+(SizeOf(MyStack)*(Length(MyStack)-1)));
  Move(slice1, MyStack, SizeOf(slice1)+(SizeOf(slice1)*(Length(slice1)-1)));

  if Length(slice1)<=0 then begin Memo1.Append('Array slice1: None'); exit; end;
  Memo1.Append('slice1 Length: '+ Length(slice1).ToString);
  Memo1.Append('SizeOf slice1: '+ SizeOf(slice1).ToString);
  Memo1.Append('slice1 LastArray: '+ MyStack[High(slice1)].ToString);

  Memo1.Append('MyStack Length: '+ Length(MyStack).ToString);
  Memo1.Append('SizeOf MyStack: '+ SizeOf(MyStack).ToString);
  if Length(MyStack)<=0 then begin Memo1.Append('Array MyStack: None'); exit; end;
  Memo1.Append('MyStack LastArray: '+ MyStack[High(MyStack)].ToString);

end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  Memo1.Append('MyStack Length: '+ Length(MyStack).ToString);
  Memo1.Append('SizeOf MyStack: '+ SizeOf(MyStack).ToString);
  if Length(MyStack)<=0 then begin Memo1.Append('Array MyStack: None'); exit; end;
   Memo1.Append('MyStack Low: '+ Low(MyStack).ToString);
  Memo1.Append('MyStack High: '+ High(MyStack).ToString);
  Memo1.Append('MyStack FirstArray: '+ MyStack[Low(MyStack)].ToString);
  Memo1.Append('MyStack LastArray: '+ MyStack[High(MyStack)].ToString);
end;

end.

