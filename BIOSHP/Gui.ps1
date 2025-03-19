#ert
Add-Type -AssemblyName PresentationFramework

# Références des valeurs correctes
$expectedValues = @{
    "USB Storage Boot" = "Disable"
    "IPv6 during UEFI Boot" = "Disable"
    "Prompt on Memory Size Change" = "Disable"
    "Embedded LAN Controller" = "Disable"
    "LAN / WLAN Auto Switching" = "Enable"
    "Wake on WLAN" = "Enable"
    "HUB Wake on LAN" = "Enable"
    "Secure Boot" = "Disable"
}

# Récupération des valeurs BIOS
$BiosInfo = Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class hp_biosEnumeration
$BiosSetup = Get-WmiObject -class hp_biossettinginterface -Namespace root/hp/instrumentedBIOS

# Dictionnaire pour stocker les valeurs des paramètres
$biosSettings = @{}

foreach ($Conf in $BiosInfo) {
    $Param = $Conf.Name
    $Valeur = $Conf.Value -join ", "  # Convertit en texte lisible
    $ActiveValue = ($Conf.Value -split "," | Where-Object {$_ -match "\*"}) -replace "\*", ""  # Extraire la valeur active

    $biosSettings[$Param] = @{
        "AllValues" = $Valeur
        "ActiveValue" = $ActiveValue
    }
}

# Création de la fenêtre principale
$window = New-Object System.Windows.Window
$window.Title = "Configuration BIOS HP - Etat des Composants"
$window.Width = 550
$window.Height = 450
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
$settings = $expectedValues.Keys

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

    # Vérification de la conformité
    if ($expectedValues.ContainsKey($setting) -and $ActiveValue -eq $expectedValues[$setting]) {
        $color = "Green"  # Valeur correcte => vert
    } else {
        $color = "Red"  # Valeur incorrecte => rouge
    }

    # Label pour le statut
    $statusLabel = New-Object System.Windows.Controls.Label
    $statusLabel.Content = $ActiveValue
    $statusLabel.Margin = "5"
    $statusLabel.FontWeight = "Bold"
    $statusLabel.HorizontalAlignment = "Right"
    $statusLabel.Foreground = $color

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

# Bouton Configurer
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
    $errors = @()  # Stocker les erreurs

    foreach ($setting in $settings) {
        if ($biosSettings.ContainsKey($setting)) {
            $currentValue = $biosSettings[$setting]["ActiveValue"]
            $expectedValue = $expectedValues[$setting]

            if ($currentValue -ne $expectedValue) {
                try {
                    $BiosSetup.SetBIOSSetting($setting, $expectedValue)
                    Write-Host "Modification de $setting : $currentValue -> $expectedValue"
                } catch {
                    $errors += "Erreur lors de la modification de $setting"
                }
            }
        } else {
            $errors += "Le paramètre $setting n'existe pas dans le BIOS"
        }
    }

    if ($errors.Count -gt 0) {
        [System.Windows.MessageBox]::Show("Certaines erreurs ont été rencontrées:`n`n$($errors -join "`n")", "Erreur", "OK", "Error")
    } else {
        [System.Windows.MessageBox]::Show("Tous les paramètres ont été configurés avec succès.", "Succès", "OK", "Information")
    }
})

# Ajout d'une ligne pour le bouton Configurer
$grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))

# Affichage de la fenêtre
$window.ShowDialog()
