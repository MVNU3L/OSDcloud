5[CmdletBinding()]
param()

$Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-OSDCloud.log"
$null = Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore

#Region Variables
$appx2remove = @('OneNote', 'BingWeather', 'CommunicationsApps', 'OfficeHub', 'People', 'Skype', 'Solitaire', 'Xbox', 'ZuneMusic', 'ZuneVideo', 'FeedbackHub', 'TCUI')
#endregion

#region Initialize
$ScriptVersion = '15112022'
if ($env:SystemDrive -eq 'X:') { $WindowsPhase = 'WinPE' }
else {
    $ImageState = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State' -ErrorAction Ignore).ImageState
    if ($env:UserName -eq 'defaultuser0') { $WindowsPhase = 'OOBE' }
    elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE') { $WindowsPhase = 'Specialize' }
    elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_AUDIT') { $WindowsPhase = 'AuditMode' }
    else { $WindowsPhase = 'Windows' }
}
Write-Host -ForegroundColor DarkGray "based on start.osdcloud.com $ScriptVersion $WindowsPhase"
Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
#endregion

#region WinPE
if ($WindowsPhase -eq 'WinPE') {
    #Initialize WinPE Phase
    if ((Get-MyComputerModel) -match 'Virtual') {
        Write-Host  -ForegroundColor Green "Setze Bildschirmauflösung auf 1600x"
        Set-DisRes 1600
    }    
    Import-Module OSD
    
    #Start OSDCloud
    #$Params = @{
    #    ImageFileUrl = "https://osd.allaround-it.de/pub/w10proretail22h2de.wim"
    #    ZTI          = $true
    #}
    #$Product = Get-MyComputerProduct
    #$DriverPack = Get-OSDCloudDriverPacks | Where-Object { ($_.Product -contains $Product) -and ($_.OS -match 'Windows 10') }
    StartOSDCloud "-OSVersion 'Windows 11' -OSBuild 22H2 -OSEdition Pro -OSLanguage de-de -OSLicense Retail"

    #================================================
    #  [PostOS] SetupComplete CMD Command Line
    #================================================
    Write-Host -ForegroundColor Green "Erstelle C:\Windows\Setup\Scripts\SetupComplete.cmd"
    $SetupCompleteCMD = @'
    RD C:\OSDCloud\OS /S /Q
    RD C:\Drivers /S /Q
    RD C:\Temp /S /Q
'@
    $SetupCompleteCMD | Out-File -FilePath 'C:\Windows\Setup\Scripts\SetupComplete.cmd' -Encoding ascii -force

    #Task sequence complete
    Write-Host -ForegroundColor Green "Alles erledigt :-) // Bitte jetzt den USB-Stick abziehen und den PC neustarten (alle Fenster schließen)."
    Pause
    Break
    
    $null = Stop-Transcript

}
#endregion

#region Specialize
if ($WindowsPhase -eq 'Specialize') {
    #Do something
    $null = Stop-Transcript
}
#endregion

#region AuditMode
if ($WindowsPhase -eq 'AuditMode') {
    #Do something
    $null = Stop-Transcript
}
#endregion

#region OOBE
if ($WindowsPhase -eq 'OOBE') {
    #Do something
    $null = Stop-Transcript
}
#endregion

