set servlandesk=Epm2020.leblogosd.lan

:: *********************************************************************** boot x86
if EXIST C:\winpe_x86 rd C:\winpe_x86 /S /Q
@echo off
echo  ----- copype x86 C:\winpe_x86 -----
@echo on
call copype x86 C:\winpe_x86

@echo off
echo  ----- copype bootx86.wim -----
@echo on
Copy "\\%servlandesk%\ldmain\landesk\vboot\boot.wim" C:\winpe_x86\media\sources\boot.wim
if EXIST "%~dp0winpe_x86.iso" Del "%~dp0winpe_x86.iso"


@echo off
echo  ----- Create ISO -----
@echo on
call Makewinpemedia /iso C:\winpe_x86 "%~dp0winpe_x86.iso"
rd C:\winpe_x86 /S /Q
pause

