'Modified by Travis Smith (wpsmith.net) to fetch all Adobe licenses. 

'To run this program make sure that sqlite3.exe is in the same folder as this vbs file.  
'SQLITE3 source and binaries can be found at www.sqlite.org 


'Variable Declarations 
Dim objFSO, objShell, objEM 
Dim strCacheFile, strCurrentDirectory, strCommand, strSQLlite, strLine, strAdobeEncryptedKey, strAdobeKey, strFile 
Dim arrTemp1, arrTemp2 
Dim csvFile 

Dim args
Set args  = Wscript.Arguments
Argument1 = args(0)


'Objects: FileSystem & Shell 
Set objFSO = CreateObject("Scripting.FileSystemObject")  
Set objShell = CreateObject("WScript.Shell") 
Set objNetwork = CreateObject("Wscript.Network") 


'Adobe Cache DB File 
If objFSO.FileExists("C:\Program Files (x86)\Common Files\Adobe\Adobe PCD\cache\cache.db") Then strCacheFile = "C:\Program Files (x86)\Common Files\Adobe\Adobe PCD\cache\cache.db" 
If objFSO.FileExists("C:\Program Files\Common Files\Adobe\Adobe PCD\cache\cache.db") Then strCacheFile = "C:\Program Files\Common Files\Adobe\Adobe PCD\cache\cache.db" 
strCacheFile = FindCacheFile(strCacheFile) 


'Set Curret Directory 
strCurrentDirectory = left(WScript.ScriptFullName,(Len(WScript.ScriptFullName))-(len(WScript.ScriptName))) 


'Location of SQLite 
strSQLlite = strCurrentDirectory & "sqlite3.exe" 
msgbox strSQLlite

'Command: Get Product Name & Key 
strCommand = strSQLlite & " " & Chr(34) & strCacheFile & Chr(34) & " " & chr(34) & "SELECT subDomain,value FROM domain_data WHERE key='SN' OR key='EncryptedSerial';" & chr(34) 
Set objOutput = objShell.Exec (strCommand) 


'Prep output text 
strOutput = "" 
Do While Not objOutput.StdOut.AtEndOfStream 
    'Read line 
    strLine = objOutput.StdOut.Readline 
     
    'Get Product 
    arrTemp1 = Split(strLine,"{|}") 
    strProduct = arrTemp1(0) 

    If IsArray(arrTemp1) Then 
        If UBound(arrTemp1) >= 0 Then 
            Msgbox("Not Empty") 
            arrTemp2 = Split(arrTemp1(1),"|") 
        Else 
            Msgbox("Empty") 
            arrTemp2 = Split(strLine,"|") 
        End If 
    Else 
        Msgbox("---Empty") 
    End If 
    strAdobeEncryptedKey = arrTemp2(1) 
    strAdobeKey = DecodeAdobeKey(strAdobeEncryptedKey) 
     

    'Output to screen 
    wscript.echo "Your Adobe " & strProduct & " License Key is: " & strAdobeKey
	CodeRetour = tracelog(Argument1 & "\GetLicenceAdobe.txt", strAdobeKey)
Loop 

'Email File 
'Set objEM = EmailAdobeKey(strOutput,strFile) 

Function IsArrayDimmed(arr) 
   IsArrayDimmed = False 
   If IsArray(arr) Then 
     On Error Resume Next 
     Dim ub : ub = UBound(arr) 
     If (Err.Number = 0) And (ub >= 0) Then IsArrayDimmed = True 
   End If   
 End Function 
  
