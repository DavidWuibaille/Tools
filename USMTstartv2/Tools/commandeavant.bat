echo %1
::cscript "%~dp0GetLicenceAdobe.vbs" %1
::cscript "%~dp0GetLicenceOffice.vbs" %1
cscript "%~dp0ListPrinters.vbs" %1
cscript "%~dp0getAdministratorsMember.vbs" %1

ver | findstr /i "5\.1\." > nul
IF %ERRORLEVEL% EQU 0 goto DetectWinXP
Set Pathrob=robocopy
goto Robobocopy

:DetectWinXP
Set Pathrob="%~dp0robocopy.exe"
goto Robobocopy



:Robobocopy
set Patchback=%1
set Patchback=%Patchback:~0,-1%
echo %Patchback%
%Pathrob% c:\ %Patchback%\_C" /MIR /R:0 /XD c:\Windows /XD c:\temp /LOG:%Patchback%\Rob_BeforeC.log"

if "%~d0" == "D:" goto bypassd
if "%~d0" == "d:" goto bypassd
%Pathrob% d:\ %Patchback%\_D" /MIR /R:0 /LOG:%Patchback%\Rob_BeforeD.log"

:bypassd
%pathrob% c:\windows %patchback%\_C\windows" *.ini /E /LOG:%Patchback%\Rob_BeforeINI.log"

attrib -h -s %Patchback%\_C"
attrib -h -s %Patchback%\_D"
dir %Patchback%"