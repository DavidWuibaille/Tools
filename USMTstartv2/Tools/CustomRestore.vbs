Const HKEY_LOCAL_MACHINE = &H80000002

Dim args, Fso,Shell
Set args  = Wscript.Arguments
Set Fso = CreateObject("Scripting.FileSystemObject")
Set Shell = CreateObject("Wscript.Shell")

Dim FolderBackup, strOs, strArchi, FUsers, PartW, PatchNotes, VersionNotes, LogFile, Temp, UserBackup, ExitCode
Dim robocopy
ExitCode = 0
' --------------------- Dossier de sauvegarde ---------------------------------
StrComputerName = Shell.ExpandEnvironmentStrings("%COMPUTERNAME%")

' --------------------- Chemin fichier INI ------------------------------------
PatchHTA = WScript.ScriptFullName
PatchHTA = Left(PatchHTA, InStrRev(PatchHTA, "\") -1)
PatchHTA = Left(PatchHTA, InStrRev(PatchHTA, "\"))

' --------------------- Dossier de sauvegarde --------------------------------- 
if args.count = 0 Then
	Msgbox "Error Args"
Else
	FolderBackup = args(0)
End If

' --------------------- Detection de l'OS -------------------------------------
Set objRegistry=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & "." & "\root\default:StdRegProv")
strKeyPath = "SOFTWARE\Microsoft\Windows NT\CurrentVersion"
strValueName = "ProductName"
objRegistry.GetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,ProductName
strOs = UCase(ProductName)
If instr(UCase(ProductName),"WINDOWS XP") 	<> 0 Then strOs = "Windows_XP"
If instr(UCase(ProductName),"WINDOWS 7")  	<> 0 Then strOs = "Windows_7"
If instr(UCase(ProductName),"WINDOWS 8")  	<> 0 Then strOs = "Windows_8"
If instr(UCase(ProductName),"VISTA")      	<> 0 Then strOs = "windows_vista"
If instr(UCase(ProductName),"Windows 10")  	<> 0 Then strOs = "Windows_10"


' --------------------- Detection de l'architecture ---------------------------
strArchi = "x86"
If Fso.FolderExists("c:\windows\SysWow64") Then strArchi = "x64"


' --------------------- Detection de la version Lotus Notes ------------------
PatchNotes = ""
If Fso.FileExists("c:\Program Files\Lotus\Notes\Notes.exe") 		Then PatchNotes = "c:\Program Files\Lotus\Notes\Notes.exe"
If Fso.FileExists("c:\Program Files\Notes\Notes.exe") 				Then PatchNotes = "c:\Program Files\Notes\Notes.exe"
If Fso.FileExists("c:\Program Files (x86)\Lotus\Notes\Notes.exe") 	Then PatchNotes = "c:\Program Files (x86)\Lotus\Notes\Notes.exe"
If Fso.FileExists("c:\Program Files (x86)\Notes\Notes.exe") 		Then PatchNotes = "c:\Program Files (x86)\Notes\Notes.exe"
If PatchNotes <> "" Then
	VersionNotes = GetVersion(PatchNotes)
Else
	VersionNotes = 0.0
End If



' #############################################################################
LogFile = Left(FolderBackup,Len(FolderBackup) - (Len(FolderBackup) - InstrRev(FolderBackup,"\"))) & Right(FolderBackup,Len(FolderBackup)-InstrRev(FolderBackup,"\")) & "\CustomRestore.log"
If Fso.FileExists(LogFile) Then CodeRetour = Fso.deleteFile(LogFile,True)
TraceLog LogFile , "#############################################################################"
TraceLog LogFile , "#############################################################################"
TraceLog LogFile , "FolderBackup=" & FolderBackup
TraceLog LogFile , "strOs=" & strOs
TraceLog LogFile , "strArchi=" & strArchi
TraceLog LogFile , "PatchNotes=" & PatchNotes 
TraceLog LogFile , "VersionNotes=" & VersionNotes
If PatchNotes = "" Then TraceLog LogFile , "Lotus Notes Not Found"

' Utilisation du robocopy <> si XP sinon on utilise celui natif dans Windows
robocopy = "c:\windows\system32\robocopy.exe"
if Fso.fileExists("c:\windows\system32\robocopy.exe") then
	robocopy = "c:\windows\system32\robocopy.exe"
Else
	robocopy = Getpath & "robocopy.exe"
End If
TraceLog LogFile , "Chemin robocopy :" & robocopy

' ----------------------- premiere pass pour les dossier non users -----------
TraceLog LogFile , " "
TraceLog LogFile , "----------------------- premiere pass pour les dossier non users -----------"
LectureTransfert = 0
set inf= Fso.OpenTextFile(PatchHTA & "USMTStart.ini")
While inf.AtEndOfStream <> True
	Ligne = Trim(Inf.Readline)
	If Left(Ligne,1) <> ";" And Ligne <> "" And Left(Ligne,1) <> "[" Then
		If LectureTransfert = 1 Then
			Ligne = UCase(Ligne)

			If Instr(Ligne,"C:\USERS\%USERNAME%") = 0 Then
				TraceLog LogFile , " "
				TraceLog LogFile , "Ligne:" & Ligne

				' verification si extension selectionnée
				Extention = " "
				If Instr(Ligne,"\*.") Then
					Temppath = Split(Ligne,"\*.")
					Ligne = Temppath(0) 'je garde uniquement le chemin
					Extention = " *." & Temppath(1) & " "
				Else
					Extention = " "				
				End If				
			
				' Si remplacement de chaine
				If instr(Ligne,"==") <> 0 Then
					Templigne = split(Ligne,"==")
					Source = UCase(Templigne(1)) 
					Destination=UCase(Templigne(0))
					TraceLog LogFile , "Source=="  & Source
					TraceLog LogFile , "Destination=="  & Destination
				Else
					Source = Ligne
					Destination = Ligne
					TraceLog LogFile , "Source=="  & Source
					TraceLog LogFile , "Destination=="  & Destination
				End If
			
				
				' test sur c:\program files et c:\program files (x86)
				TraceLog LogFile , "Source:" & Source
				If Instr(Source,"C:\PROGRAM FILES\") <> 0 Then
					If Fso.folderExists(Source) = False Then
						TempLigne = Replace(Source, "C:\PROGRAM FILES\", "C:\PROGRAM FILES (X86)\")
						If Fso.FolderExists(TempLigne) Then
							Source = TempLigne
							TraceLog LogFile , "Remplace Source (PROGRAM FILES\)=>" & Source
						End If
					End If					
				End If					
				
				' Definition du dossier de destination

				' fix bug si HDD USB avec lettre D
				TraceLog LogFile , "Destination:" & Destination
				TempDestination = ""
				TempDestination = Replace(UCase(Destination), "C:","C")
				TempDestination = Replace(UCase(TempDestination), "D:","D")
				TraceLog LogFile , "TempDestination:" & TempDestination
				
				Destination = FolderBackup & "\" & TempDestination

				TraceLog LogFile , "Destination Final:" & Destination
				

				If Fso.FolderExists(Destination) Then
					TraceLog LogFile , "Found! "  & Destination
					Commande = chr(34) & robocopy & chr(34) & " " & Chr(34) & Destination & chr(34) & " " & chr(34) & Source & chr(34) & " /e /R:0 /W:10" & " /log+:" & chr(34) & LogFile & chr(34)
					TraceLog LogFile , Commande
					CodeRetour = Shell.run(Commande,,True)
					TraceLog LogFile , "EXIT : " & CodeRetour
					TraceLog LogFile , " "
					If CodeRetour = 1 then CodeRetour = 0
					If CodeRetour = 2 then CodeRetour = 0
					If CodeRetour = 3 then CodeRetour = 0
					ExitCode = ExitCode + CodeRetour
				Else
					TraceLog LogFile , "not Exist " & Destination
					TraceLog LogFile , " "
				End If
			End If
		End If
	End If
	if Instr(UCase(Ligne),"[") <> 0 And Instr(UCase(Ligne),"]") <> 0 Then LectureTransfert = 0
	If Instr(UCase(Ligne),"[TRANSFERT]") <> 0 Then LectureTransfert = 1
Wend
inf.close



' --------------------- Boucle Users ------------------------------------------
TraceLog LogFile , " "
TraceLog LogFile , "--------------------- Boucle Users ------------------------------------------"
' Enumeration des users sauvegardés partition C
FUsers = ""
If Fso.FolderExists("c:\Documents And Settings") Then FUsers = "c:\Documents And Settings"
If Fso.FolderExists("c:\Users") Then FUsers = "c:\Users"
TraceLog LogFile , "FUsers=" & FUsers
if FUsers <> "" Then
	Set fs=Fso.GetFolder(FUsers)
	Set collfolders = fs.SubFolders
	For each folder in collfolders
		curfolder = FUsers & "\" & folder.name
		call CopyUsers(curfolder)
	Next
End If

' Enumeration des users sauvegardés Partition D
FUsers = ""
If Fso.FolderExists("d:\Documents And Settings") Then FUsers = "d:\Documents And Settings"
If Fso.FolderExists("d:\Users") Then FUsers = "d:\Users"
TraceLog LogFile , "FUsers=" & FUsers
If FUsers <> "" Then
	Set fs=Fso.GetFolder(FUsers)
	Set collfolders = fs.SubFolders
	For each folder in collfolders
		curfolder = FUsers & "\" & folder.name
		call CopyUsers(curfolder)
	Next
End If



' Set des password
on error resume next
LecturePassword = 0
setpassword = "NO"
newpassword = ""
Excludeuser = ""
set inf= Fso.OpenTextFile(PatchHTA & "USMTStart.ini")
While inf.AtEndOfStream <> True
	Ligne = Trim(Inf.Readline)
	if LecturePassword = 1 Then
		If Instr(UCase(Ligne),"SETPASSWORD") <> 0 Then
			If Instr(Ligne,"=") <> 0 Then
				Temp3 = Split(Ligne,"=")
				setpassword = Temp3(1)
			End If
		End If
		
		If Instr(UCase(Ligne),"NEWPASSWORD") <> 0 Then
			If Instr(Ligne,"=") <> 0 Then
				Temp3 = Split(Ligne,"=")
				newpassword = Temp3(1)
			End If
		End If		


		If Instr(UCase(Ligne),"EXCLUDEUSER") <> 0 Then
			If Instr(Ligne,"=") <> 0 Then
				Temp3 = Split(Ligne,"=")
				Excludeuser = Temp3(1)
			End If		
		End If	
	
	End If
	If UCase(Ligne) = "[PASSWORD]" Then LecturePassword = 1
Wend
inf.close
TraceLog LogFile , " "
TraceLog LogFile , "--------------------------------------------------"
TraceLog LogFile , "setpassword = " & setpassword
TraceLog LogFile , "newpassword = " & newpassword
TraceLog LogFile , "Excludeuser = " & Excludeuser

If UCAse(setpassword) = "YES" and newpassword <> "" And Excludeuser <> "" Then
	Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & "." & "\root\cimv2") 
 	Set colItems = objWMIService.ExecQuery ("Select * from Win32_UserAccount Where LocalAccount = True") 
 
	For Each objItem in colItems 
		If Instr(UCase(Excludeuser),"," & UCase(objItem.Name) & ",") = 0 Then
			Command1 = "net user " & chr(34) & objItem.Name & chr(34) & " " & newpassword
			TraceLog LogFile , Command1
			CodeRetour = Shell.run("cmd /c " & Command1,0,True)
			ExitCode = ExitCode + CodeRetour
			TraceLog LogFile , "Exit : " & CodeRetour
		Else
			TraceLog LogFile , "Exclude = " & objItem.Name
		End If
	Next 
End If


wscript.Quit(ExitCode)



' #############################################################################
' --------------------- Restore des data Users --------------------------------
Sub CopyUsers(PatchUsers)
	Temp = Split(VersionNotes,".")

	LectureTransfert = 0
	set inf= Fso.OpenTextFile(PatchHTA & "USMTStart.ini")
	While inf.AtEndOfStream <> True
		Ligne = Trim(Inf.Readline)
		If Left(Ligne,1) <> ";" And Ligne <> "" And Left(Ligne,1) <> "[" Then
			If LectureTransfert = 1 Then
				Ligne = UCase(Ligne)
				
				If Instr(Ligne,"C:\USERS\%USERNAME%") <> 0 Then

					TraceLog LogFile , " "
					Ligne = Replace(Ligne,"C:\USERS\%USERNAME%",PatchUsers)
					TraceLog LogFile ,"Ligne:" & Ligne
					' verification si extension selectionnée
					Extention = " "
					If Instr(Ligne,"\*.") Then
						Temppath = Split(Ligne,"\*.")
						Ligne = Temppath(0) 'je garde uniquement le chemin
						Extention = " *." & Temppath(1) & " "
					Else
						Extention = " "				
					End If					
					
				
					' 010877
					' Si remplacement de chaine
					If instr(Ligne,"==") <> 0 Then
						Templigne = split(Ligne,"==")
						Source = UCase(Templigne(1)) 
						Destination=UCase(Templigne(0))
						TraceLog LogFile , "Source=="  & Source
						TraceLog LogFile , "Destination=="  & Destination
					Else
						Source = Ligne
						Destination = Ligne
						TraceLog LogFile , "Source=="  & Source
						TraceLog LogFile , "Destination=="  & Destination
					End If


			
					TraceLog LogFile , "Check =>" & Source
					' test DESKTOP et BUREAU pour les postes XP
					If Instr(Source,"\DESKTOP") <> 0 Then
						If Fso.folderExists(Source) = False Then
							TempLigne = Replace(Source, "\DESKTOP", "\BUREAU")
							If Fso.FolderExists(TempLigne) Then
								Source = TempLigne
								TraceLog LogFile , "Remplace Source(DESKTOP)=>" & Source
							End If
						End If					
					End If

					' test Documents et Mes document pour les postes XP
					If Instr(Source,"\DOCUMENTS") <> 0 Then
						If Fso.folderExists(Source) = False Then
							TempLigne = Replace(Source, "\DOCUMENTS", "\MES DOCUMENTS")
							If Fso.FolderExists(TempLigne) Then
								Source = TempLigne
								TraceLog LogFile , "Remplace Source(DOCUMENTS)=>" & Source
							End If
						End If					
					End If
					
					' test Favorites et favoris pour les postes XP
					If Instr(Source,"\FAVORITES") <> 0 Then
						If Fso.folderExists(Source) = False Then
							TempLigne = Replace(Source, "\FAVORITES", "\FAVORIS")
							If Fso.FolderExists(TempLigne) Then
								Source = TempLigne
								TraceLog LogFile , "Remplace Source(FAVORITES)=>" & Source
							End If
						End If					
					End If
				
					TraceLog LogFile ,"Source final:" & Source
					
					' Definition du dossier de destinantion
					TraceLog LogFile , "Destination=>" & Destination
					
					' fix bug si HDD USB avec lettre D
					TempDestination = ""
					TempDestination = Replace(UCase(Destination), "C:","C")
					TempDestination = Replace(UCase(TempDestination), "D:","C")
					
					TraceLog LogFile , "TempDestination=>" & TempDestination
					
					Destination = FolderBackup & "\" & TempDestination
					Destination = UCase(Destination)
					Destination = Replace(Destination, "\DOCUMENTS AND SETTINGS\", "\USERS\")
					TraceLog LogFile , "Destination Final=>" & Destination
					
					
					
					
					If Fso.FolderExists(Destination) Then
						TraceLog LogFile , "Found! " & Destination
						
						Commande = chr(34) & robocopy & chr(34) & " " & chr(34) & Destination & chr(34) & " " & chr(34) & Source & chr(34) & " /e /R:0 /W:10" & " /log+:" & chr(34) & LogFile & chr(34)
						TraceLog LogFile , Commande

						CodeRetour = Shell.run(Commande,,True)
						TraceLog LogFile , "EXIT : " & CodeRetour
						TraceLog LogFile , " "
						If CodeRetour = 1 then CodeRetour = 0
						If CodeRetour = 2 then CodeRetour = 0
						If CodeRetour = 3 then CodeRetour = 0
						ExitCode = ExitCode + CodeRetour
					Else
						TraceLog LogFile , "not Exist " & Destination
						TraceLog LogFile , " "
					End If
				End If
			End If
		End If
		if Instr(UCase(Ligne),"[") <> 0 And Instr(UCase(Ligne),"]") <> 0 Then LectureTransfert = 0
		If Instr(UCase(Ligne),"[TRANSFERT]") <> 0 Then LectureTransfert = 1
	Wend
	inf.close
	
End Sub
' #############################################################################
' --------------------- Fonction ----------------------------------------------
Function GetVersion(pathspec) 
    Dim oFso, temp 
    Set oFso = CreateObject("Scripting.FileSystemObject")
    temp = oFso.GetFileVersion(pathspec) 
    If Len(temp) Then 
       GetVersion = temp 
    Else 
       GetVersion = "No version information available." 
    End If 
End Function 

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
