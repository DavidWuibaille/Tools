Set oFSO = CreateObject("Scripting.FileSystemObject")
Set Shell = CreateObject("Wscript.Shell")

Const TRISTATE_USE_DEFAULT      = -2
Const TRISTATE_TRUE             = -1
Const TRISTATE_FALSE            =  0

Const OVERWRITE_TRUE            = -1
Const OVERWRITE_FALSE           =  0

Const LOCATION_MODIFY_TRUE      = -1
Const LOCATION_MODIFY_FALSE     =  0

Const TEXT_USE_DEFAULT          = -2
Const TEXT_UNICODE              = -1  'Open the file as Unicode. 
Const TEXT_ASCII                =  0  'Open the file as ASCII. 
Dim TabUSB
Redim TabUSB(0)

If oFSO.FileExists(GetPath & "USMTExcludeDrives.xml") Then CodeRetour = oFSO.DeleteFile(GetPath & "USMTExcludeDrives.xml")

StrComputerName = Shell.ExpandEnvironmentStrings("%COMPUTERNAME%")
TraceLog GetPath & "USMTExcludeDrives.log", StrComputerName & " | " & "Start"

'Show drive letters associated with each
ComputerName = "."
Set wmiServices  = GetObject ("winmgmts:{impersonationLevel=Impersonate}!//" & ComputerName)
' Get physical disk drive
Set wmiDiskDrives =  wmiServices.ExecQuery ( "SELECT Caption, DeviceID FROM Win32_DiskDrive WHERE InterfaceType = 'USB'")

For Each wmiDiskDrive In wmiDiskDrives
    query = "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" & wmiDiskDrive.DeviceID & "'} WHERE AssocClass = Win32_DiskDriveToDiskPartition"    
    Set wmiDiskPartitions = wmiServices.ExecQuery(query)

    For Each wmiDiskPartition In wmiDiskPartitions
        'Use partition device id to find logical disk
        Set wmiLogicalDisks = wmiServices.ExecQuery ("ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" & wmiDiskPartition.DeviceID & "'} WHERE AssocClass = Win32_LogicalDiskToPartition") 
		x = ""
        For Each wmiLogicalDisk In wmiLogicalDisks
            TabUSB(Ubound(TabUSB)) = wmiLogicalDisk.DeviceID
			Redim preserve tabUSB(Ubound(TabUSB)+1)
			TraceLog GetPath & "USMTExcludeDrives.log", StrComputerName & " | " & "USB=" & wmiLogicalDisk.DeviceID
        Next      
    Next
Next

If Ubound(TabUSB) > 0 Then

	Set oFile = oFSO.CreateTextFile(GetPath & "USMTExcludeDrives.xml", OVERWRITE_TRUE, TEXT_UNICODE)

	oFile.WriteLine "<?xml version=""1.0"" encoding=""UTF-16""?>"
	oFile.WriteLine "<migration urlid=""http://www.microsoft.com/migration/1.0/migxmlext/MigExcludeDrives"">"
	oFile.WriteLine ""
	oFile.WriteLine "    <_locDefinition>"
	oFile.WriteLine "    <_locDefault _loc=""locNone""/>"
	oFile.WriteLine "    <_locTag _loc=""locData"">displayName</_locTag>"
	oFile.WriteLine "    </_locDefinition>"
	oFile.WriteLine "    <component type=""Documents"" context=""UserAndSystem"">"
	oFile.WriteLine "        <displayName _locID=""migexcludedrives.excludedrives"">Unconditional Exclude Drives</displayName>"
	oFile.WriteLine "        <role role=""Data"">"
	oFile.WriteLine "            <rules>"
	oFile.WriteLine "                <unconditionalExclude>"
	oFile.WriteLine "                    <objectSet>"
	'                       				 	<pattern type="File">H:\* [*]</pattern>
	For i = 0 To (Ubound(TabUSB)-1)
		oFile.WriteLine "                        <pattern type=""File"">" & UCase(TabUSB(i)) & "\* [*]</pattern>"
	Next


	oFile.WriteLine "                    </objectSet>"
	oFile.WriteLine "                </unconditionalExclude>"
	oFile.WriteLine "            </rules>"
	oFile.WriteLine "        </role>"
	oFile.WriteLine "    </component>"
	oFile.WriteLine "</migration>"
	oFile.Close
	TraceLog GetPath & "USMTExcludeDrives.log", StrComputerName & " | " & "Fin de creation du xml"
Else
	TraceLog GetPath & "USMTExcludeDrives.log", StrComputerName & " | " & "Pas de disque USB"
End If

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