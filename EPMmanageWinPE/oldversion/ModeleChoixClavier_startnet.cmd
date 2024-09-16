ECHO 1: Keyboard = FR
ECHO 2: Keyboard = IT
ECHO 3: Keyboard = EN
ECHO 4: Keyboard = CA
CHOICE /C 1234 /N /T 90 /D 1 /M "Choice keyboard"
 
echo %ERRORLEVEL%
IF %ERRORLEVEL% == 1 SET Clavier=040C:0000040C
IF %ERRORLEVEL% == 2 SET Clavier=0410:00000410
IF %ERRORLEVEL% == 3 SET Clavier=0409:00000409
IF %ERRORLEVEL% == 4 SET Clavier=0c0c:00001009
 
wpeutil setkeyboardlayout %Clavier%


