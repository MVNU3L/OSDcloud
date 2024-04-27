#Check if Hyper-V is enabled and enable it if necessary
if((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Hypervisor).State -eq "Disabled")
{
    Write-host "Enabling Microsoft-Hyper-V ...."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
}
else
{
    Write-host "Microsoft-Hyper-V has succesfully been installed"
}

#Check if Hyper-V Gui is enabled and enable it if necessary
if((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Management-Clients).State -eq "Disabled") 
{ 
    Write-host "Enabling Microsoft-Hyper-V GUI ...."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
}
else 
{
    Write-host "Microsoft-Hyper-V With GUI has succesfully installed"
}
