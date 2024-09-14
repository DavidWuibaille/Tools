# Load the Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Test Ports GUI'
$form.Size = New-Object System.Drawing.Size(500,500)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false

# Create the label for target input
$labelTarget = New-Object System.Windows.Forms.Label
$labelTarget.Location = New-Object System.Drawing.Point(10,10)
$labelTarget.Size = New-Object System.Drawing.Size(480,20)
$labelTarget.Text = 'Target:'
$form.Controls.Add($labelTarget)

# Create the textbox for target input
$textboxTarget = New-Object System.Windows.Forms.TextBox
$textboxTarget.Location = New-Object System.Drawing.Point(10,30)
$textboxTarget.Size = New-Object System.Drawing.Size(460,20)
$form.Controls.Add($textboxTarget)

# Create the label for port selection
$labelPort = New-Object System.Windows.Forms.Label
$labelPort.Location = New-Object System.Drawing.Point(10,60)
$labelPort.Size = New-Object System.Drawing.Size(480,20)
$labelPort.Text = 'Port:'
$form.Controls.Add($labelPort)

# Create the combobox for port selection
$comboBoxPort = New-Object System.Windows.Forms.ComboBox
$comboBoxPort.Location = New-Object System.Drawing.Point(10,80)
$comboBoxPort.Size = New-Object System.Drawing.Size(460,20)
$comboBoxPort.DropDownStyle = 'DropDownList'
# Add the port options
$comboBoxPort.Items.AddRange(@('FTP','HTTP','SMB','LDAP','SQL','EPMtestCore','EPMtestClient','VNC','Synology'))
$form.Controls.Add($comboBoxPort)



# Create the button to trigger port testing
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10,110)
$button.Size = New-Object System.Drawing.Size(460,20)
$button.Text = 'Test Port'
$button.BackColor = [System.Drawing.Color]::LightBlue
$button.ForeColor = [System.Drawing.Color]::Black
$button.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$button.Add_MouseEnter({ $button.BackColor = [System.Drawing.Color]::RoyalBlue })
$button.Add_MouseLeave({ $button.BackColor = [System.Drawing.Color]::LightBlue })

$button.Add_Click({
    $outputBox.Clear()
    $progressBar.Value = 0
    $progressBar.Maximum = $comboBoxPort.Items.Count
    $result = Test-Ports -TargetHost $textboxTarget.Text -Protocol $comboBoxPort.SelectedItem.ToString()
    foreach ($line in $result) {
        $outputBox.AppendText("$line`r`n")
        $progressBar.PerformStep()
    }
    $progressBar.Value = $progressBar.Maximum # Compléter la barre de progression
})
$form.Controls.Add($button)

# Créer le bouton pour déclencher le test de ping
$pingButton = New-Object System.Windows.Forms.Button
$pingButton.Location = New-Object System.Drawing.Point(10,140)
$pingButton.Size = New-Object System.Drawing.Size(460,20)
$pingButton.Text = 'Test Ping'
$pingButton.BackColor = [System.Drawing.Color]::LightBlue
$pingButton.ForeColor = [System.Drawing.Color]::Black
$pingButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$pingButton.Add_MouseEnter({ $pingButton.BackColor = [System.Drawing.Color]::RoyalBlue })
$pingButton.Add_MouseLeave({ $pingButton.BackColor = [System.Drawing.Color]::LightBlue })
$pingButton.Add_Click({
    $outputBox.Clear()
    $progressBar.Value = 0
    $pingResult = Test-Ping -TargetHost $textboxTarget.Text
    $outputBox.AppendText($pingResult)
})
$form.Controls.Add($pingButton)

# Create the output console
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Multiline = $true
$outputBox.ScrollBars = 'Vertical'
$outputBox.Location = New-Object System.Drawing.Point(10,180)
$outputBox.Size = New-Object System.Drawing.Size(460,220)
$form.Controls.Add($outputBox)


# Créer la barre de progression
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 420)
$progressBar.Size = New-Object System.Drawing.Size(460, 20)
$progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
$form.Controls.Add($progressBar)

# Function to test ports (Place your existing function here with slight modifications)

# Fonction pour tester le ping
function Test-Ping {
    param (
        [string]$TargetHost = "localhost"
    )

    try {
        $ping = New-Object System.Net.NetworkInformation.Ping
        $result = $ping.Send($TargetHost)
        if ($result.Status -eq 'Success') {
            return "Ping to $TargetHost successful: $($result.RoundtripTime)ms"
        } else {
            return "Ping to $TargetHost failed: $($result.Status)"
        }
    } catch {
        return "Ping failed: $_"
    }
}