#region Windows
# if ($WindowsPhase -eq 'Windows') {
#     #region Variables
#     $fromIsoUrl = 'https://osd.allaround-it.de/circet/OSDCloud.iso'
#     #region Warning
#     Clear-Host
#     Write-Host  -BackgroundColor  White -ForegroundColor Gray "Willkommen beim Roboter für die automatische Neuinstallation von Windows. Nach Abschluss des Vorgangs, werden Sie ein frisch installiertes Windows System nebst aktuellen Treibern auf Ihrer Festplatte vorfinden. Der Autopilot von Intune wird dann wieder alle Einstellungen und Programme installieren. Stellen Sie bitte sicher, dass alle wichtigen Daten in OneDrive gesichert sind und dass Sie den Roboter 'als Administrator' gestartet haben.`r`n"
#     Write-Host  -BackgroundColor  White -ForegroundColor Red " WARNUNG!!! `r`n"
#     Write-Host  -BackgroundColor  White -ForegroundColor Red " Wenn Sie fortfahren und die Voraussetzungen stimmen, wird im nächsten Moment der Inhalt Ihrere Festplatte unwiderbringlich gelöscht, bevor Windows neu installiert wird. Wenn Sie fortfahren möchten, geben Sie jetzt 'Ja' über die Tastatur ein und drücken 'Enter'. Wenn Sie abbrechen möchten, drücken Sie 'Enter'.`n"
#     $Commitment = Read-Host
#     if ($Commitment -ne 'Ja') {
#         Write-Host  -BackgroundColor  White -ForegroundColor Green " OK, der Vorgang wurde abgebrochen. "
#         Break
#     }
#     Write-Host  -BackgroundColor  White -ForegroundColor Green "Sie haben 'Ja' eingegeben. In 30 Sekunden startet der automatische Vorgang. Lehnen Sie sich zurück und lassen Sie den Dingen Ihren Lauf. Die Finger immer schön von der Tastatur und der Maus weglassen. Erst wenn die Sprachauswahl erscheint, dürfen Sie wieder eine Kleinigkeit tun."
#     Start-Sleep -Seconds 30
#     if ($fromIsoUrl) {
#         #region Initialize
#         $OSDCloudREVersion = '22.4.12.1'
#         [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#         Write-Host -ForegroundColor DarkGray "OSDCloudRE $OSDCloudREVersion"
#         #endregion
    
#         #region Prerequesites
#         #============================================
#         #   Test Admin Rights
#         #============================================
#         Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test Admin Rights"
#         $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
#         if (! $IsAdmin) {
#             Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloudRE requires elevated Admin Rights"
#             Break
#         }
#         #============================================
#         #   Test PowerShell Execution Policy
#         #============================================
#         Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test PowerShell Execution Policy"
#         if ((Get-ExecutionPolicy) -ne 'RemoteSigned') {
#             Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -force
#         }
#         #============================================
#         #	Test OSD Module
#         #============================================
#         Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test OSD Module"
#         $TestOSDModule = Import-Module OSD -PassThru -ErrorAction Ignore
#         if (! $TestOSDModule) {
#             Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Install Module OSD"
#             Install-Module OSD -force
#         }
#         Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test OSD Commands"
#         $TestOSDCommand = Get-Command Get-OSDCloudREPSDrive -ErrorAction Ignore
#         if (-not $TestOSDCommand) {
#             Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Install Module OSD"
#             Install-Module OSD -force
#         }
#         #endregion
    
#         #region Warning
#         Write-Warning "OSDCloudRE will be created in 10 seconds"
#         Write-Warning "Press CTRL + C to cancel"
#         Start-Sleep -Seconds 10
#         #endregion

#         $ResolveUrl = Invoke-WebRequest -Uri $fromIsoUrl -Method Head -MaximumRedirection 0 -UseBasicParsing -ErrorAction SilentlyContinue
#         if ($ResolveUrl.StatusCode -eq 302) {
#             $fromIsoUrl = $ResolveUrl.Headers.Location
#         }
    
#         Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Downloading $fromIsoUrl"
#         $fromIsoFileGetItem = Save-WebFile -SourceUrl $fromIsoUrl -DestinationDirectory (Join-Path $HOME 'Downloads')
#         $fromIsoFileFullName = $fromIsoFileGetItem.FullName
    
#         if ($fromIsoFileGetItem -and $fromIsoFileGetItem.Extension -eq '.iso') {
#             Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloudISO downloaded to $fromIsoFileFullName"
#         }
#         else {
#             Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to download OSDCloudISO"
#             Break
#         }
#         #============================================
#         #	Download ISO
#         #============================================
#         $Volumes = (Get-Volume).Where({ $_.DriveLetter }).DriveLetter
    
#         Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mounting OSDCloudISO"
#         $MountDiskImage = Mount-DiskImage -ImagePath $fromIsoFileFullName
#         Start-Sleep -Seconds 3
#         $MountDiskImageDriveLetter = (Compare-Object -ReferenceObject $Volumes -DifferenceObject (Get-Volume).Where({ $_.DriveLetter }).DriveLetter).InputObject
    
