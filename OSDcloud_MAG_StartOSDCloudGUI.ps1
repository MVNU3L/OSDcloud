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

#Set OSDCloud Vars
$Global:MyOSDCloud = [ordered]@{
    MSCatalogFirmware     = [bool]$false
    MSCatalogDiskDrivers  = [bool]$false
    MSCatalogNetDrivers   = [bool]$false
    MSCatalogScsiDrivers  = [bool]$false
    Restart               = [bool]$False
    RecoveryPartition     = [bool]$true
    OEMActivation         = [bool]$True
    WindowsUpdate         = [bool]$True
    WindowsUpdateDrivers  = [bool]$false
    WindowsDefenderUpdate = [bool]$true
    SetTimeZone           = [bool]$true
    ClearDiskConfirm      = [bool]$False
    ShutdownSetupComplete = [bool]$false
    SyncMSUpCatDriverUSB  = [bool]$false
}
#endregion

Write-Host "Loading OSDCloud..." -ForegroundColor Yellow
if ($WindowsPhase -eq 'WinPE') {
    #Initialize WinPE Phase
    if ((Get-MyComputerModel) -match 'Virtual') {
        Write-Host  -ForegroundColor Green "Setze Bildschirmaufloesung auf 1600x"
        Set-DisRes 1600
    }  
}

#write variables to console
Write-Output $Global:MyOSDCloud

Write-Host -ForegroundColor DarkGray "based on start.osdcloud.com $ScriptVersion $WindowsPhase"
Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
#endregion

#Import OSD Module
Import-Module OSD -Force

Write-Host  -ForegroundColor Yellow "Starting MAG Custom OSDCloud-Menu..."
Write-Host 
Write-Host "===================== Main Menu =======================" -ForegroundColor Yellow
Write-Host "1: Zero-Touch Win11 23H2 | German | Professional"-ForegroundColor Yellow
Write-Host "2: Zero-Touch Win10 22H2 | German | Professional" -ForegroundColor Yellow
Write-Host "3: Zero-Touch Win11 24H2 | German | Professional" -ForegroundColor Yellow
Write-Host "4: Custom MAG WIM Install"
Write-Host "=======================================================" -ForegroundColor Yellow
$input = Read-Host "Please select a number and press Enter"



switch ($input)
{
    '1' { Start-OSDCloud -OSVersion 'Windows 11' -OSBuild 23H2 -OSEdition Pro -OSLanguage de-de -OSLicense Retail } 
    '2' { Start-OSDCloud -OSVersion 'Windows 10' -OSBuild 22H2 -OSEdition Pro -OSLanguage de-de -OSLicense Retail }
    '3' { Start-OSDCloud -OSVersion 'Windows 11' -OSBuild 24H2 -OSEdition Pro -OSLanguage de-de -OSLicense Retail }
    '4' { Start-OSDCloudGUI -WimFile "D:\OSDCloud\OS\install.wim" }   
}

#================================================
#  [PostOS] AutopilotOOBE CMD Command Line
#================================================
Write-Host -ForegroundColor Cyan "Create C:\Windows\System32\OOBE.cmd"
$OOBE = @'
PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -Force
Set Path = %PATH%;C:\Program Files\WindowsPowerShell\Scripts
Start /Wait PowerShell -NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/andrew-s-taylor/public/main/De-Bloat/RemoveBloat.ps1
'@

$OOBE | Out-File -FilePath 'C:\Windows\System32\OOBE.cmd' -Encoding ascii -Force

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
Write-Host -ForegroundColor Green "Everything is done"
    
#$null = Stop-Transcript

#region Windows
#if ($WindowsPhase -eq 'Windows') {
#Execute Custom Script
#$Uri = 'https://raw.githubusercontent.com/andrew-s-taylor/public/main/De-Bloat/RemoveBloat.ps1'
#Invoke-Expression -Command (Invoke-RestMethod -Uri $Uri)
#}

# Restart from WinPE
Write-Host  "Computer will restart in 10 seconds" -ForegroundColor Cyan
Start-Sleep -Seconds 10

wpeutil reboot

$null = Stop-Transcript
