[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Download Drivers Dell" Height="550.434" Width="521">
    <Grid Margin="0,0,2,0">
        <Grid.ColumnDefinitions>
            <ColumnDefinition/>
            <ColumnDefinition Width="0*"/>
        </Grid.ColumnDefinitions>
        <ListBox HorizontalAlignment="Left" Name="DellW10" Height="337" Margin="18,42,0,0" SelectionMode="Extended" VerticalAlignment="Top" Width="220"/>
        <ListBox HorizontalAlignment="Left" Name="DellW11" Height="337" Margin="263,42,0,0" SelectionMode="Extended" VerticalAlignment="Top" Width="220"/>
        <Label Content="Dell Drivers Pack W10" HorizontalAlignment="Left" Margin="18,10,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.515,-0.092" Width="150" Height="26"/>
        <Label Content="Dell Drivers Pack W11"  HorizontalAlignment="Left" Margin="263,10,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.515,-0.092" Width="150" Height="26"/>
        <Button Content="Download" Name="Download" HorizontalAlignment="Left" Margin="18,467,0,0" VerticalAlignment="Top" Width="465"/>
        <Label Content="Dossier de telechargement" HorizontalAlignment="Left" Margin="23,394,0,0" VerticalAlignment="Top" Width="164"/>
        <TextBox HorizontalAlignment="Left" Name="Folderdownload" Height="23" Margin="18,425,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="465"/>
    </Grid>
</Window>


'@
#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}

#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}


$xmlpath = $PSScriptRoot + "\DownloadDriversGUI.xml"
$LogFile = $PSScriptRoot + "\DownloadDriversGUI.log"

# Get-HPDeviceProductID
# https://ftp.hp.com/pub/caps-softpaq/cmit/release/cmsl/hp-cmsl-latest.exe


Function InitialisationMenu {
    $DellW10.Items.Clear()
    $DellW11.Items.Clear()

	$currentpathXAML = $PSScriptRoot
	
	$TableauDellW10 = @()
 	$TableauDellW11 = @()   
	
    If (test-path $xmlpath) {
       [xml]$xml = get-content ("$xmlpath")
        #Puis j'affiche mes données.
        foreach ($valeurxml in $xml.Drivers) {
            $ValueDriversFolder = $valeurxml.Menu.Folder
            $Folderdownload.Text = $ValueDriversFolder
        }
	}
    Log -fichierLog "$LogFile" -ValeurLog "----- Download dell catalog"
    if (Test-Path "$currentpathXAML\DriverPackCatalog.cab") { Remove-Item -Path "$currentpathXAML\DriverPackCatalog.cab" -Force }
    if (Test-Path "$currentpathXAML\DriverPackCatalog.xml") { Remove-Item -Path "$currentpathXAML\DriverPackCatalog.xml" -Force }

    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile("http://downloads.dell.com/catalog/DriverPackCatalog.cab", "$currentpathXAML\DriverPackCatalog.cab")

    if (Test-Path "DriverPackCatalog.cab") {
        Log -fichierLog "$LogFile" -ValeurLog "----- Extract Dell catalog"
        EXPAND "$currentpathXAML\DriverPackCatalog.cab" "$currentpathXAML\DriverPackCatalog.xml"  | Out-Null
        
        if (Test-Path "$currentpathXAML\DriverPackCatalog.xml") {
            Log -fichierLog "$LogFile" -ValeurLog "----- Read XML Dell Catalog"
            [XML]$Catalog = Get-Content "$currentpathXAML\DriverPackCatalog.xml"

            # Gather Common Data from XML
            $BaseURI = "http://$($Catalog.DriverPackManifest.baseLocation)"
            $CatalogVersion = $Catalog.DriverPackManifest.version
            #Log -fichierLog "$LogFile" -ValeurLog "Catalog Version: $CatalogVersion"

            # Create Array of Driver Packages to Process
            [array]$DriverPackages = $Catalog.DriverPackManifest.DriverPackage
            
          	# Process Each Driver Package
            foreach ($DriverPackage in $DriverPackages) {
                $DriverPackageVersion = $DriverPackage.dellVersion
                $DriverPackageDownloadPath = "$BaseURI/$($DriverPackage.path)"
                $DriverPackageName = $DriverPackage.Name.Display.'#cdata-section'.Trim()
                
                if ($DriverPackage.SupportedSystems) {
					$SupportedSystems = $DriverPackage.SupportedSystems.Brand
					$SupportedSystems = $SupportedSystems | Sort Model.name
                    foreach ($SupportedSystem in $SupportedSystems) {
                        $Brand = $SupportedSystem.Display.'#cdata-section'.Trim()
                        $Model = $SupportedSystem.Model.Display.'#cdata-section'.Trim()
						$model2= $SupportedSystem.Model.name
                        If ($Model -like "*/*") {
                            $Temp = $Model.split("/")
                            $Model = $Temp[0]
                        }
                        $Model = $Model.replace("2in1","2-in-1")
						$Model = $Model.Trim()
						
                        $model2 = $model2.replace("2in1","2-in-1")
						$Model2 = $Model2.Trim()						
                    }
                }
				if ($DriverPackage.SupportedOperatingSystems) {
                    foreach ($SupportedOS in $DriverPackage.SupportedOperatingSystems) {
                        $osMatchFound = $false
                        $OSname = $SupportedOS.OperatingSystem.Display.'#cdata-section'.Trim()
						#write-host $OSname
                        if ($OSname -match "Windows 10 x64") { 
							#$Dell.Items.Add("$model2") | out-null
							$TableauDellW10 += "$model2"
						}
                        if ($OSname -match "Windows 11 x64") { 
							#$Dell.Items.Add("$model2") | out-null
							$TableauDellW11 += "$model2"
						}
                    }
                }
				
			}
			
			$TableauDellW10 = $TableauDellW10 | Sort-Object 
			Foreach($valeur in $TableauDellW10) { $DellW10.Items.Add("$valeur") | out-null 	}
			$TableauDellW11 = $TableauDellW11 | Sort-Object 
			Foreach($valeur in $TableauDellW11) { $DellW11.Items.Add("$valeur") | out-null 	}
			
		}
	
    }
}


$Download.add_Click({
    $Dossier    = $Folderdownload.Text
    $ReleaseW10 = ''
	$ReleaseW11 = ''
    


    [xml]$xml = get-content ("$xmlpath")
    $xml.Drivers.Menu.Folder  = $Dossier
    $xml.Save("$xmlpath")

    if(test-path $LogFile) { Remove-item $LogFile -Force -Recurse }


    $SelectionDell = $DellW10.SelectedItems
    foreach ($Selection in $SelectionDell) {
        Write-host "SelectionDell:$Selection"
        #$Selection = $Selection.replace(" ","")
        DownloadDellDriversPackW10 -TargetModel $Selection -OSName "Windows 10 x64" -DownloadFolder "$Dossier\Win10"
    }

    $SelectionDell = $DellW11.SelectedItems
    foreach ($Selection in $SelectionDell) {
        Write-host "SelectionDell:$Selection"
        #$Selection = $Selection.replace(" ","")
        DownloadDellDriversPackW10 -TargetModel $Selection -OSName "Windows 11 x64" -DownloadFolder "$Dossier\Win11"
    }

    Write-host "*******************************************"
    Write-host "****Fin de telechargement******************"
    Write-host "*******************************************"
    $Message = "Fin de telechargement"
    $Title = "Information"
    $Button = "OK" #valeurs possibles  OK OKCancel YesNo YesNoCancel
    $Icon = "Information" #Valeurs possibles Asterisk Error Exclamation Hand Information None Question Stop Warning
    $DefaultButton = "None" #=> resultat par defaut de $Button, les valeurs possibles sont donc les mêmes
    $result = [System.Windows.MessageBox]::Show($Message,$Title,$Button,$Icon,$DefaultButton)
})

Function GetIni {
    Param
    (
        [String]$FileName,
        [String]$Section,
        [String]$Name
    )
    $valeur = ""
    
    $inf = Get-Content -path $FileName
    Foreach ( $line in $inf ) {
        If ($line -like "*]") { $CheckSection = "NO" }

        If ($CheckSection -eq "YES") {
            if ($line -like "$Name=*") {
                $line = $line.replace("$Name=","")
                $valeur = $line
            }
        }
       
        If ($line -eq "[$Section]") { $CheckSection = "YES" }
    }
    Return $valeur
}


	
function Log {
    param(
        [string] $fichierLog,
		[string] $ValeurLog
    )
    $ErrorActionPreference = "SilentlyContinue"
	$ValeurLog | Out-File $fichierLog -Append
    write-host $ValeurLog
    $ErrorActionPreference = "Continue"
}


function Get-RedirectedUrl {
    Param (
        [Parameter(Mandatory = $true)]
        [String]$URL
    )
    
    $Request = [System.Net.WebRequest]::Create($URL)
    $Request.AllowAutoRedirect = $false
    $Request.Timeout = 3000
    $Response = $Request.GetResponse()
    if ($Response.ResponseUri) {
        [string]$ReturnedURL = $Response.GetResponseHeader("Location")
    }
    $Response.Close()
    
    Return $ReturnedURL
}

Function DownloadDellDriversPackW10 {
    Param
    (
        [String]$TargetModel,
		[String]$OSName,
        [String]$DownloadFolder
    )

	$currentpathXAML = $PSScriptRoot
    if (!(Test-Path $DownloadFolder)) { New-Item -Path $DownloadFolder -ItemType Directory -Force  | Out-Null }
    Log -fichierLog "$LogFile" -ValeurLog "----- $TargetModel - $OSName - $DownloadFolder"

	[XML]$Catalog = Get-Content "$currentpathXAML\DriverPackCatalog.xml"
	# Gather Common Data from XML
	$BaseURI = "http://$($Catalog.DriverPackManifest.baseLocation)"
	$CatalogVersion = $Catalog.DriverPackManifest.version
	Log -fichierLog "$LogFile" -ValeurLog "Catalog Version: $CatalogVersion"

	# Create Array of Driver Packages to Process
	[array]$DriverPackages = $Catalog.DriverPackManifest.DriverPackage
	
	# Process Each Driver Package
	foreach ($DriverPackage in $DriverPackages) {
		#Write-Verbose "Processing Driver Package: $($DriverPackage.path)"
		$DriverPackageName         = $DriverPackage.Name.Display.'#cdata-section'.Trim()
		$DriverPackageVersion      = $DriverPackage.dellVersion
		$DriverPackageDownloadPath = "$BaseURI/$($DriverPackage.path)"
		
		if ($DriverPackage.SupportedSystems) {
			foreach ($SupportedSystem in $DriverPackage.SupportedSystems.Brand) {
				$Brand = $SupportedSystem.Display.'#cdata-section'.Trim()
				$Model = $SupportedSystem.Model.Display.'#cdata-section'.Trim()
				$model2= $SupportedSystem.Model.name
				If ($Model -like "*/*") {
					$Temp = $Model.split("/")
					$Model = $Temp[0]
				}

				$Model = $Model.replace("2in1","2-in-1")
				$Model = $Model.Trim()
				
				$model2 = $model2.replace("2in1","2-in-1")
				$Model2 = $Model2.Trim()
			}
		}
		
		$osMatchFound = $false
		if ($DriverPackage.SupportedOperatingSystems) {
			foreach ($SupportedOS in $DriverPackage.SupportedOperatingSystems) {
				$OSnamexml = $SupportedOS.OperatingSystem.Display.'#cdata-section'.Trim()
				if ($OSnamexml -match $OSName) { 
					$osMatchFound = $true 
				}
			}
		}
			 
		$modelMatchFound = $false
		If (("$Brand $Model" -eq $TargetModel) -or ("$Model2" -eq $TargetModel)) { 
			Log -fichierLog "$LogFile" -ValeurLog "----- $Brand $Model - $TargetModel or $Model2 - $TargetModel"
			$modelMatchFound = $true 
		}

		if ($modelMatchFound -and $osMatchFound) {
			Log -fichierLog "$LogFile" -ValeurLog "---------- Download Cab $DriverPackageDownloadPath"
			$wc = New-Object System.Net.WebClient
			$wc.DownloadFile($DriverPackageDownloadPath, "$DownloadFolder\$DriverPackageName")
			
			Log -fichierLog "$LogFile" -ValeurLog "---------- Extract ""$DownloadFolder\$DriverPackageName"" ""$DownloadFolder\$TargetModel"""
			HPextract -Exe "$DownloadFolder\$DriverPackageName" -Destination "$DownloadFolder\$TargetModel"
		}
	}

}

Function HPextract {
    Param
    (
        [String]$Exe,
        [String]$Destination
    )
    if (Test-Path $Destination) { Remove-Item -Path $Destination -Force -Recurse}

    $7z  = "C:\Program Files\7-Zip\7z.exe"
    $arg = "x ""$Exe"" -o""$Destination"""
    $process = (start-process $7z $arg -PassThru -Wait)
    $CodeSortie = $process.ExitCode
}


InitialisationMenu

# Display UI object
$Form.ShowDialog() | out-null


