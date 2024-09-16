set servlandesk=Epm2020.leblogosd.lan
md c:\mount

for /F "skip=1 delims=" %%F in ('
 wmic PATH Win32_LocalTime GET Day^,Month^,Year /FORMAT:TABLE
') do (
 for /F "tokens=1-3" %%L in ("%%F") do (
 set CurrDay=0%%L
 set CurrMonth=0%%M
 set CurrYear=%%N
 )
)
set CurrDay=%CurrDay:~-2%
set CurrMonth=%CurrMonth:~-2%
set vardate=%CurrYear%%CurrMonth%%CurrDay%
if "%time:~0,1%"==" " (
set vartime=0%time:~1,1%%time:~3,2%
) else (
set vartime=%time:~0,2%%time:~3,2%
)

Set cmddism=dism
Set cmdwusa=wusa
Set cmdpowershell=powershell
Set cmdreg=reg
Set cmdpowercfg=powercfg
Set cmdcscript=cscript
if defined PROCESSOR_ARCHITEW6432 Set cmddism=%SystemRoot%\Sysnative\cmd.exe /c Dism
if defined PROCESSOR_ARCHITEW6432 Set cmdpowershell=%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe
if defined PROCESSOR_ARCHITEW6432 Set cmdwusa=%SystemRoot%\sysnative\wusa.exe
if defined PROCESSOR_ARCHITEW6432 Set cmdreg=%SystemRoot%\sysnative\reg.exe
if defined PROCESSOR_ARCHITEW6432 Set cmdpowercfg=%SystemRoot%\Sysnative\cmd.exe /c powercfg
if defined PROCESSOR_ARCHITEW6432 Set cmdcscript=%SystemRoot%\Sysnative\cscript.exe

copy "\\%servlandesk%\ldmain\landesk\vboot\boot_x64.wim" "\\%servlandesk%\ldmain\landesk\vboot\boot_x64.wim_%vardate%_%vartime%.old"
dism /mount-wim /wimfile:"\\%servlandesk%\ldmain\landesk\vboot\boot_x64.wim" /index:1 /mountdir:c:\mount

Copy "%~dp0choice_x64.exe" C:\mount\Windows\system32\choice.exe
Notepad C:\mount\Windows\System32\startnet.cmd

:: Nom FQDN du core server EPM
Notepad c:\mount\temp\corename.txt
pause 

:: Ajout de drivers
Dism /Image:C:\mount /Add-Driver /Driver:"%~dp0Drivers\x64" /Recurse
pause

::Dism /Add-Package /Image:"C:\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-WMI.cab"
::Dism /Add-Package /Image:"C:\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-WMI_en-us.cab"
::Dism /Add-Package /Image:"C:\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-NetFX.cab"
::Dism /Add-Package /Image:"C:\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-NetFX_en-us.cab"
::Dism /Add-Package /Image:"C:\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-Scripting.cab"
::Dism /Add-Package /Image:"C:\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-Scripting_en-us.cab"
::Dism /Add-Package /Image:"C:\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-PowerShell.cab"
::Dism /Add-Package /Image:"C:\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-PowerShell_en-us.cab"
::Dism /Add-Package /Image:"C:\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-StorageWMI.cab"
::Dism /Add-Package /Image:"C:\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-StorageWMI_en-us.cab"
::Dism /Add-Package /Image:"C:\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-DismCmdlets.cab"
::Dism /Add-Package /Image:"C:\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-DismCmdlets_en-us.cab"
Dism /unmount-wim /mountdir:c:\mount /commit
pause
