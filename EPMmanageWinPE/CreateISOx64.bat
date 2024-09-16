set servlandesk=Epm2020.leblogosd.lan

:: *********************************************************************** boot x64
if EXIST C:\winpe_amd64 rd C:\winpe_amd64 /S /Q
@echo off
echo  ----- copype amd64 C:\winpe_amd64 -----
@echo on
call copype amd64 C:\winpe_amd64

@echo off
echo  ----- copype bootx64.wim -----
@echo on
Copy "\\%servlandesk%\ldmain\landesk\vboot\boot_x64.wim" C:\winpe_amd64\media\sources\boot.wim
if EXIST "%~dp0winpe_amd64.iso" Del "%~dp0winpe_amd64.iso"


@echo off
echo  ----- Create ISO -----
@echo on
call Makewinpemedia /iso C:\winpe_amd64 "%~dp0winpe_amd64.iso"
rd C:\winpe_amd64 /S /Q
pause

