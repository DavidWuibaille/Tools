dim strUser, strPass
strUser = "Proservia1"
strPass = "Psv@2016"



    Set Shell = WScript.CreateObject("WScript.Shell")
        CodeRetour = Shell.run("cmd /c net user " & strUser & " " & strPass & " /add",0,True)
    CodeRetour = Shell.run("cmd /c net localgroup " & chr(34) & "Administrateurs" & chr(34) & " " & strUser & " /add",0,True)
 
    Set objUser = Getobject("WinNT://" & "." & "/" & strUser)
    'Password never expires flag
    Flags = objUser.Get("UserFlags")
    objUser.put "Userflags", flags OR &H10000
    objUser.setinfo
