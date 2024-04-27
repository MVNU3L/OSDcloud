Install-Module OSD -Force
Import-Module OSD -Force

Write-Host  -ForegroundColor Yellow "Starting ALN's Custom OSDCloud-Menu ..."
Write-Host 
Write-Host "===================== Main Menu =======================" -ForegroundColor Yellow
Write-Host "1: Zero-Touch Win10 21H1 | German | Professional"-ForegroundColor Yellow
Write-Host "2: Zero-Touch Win10 20H2 | German | Professional" -ForegroundColor Yellow
Write-Host "3: Zero-Touch Win10 21H1 | English | Enterprise"-ForegroundColor Yellow
Write-Host "4: Zero-Touch Win10 20H2 | English | Enterprise" -ForegroundColor Yellow
Write-Host "=======================================================" -ForegroundColor Yellow
Write-Host "7: StartOSDCloudGUI" -ForegroundColor Yellow
Write-Host "8: I'll select it myself" -ForegroundColor Yellow
Write-Host "9: Exit`n" -ForegroundColor Yellow
$input = Read-Host "Please make a selection"

Write-Host "Loading OSDCloud..." -ForegroundColor Yellow
# Change Display Resolution for Virtual Machine
if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host  -ForegroundColor Cyan "Setting Display Resolution to 1600x"
    Set-DisRes 1600
}

switch ($input)
{
    '1' { Start-OSDCloud -OSLanguage de-de -OSBuild 21H1 -OSEdition Pro } 
    '2' { Start-OSDCloud -OSLanguage de-de -OSBuild 20H2 -OSEdition Pro }
    '3' { Start-OSDCloud -OSLanguage en-us -OSBuild 21H1 -OSEdition Enterprise -ZTI }
    '4' { Start-OSDCloud -OSLanguage en-us -OSBuild 20H2 -OSEdition Enterprise -ZTI } 
    
    '7' { Start-OSDCloudGUI } 
    '8' { Start-OSDCloud	} 
    '9' { Continue		}
}

# Restart from WinPE
Write-Host  "Restarting in 10 seconds!" -ForegroundColor Cyan
Start-Sleep -Seconds 10

wpeutil reboot
