# Set-ExecutionPolicy RemoteSigned
# Unblock-File -Path "C:\HyperV_Status.ps1"
# "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -File "C:\HyperV_Status.ps1"
Param ([string]$VMID)
Param ([string]$Status)
<#  
    $LogPath is where log files are saved.
#>  
$LogPath = "C:\Users\Public\Documents\Hyper-V\Status"

if (!($VMID)) {
    Write-Host "VMID is required."
    Write-Host $(Get-VM | Select-Object VMName, VMID)
    Write-Host "CMD> ""powershell.exe"" -File ""C:\HyperV_Status.ps1"" -VMID ""9623d59a-a9e9-40cf-a0fd-913248491d50"" -Status ""Running"""
    Write-Host "PowerShell> & ""C:\HyperV_Status.ps1"" -VMID ""9623d59a-a9e9-40cf-a0fd-913248491d50"" -Status ""Running"""
    Exit
}
if (!($Status)) {
    Write-Host "Status is required."
    Write-Host "Running, Paused, Saved, Off"
    Write-Host "CMD> ""powershell.exe"" -File ""C:\HyperV_Status.ps1"" -VMID ""9623d59a-a9e9-40cf-a0fd-913248491d50"" -Status ""Running"""
    Write-Host "PowerShell> & ""C:\HyperV_Status.ps1"" -VMID ""9623d59a-a9e9-40cf-a0fd-913248491d50"" -Status ""Running"""
    Exit
}
$DateTimeStart = Get-Date -format "yyyy-MM-dd-THHmm"
try {
    $VMName = $(Get-VM -Id $VMID -ErrorAction Stop).VMName  
}
catch {
    Write-Host $Error[0].Exception.GetType().FullName
    Write-Host $PSItem.ToString()
    Exit
}
$LogFile = "$($LogPath)\$($VMName)_$($DateTimeStart).log"
Function LogWrite {
    Param ([string]$LogString)
    Add-content $LogFile -value $LogString
    Write-Host $LogString
}

try {
    $State = $(Get-VM -Id $VMID).State
    if ($(Get-VM -Id $VMID).State -eq "Saving") {
        while($(Get-VM -Id $VMID).State -eq "Saving") {
            Start-Sleep -s 1
        }
    }

    $State = $(Get-VM -Id $VMID).State
    if ($(Get-VM -Id $VMID).State -eq "Paused") {
        LogWrite "$($VMName) state is $($State). Sending command to resume."
        Start-VM -Name $VMName -ErrorAction Resume
    }

    $State = $(Get-VM -Id $VMID).State
    if ($(Get-VM -Id $VMID).State -eq "Off") {
        LogWrite "$($VMName) state is $($State). Sending command to start."
        Start-VM -Name $VMName -ErrorAction Start
    }

    $State = $(Get-VM -Id $VMID).State
    if ($(Get-VM -Id $VMID).State -eq "Saved") {
        LogWrite "$($VMName) state is $($State). Sending command to start."
        Start-VM -Name $VMName -ErrorAction Start
    }

    $State = $(Get-VM -Id $VMID).State
    if ($(Get-VM -Id $VMID).State -eq "Starting") {
        while($(Get-VM -Id $VMID).State -eq "Starting") {
            Start-Sleep -s 1
        }
    }

    $State = $(Get-VM -Id $VMID).State
    if ($(Get-VM -Id $VMID).State -eq "Running") {
        # no action
    }
}
catch {
    LogWrite $($Error[0].Exception.GetType().FullName)
    LogWrite $($PSItem.ToString())
}
