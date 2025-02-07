Add-Type -AssemblyName PresentationFramework

[xml]$XAML = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Historique PC" Height="250" Width="350" ResizeMode="NoResize"
        WindowStartupLocation="CenterScreen" Background="#F3F3F3">
    <Grid Margin="10">
        <StackPanel Orientation="Vertical" HorizontalAlignment="Center">
            <Label Content="Nom du PC :" FontSize="14" Margin="5" FontWeight="Bold"/>
            <TextBox Name="ComputerName" Width="250" Height="25" Margin="5"/>
            <Button Name="GetHistorique" Content="Obtenir l'historique" Width="250" Height="30" Margin="10"
                    Background="#0078D7" Foreground="White" FontWeight="Bold"/>
            <TextBox Name="ResultsBox" Width="300" Height="80" Margin="5"
                     IsReadOnly="True" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto"/>
        </StackPanel>
    </Grid>
</Window>  
'@

# Lire le XAML et générer l'interface
$reader = (New-Object System.Xml.XmlNodeReader $XAML) 
try { $Form = [Windows.Markup.XamlReader]::Load($reader) }
catch { Write-Host "Erreur : Vérifiez votre environnement PowerShell (lancez en mode STA)." ; exit }

# Associer les objets XAML aux variables PowerShell
$XAML.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Form.FindName($_.Name) }

# Fonction pour récupérer l'historique
$GetHistorique.Add_Click({
    $NomPCRecord = $ComputerName.Text
    $ResultsBox.Text = "" # Nettoyer la boîte de résultats

    if ($NomPCRecord -eq "") {
        $ResultsBox.Text = "Veuillez entrer un nom de PC valide."
        return
    }

    try {
        $Records = Get-WmiObject -Class win32_ReliabilityRecords -ComputerName $NomPCRecord -ErrorAction Stop
        if ($Records.Count -eq 0) {
            $ResultsBox.Text = "Aucun historique trouvé pour $NomPCRecord."
            return
        }

        $ResultsBox.Text = "Historique de $NomPCRecord`n---------------------------"
        foreach ($element in $Records) {
            $Date = $element.ConvertToDateTime($element.TimeGenerated)
            $ResultsBox.AppendText("`n[$Date] $($element.ProductName) - $($element.SourceName)`n")
        }
    } catch {
        $ResultsBox.Text = "Erreur de connexion à $NomPCRecord. Vérifiez le nom du PC et les autorisations."
    }
})

# Afficher l'interface utilisateur
$Form.ShowDialog() | Out-Null
