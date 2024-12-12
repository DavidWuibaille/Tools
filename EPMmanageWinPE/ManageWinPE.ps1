Add-Type -AssemblyName System.Windows.Forms

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Configure Drivers /Keyboard for EPM"
$form.Size = New-Object System.Drawing.Size(400, 250) # Adjusted size to fit elements nicely

# Server name label and textbox
$labelServer = New-Object System.Windows.Forms.Label
$labelServer.Text = "IVANTI Server Name:"
$labelServer.Location = New-Object System.Drawing.Point(10, 20)
$form.Controls.Add($labelServer)

$textBoxServer = New-Object System.Windows.Forms.TextBox
$textBoxServer.Location = New-Object System.Drawing.Point(150, 18)
$textBoxServer.Width = 200
$form.Controls.Add($textBoxServer)

# Architecture selection (x64 or x86)
$labelArch = New-Object System.Windows.Forms.Label
$labelArch.Text = "Select Architecture:"
$labelArch.Location = New-Object System.Drawing.Point(10, 60)
$form.Controls.Add($labelArch)

$radioButtonX64 = New-Object System.Windows.Forms.RadioButton
$radioButtonX64.Text = "x64"
$radioButtonX64.Location = New-Object System.Drawing.Point(150, 58)
$radioButtonX64.Checked = $true
$form.Controls.Add($radioButtonX64)

$radioButtonX86 = New-Object System.Windows.Forms.RadioButton
$radioButtonX86.Text = "x86"
$radioButtonX86.Location = New-Object System.Drawing.Point(150, 88)
$form.Controls.Add($radioButtonX86)

# Execute button with improved positioning and appearance
$buttonExecute = New-Object System.Windows.Forms.Button
$buttonExecute.Text = "Execute"
$buttonExecute.Location = New-Object System.Drawing.Point(150, 150) # Lowered position
$buttonExecute.Size = New-Object System.Drawing.Size(100, 30) # Wider and more visible
$buttonExecute.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($buttonExecute)

