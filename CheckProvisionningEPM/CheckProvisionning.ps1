[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Check Provisionning" Height="565" Width="457">
    <Grid Margin="0,0,0,3">
        <Button Name="Bouton" Content="OK" HorizontalAlignment="Center" Margin="0,476,0,0" VerticalAlignment="Top" Width="199" Height="39" />
        <Image Name="Result" HorizontalAlignment="Left" Height="200" Margin="130,147,0,0" VerticalAlignment="Top" Width="200"/>
        <TextBox Name="info" AcceptsReturn="True" HorizontalAlignment="Center" Margin="0,364,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="437" Height="97" Background="#FFC78A8A"/>
        <TextBox Name="nompc" HorizontalAlignment="Center" Margin="0,10,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="438" FontWeight="Bold" SelectionOpacity="0" Visibility="Visible" TextAlignment="Center" FontSize="24" Background="#FFC6E8F9"/>
        <TextBox Name="Ipaddress" HorizontalAlignment="Center" Margin="0,44,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="438" FontWeight="Bold" SelectionOpacity="0" Visibility="Visible" TextAlignment="Center" FontSize="16" Background="#FFC6E8F9" Height="23"/>
        <TextBox Name="Model" HorizontalAlignment="Center" Margin="0,67,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="438" FontWeight="Normal" SelectionOpacity="0" Visibility="Visible" TextAlignment="Center" FontSize="16" Background="#FFC6E8F9" Height="23"/>
        <TextBox Name="CPU" HorizontalAlignment="Center" Margin="0,90,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="438" FontWeight="Normal" SelectionOpacity="0" Visibility="Visible" TextAlignment="Center" FontSize="16" Background="#FFC6E8F9" Height="23"/>
        <TextBox Name="RAM" HorizontalAlignment="Center" Margin="0,113,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="438" FontWeight="Normal" SelectionOpacity="0" Visibility="Visible" TextAlignment="Center" FontSize="16" Background="#FFC6E8F9" Height="23"/>
    </Grid>
</Window>

'@
#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}


$Image_OK = "/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBYQERMUFRUVDA8XGBYUGBIUFRT/2wBDAQMEBAUEBQkFBQkUDQsNFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBT/wAARCAEsASwDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD9U6KKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAoooo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"
$bitmap_OK = New-Object System.Windows.Media.Imaging.BitmapImage
$bitmap_OK.BeginInit()
$bitmap_OK.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($Image_OK)
$bitmap_OK.EndInit()
$bitmap_OK.Freeze()

$Image_KO = "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"
$bitmap_KO= New-Object System.Windows.Media.Imaging.BitmapImage
$bitmap_KO.BeginInit()
$bitmap_KO.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($Image_KO)
$bitmap_KO.EndInit()
$bitmap_KO.Freeze()

function GetLog {
	$Vbootactif = 0
	$nompc.Text = $env:COMPUTERNAME
    $Result.source = $bitmap_OK

	$StringModel  = "Model : " + (Get-WmiObject Win32_ComputerSystem).Model
	$StringSerial = "Serial : " + (Get-WmiObject -Class Win32_BIOS).SerialNumber
	$Model.text = "$StringModel $StringSerial"


	$StringCPU = "CPU : " + (Get-WmiObject -Class Win32_Processor).Name
	$Totalmemory = "Memory : " + (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb + " Go"
	$CPU.text = $StringCPU
	$RAM.Text = $Totalmemory


	$Ipaddress.Text = ""
	$Addresses = Get-NetIPAddress -AddressFamily IPv4
	Foreach ($Addresse in $Addresses ) {
		$AddresseIP = $Addresse.IPAddress
		
		$AddresseAl = $Addresse.InterfaceAlias
		if (($AddresseIP -notlike "169.*") -and ($AddresseIP -notlike "127.*") -and ($AddresseAl -notlike "*Default Switch*")) {
			$Ipaddress.Text = $AddresseIP
		
		}
	
	}
	
	$info.Background = "#FF35E62F"
	
	$logfile = "C:\exploit\log\ProvisionGUI.exe.log"
	if(test-path "C:\ldprovisioning\ProvisionGUI.exe.log") {
		$logfile = "C:\ldprovisioning\ProvisionGUI.exe.log"
		if(test-path "C:\exploit\log") { Copy-Item "C:\ldprovisioning\ProvisionGUI.exe.log" -destination "C:\exploit\log\ProvisionGUI.exe.log" -Force }
	}
	
	if(test-path $logfile) {
		$inf = Get-Content -path $logfile
		$lastActionerror = "xxx"
		$errorLogP = 0
		$affiche = 0
		Foreach ( $line in $inf ) {
			if ($affiche -eq 1 ) { 
				$lastAction = $line
				$affiche = 0
			}
			if ($line -like "*Recieved command to set print: Action*") { $affiche = 1 }
			if (($line -like "*Recieved command to set print: <*") -and ($line -like "*ActionName*")) { 
				$temp = $line.split("/")
				Foreach($element in $temp) {
					if ($element -like "*ActionId><ActionName*")  { 
						$element = $element -replace "ActionId><ActionName" , ""
						$element = $element -replace ">" , ""
						$element = $element -replace "<" , ""
						$lastAction = $element 
					}
				}
			}
			
			if (($line -like "*SUCCESS*") -and ($line -like "*>Vboot<*")) { 
				$Vbootactif = 1 
				#write-host ">>>>$line<<<<"
			}
			if (($line -like "*FAILED*") -and ($line -notlike "*>Vboot<*") -and ($line -notlike "*<ParentActionID>*") -and ($line -notlike "*Failed processing*") ) { 
				if ($lastAction -notlike "*NoCheck*") {
					$Result.source = $bitmap_KO
					if ( $info.text -notlike "*$lastAction*") {
						$info.text = $info.text + "ERROR:$lastAction" + "`r`n"
						$errorLogP = 1
						$info.Background = "#FFE62F2F"
					}
				}
			}
			
			#Check pb logo
			if (($line -like "*return:*") -and ($line -notlike "*return:0*") -AND ($line -notlike "*return:3010*")) { 
				if ($lastAction -notlike "*NoCheck*") {
					$Result.source = $bitmap_KO
					if ( $info.text -notlike "*$lastAction*") {
						$info.text = $info.text + "ERROR:$lastAction" + "`r`n"
						$errorLogP = 1
						$info.Background = "#FFE62F2F"
					}
				}
			}
			
		}
		if ($errorLogP  -eq 0) { 
			$info.text = "Provisionning OK"
		}
	
	} Else {
		$info.text = "*** ERROR $logfile ***"
		$info.Background = "#FFE62F2F"
		$Result.source = $bitmap_KO
	}
	return $Vbootactif
	
}


function DriversAbsents {
    $Devices = get-wmiObject Win32_pnpEntity
	
	$errorDrivers = 0
    Foreach($Device in $Devices) {
        $Errorcode   = $Device.ConfigManagerErrorcode
        $Errordevice = $Device.PNPDeviceID
        $Errorclass  = $Device.PNPClass
        $Errorname   = $Device.Name


        if(($Errorclass -eq "Display") -and ($Errorname -like "*Microsoft*") -and ($Errorname -notlike "*remote*")) {
        	$Result.source = $bitmap_KO
			$info.text = $info.text + "`r`n" + "Drivers:$Errorname"
			$errorDrivers = 1
			$info.Background = "#FFE62F2F"  
        }
        If($Errorcode -gt 0) {
			if(($Errorname -notlike "*Keyboard*") -and ($Errorname -notlike "*Mouse*") -and ($Errorname -notlike "*PS/2*")) {
				$Result.source = $bitmap_KO
				$info.text = $info.text + "`r`n" + "Drivers:$Errordevice"
				$errorDrivers = 1
				$info.Background = "#FFE62F2F"  	
			}
        }
    }
	
	if ($errorDrivers -eq 0) { 
		$info.text = $info.text + "`r`n" + "Drivers OK"
	}

}




$Bouton.add_Click({
	 $Form.Close()
})



$Etatvboot = GetLog
DriversAbsents
if (($Etatvboot -eq 1) -And (test-path "C:\ldprovisioning\ProvisionGUI.exe.log")) { 
	#write-host "Auto close"
} Else {
	# Display UI object
	$Form.ShowDialog() | out-null
}