function Test-Ports {
    param (
        [string]$TargetHost = "localhost",
        [string]$Protocol = "FTP"
    )

    # Définir une liste de ports avec leurs descriptions
    $FTP = @(
        @{ Port = 20; Description = "FTP Data Transfer" },
        @{ Port = 21; Description = "FTP Command Control"}
        @{ Port = 22; Description = "SFTP" },
        @{ Port = 990; Description = "FTPS Command Control (Explicit Mode)"},
        @{ Port = 989; Description = "FTPS Data Transfert (Explicit Mode)" }
    )

    $HTTP = @(
        @{ Port = 80; Description = "HTTP" },
        @{ Port = 443; Description = "HTTPS"}
    )

    $SMB = @(
        @{ Port = 139; Description = "SMB" },
        @{ Port = 445; Description = "SMB"}
    )

    $VNC = @(
        @{ Port = 5800; Description = "VNC"},
        @{ Port = 5900; Description = "VNC (java)"}
    )

    $LDAP = @(
        @{ Port = 389;  Description = "LDAP standard" },
        @{ Port = 636;  Description = "LDAP sur SSL/TLS (LDAPS)" },
        @{ Port = 3268; Description = "LDAP Query globales MS AD" },
        @{ Port = 3269; Description = "LDAPS Query globales MS AD" },
        @{ Port = 464;  Description = "Kerberos - set/change password" },
        @{ Port = 88;   Description = "Kerberos - Authentification" },
        @{ Port = 9389; Description = "AD DS Web Services" },
        @{ Port = 53;   Description = "DNS standard" },
        @{ Port = 5353; Description = "mDNS (Multicast DNS)" }
    )

    $SQL= @(
        @{ Port = 1433; Description = "SQL" }
    )

    $EPMtestClient = @(      
        @{ Port = 139;  Description = "SMB" },
        @{ Port = 445;  Description = "SMB"},  
        @{ Port = 9593;  Description = "Agent discovery, Software distribution"},         
        @{ Port = 9594;  Description = "Agent discovery and management" },
        @{ Port = 9595;  Description = "Agent discovery and management"}, 
		@{ Port = 33354;  Description = "Peer Download"},
		@{ Port = 33355;  Description = "Peer Download"}, 
		@{ Port = 33370;  Description = "Peer Download"}, 
		@{ Port = 33371;  Description = "Peer Download"}, 
        @{ Port = 44343; Description = "WS Remote Control" }
    )

    $EPMtestCore = @(
        @{ Port = 80;    Description = "HTTP" },
        @{ Port = 443;   Description = "HTTPS"},
        @{ Port = 139;   Description = "SMB" },
        @{ Port = 445;   Description = "SMB"},
        @{ Port = 9593;  Description = "Agent discovery, Software distribution"},
        @{ Port = 9594;  Description = "Agent discovery and management"},
        @{ Port = 9595;  Description = "Agent discovery and management"}
    )


	$SynologyNASPorts = @(
		@{ Port = 5000;  Description = "HTTP access" },
		@{ Port = 5001;  Description = "HTTPS access" },
		@{ Port = 21;    Description = "FTP access" },
		@{ Port = 22;    Description = "SSH access" },
		@{ Port = 2049;  Description = "NFS service" },
		@{ Port = 445;   Description = "SMB service" },
		@{ Port = 5432;  Description = "PostgreSQL database service" },
		@{ Port = 3306;  Description = "MySQL database service" },
		@{ Port = 137;   Description = "NetBIOS name service" },
		@{ Port = 138;   Description = "NetBIOS datagram service" },
		@{ Port = 139;   Description = "NetBIOS session service" },
		@{ Port = 80;    Description = "HTTP access (additional)" },
		@{ Port = 443;   Description = "HTTPS access (additional)" },
		@{ Port = 873;   Description = "rsync" },
		@{ Port = 3260;  Description = "iSCSI" },
		@{ Port = 1194;  Description = "OpenVPN service" },
		@{ Port = 5353;  Description = "DNS-SD service" },
		@{ Port = 6690;  Description = "Synology Cloud Station" },
		@{ Port = 6881;  Description = "BitTorrent service" },
		@{ Port = 1900;  Description = "UPnP/DLNA" }
	)



    # Résultats du tableau
    $results = @()

    # Sélectionner les ports en fonction du protocole
    switch ($Protocol) {
        "FTP"               { $filteredPorts = $FTP              }
        "HTTP"              { $filteredPorts = $HTTP             }
        "SMB"               { $filteredPorts = $SMB              }
        "LDAP"              { $filteredPorts = $LDAP             }
        "SQL"               { $filteredPorts = $SQL              }
        "EPMtestClient"     { $filteredPorts = $EPMtestClient    }
        "EPMtestCore"       { $filteredPorts = $EPMtestCore      }
        "VNC"               { $filteredPorts = $VNC              }
        "Synology"          { $filteredPorts = $SynologyNASPorts }
    }

    $OriginalProgressPreference = $Global:ProgressPreference
    $Global:ProgressPreference = 'SilentlyContinue'

    # Mettre à jour la barre de progression
    $progressBar.Value = 0
    $progressBar.Maximum = $filteredPorts.Count
    $progressBar.Step = 1

    # Tester chaque port
    foreach ($port in $filteredPorts) {
        $testResult = Test-NetConnection -ComputerName $TargetHost -Port $port.Port -InformationLevel Quiet
        #write-host "Test-NetConnection -ComputerName $TargetHost -Port $($port.Port)"
        #write-host $testResult          
        $results += [PSCustomObject]@{
            "Host"        = $TargetHost
            "Port"        = $port.Port
            "Description" = $port.Description
            "Status"      = if ($testResult -eq $true)  { "Open" } else { "Closed" }
        }
        $progressBar.PerformStep() # Mettre à jour la barre de progression
    }

    $Global:ProgressPreference = $OriginalProgressPreference

    $resultsText = @()
    foreach ($result in $results) {
        $Hostalign = $($result.Host).PadRight(30)
        $Portalign = $($result.Port).ToString().PadRight(8)
        $Statalign = $($result.Status).PadRight(8)
        $Desralign = $($result.Description)


        $resultsText += "$Portalign $Statalign $Desralign"
    }
 
    return $resultsText
}

# Show the form
$form.ShowDialog()
