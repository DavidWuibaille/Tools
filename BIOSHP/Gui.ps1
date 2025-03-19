Add-Type -AssemblyName PresentationFramework

# Récupération des valeurs BIOS
$BiosInfo = Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class hp_biosEnumeration

# Dictionnaire pour stocker les valeurs des paramètres
$biosSettings = @{}

foreach ($Conf in $BiosInfo) {
    $Param = $Conf.Name
    $Valeur = $Conf.Value -join ", "  # Convertit en texte lisible
    $ActiveValue = ($Conf.Value -match "\*") -join ", "  # Extraction des valeurs actives
    $ActiveValue = $ActiveValue -replace "\*", ""  # Suppression des "*"

    $biosSettings[$Param] = @{
        "AllValues" = $Valeur
        "ActiveValue" = $ActiveValue
    }
}

# Création de la fenêtre principale
$window = New-Object System.Windows.Window
$window.Title = "Configuration BIOS HP – État des Composants"
$window.Width = 600
$window.Height = 500
$window.WindowStartupLocation = "CenterScreen"
$window.FontFamily = "Segoe UI"
$window.FontSize = 14

# Création du Grid principal
$grid = New-Object System.Windows.Controls.Grid
$grid.Margin = "15"
$window.Content = $grid

# Ajout des colonnes au Grid
$grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition)) # Colonne Nom
$grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition)) # Colonne Statut

# Liste des paramètres à afficher
$settings = @(
    "USB Storage Boot"
    "IPv6 during UEFI Boot"
    "Prompt on Memory Size Change"
    "Embedded LAN Controller"
    "LAN / WLAN Auto Switching"
    "Wake on WLAN"
    "HUB Wake on LAN"
    "Secure Boot"
)

# Ajout des lignes pour les paramètres
$rowIndex = 0
foreach ($setting in $settings) {
    # Nom de la configuration
    $label = New-Object System.Windows.Controls.Label
    $label.Content = $setting
    $label.Margin = "5"
    $label.HorizontalAlignment = "Left"
    [System.Windows.Controls.Grid]::SetRow($label, $rowIndex)
    [System.Windows.Controls.Grid]::SetColumn($label, 0)
    $grid.Children.Add($label)

    # Récupération de la valeur actuelle
    if ($biosSettings.ContainsKey($setting)) {
        $ActiveValue = $biosSettings[$setting]["ActiveValue"]
    } else {
        $ActiveValue = "Unknown"
    }

    # Label pour le statut
    $statusLabel = New-Object System.Windows.Controls.Label
    $statusLabel.Content = $ActiveValue
    $statusLabel.Margin = "5"
    $statusLabel.FontWeight = "Bold"
    $statusLabel.HorizontalAlignment = "Right"

    # Couleur : Vert si une valeur est récupérée, Rouge si "Unknown"
    if ($ActiveValue -eq "Unknown") {
        $statusLabel.Foreground = "Red"
    } else {
        $statusLabel.Foreground = "Green"
    }

    [System.Windows.Controls.Grid]::SetRow($statusLabel, $rowIndex)
    [System.Windows.Controls.Grid]::SetColumn($statusLabel, 1)
    $grid.Children.Add($statusLabel)

    $rowIndex++
}

# Ajout des lignes dynamiquement dans le Grid
for ($i = 0; $i -lt $settings.Count; $i++) {
    $grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))
}

# Séparateur visuel
$separator = New-Object System.Windows.Controls.Separator
$separator.Margin = "5,10,5,10"
[System.Windows.Controls.Grid]::SetRow($separator, $settings.Count)
[System.Windows.Controls.Grid]::SetColumnSpan($separator, 2)
$grid.Children.Add($separator)

# Bouton Configurer (design amélioré)
$configureButton = New-Object System.Windows.Controls.Button
$configureButton.Content = "Configurer"
$configureButton.Margin = "5"
$configureButton.Width = 150
$configureButton.Height = 40
$configureButton.FontSize = 14
$configureButton.FontWeight = "Bold"
$configureButton.Background = "#0071C5"
$configureButton.Foreground = "White"
$configureButton.HorizontalAlignment = "Center"
$configureButton.VerticalAlignment = "Bottom"
$configureButton.Cursor = "Hand"
$configureButton.BorderThickness = "2"
$configureButton.BorderBrush = "Black"

[System.Windows.Controls.Grid]::SetRow($configureButton, $settings.Count + 1)
[System.Windows.Controls.Grid]::SetColumnSpan($configureButton, 2)
$grid.Children.Add($configureButton)

# Gestion du clic sur le bouton Configurer
$configureButton.Add_Click({
    [System.Windows.MessageBox]::Show("Accès à la configuration BIOS en cours de développement.", "Information", "OK", "Information")
})

# Ajout d'une ligne pour le bouton Configurer
$grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))

# Affichage de la fenêtre
$window.ShowDialog()