Function EmailAdobeKey(strText, strFile) 
    Set objSysInfo = CreateObject("ADSystemInfo") 
    Set objOutlookApp = CreateObject("Outlook.Application") 
    Set objMailItem = objOutlookApp.CreateItem(olMailItem) 
    'comment the next line If you do Not want to see the outlook window 
    objMailItem.Display 
    objMailItem.Recipients.Add "travis.smith@ups.com" 
    objMailItem.Subject = "Adobe Licenses" 
    objMailItem.Body = "Hello," & vbCrLf & "Attached are my Adobe License Keys: " & strText & vbCrLf & "Thanks," & vbCrLf & objSysInfo.UserName 
    objMailItem.Attachments.Add strFile 
    objMailItem.Send 
     
    Set objSysInfo = Nothing 
    Set objOutlookApp = Nothing 
    Set objMailItem = Nothing 
    Set EmailAdobeKey = Nothing 
    Msgbox "Completed!",vbokonly,"Done" 
End Function 


Function DecodeAdobeKey(strAdobeEncryptedKey) 
    Dim AdobeCipher(24) 
    Dim strAdobeDecryptedKey 

    AdobeCipher(0) = "0000000001" 
    AdobeCipher(1) = "5038647192" 
    AdobeCipher(2) = "1456053789" 
    AdobeCipher(3) = "2604371895" 
    AdobeCipher(4) = "4753896210" 
    AdobeCipher(5) = "8145962073" 
    AdobeCipher(6) = "0319728564" 
    AdobeCipher(7) = "7901235846" 
    AdobeCipher(8) = "7901235846" 
    AdobeCipher(9) = "0319728564" 
    AdobeCipher(10) = "8145962073" 
    AdobeCipher(11) = "4753896210" 
    AdobeCipher(12) = "2604371895" 
    AdobeCipher(13) = "1426053789" 
    AdobeCipher(14) = "5038647192" 
    AdobeCipher(15) = "3267408951" 
    AdobeCipher(16) = "5038647192" 
    AdobeCipher(17) = "2604371895" 
    AdobeCipher(18) = "8145962073" 
    AdobeCipher(19) = "7901235846" 
    AdobeCipher(20) = "3267408951" 
    AdobeCipher(21) = "1426053789" 
    AdobeCipher(22) = "4753896210" 
    AdobeCipher(23) = "0319728564" 

    'decode the adobe key 
	for i = 0 To 23 
		if (i Mod 4 = 0 And i > 0) Then  
			'every 4 characters add a "-" 
			strAdobeDecryptedKey = strAdobeDecryptedKey & "-" 
		end if  

		'Grab the next number from the adobe encrypted key. Add one to 'i' because it isn't base 0 
		j = mid (strAdobeEncryptedKey, i + 1, 1) 

		'Add one to J because it isn't base 0 and grab that numbers position in the cipher 
		k = mid (AdobeCipher(i), j + 1, 1) 
	 
		strAdobeDecryptedKey = strAdobeDecryptedKey & k 
	Next 
	 
	DecodeAdobeKey = strAdobeDecryptedKey 
End Function 


Function FindCacheFile(CacheFile) 
	If (Not CacheFile = "") And (objFSO.FileExists(CacheFile)) Then 
		FindCacheFile = CacheFile 
	ElseIf objFSO.FileExists("c:\Program Files (x86)\Common Files\Adobe\Adobe PCD\cache\cache.db") Then 
		FindCacheFile = "c:\Program Files (x86)\Common Files\Adobe\Adobe PCD\cache\cache.db" 
	ElseIf objFSO.FileExists("c:\Program Files\Common Files\Adobe\Adobe PCD\cache\cache.db") Then 
		FindCacheFile = "c:\Program Files\Common Files\Adobe\Adobe PCD\cache\cache.db" 
	Else 
		wscript.echo "Can't find the cache.db file" 
		wscript.quit 
	End IF 
End Function 

' ********** Fonction  **********************************************************************************************
Function GetPath()
    Dim path
    path = WScript.ScriptFullName
	GetPath = Left(path, InStrRev(path, "\"))
End Function

Function TraceLog(FichierLog,Commentaire)
	Dim oFso, fich
	Set oFso = CreateObject("Scripting.FileSystemObject")
	Set fich = oFso.OpenTextFile(FichierLog,8,True)
	fich.writeline cstr(Date) & " " & cstr(Time) & " | " & Commentaire
 	fich.close
End Function 
