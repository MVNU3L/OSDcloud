#Start Transcript
$Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-OSDCloud.log"
$null = Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore

#Region Variables
$appx2remove = @('OneNote', 'BingWeather', 'CommunicationsApps', 'OfficeHub', 'People', 'Skype', 'Solitaire', 'Xbox', 'ZuneMusic', 'ZuneVideo', 'FeedbackHub', 'TCUI')
#endregion

#region Initialize
$ScriptVersion = '27042024'
if ($env:SystemDrive -eq 'X:') { $WindowsPhase = 'WinPE' }
else {
    $ImageState = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State' -ErrorAction Ignore).ImageState
    if ($env:UserName -eq 'defaultuser0') { $WindowsPhase = 'OOBE' }
    elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE') { $WindowsPhase = 'Specialize' }
    elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_AUDIT') { $WindowsPhase = 'AuditMode' }
    else { $WindowsPhase = 'Windows' }
}

Write-Host "Loading OSDCloud..." -ForegroundColor Yellow
if ($WindowsPhase -eq 'WinPE') {
    #Initialize WinPE Phase
    if ((Get-MyComputerModel) -match 'Virtual') {
        Write-Host  -ForegroundColor Green "Setze Bildschirmauflösung auf 1600x"
        Set-DisRes 1600
    }  
}

Write-Host -ForegroundColor DarkGray "based on start.osdcloud.com $ScriptVersion $WindowsPhase"
Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
#endregion

#Import OSD Module
Import-Module OSD -Force

#Set OSDCloud Vars
$Global:MyOSDCloud = [ordered]@{
    #Restart = [bool]$False
    #RecoveryPartition = [bool]$true
    OEMActivation = [bool]$True
    WindowsUpdate = [bool]$true
    WindowsUpdateDrivers = [bool]$true
    WindowsDefenderUpdate = [bool]$true
    SetTimeZone = [bool]$true
    ClearDiskConfirm = [bool]$true
    #ShutdownSetupComplete = [bool]$false
    #SyncMSUpCatDriverUSB = [bool]$true
    #CheckSHA1 = [bool]$true
}

Write-Host  -ForegroundColor Yellow "Starting Manuel's Custom OSDCloud-Menu ..."
Write-Host 
Write-Host "===================== Main Menu =======================" -ForegroundColor Yellow
Write-Host "1: Zero-Touch Win11 23H2 | German | Professional"-ForegroundColor Yellow
Write-Host "2: Zero-Touch Win11 23H2 | English | Professional" -ForegroundColor Yellow
Write-Host "3: Zero-Touch Win10 22H2 | German | Professional" -ForegroundColor Yellow
Write-Host "4: Zero-Touch Win10 22H2 | English | Professional" -ForegroundColor Yellow
Write-Host "5: Zero-Touch Win11 24H2 | English | Professional" -ForegroundColor Yellow
Write-Host "6: Zero-Touch Win11 24H2 | German | Professional" -ForegroundColor Yellow
Write-Host "=======================================================" -ForegroundColor Yellow
$input = Read-Host "Please choose a number"

switch ($input)
{
    '1' { Start-OSDCloud -OSVersion 'Windows 11' -OSBuild 23H2 -OSEdition Pro -OSLanguage de-de -OSLicense Retail } 
    '2' { Start-OSDCloud -OSVersion 'Windows 11' -OSBuild 23H2 -OSEdition Pro -OSLanguage en-us -OSLicense Retail }
    '3' { Start-OSDCloud -OSVersion 'Windows 10' -OSBuild 22H2 -OSEdition Pro -OSLanguage de-de -OSLicense Retail }
    '4' { Start-OSDCloud -OSVersion 'Windows 10' -OSBuild 22H2 -OSEdition Pro -OSLanguage en-us -OSLicense Retail }
    '5' { Start-OSDCloud -OSVersion 'Windows 11' -OSBuild 24H2 -OSEdition Pro -OSLanguage en-us -OSLicense Retail }
    '6' { Start-OSDCloud -OSVersion 'Windows 11' -OSBuild 24H2 -OSEdition Pro -OSLanguage de-de -OSLicense Retail }
}

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
Write-Host -ForegroundColor Green "Alles erledigt"
    
#$null = Stop-Transcript

# #region Windows
# if ($WindowsPhase -eq 'WinPE') {
# #Execute Custom Script
# $Uri = 'https://raw.githubusercontent.com/MVNU3L/OSDcloud/main/HyperV.ps1'
# Invoke-Expression -Command (Invoke-RestMethod -Uri $Uri)
# $null = Stop-Transcript
# }

# Restart from WinPE
Write-Host  "Restarting in 10 seconds!" -ForegroundColor Cyan
Start-Sleep -Seconds 10

wpeutil reboot

if ($WindowsPhase -eq 'Windows') {
#============================================
        #	Suspend BitLocker
        #   https://docs.microsoft.com/en-us/windows/security/information-protection/bitlocker/bcd-settings-and-bitlocker
        #============================================
        $BitLockerVolumes = Get-BitLockerVolume | Where-Object { ($_.ProtectionStatus -eq 'On') -and ($_.VolumeType -eq 'OperatingSystem') } -ErrorAction Ignore
        if ($BitLockerVolumes) {
            $BitLockerVolumes | Suspend-BitLocker -RebootCount 1 -ErrorAction Ignore
    
            if (Get-BitLockerVolume -MountPoint $BitLockerVolumes | Where-Object ProtectionStatus -eq "On") {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to suspend BitLocker for next boot"
            }
            else {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) BitLocker is suspended for the next boot"
            }
        }

$null = Stop-Transcript
