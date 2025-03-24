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

Write-Host  -ForegroundColor Yellow "MAG OSDcloud Setup..."
Write-Host 
Write-Host "===================== Main Menu =======================" -ForegroundColor Yellow
Write-Host "1: Zero-Touch Win11 23H2 | German | Professional"-ForegroundColor Yellow
Write-Host "2: Zero-Touch Win10 22H2 | German | Professional" -ForegroundColor Yellow
Write-Host "3: Zero-Touch Win11 24H2 | German | Professional" -ForegroundColor Yellow
Write-Host "=======================================================" -ForegroundColor Yellow
$input = Read-Host "Bitte eine Nummer wählen"

switch ($input)
{
    '1' { Start-OSDCloud -OSVersion 'Windows 11' -OSBuild 23H2 -OSEdition Pro -OSLanguage de-de -OSLicense Retail } 
    '2' { Start-OSDCloud -OSVersion 'Windows 10' -OSBuild 22H2 -OSEdition Pro -OSLanguage de-de -OSLicense Retail }
    '3' { Start-OSDCloud -OSVersion 'Windows 11' -OSBuild 24H2 -OSEdition Pro -OSLanguage de-de -OSLicense Retail }
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
Write-Host  "Neustart wird in 10 sekunden ausgeführt!" -ForegroundColor Cyan
Start-Sleep -Seconds 10

wpeutil reboot

$null = Stop-Transcript
