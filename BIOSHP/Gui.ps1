Add-Type -AssemblyName PresentationFramework

# Expected BIOS values (reference table)
$expectedValues = @{
    "USB Storage Boot" = "Disable"
    "IPv6 during UEFI Boot" = "Disable"
    "Prompt on Memory Size Change" = "Disable"
    "Embedded LAN Controller" = "Disable"
    "LAN / WLAN Auto Switching" = "Enable"
    "Wake on WLAN" = "Enable"
    "HUB Wake on LAN" = "Enable"
    "Secure Boot" = "Disable"  # This will not be modified
}

# Function to fetch BIOS settings
function Get-BIOSValues {
    $biosSettings = @{}
    $BiosInfo = Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class hp_biosEnumeration
    foreach ($Conf in $BiosInfo) {
        $Param = $Conf.Name
        $Value = $Conf.Value -join ", "  # Convert array to readable text
        $ActiveValue = ($Conf.Value -split "," | Where-Object {$_ -match "\*"}) -replace "\*", ""  # Extract the active value
        $biosSettings[$Param] = @{
            "AllValues" = $Value
            "ActiveValue" = $ActiveValue
        }
    }
    return $biosSettings
}

# Retrieve current BIOS settings
$biosSettings = Get-BIOSValues

# Create the main window
$window = New-Object System.Windows.Window
$window.Title = "HP BIOS Configuration - Component Status"
$window.Width = 550
$window.Height = 450
$window.WindowStartupLocation = "CenterScreen"
$window.FontFamily = "Segoe UI"
$window.FontSize = 14

# Create the main Grid
$grid = New-Object System.Windows.Controls.Grid
$grid.Margin = "15"
$window.Content = $grid

# Define columns for the Grid
$grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition)) # Configuration Name
$grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition)) # Status

# Get the list of settings to display
$settings = $expectedValues.Keys
$statusLabels = @{}  # Dictionary to store UI labels

# Function to refresh the UI with updated values
function Refresh-UI {
    $biosSettings = Get-BIOSValues  # Re-fetch BIOS values
    foreach ($setting in $settings) {
        if ($biosSettings.ContainsKey($setting)) {
            $ActiveValue = $biosSettings[$setting]["ActiveValue"]
        } else {
            $ActiveValue = "Unknown"
        }
        # Check if the value matches the expected setting
        $color = if ($expectedValues.ContainsKey($setting) -and $ActiveValue -eq $expectedValues[$setting]) { "Green" } else { "Red" }
        
        # Update the UI Label dynamically
        $statusLabels[$setting].Content = $ActiveValue
        $statusLabels[$setting].Foreground = $color
    }
}

# Add rows for each setting
$rowIndex = 0
foreach ($setting in $settings) {
    # Label for the configuration name
    $label = New-Object System.Windows.Controls.Label
    $label.Content = $setting
    $label.Margin = "5"
    $label.HorizontalAlignment = "Left"
    [System.Windows.Controls.Grid]::SetRow($label, $rowIndex)
    [System.Windows.Controls.Grid]::SetColumn($label, 0)
    $grid.Children.Add($label)

    # Retrieve the current value
    if ($biosSettings.ContainsKey($setting)) {
        $ActiveValue = $biosSettings[$setting]["ActiveValue"]
    } else {
        $ActiveValue = "Unknown"
    }

    # Compare with expected values and set color
    $color = if ($expectedValues.ContainsKey($setting) -and $ActiveValue -eq $expectedValues[$setting]) { "Green" } else { "Red" }

    # Label for the status
    $statusLabel = New-Object System.Windows.Controls.Label
    $statusLabel.Content = $ActiveValue
    $statusLabel.Margin = "5"
    $statusLabel.FontWeight = "Bold"
    $statusLabel.HorizontalAlignment = "Right"
    $statusLabel.Foreground = $color
    $statusLabels[$setting] = $statusLabel  # Store label reference for later update

    [System.Windows.Controls.Grid]::SetRow($statusLabel, $rowIndex)
    [System.Windows.Controls.Grid]::SetColumn($statusLabel, 1)
    $grid.Children.Add($statusLabel)

    $rowIndex++
}

# Dynamically add rows to the Grid
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

# Action when clicking the "Configure" button
$configureButton.Add_Click({
    $errors = @()  # Store errors

    foreach ($setting in $settings) {
        # Exclude Secure Boot from modifications
        if ($setting -eq "Secure Boot") {
            Write-Host "Skipping Secure Boot modification."
            continue
        }

        # Check if the setting exists and needs modification
        if ($biosSettings.ContainsKey($setting)) {
            $currentValue = $biosSettings[$setting]["ActiveValue"]
            $expectedValue = $expectedValues[$setting]

            if ($currentValue -ne $expectedValue) {
                try {
                    $BiosSetup.SetBIOSSetting($setting, $expectedValue)
                    Write-Host "Modified $setting: $currentValue -> $expectedValue"
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

    # Show message box with success or error message
    if ($errors.Count -gt 0) {
        [System.Windows.MessageBox]::Show("Some errors occurred:`n`n$($errors -join "`n")", "Error", "OK", "Error")
    } else {
        [System.Windows.MessageBox]::Show("All settings have been successfully configured.", "Success", "OK", "Information")
    }
})

# Add an extra row for the "Configure" button
$grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))

# Show the window
$window.ShowDialog()
