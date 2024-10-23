Invoke-WebRequest -Uri "https://nas.wuibaille.fr/LeblogOSDdownload/Repository/WindowsISO.psm1" -OutFile "$PSScriptRoot\WindowsISO.psm1"
import-module "$PSScriptRoot\WindowsISO.psm1"

$DossierAvecLesISO      = "\\nas\web\SourcesISO\Microsoft\Windows11\Windows11_22H2\ISO"
$DossierAvecLesMSU      = "\\nas\web\SourcesISO\Microsoft\Windows11\Windows11_22H2\MSU"
$DossierWinPE_OCs       = "\\nas\web\SourcesISO\Microsoft\Windows11\Windows11_22H2\MUI\Windows Preinstallation Environment\x64\WinPE_OCs"
$DossierLanguagePack    = "\\nas\web\SourcesISO\Microsoft\Windows11\Windows11_22H2\MUI\LanguagesAndOptionalFeatures"
$DossierAvecFOD			= "\\nas\web\SourcesISO\Microsoft\Windows11\Windows11_22H2\MUI\LanguagesAndOptionalFeatures"
$DossierExport          = "\\nas\usbshare1\Projets\Windows11_22H2_MUIofficiel"
$ServerClient           = "Client"
$OsName                 = "Windows 11 Pro"
#Windows 11 Education
#Windows 11 Enterprise
#Windows 11 Pro
#Windows 11 Pro Education
#Windows 11 Pro for Workstations
#Windows 10 Enterprise 2016 LTSB
#Windows 10 Enterprise LTSC => 2019 / 2021
$LocalMountWinPE        = "C:\MountWinPE"
$LocalMountWinRE        = "C:\MountWinRE"
$LocalMountInstall      = "C:\MountInstall"
$Localscratch		    = "c:\scratch"
$LocalDistribution      = "c:\distribution"
$BaseLangue             = "en-US"
	
write-host "----------- $OsName --------------------------"	


################################### Mui ###########################################################################
#Étape 1. Copier des fichiers d’installation dans un dossier de travail
Cleanup -DossierMountWindows $LocalMountInstall -DossierMountWinPE $LocalMountWinPE -DossierMountWinRE $LocalMountWinRE -DossierMountScratch $Localscratch -DossierTravail $LocalDistribution
Prepare -DossierMountWindows $LocalMountInstall -DossierMountWinPE $LocalMountWinPE -DossierMountWinRE $LocalMountWinRE -DossierMountScratch $Localscratch -DossierTravail $LocalDistribution
CopierFichierInstallation -Languebase $BaseLangue -DossierExport $LocalDistribution -DossierAvecISO $DossierAvecLesISO

#Étape 2. Ajouter des langues à l’image de démarrage du programme d’installation par défaut Windows (index:2)
AjoutLangueWinPE -DossierMountWinPE $LocalMountWinPE -DossierAvecISO $DossierAvecLesISO -OSclientOuServer $ServerClient -DossierLangueWinPE $DossierWinPE_OCs -LangueDeBase $BaseLangue -DossierExport $LocalDistribution 
AjoutLangueWinRE -DossierMountWinRE $LocalMountWinRE -DossierAvecISO $DossierAvecLesISO -DossierMountWindows $LocalMountInstall -DossierLangueWinRE $DossierWinPE_OCs                   -DossierExport $LocalDistribution  -IndexName $OsName

#Étape 3 : Ajouter des ressources d’installation de Windows localisées à la distribution Windows
AjoutLangueDistribution -DossierExport $DossierExport -DossierAvecISO $DossierAvecLesISO

#Étape 4. Ajouter des modules linguistiques à l’image Windows
AjoutLangueInstall -DossierMountWindows $LocalMountInstall -DossierAvecISO $DossierAvecLesISO -DossierAvecLangCab $DossierLanguagePack -Dossierscratch $Localscratch -DossierExport $LocalDistribution -IndexName $OsName -Languebase $BaseLangue

ActivateNetFX3 -DossierMountWindows $LocalMountInstall -DossierExport $LocalDistribution -IndexName $OsName 
ActivateFOD    -DossierMountWindows $LocalMountInstall -DossierExport $LocalDistribution -DossierAvecFOD $DossierAvecFOD -IndexName $OsName -DossierAvecISO $DossierAvecLesISO
InstallMSU     -DossierMountWindows $LocalMountInstall -DossierExport $LocalDistribution -DossierAvecMSU $DossierAvecLesMSU -IndexName $OsName 

AutoLangIni    -DossierMountWindows $LocalMountInstall -DossierExport $LocalDistribution -MountWinPE $LocalMountWinPE -IndexName $OsName 

CopyExport -Source $LocalDistribution -Destination $DossierExport
Cleanup -DossierMountWindows $LocalMountInstall -DossierMountWinPE $LocalMountWinPE -DossierMountWinRE $LocalMountWinRE -DossierMountScratch $Localscratch -DossierTravail $LocalDistribution




#remove-item "$PSScriptRoot\ImageWindowsCustomize.psm1" -Force -Recurse