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
	if args.count = 2 Then
		UserBackup = args(1)
	Else
		UserBackup = ","
	End If
End If

TempUser = Split(UserBackup,",")
 
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
LogFile = Left(FolderBackup,Len(FolderBackup) - (Len(FolderBackup) - InstrRev(FolderBackup,"\"))) & StrComputerName & "\CustomBackup.log"
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
				
				If instr(Ligne,"==") <> 0 Then
					Templigne = split(Ligne,"==")
					Ligne = Templigne(0) ' pas de prise en compte de la conversion lors de la sauvegarde
					TraceLog LogFile , "Ligne=="  & Ligne
				End If
				
				
				' verification si extension selectionnée
				Extention = " "
				If Instr(Ligne,"\*.") Then
					Temppath = Split(Ligne,"\*.")
					Ligne = Temppath(0) 'je garde uniquement le chemin
					Extention = " *." & Temppath(1) & " "
				Else
					Extention = " "				
				End If
				
				' Definition du dossier source
				Source = ligne
				TraceLog LogFile , "Source:" & Source
				
				' test sur c:\program files et c:\program files (x86)
				If Instr(Ligne,"C:\PROGRAM FILES\") <> 0 Then
					If Fso.folderExists(Ligne) = False Then
						TempLigne = Replace(Ligne, "C:\PROGRAM FILES\", "C:\PROGRAM FILES (X86)\")
						If Fso.FolderExists(TempLigne) Then
							Source = TempLigne
							TraceLog LogFile , "Remplace Source (PROGRAM FILES\)=>" & Source
						Else
							Source = Ligne
						End If
					Else
						Source = Ligne
					End If					
				End If				
				
				' Definition du dossier de destination
				TraceLog LogFile , "Destination:" & FolderBackup & "\" & Ligne
				Destination = FolderBackup & "\" & Replace(UCase(Ligne), "C:","C")
				Destination = Replace(UCase(Destination), "D:","D")
				TraceLog LogFile , "Destination Final:" & Destination
									
				If Fso.FolderExists(Source) Then
					TraceLog LogFile , "Found! " & Source
					Commande = chr(34) & robocopy & chr(34) & " " & Chr(34) & Source & chr(34) & " " & chr(34) & Destination & chr(34) & Extention & "/MIR /R:3" & " /log+:" & chr(34) & LogFile & chr(34)
					TraceLog LogFile , Commande
					CodeRetour = Shell.run(Commande,,True)
					TraceLog LogFile , "EXIT : " & CodeRetour
					TraceLog LogFile , " "
					If CodeRetour = 1 then CodeRetour = 0
					If CodeRetour = 2 then CodeRetour = 0
					ExitCode = ExitCode + CodeRetour
				Else
					TraceLog LogFile , "not Exist " & Source
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
' Enumeration des users Partition C
FUsers = ""
If Fso.FolderExists("c:\Documents And Settings") Then FUsers = "c:\Documents And Settings"
If Fso.FolderExists("c:\Users") Then FUsers = "c:\Users"
TraceLog LogFile , "FUsers=" & FUsers
If FUsers <> "" Then
	Set fs=Fso.GetFolder(FUsers)
	Set collfolders = fs.SubFolders
	For each folder in collfolders
		curfolder = FUsers & "\" & folder.name
		OKuser = 0
		For i = 0 to Ubound(TempUser)
			If UCase(folder.name) = UCase(TempUser(i)) Then OKuser = 1
		Next
		
		If OKuser = 1 Then
			TraceLog LogFile , "Backup User=" & folder.name
			TraceLog LogFile , " "
			call CopyUsers(curfolder)
		Else
			TraceLog LogFile , "Exclude User=" & folder.name
			TraceLog LogFile , " "
		End If
	Next
End If

' Enumeration des users Partition D
FUsers = ""
If Fso.FolderExists("d:\Documents And Settings") Then FUsers = "d:\Documents And Settings"
If Fso.FolderExists("d:\Users") Then FUsers = "d:\Users"
TraceLog LogFile , "FUsers=" & FUsers
If FUsers <> "" Then
	Set fs=Fso.GetFolder(FUsers)
	Set collfolders = fs.SubFolders
	For each folder in collfolders
		curfolder = FUsers & "\" & folder.name
		OKuser = 0
		For i = 0 to Ubound(TempUser)
			If UCase(folder.name) = UCase(TempUser(i)) Then OKuser = 1
		Next
		
		If OKuser = 1 Then
			TraceLog LogFile , "Backup User=" & folder.name
			TraceLog LogFile , " "
			call CopyUsers(curfolder)
		Else
			TraceLog LogFile , "Exclude User=" & folder.name
			TraceLog LogFile , " "
		End If
	Next
End If

wscript.Quit(ExitCode)

' #############################################################################
' --------------------- Copy des data Users -----------------------------------
Sub CopyUsers(PatchUsers)
	Temp = Split(VersionNotes,".")

	LectureTransfert = 0
	set inf= Fso.OpenTextFile(PatchHTA & "USMTStart.ini")
	While inf.AtEndOfStream <> True
		Ligne = Trim(Inf.Readline)
		TraceLog LogFile , " "
		If Left(Ligne,1) <> ";" And Ligne <> "" And Left(Ligne,1) <> "[" Then
			If LectureTransfert = 1 Then
				Ligne = UCase(Ligne)
				If Instr(Ligne,"C:\USERS\%USERNAME%") <> 0 Then
					TraceLog LogFile ,"Ligne:" & Ligne
					
					' 010877
					if instr(Ligne,"==") <> 0 Then
						Templigne = split(Ligne,"==")
						Ligne = Templigne(0) ' pas de prise en compte de la conversion lors de la sauvegarde
						TraceLog LogFile , "Ligne=="  & Ligne
					End If
					
					
					Ligne = Replace(Ligne,"C:\USERS\%USERNAME%",PatchUsers)
					TraceLog LogFile ,Ligne
					' verification si extension selectionnée
					Extention = " "
					If Instr(Ligne,"\*.") Then
						Temppath = Split(Ligne,"\*.")
						Ligne = Temppath(0) 'je garde uniquement le chemin
						Extention = " *." & Temppath(1) & " " ' j'ajoute *.ext avec le /MIR
					Else
						Extention = " "				 ' je met simplement un espace devant le /MIR
					End If
					
					' test DESKTOP et BUREAU pour les postes XP
					If Instr(Ligne,"\DESKTOP") <> 0 Then
						If Fso.folderExists(Ligne) = False Then
							TempLigne = Replace(Ligne, "\DESKTOP", "\BUREAU")
							If Fso.FolderExists(TempLigne) Then
								Source = TempLigne
								TraceLog LogFile , "Remplace Source (DESKTOP)=>" & Source
							Else
								Source = Ligne
							End If
						Else
							Source = Ligne
						End If					
					End If



					' test Documents et Mes document pour les postes XP
					If Instr(Ligne,"\DOCUMENTS") <> 0 Then
						If Fso.folderExists(Ligne) = False Then
							TempLigne = Replace(Ligne, "\DOCUMENTS", "\MES DOCUMENTS")
							If Fso.FolderExists(TempLigne) Then
								Source = TempLigne
								TraceLog LogFile , "Remplace Source(DOCUMENTS)=>" & Source
							Else
								Source = Ligne
							End If
						Else
							Source = Ligne
						End If					
					End If
					
					' test Favorites et favoris pour les postes XP
					If Instr(Ligne,"\FAVORITES") <> 0 Then
						If Fso.folderExists(Ligne) = False Then
							TempLigne = Replace(Ligne, "\FAVORITES", "\FAVORIS")
							If Fso.FolderExists(TempLigne) Then
								Source = TempLigne
								TraceLog LogFile , "Remplace Source(FAVORITES)=>" & Source
							Else
								Source = Ligne
							End If
						Else
							Source = Ligne
						End If					
					End If
					
					If Instr(Ligne,"\DESKTOP") = 0 AND Instr(Ligne,"\FAVORITES") = 0 AND Instr(Ligne,"\DOCUMENTS") = 0Then
						Source = Ligne
					End If
					TraceLog LogFile ,"Source final:" & Source	
					
					' Definition du dossier de destinantion
					TraceLog LogFile , "Destination=>" & FolderBackup & "\" & Ligne
					Destination = FolderBackup & "\" & Replace(UCase(Ligne), "C:","C")
					Destination = Replace(UCase(Destination), "D:","C")
					Destination = UCase(Destination)
					Destination = Replace(Destination, "\DOCUMENTS AND SETTINGS\", "\USERS\")
					TraceLog LogFile , "Destination Final=>" & Destination
				
					If Fso.FolderExists(Source) Then
						TraceLog LogFile , "Found! " & Source
						
						Commande = chr(34) & robocopy & chr(34) & " " & Chr(34) & Source & chr(34) & " " & chr(34) & Destination & chr(34) & Extention & "/MIR /R:3" & " /log+:" & chr(34) & LogFile & chr(34)
						TraceLog LogFile , Commande
						CodeRetour = Shell.run(Commande,,True)
						TraceLog LogFile , "EXIT : " & CodeRetour
						TraceLog LogFile , " "
						If CodeRetour = 1 then CodeRetour = 0
						If CodeRetour = 2 then CodeRetour = 0
						ExitCode = ExitCode + CodeRetour
					Else
						TraceLog LogFile , "not Exist " & Source
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
