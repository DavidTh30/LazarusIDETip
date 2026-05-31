@echo off
SET THEFILE=C:\Users\root\Documents\Sender Receiver01\Dll\project1.dll
echo Linking %THEFILE%
C:\lazarus\fpc\3.2.2\bin\i386-win32\ld.exe -b pei-i386 -m i386pe  --gc-sections  -s --dll --subsystem windows --entry _DLLWinMainCRTStartup   --base-file base.$$$ -o "C:\Users\root\Documents\Sender Receiver01\Dll\project1.dll" "C:\Users\root\Documents\Sender Receiver01\Dll\link8704.res"
if errorlevel 1 goto linkend
C:\lazarus\fpc\3.2.2\bin\i386-win32\dlltool.exe -S C:\lazarus\fpc\3.2.2\bin\i386-win32\as.exe -D "C:\Users\root\Documents\Sender Receiver01\Dll\project1.dll" -e exp.$$$ --base-file base.$$$ 
if errorlevel 1 goto linkend
C:\lazarus\fpc\3.2.2\bin\i386-win32\ld.exe -b pei-i386 -m i386pe  -s --dll --subsystem windows --entry _DLLWinMainCRTStartup   -o "C:\Users\root\Documents\Sender Receiver01\Dll\project1.dll" "C:\Users\root\Documents\Sender Receiver01\Dll\link8704.res" exp.$$$
if errorlevel 1 goto linkend
C:\lazarus\fpc\3.2.2\bin\i386-win32\postw32.exe --subsystem gui --input "C:\Users\root\Documents\Sender Receiver01\Dll\project1.dll" --stack 16777216
if errorlevel 1 goto linkend
goto end
:asmend
echo An error occurred while assembling %THEFILE%
goto end
:linkend
echo An error occurred while linking %THEFILE%
:end
