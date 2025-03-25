#region Windows
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

}