Const ForAppending = 8 
Const ForReading = 1 

Dim WshNetwork, objPrinter, intDrive, intNetLetter

Dim args
Set args  = Wscript.Arguments
If args.count = 0 then
	Argument1 = Left(GetPath,len(GetPath) -1)
Else
	Argument1 = args(0)
End If



Set objFSO = CreateObject("Scripting.FileSystemObject") 

filOutput = Argument1 & "\printers.csv" 
If objFSO.FileExists(filOutput) Then objFSO.DeleteFile(filOutput) 

Dim objWMIService, objItem, colItems, strComputer, intPrinters

Set objOutputFile = objFSO.OpenTextFile (filOutput, ForAppending, True) 
objOutputFile.WriteLine(	"Printers " & ";" & _ 
							"Printer: "  & ";" & _ 
							"Driver Name: "  & ";" & _ 
							"Port Name: "  & ";" & _ 
							"Published: " & ";" & _ 
							"ShareName: "  & ";" & _ 
							"Location: " & ";" & _ 
							"Work Offline: ")



Set objWMIService = GetObject ("winmgmts:\\" & "." & "\root\CIMV2")
Set colItems = objWMIService.ExecQuery ("SELECT * FROM Win32_Printer")
For Each objItem In colItems
	objOutputFile.WriteLine(	objItem.name & ";" & _ 
								objItem.DeviceID & ";" & _ 
								objItem.DriverName & ";" & _ 
								objItem.PortName & ";" & _ 
								objItem.Published & ";" & _ 
								objItem.ShareName & ";" & _ 
								objItem.Location & ";" & _  
								objItem.WorkOffline )
	
Next







objOutputFile.close


Function GetPath()
 Dim path
 Deftpath = WScript.ScriptFullName
 GetPath = Left(Deftpath, InStrRev(Deftpath, "\"))
End Function