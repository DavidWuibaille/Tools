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
    "Secure Boot" = "Disable"
}

# Retrieve BIOS values
$BiosInfo = Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class hp_biosEnumeration
$BiosSetup = Get-WmiObject -Class hp_biossettinginterface -Namespace root/hp/instrumentedBIOS

# Store BIOS settings in a dictionary
$biosSettings = @{}

foreach ($Conf in $BiosInfo) {
    $Param = $Conf.Name
    $Value = $Conf.Value -join ", "  # Convert to readable text
    $ActiveValue = ($Conf.Value -split "," | Where-Object {$_ -match "\*"}) -replace "\*", ""  # Extract active value

    $biosSettings[$Param] = @{
        "AllValues" = $Value
        "ActiveValue" = $ActiveValue
    }
}

# Create main window
$window = New-Object System.Windows.Window
$window.Title = "HP BIOS Configuration - Component Status"
$window.Width = 550
$window.Height = 450
$window.WindowStartupLocation = "CenterScreen"
$window.FontFamily = "Segoe UI"
$window.FontSize = 14

# Create main grid
$grid = New-Object System.Windows.Controls.Grid
$grid.Margin = "15"
$window.Content = $grid

# Define grid columns
$grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition)) # Name column
$grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition)) # Status column

# List of settings to display
$settings = $expectedValues.Keys

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

    # Get the current value
    if ($biosSettings.ContainsKey($setting)) {
        $ActiveValue = $biosSettings[$setting]["ActiveValue"]
    } else {
        $ActiveValue = "Unknown"
    }

    # Check compliance
    $color = if ($expectedValues.ContainsKey($setting) -and $ActiveValue -eq $expectedValues[$setting]) { "Green" } else { "Red" }

    # Status label
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

# Dynamically add rows to grid
for ($i = 0; $i -lt $settings.Count; $i++) {
    $grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))
}

# Visual separator
$separator = New-Object System.Windows.Controls.Separator
$separator.Margin = "5,10,5,10"
[System.Windows.Controls.Grid]::SetRow($separator, $settings.Count)
[System.Windows.Controls.Grid]::SetColumnSpan($separator, 2)
$grid.Children.Add($separator)

# Configure button
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
    $changesMade = $false  # Track if any settings were changed

    foreach ($setting in $settings) {
        if ($biosSettings.ContainsKey($setting)) {
            $currentValue = $biosSettings[$setting]["ActiveValue"]
            $expectedValue = $expectedValues[$setting]

            if ($currentValue -ne $expectedValue) {
                try {
                    $BiosSetup.SetBIOSSetting($setting, $expectedValue)
                    Write-Host "Modified $setting : $currentValue -> $expectedValue"
                    $changesMade = $true  # A change was made
                } catch {
                    $errors += "Error modifying $setting"
                }
            }
        } else {
            $errors += "Setting $setting not found in BIOS"
        }
    }

    # If changes were made, restart PowerShell
    if ($changesMade) {
        [System.Windows.MessageBox]::Show("Settings updated. Restarting PowerShell...", "Restart", "OK", "Information")
$window.Close()  # Close the GUI window before restarting PowerShell
Start-Sleep -Seconds 1  # Ensure the window has time to close
Start-Process "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -WindowStyle Normal
exit

    } else {
        [System.Windows.MessageBox]::Show("No changes were necessary.", "Success", "OK", "Information")
    }
})

# Add a row for the "Configure" button
$grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))

# Show window
$window.ShowDialog()
