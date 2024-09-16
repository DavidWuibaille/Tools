set servlandesk=Epm2020.leblogosd.lan

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


copy "\\%servlandesk%\ldmain\landesk\vboot\boot.wim" "\\%servlandesk%\ldmain\landesk\vboot\boot.wim_%vardate%_%vartime%.old"
dism /mount-wim /wimfile:"\\%servlandesk%\ldmain\landesk\vboot\boot.wim" /index:1 /mountdir:c:\mount

::Menu choix langue pour le clavier
Copy "%~dp0choice_x86.exe" C:\mount\Windows\system32\choice.exe
Notepad C:\mount\Windows\System32\startnet.cmd

:: Nom FQDN du core server EPM
Notepad c:\mount\temp\corename.txt
pause 

:: Ajout de drivers
Dism /Image:C:\mount /Add-Driver /Driver:"%~dp0Drivers\x86" /Recurse
pause

Dism /unmount-wim /mountdir:c:\mount /commit
pause