#         if ($MountDiskImageDriveLetter) {
#             $OSDCloudREMedia = "$($MountDiskImageDriveLetter):\"
#         }
#         else {
#             Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to mount $MountDiskImage"
#             Break
#         }
#         #============================================
#         #	Suspend BitLocker
#         #   https://docs.microsoft.com/en-us/windows/security/information-protection/bitlocker/bcd-settings-and-bitlocker
#         #============================================
#         $BitLockerVolumes = Get-BitLockerVolume | Where-Object { ($_.ProtectionStatus -eq 'On') -and ($_.VolumeType -eq 'OperatingSystem') } -ErrorAction Ignore
#         if ($BitLockerVolumes) {
#             $BitLockerVolumes | Suspend-BitLocker -RebootCount 1 -ErrorAction Ignore
    
#             if (Get-BitLockerVolume -MountPoint $BitLockerVolumes | Where-Object ProtectionStatus -eq "On") {
#                 Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to suspend BitLocker for next boot"
#             }
#             else {
#                 Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) BitLocker is suspended for the next boot"
#             }
#         }
#         #============================================
#         #   New-OSDCloudREVolume
#         #============================================
#         Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating a new OSDCloudRE volume"
#         $OSDCloudREVolume = New-OSDCloudREVolume
#         #============================================
#         #   PSDrive
#         #============================================
#         Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test OSDCloudRE PSDrive"
#         $OSDCloudREPSDrive = Get-OSDCloudREPSDrive
    
#         if (! $OSDCloudREPSDrive) {
#             Write-Error "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find OSDCloudRE PSDrive"
#             Break
#         }
#         #============================================
#         #	OSDCloudRERoot
#         #============================================
#         Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test OSDCloudRE Root"
#         $OSDCloudRERoot = ($OSDCloudREPSDrive).Root
#         if (-NOT (Test-Path $OSDCloudRERoot)) {
#             Write-Error "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find OSDCloudRE Root at $OSDCloudRERoot"
#             Break
#         }
#         #============================================
#         #	Update WinPE Volume
#         #============================================
#         if ((Test-Path -Path "$OSDCloudREMedia") -and (Test-Path -Path "$OSDCloudRERoot")) {
#             Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $OSDCloudREMedia to OSDCloud WinPE partition at $OSDCloudRERoot"
#             $null = robocopy "$OSDCloudREMedia" "$OSDCloudRERoot" *.* /e /ndl /njh /njs /np /r:0 /w:0 /b /zb
#         }
#         else {
#             Write-Error "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to copy Media to OSDCloudRE"
#             Break
#         }
#         #============================================
#         #	Remove Read-Only Attribute
#         #============================================
#         Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Removing Read Only attributes in $OSDCloudRERoot"
#         Get-ChildItem -Path $OSDCloudRERoot -File -Recurse -force | ForEach-Object {
#             Set-ItemProperty -Path $_.FullName -Name IsReadOnly -Value $false -force -ErrorAction Ignore
#         }
#         #============================================
#         #   Dismount OSDCloudISO
#         #============================================
#         if ($MountDiskImage) {
#             Start-Sleep -Seconds 3
#             Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Dismounting ISO at $($MountDiskImage.ImagePath)"
#             $null = Dismount-DiskImage -ImagePath $MountDiskImage.ImagePath
#         }
#         #============================================
#         #   Get-OSDCloudREVolume
#         #============================================
#         Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Testing OSDCloudRE Volume"
#         if (! (Get-OSDCloudREVolume)) {
#             Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Could not create OSDCloudRE"
#             Break
#         }
#         #============================================
#         #   Set-OSDCloudREBCD
#         #============================================
#         Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set OSDCloudRE Ramdisk: Set-OSDCloudREBootmgr -SetRamdisk"
#         Set-OSDCloudREBootmgr -SetRamdisk
#         Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set OSDCloudRE OSLoader: Set-OSDCloudREBootmgr -SetOSloader"
#         Set-OSDCloudREBootmgr -SetOSloader
#         Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Hiding OSDCloudRE volume"
#         Hide-OSDCloudREDrive
#         Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set OSDCloudRE to restart on next boot: Set-OSDCloudREBootmgr -BootToOSDCloudRE"
#         Set-OSDCloudREBootmgr -BootToOSDCloudRE
#         Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloudRE setup is complete"
#         #============================================
#     }
#     Restart-Computer -force
#     $null = Stop-Transcript
# }
# #endregion