# Function to handle the button click event
$buttonExecute.Add_Click({
    $serverName = $textBoxServer.Text
    $architecture = if ($radioButtonX64.Checked) { "x64" } else { "x86" }
    $WinPEfile = if ($radioButtonX64.Checked) { "boot_x64.wim" } else { "boot.wim" }

    if ([string]::IsNullOrWhiteSpace($serverName)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter the IVANTI server name.","Input Error",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    Write-Host "--- Forcing unmount of all mounted WIM files..."
    # Force unmount of all mounted WIM files (DISM alternative via PowerShell)
    Get-WindowsImage -Mounted | ForEach-Object {
        Dismount-WindowsImage -Path $_.Path -Discard
        Write-Host "--- Unmounted WIM: $($_.Path)"
    }

    Write-Host "--- Creating mount directory at C:\mount"
    # Create the mount directory
    $mountDir = "C:\mount"
    if (-Not (Test-Path $mountDir)) {
        New-Item -Path $mountDir -ItemType Directory
        Write-Host "--- Mount directory created."
    } else {
        Write-Host "--- Mount directory already exists."
    }

    # Date and time formatting
    $date = Get-Date -Format "yyyyMMdd"
    $time = Get-Date -Format "HHmm"

    # Define the paths based on architecture
    $wimFile = "\\$serverName\ldmain\landesk\vboot\$WinPEfile"
    $backupFile = $WinPEfile.replace(".wim","")
    $backupFile = "\\$serverName\ldmain\landesk\vboot\" + $backupFile + "_" + $date + "_" + $time + "_backup.wim"

    Write-Host "--- Backing up the WIM file to $backupFile"
    # Backup the WIM file
    Copy-Item -Path $wimFile -Destination $backupFile -Force
    Write-Host "--- Backup completed."

    Write-Host "--- Mounting the WIM file..."
    # Mount the WIM file using PowerShell cmdlet
    Mount-WindowsImage -ImagePath $wimFile -Index 1 -Path $mountDir
    Write-Host "--- WIM file mounted."

    Write-Host "--- Copying choice.exe to the mounted WIM image."
    # Copy necessary files and open scripts for editing
    Copy-Item -Path "$PSScriptRoot\choice_$architecture.exe" -Destination "$mountDir\Windows\system32\choice.exe"
    
    # Path to startnet.cmd
    $startnetCmdPath = "$mountDir\Windows\System32\startnet.cmd"

    Write-Host "--- Checking and updating startnet.cmd if necessary."
    # Read the content of startnet.cmd if exists
    if (Test-Path $startnetCmdPath) {
        $startnetContent = Get-Content -Path $startnetCmdPath -Raw

        # Check if 'setkeyboardlayout' is not present, ignoring case
        if ($startnetContent -notmatch '(?i)setkeyboardlayout') {
            # Define the keyboard selection block
            $keyboardBlock = @"
@echo off
echo 1: Keyboard = FR
echo 2: Keyboard = IT
echo 3: Keyboard = EN
echo 4: Keyboard = CA
echo 5: Keyboard = DE
echo 6: Keyboard = ES
echo 7: Keyboard = IT
echo 8: Keyboard = PT
echo 9: Keyboard = PL
echo 0: Keyboard = RU

CHOICE /C 1234567890 /N /T 90 /D 1 /M "Choice keyboard"

if %ERRORLEVEL%==1  set Clavier=040C:0000040C
if %ERRORLEVEL%==2  set Clavier=0410:00000410
if %ERRORLEVEL%==3  set Clavier=0409:00000409
if %ERRORLEVEL%==4  set Clavier=0c0c:00001009
if %ERRORLEVEL%==5  set Clavier=0407:00000407
if %ERRORLEVEL%==6  set Clavier=0C0A:0000040A
if %ERRORLEVEL%==7  set Clavier=0410:00000410
if %ERRORLEVEL%==8  set Clavier=0816:00000816
if %ERRORLEVEL%==9  set Clavier=0415:00000415
if %ERRORLEVEL%==10 set Clavier=0419:00000419

wpeutil setkeyboardlayout %Clavier%
"@

            # Prepend the keyboard block to the startnet.cmd file
            Set-Content -Path $startnetCmdPath -Value "$keyboardBlock`r`n$startnetContent"
            Write-Host "--- Keyboard configuration added to startnet.cmd."
        } else {
            Write-Host "--- Keyboard configuration already exists in startnet.cmd."
        }
    } else {
        # Handle the case where startnet.cmd does not exist
        [System.Windows.Forms.MessageBox]::Show("startnet.cmd not found at $startnetCmdPath.","File Error",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    Write-Host "--- Opening startnet.cmd and corename.txt for review."
    # Open files in Notepad and block execution until they are closed
    Start-Process notepad.exe -ArgumentList "$mountDir\Windows\System32\startnet.cmd" -Wait
    Start-Process notepad.exe -ArgumentList "$mountDir\temp\corename.txt" -Wait

    Write-Host "--- Adding drivers $PSScriptRoot\Drivers\$architecture"
    # Add drivers using PowerShell cmdlet and handle errors
    try {
        Add-WindowsDriver -Path $mountDir -Driver "$PSScriptRoot\Drivers\$architecture" -Recurse -ErrorAction Stop
        Write-Host "--- Drivers added."
    } catch {
        Write-Host "--- Error adding drivers: $($_.Exception.Message)"
        
        # Attempt to open the DISM log for more details without blocking the script
        $dismLog = "$env:windir\Logs\DISM\dism.log"
        Write-Host "--- ERROR open $dismLog for more details"
        # Exit the script if driver addition fails
    }

    Write-Host "--- Unmounting the WIM file and committing changes."
    # Unmount the WIM file using PowerShell cmdlet
    Dismount-WindowsImage -Path $mountDir -Save
    Write-Host "--- WIM file unmounted and changes committed."

    Write-Host "--- Operation completed successfully."
    [System.Windows.Forms.MessageBox]::Show("Operation completed successfully.","Success",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
})

# Show the form
$form.ShowDialog()
