<#
    Script to do Pre-Testing on VM to be migrated

    Version 1.0

    Run this on Source Hyper-V Host

    If the Invoke Command Fails, try to enable WinRM in the VM with the following command "Enable-PSRemoting"
    This will also fail if the VM cannot be reached over the network (i.e. ping <name> fails)

#>
param( 
    # Parameter help description
    [Parameter(Mandatory=$true)]
    [string]$VMName, # Name of VM to be migrated

    [Parameter(Mandatory=$false)]
    [boolean]$Reboot = $true # Name of VM to be migrated    
)
if($Reboot){
    Restart-Computer -ComputerName $VMName -Force
    do {
        $ping = Test-Connection -ComputerName $VMName -Count 1 -ErrorAction SilentlyContinue
    } until($ping -eq $null)
    write-host "Pausing 5 mins."  # this time interval is big enough to allow most VMs to fully boot and be ready for WinRM calls
    Start-Sleep -Seconds 300
}

$session = New-PSSession $VMName

# collects errors for the last 24 hours and all running services and exports it to .xml files that are used by the Post-Test.ps1 script
Invoke-Command -Session $session -ScriptBlock { get-eventlog -logname System -EntryType Error -After (get-date).AddDays(-1)} | Export-Clixml .\$($VMName + "pre-event.xml")
Invoke-Command -Session $session -ScriptBlock { get-Service | ?{$_.Status -eq "Running"}} | Export-Clixml .\$($VMName + "pre-service.xml")

Remove-PSSession -Session $session
