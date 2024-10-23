Invoke-WebRequest -Uri "https://nas.wuibaille.fr/LeblogOSDdownload/Repository/WindowsISO.psm1" -OutFile "$PSScriptRoot\WindowsISO.psm1"
import-module "$PSScriptRoot\WindowsISO.psm1"

#********************************************************************************************************************************
# ATTENTION : Installer le Windows ADK correspondant à la version de Windows
#********************************************************************************************************************************

$DossierAvecLesISO      = "\\nas\web\SourcesISO\Microsoft\Windows11\Windows11_22H2\ISO"
$DossierAvecLesMSU      = "\\nas\web\SourcesISO\Microsoft\Windows11\Windows11_22H2\MSU"
$DossierWinPE_OCs       = "\\nas\web\SourcesISO\Microsoft\Windows11\Windows11_22H2\MUI\Windows Preinstallation Environment\x64\WinPE_OCs"
$DossierLanguagePack    = "\\nas\web\SourcesISO\Microsoft\Windows11\Windows11_22H2\MUI\LanguagesAndOptionalFeatures"
$DossierExport          = "\\nas\usbshare1\Projets\Windows11_22H2_MultiIndex"
$ServerClient           = "Client"
$OsName                 = "Windows 11 Pro"
#Windows 11 Education
#Windows 11 Enterprise
#Windows 11 Pro
#Windows 11 Pro Education
#Windows 11 Pro for Workstations


$LocalMountWinPE        = "C:\MountWinPE"
$LocalMountWinRE        = "C:\MountWinRE"
$LocalMountInstall      = "C:\MountInstall"
$Localscratch		    = "c:\scratch"
$LocalDistribution      = "c:\distribution"
$BaseLangue             = "en-US"
	

################################### MultiIndex ###########################################################################
#Étape 1. Copier des fichiers d’installation dans un dossier de travail
Cleanup -DossierMountWindows $LocalMountInstall -DossierMountWinPE $LocalMountWinPE -DossierMountWinRE $LocalMountWinRE -DossierMountScratch $Localscratch -DossierTravail $LocalDistribution
Prepare -DossierMountWindows $LocalMountInstall -DossierMountWinPE $LocalMountWinPE -DossierMountWinRE $LocalMountWinRE -DossierMountScratch $Localscratch -DossierTravail $LocalDistribution
CopierFichierInstallation -Languebase $BaseLangue -DossierExport $DossierExport -DossierAvecISO $DossierAvecLesISO

#Étape 2. Ajouter des langues à l’image de démarrage du programme d’installation par défaut Windows (index:2)
AjoutLangueWinPE -DossierMountWinPE $LocalMountWinPE -DossierAvecISO $DossierAvecLesISO -OSclientOuServer $ServerClient -DossierLangueWinPE $DossierWinPE_OCs -LangueDeBase $BaseLangue -DossierExport $DossierExport

#Étape 3 : Ajouter des ressources d’installation de Windows localisées à la distribution Windows
AjoutLangueDistribution -DossierExport $DossierExport -DossierAvecISO $DossierAvecLesISO

#Étape 4. Ajouter des modules linguistiques à l’image Windows
Wimindex -DossierAvecISO $DossierAvecLesISO -DossierExport $DossierExport -DossierTravail $LocalDistribution -IndexName $OsName 
ActivateNetFX3 -DossierMountWindows $LocalMountInstall -DossierExport $DossierExport -IndexName "ALL" 
ActivateFOD -DossierMountWindows $LocalMountInstall -DossierExport $DossierExport -DossierAvecFOD $DossierLanguagePack -IndexName "ALL" -DossierAvecISO $DossierAvecLesISO
InstallMSU -DossierMountWindows $LocalMountInstall -DossierExport $DossierExport -DossierAvecMSU $DossierAvecLesMSU -IndexName "ALL" 
FakeLangIni -DossierExport $DossierExport -DossierAvecISO $DossierAvecLesISO -Languebase $BaseLangue

Cleanup -DossierMountWindows $LocalMountInstall -DossierMountWinPE $LocalMountWinPE -DossierMountWinRE $LocalMountWinRE -DossierMountScratch $Localscratch -DossierTravail $LocalDistribution