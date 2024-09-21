net user Proservia1 /delete
echo %1

cscript "%~dp0setAdministratorsMember.vbs" %1

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

%Pathrob% %Patchback%\_C" c:\_C /e /R:0 /LOG:%Patchback%\Rob_AfterC.log"
%Pathrob% %Patchback%\_D" c:\_D /e /R:0 /LOG:%Patchback%\Rob_AfterD.log"


