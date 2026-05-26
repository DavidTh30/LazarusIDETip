unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Windows, ShellApi, Process;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

function RunAsAdmin(const Handle: Hwnd; const Path, Params: string): Boolean;
var
  sei: TShellExecuteInfoA;
begin
  FillChar(sei, SizeOf(sei), 0);
  sei.cbSize := SizeOf(sei);
  sei.Wnd := Handle;
  sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  sei.lpVerb := 'runas';
  sei.lpFile := PAnsiChar(Path);
  sei.lpParameters := PAnsiChar(Params);
  sei.nShow := SW_SHOWNORMAL;
  Result := ShellExecuteExA(@sei);
end;

// or a useful procedure:
procedure RunShellExecute(const prog,params:string);
begin
  //  ( Handle, nil/'open'/'edit'/'find'/'explore'/'print',   // 'open' isn't always needed
  //      path+prog, params, working folder,
  //        0=hide / 1=SW_SHOWNORMAL / 3=max / 7=min)   // for SW_ constants : uses ... Windows ...
  if ShellExecute(0,'open',PChar(prog),PChar(params),PChar(extractfilepath(prog)),1) >32 then; //success
  // return values 0..32 are errors
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  {Not work yet}
  //Click on Project > Project Options.Navigate to Application (or Compilation) settings and find the Execution Level drop-down.

  RunAsAdmin(Form1.Handle, 'rundll32.exe shell32.dll,Control_RunDLL appwiz.cpl', '');
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  AProcess: TProcess;
begin
  {Not work yet}
  //Click on Project > Project Options.Navigate to Application (or Compilation) settings and find the Execution Level drop-down.

  // Now we will create the TProcess object, and
  // assign it to the var AProcess.
  AProcess := TProcess.Create(nil);

  AProcess.Executable:= 'rundll32.exe';

  AProcess.Parameters.Add('shell32.dll,Control_RunDLL appwiz.cpl');

  // We will define an option for when the program
  // is run. This option will make sure that our program
  // does not continue until the program we will launch
  // has stopped running.                vvvvvvvvvvvvvv
  AProcess.Options := AProcess.Options + [poWaitOnExit];

  // Now let AProcess run the program
  AProcess.Execute;

  // This is not reached until ppc386 stops running.
  AProcess.Free;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  AProcess: TProcess;
begin
  // Now we will create the TProcess object, and
  // assign it to the var AProcess.
  AProcess := TProcess.Create(nil);

  AProcess.Executable:= 'EasterEgg.exe';

  AProcess.Parameters.Add('');

  // We will define an option for when the program
  // is run. This option will make sure that our program
  // does not continue until the program we will launch
  // has stopped running.                vvvvvvvvvvvvvv
  AProcess.Options := AProcess.Options + [poWaitOnExit];

  // Now let AProcess run the program
  AProcess.Execute;

  // This is not reached until ppc386 stops running.
  AProcess.Free;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  AProcess: TProcess;
begin
  // Now we will create the TProcess object, and
  // assign it to the var AProcess.
  AProcess := TProcess.Create(nil);

  AProcess.Executable:= 'EasterEgg.exe';

  AProcess.Parameters.Add('');

  // We will define an option for when the program
  // is run. This option will make sure that our program
  // does not continue until the program we will launch
  // has stopped running.                vvvvvvvvvvvvvv
  AProcess.Options := AProcess.Options;

  // Now let AProcess run the program
  AProcess.Execute;

  // This is not reached until ppc386 stops running.
  AProcess.Free;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  Process: TProcess;
  I: Integer;
begin
  Process := TProcess.Create(nil);
  try
    Process.InheritHandles := False;
    Process.Options := [];
    Process.ShowWindow := swoShow;

    // Copy default environment variables including DISPLAY variable for GUI application to work
    for I := 1 to GetEnvironmentVariableCount do
      Process.Environment.Add(GetEnvironmentString(I));

    Process.Executable := 'EasterEgg.exe';
    Process.Execute;
  finally
    Process.Free;
  end;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  
  // Simple one-liner (ignoring error returns) :
  if ShellExecute(0,nil, PChar('"prog.exe"'),PChar('"some_doc"'),nil,1) =0 then;

  // Execute a Batch File :
  if ShellExecute(0,nil, PChar('cmd'),PChar('/c Test.bat'),nil,1) =0 then;

  // Open a command window in a given folder :
  if ShellExecute(0,nil, PChar('cmd'),PChar('/k cd \path'),nil,1) =0 then;

  // Open a webpage URL in the default browser using 'start' command (via a brief hidden cmd window) :
  if ShellExecute(0,nil, PChar('cmd'),PChar('/c start www.lazarus.freepascal.org/'),nil,0) =0 then;
end;

end.

