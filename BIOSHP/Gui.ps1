Add-Type -AssemblyName PresentationFramework

# Création de la fenêtre principale
$window = New-Object System.Windows.Window
$window.Title = "Configuration BIOS HP"
$window.Width = 550
$window.Height = 450
$window.WindowStartupLocation = "CenterScreen"
$window.FontFamily = "Segoe UI"
$window.FontSize = 14

# Chargement de l'icône HP (si disponible localement)
$iconPath = "$env:SystemRoot\System32\shell32.dll"
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
$window.Icon = $icon

# Création du Grid principal
$grid = New-Object System.Windows.Controls.Grid
$grid.Margin = "15"
$window.Content = $grid

# Ajout des colonnes au Grid
$grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition)) # Colonne Nom
$grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition)) # Colonne Statut

# Ajout des lignes pour les paramètres
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

# Ajout des styles
$statusColor = "Red"  # Couleur des statuts "Unknown"
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

    # Statut (Unknown en rouge)
    $statusLabel = New-Object System.Windows.Controls.Label
    $statusLabel.Content = "Unknown"
    $statusLabel.Margin = "5"
    $statusLabel.Foreground = $statusColor
    $statusLabel.FontWeight = "Bold"
    $statusLabel.HorizontalAlignment = "Right"
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
