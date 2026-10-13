[CmdletBinding()]
param()

$Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-OSDCloud.log"
$null = Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore

#region Initialize
$ScriptVersion = '15122025'
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
    #Variables to define the Windows OS / Edition etc to be applied during OSDCloud
    $Product = (Get-MyComputerProduct)
    $OSVersion = 'Windows 11' #Used to Determine Driver Pack
    $OSReleaseID = '26H2' #Used to Determine Driver Pack
    $OSName = 'Windows 11 26H2 x64'
    $OSEdition = 'Pro'
    $OSActivation = 'Retail'
    $OSLanguage = 'de-de'


    #Set OSDCloud Vars
    $Global:MyOSDCloud = [ordered]@{
        MSCatalogFirmware     = [bool]$True
        MSCatalogDiskDrivers  = [bool]$True
        MSCatalogNetDrivers   = [bool]$True
        MSCatalogScsiDrivers  = [bool]$False
        Restart               = [bool]$False
        RecoveryPartition     = [bool]$True
        OEMActivation         = [bool]$True
        WindowsUpdate         = [bool]$True
        WindowsUpdateDrivers  = [bool]$True
        WindowsDefenderUpdate = [bool]$True
        SetTimeZone           = [bool]$True
        ClearDiskConfirm      = [bool]$False
	SkipClearDisk         = [bool]$False
        ShutdownSetupComplete = [bool]$False
        SyncMSUpCatDriverUSB  = [bool]$False
    }

    #Used to Determine Driver Pack
    $DriverPack = Get-OSDCloudDriverPack -Product $Product -OSVersion $OSVersion -OSReleaseID $OSReleaseID

    if ($DriverPack) {
        $Global:MyOSDCloud.DriverPackName = $DriverPack.Name
    }

    #write variables to console
    Write-Output $Global:MyOSDCloud

    #Launch OSDCloud
    Write-Host "Starting OSDCloud" -ForegroundColor Green
    write-host "Start-OSDCloud -OSName $OSName -OSEdition $OSEdition -OSActivation $OSActivation -OSLanguage $OSLanguage"

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Start-OSDCloud -OSName $OSName -OSEdition $OSEdition -OSActivation $OSActivation -OSLanguage $OSLanguage
}
    
#================================================
#  [PostOS] AutopilotOOBE Configuration
#================================================

Write-Host -ForegroundColor Green "Creating C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json"
$AutopilotOOBEJson = @'
    {
    "Assign":  {
                   "IsPresent":  true
                },
    "GroupTag":  "EP_Hybrid",
    "Hidden":  [
                   "AddToGroup",
                   "AssignedUser",
				   "AssignedComputerName",
                   "PostAction",
                   "Assign"
               ],
    "PostAction":  "Quit",
    "Run":  "NetworkingWireless",
    "Docs":  "https://google.com/",
    "Title":  "abilis Autopilot Registrierung"
}
'@

If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -force | Out-Null
}
$AutopilotOOBEJson | Out-File -FilePath "C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json" -Encoding ascii -force

#================================================
#  [PostOS] OOBEDeploy CMD Command Line - 1.cmd
#================================================
Write-Host -ForegroundColor Green "Erstelle C:\Windows\System32\1.cmd"
$OOBECMD = @'
    PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -force
    Set Path = %PATH%;C:\Program Files\WindowsPowerShell\Scripts
    Start /Wait PowerShell -NoL -C Invoke-WebPSScript https://tinyurl.com/osdclouddebloat
	Start /Wait PowerShell -NoL -C Install-Module AutopilotOOBE -force
    Start /Wait PowerShell -NoL -C Start-AutopilotOOBE
    Start /Wait PowerShell -NoL -C Restart-Computer -force
'@
$OOBECMD | Out-File -FilePath 'C:\Windows\System32\1.cmd' -Encoding ascii -force

#Task sequence complete
Write-Host -ForegroundColor Green "Alles erledigt :-) // Bitte jetzt den USB-Stick abziehen und den PC neustarten (alle Fenster schliessen)."
Pause
Break
    
$null = Stop-Transcript


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
if ($WindowsPhase -eq 'Windows') {
    #Do something
    $null = Stop-Transcript
}
#endregion