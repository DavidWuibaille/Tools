Add-Type -AssemblyName PresentationFramework

# Expected BIOS values
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

# Function to retrieve BIOS settings
function Get-BIOSValues {
    $biosSettings = @{}
    $BiosInfo = Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class hp_biosEnumeration

    foreach ($Conf in $BiosInfo) {
        $Param = $Conf.Name
        $Value = $Conf.Value -join ", "  # Convert array to text
        $ActiveValue = ($Conf.Value -split "," | Where-Object {$_ -match "\*"}) -replace "\*", ""  # Extract active value

        $biosSettings[$Param] = @{
            "AllValues" = $Value
            "ActiveValue" = $ActiveValue
        }
    }
    return $biosSettings
}

# Retrieve initial BIOS settings
$BiosSetup = Get-WmiObject -Class hp_biossettinginterface -Namespace root/hp/instrumentedBIOS
$biosSettings = Get-BIOSValues

# Create main window
$window = New-Object System.Windows.Window
$window.Title = "HP BIOS Configuration - Component Status"
$window.Width = 550
$window.Height = 450
$window.WindowStartupLocation = "CenterScreen"
$window.FontFamily = "Segoe UI"
$window.FontSize = 14

# Create grid
$grid = New-Object System.Windows.Controls.Grid
$grid.Margin = "15"
$window.Content = $grid

# Define grid columns
$grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition)) # Configuration Name
$grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition)) # Status

# Settings list
$settings = $expectedValues.Keys
$statusLabels = @{}  # Store UI labels for dynamic updates

# Function to refresh the UI with updated BIOS values
function Refresh-UI {
    $biosSettings = Get-BIOSValues  # Retrieve latest BIOS values

    foreach ($setting in $settings) {
        if ($biosSettings.ContainsKey($setting)) {
            $ActiveValue = $biosSettings[$setting]["ActiveValue"]
        } else {
            $ActiveValue = "Unknown"
        }

        # Check if the value matches the expected setting
        $color = if ($expectedValues.ContainsKey($setting) -and $ActiveValue -eq $expectedValues[$setting]) { "Green" } else { "Red" }

        # Update the UI dynamically
        $statusLabels[$setting].Content = $ActiveValue
        $statusLabels[$setting].Foreground = $color
    }
}

# Add rows for each setting
$rowIndex = 0
foreach ($setting in $settings) {
    # Configuration name label
    $label = New-Object System.Windows.Controls.Label
    $label.Content = $setting
    $label.Margin = "5"
    $label.HorizontalAlignment = "Left"
    [System.Windows.Controls.Grid]::SetRow($label, $rowIndex)
    [System.Windows.Controls.Grid]::SetColumn($label, 0)
    $grid.Children.Add($label)

    # Get current value
    if ($biosSettings.ContainsKey($setting)) {
        $ActiveValue = $biosSettings[$setting]["ActiveValue"]
    } else {
        $ActiveValue = "Unknown"
    }

    # Compare with expected values
    $color = if ($expectedValues.ContainsKey($setting) -and $ActiveValue -eq $expectedValues[$setting]) { "Green" } else { "Red" }

    # Status label
    $statusLabel = New-Object System.Windows.Controls.Label
    $statusLabel.Content = $ActiveValue
    $statusLabel.Margin = "5"
    $statusLabel.FontWeight = "Bold"
    $statusLabel.HorizontalAlignment = "Right"
    $statusLabel.Foreground = $color
    $statusLabels[$setting] = $statusLabel  # Store reference for later updates

    [System.Windows.Controls.Grid]::SetRow($statusLabel, $rowIndex)
    [System.Windows.Controls.Grid]::SetColumn($statusLabel, 1)
    $grid.Children.Add($statusLabel)

    $rowIndex++
}

# Add rows dynamically
for ($i = 0; $i -lt $settings.Count; $i++) {
    $grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))
}

# Visual separator
$separator = New-Object System.Windows.Controls.Separator
$separator.Margin = "5,10,5,10"
[System.Windows.Controls.Grid]::SetRow($separator, $settings.Count)
[System.Windows.Controls.Grid]::SetColumnSpan($separator, 2)
$grid.Children.Add($separator)

# "Configure" button
$configureButton = New-Object System.Windows.Controls.Button
$configureButton.Content = "Configure"
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

# Handle "Configure" button click
$configureButton.Add_Click({
    $errors = @()  # Store errors
    $changesMade = $false  # Track changes

    foreach ($setting in $settings) {
        if ($biosSettings.ContainsKey($setting)) {
            $currentValue = $biosSettings[$setting]["ActiveValue"]
            $expectedValue = $expectedValues[$setting]

            if ($currentValue -ne $expectedValue) {
                try {
                    $BiosSetup.SetBIOSSetting($setting, $expectedValue)
                    Write-Host "Modified $setting -> $expectedValue"
                    $changesMade = $true  # A change was made
                } catch {
                    $errors += "Error modifying $setting"
                }
            }
        } else {
            $errors += "Setting $setting not found in BIOS"
        }
    }

    # Refresh UI after modifications
    Refresh-UI

    # Show message with success or errors
    if ($errors.Count -gt 0) {
        [System.Windows.MessageBox]::Show("Some errors occurred:`n`n$($errors -join "`n")", "Error", "OK", "Error")
    } elseif ($changesMade) {
        [System.Windows.MessageBox]::Show("All settings have been successfully configured and updated in the interface.", "Success", "OK", "Information")
    } else {
        [System.Windows.MessageBox]::Show("No changes were necessary.", "Success", "OK", "Information")
    }
})

# Add extra row for the "Configure" button
$grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))

# Show the window
$window.ShowDialog()
