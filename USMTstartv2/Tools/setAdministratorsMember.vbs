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

LogFile = Left(FolderBackup,Len(FolderBackup) - (Len(FolderBackup) - InstrRev(FolderBackup,"\"))) & Right(FolderBackup,Len(FolderBackup)-InstrRev(FolderBackup,"\")) & "\SetAdministratorsMembers.log"
If Fso.FileExists(LogFile) Then CodeRetour = Fso.deleteFile(LogFile,True)
TraceLog LogFile , "#############################################################################"

FileAdmin = Left(FolderBackup,Len(FolderBackup) - (Len(FolderBackup) - InstrRev(FolderBackup,"\"))) & Right(FolderBackup,Len(FolderBackup)-InstrRev(FolderBackup,"\")) & "\AdministratorsMembers.txt"
If Fso.FileExists(FileAdmin) Then

	set inf= Fso.OpenTextFile(FileAdmin)
	While inf.AtEndOfStream <> True
		Ligne = Trim(Inf.Readline)
		Command1 = "net localgroup " & chr(34) & "Administrateurs" & chr(34) & " " & Ligne & " /add"
		Command2 = "net localgroup " & chr(34) & "Administrators" & chr(34) & " " & Ligne & " /add"
		TraceLog LogFile , Command1
		CodeRetour = Shell.run("cmd /c " & Command1,0,True)
		TraceLog LogFile , "Exit : " & CodeRetour

		TraceLog LogFile , Command2
		CodeRetour = Shell.run("cmd /c " & Command2,0,True)
		TraceLog LogFile , "Exit : " & CodeRetour
		
		TraceLog LogFile , " "
	Wend

Else
	TraceLog LogFile , "ERROR " & FileAdmin & " not exist"
End If


Function TraceLog(FichierLog,Commentaire)
	Dim oFso, fich
	Set oFso = CreateObject("Scripting.FileSystemObject")
	Set fich = oFso.OpenTextFile(FichierLog,8,True)
	fich.writeline cstr(Date) & " " & cstr(Time) & " | " & Commentaire
 	fich.close
End Function

Function GetPath()
 Dim path
 Deftpath = WScript.ScriptFullName
 GetPath = Left(Deftpath, InStrRev(Deftpath, "\"))
End Function