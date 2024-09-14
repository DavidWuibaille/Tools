[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="v1.0" Height="132.43" Width="258.527">
    <Grid>
    <TextBox HorizontalAlignment="Left" Name= "ComputerName" Height="23" Margin="21,26,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="195"/>
    <Button Name="GetHistorique" Content="Get Historique PC" HorizontalAlignment="Left" Margin="21,49,0,0" VerticalAlignment="Top" Width="195"/>
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

$GetHistorique.add_Click({
    $NomPCRecord = $ComputerName.text
    $fichier = "record.txt"
    if (Test-Path $fichier) {Remove-Item $fichier}
    if ($NomPCRecord -ne "") {
        $Records = Get-WmiObject -class win32_ReliabilityRecords -computername $NomPCRecord
        foreach ($element in $Records) {
            $Date = $element.ConvertToDateTime($element.TimeGenerated)
            
            ADD-content -path $fichier -value $Date
            ADD-content -path $fichier -value $element.ProductName
            ADD-content -path $fichier -value $element.SourceName
            ADD-content -path $fichier -value $element.User
            ADD-content -path $fichier -value $element.Message
            ADD-content -path $fichier -value ""
            
        }
        
        start record.txt

    }
})

# Display UI object
$Form.ShowDialog() | out-null