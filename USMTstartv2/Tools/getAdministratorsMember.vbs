Const HKEY_LOCAL_MACHINE = &H80000002

Dim args, Fso,Shell
Set args  = Wscript.Arguments
Set Fso = CreateObject("Scripting.FileSystemObject")
Set Shell = CreateObject("Wscript.Shell")

Dim FolderBackup, strOs, strArchi, FUsers, PartW, PatchNotes, VersionNotes, LogFile, Temp, UserBackup, ExitCode
Dim robocopy, Extention
ExitCode = 0
' --------------------- Chemin fichier INI ------------------------------------
PatchHTA = WScript.ScriptFullName
PatchHTA = Left(PatchHTA, InStrRev(PatchHTA, "\") -1)
PatchHTA = Left(PatchHTA, InStrRev(PatchHTA, "\"))

' --------------------- Dossier de sauvegarde ---------------------------------
StrComputerName = Shell.ExpandEnvironmentStrings("%COMPUTERNAME%")

' --------------------- Dossier de sauvegarde --------------------------------- 
if args.count = 0 Then
	Msgbox "Error Args"
Else
	FolderBackup = args(0)
End If

LogFile = Left(FolderBackup,Len(FolderBackup) - (Len(FolderBackup) - InstrRev(FolderBackup,"\"))) & StrComputerName & "\AdministratorsMembers.txt"
If Fso.FileExists(LogFile) Then CodeRetour = Fso.deleteFile(LogFile,True)


Set colGroups = GetObject("WinNT://" & "." & "")
colGroups.Filter = Array("group")
For Each objGroup In colGroups
    For Each objUser in objGroup.Members
		If UCASE(objGroup.Name) = "ADMINISTRATEURS" Or UCASE(objGroup.Name) = "ADMINISTRATORS" Then
			TraceLog LogFile , objUser.Name
		End If
    Next
Next


Function TraceLog(FichierLog,Commentaire)
	Dim oFso, fich
	Set oFso = CreateObject("Scripting.FileSystemObject")
	Set fich = oFso.OpenTextFile(FichierLog,8,True)
	fich.writeline Commentaire
 	fich.close
End Function 

Function GetPath()
 Dim path
 Deftpath = WScript.ScriptFullName
 GetPath = Left(Deftpath, InStrRev(Deftpath, "\"))
End Function