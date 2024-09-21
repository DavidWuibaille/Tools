CONST HKEY_LOCAL_MACHINE = &H80000002
CONST SEARCH_KEY = "DigitalProductID"

Dim args
Set args  = Wscript.Arguments
Set WshShell = CreateObject("WScript.Shell")

Argument1 = args(0)

Dim arrSubKeys(6,1)
Dim foundKeys
Dim iValues, arrDPID
foundKeys = Array()
iValues = Array()
strComputer = "."

Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colProcessors = objWMIService.ExecQuery("Select * from Win32_Processor")
For Each objProcessor in colProcessors
  Select Case objProcessor.AddressWidth
					Case 32
						arrSubKeys(2,0) = "Microsoft Office XP"
						arrSubKeys(2,1) = "SOFTWARE\Microsoft\Office\10.0\Registration"
						arrSubKeys(1,0) = "Microsoft Office 2003"
						arrSubKeys(1,1) = "SOFTWARE\Microsoft\Office\11.0\Registration"
						arrSubKeys(3,0) = "Microsoft Office 2007"
						arrSubKeys(3,1) = "SOFTWARE\Microsoft\Office\12.0\Registration"
						arrSubKeys(4,0) = "Microsoft Office 2010"
						arrSubKeys(4,1) = "SOFTWARE\Microsoft\Office\14.0\Registration"
					Case 64
						arrSubKeys(2,0) = "Microsoft Office XP"
						arrSubKeys(2,1) = "SOFTWARE\Wow6432Node\Microsoft\Office\10.0\Registration"
						arrSubKeys(1,0) = "Microsoft Office 2003"
						arrSubKeys(1,1) = "SOFTWARE\Wow6432Node\Microsoft\Office\11.0\Registration"
						arrSubKeys(3,0) = "Microsoft Office 2007"
						arrSubKeys(3,1) = "SOFTWARE\Wow6432Node\Microsoft\Office\12.0\Registration"
						arrSubKeys(4,0) = "Microsoft Office 2010"
						arrSubKeys(4,1) = "SOFTWARE\Wow6432Node\Microsoft\Office\14.0\Registration"
				End Select
next
Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")

For x = 1 To 4
	oReg.GetBinaryValue HKEY_LOCAL_MACHINE, arrSubKeys(x,1), SEARCH_KEY, arrDPIDBytes
	If Not IsNull(arrDPIDBytes) Then
		call decodeKey(arrDPIDBytes, arrSubKeys(x,0))
	Else
		oReg.EnumKey HKEY_LOCAL_MACHINE, arrSubKeys(x,1), arrGUIDKeys
		If Not IsNull(arrGUIDKeys) Then
			For Each GUIDKey In arrGUIDKeys
				oReg.GetBinaryValue HKEY_LOCAL_MACHINE, arrSubKeys(x,1) & "\" & GUIDKey, SEARCH_KEY, arrDPIDBytes
				If Not IsNull(arrDPIDBytes) Then
					CodeRetour = tracelog(Argument1 & "\GetLicenceOffice.txt", arrSubKeys(x,0)) 
					call decodeKey(arrDPIDBytes, arrSubKeys(x,0))
				End If
			Next
		End If
	End If
Next

Function decodeKey(iValues, strProduct)
	Dim arrDPID
	arrDPID = Array()

	For i = 52 to 66
		ReDim Preserve arrDPID( UBound(arrDPID) + 1 )
		arrDPID( UBound(arrDPID) ) = iValues(i)
	Next
	Dim arrChars
	arrChars = Array("B","C","D","F","G","H","J","K","M","P","Q","R","T","V","W","X","Y","2","3","4","6","7","8","9")

	For i = 24 To 0 Step -1
		k = 0
		For j = 14 To 0 Step -1
			k = k * 256 Xor arrDPID(j)
			arrDPID(j) = Int(k / 24)
			k = k Mod 24
		Next
		strProductKey = arrChars(k) & strProductKey
		If i Mod 5 = 0 And i <> 0 Then strProductKey = "-" & strProductKey
	Next

	ReDim Preserve foundKeys( UBound(foundKeys) + 1 )
	foundKeys( UBound(foundKeys) ) = strProductKey
	strKey = UBound(foundKeys)
	wscript.echo ( "Product(license) key is  "   & foundKeys(strKey))
	CodeRetour = tracelog(Argument1 & "\GetLicenceOffice.txt", foundKeys(strKey))
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
	fich.writeline Commentaire
 	fich.close
End Function 
