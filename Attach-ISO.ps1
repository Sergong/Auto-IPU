<#

  Script to attach the ISO with Windows Installation

#>
param( 
    # Parameter help description
    [Parameter(Mandatory=$true)]
    [string]$VMName, # Name of VM to be migrated

    [Parameter(Mandatory=$false)]
    [string]$vcenter = "vcenter01.cabot.local", # Name of vCenter Server
    
    [Parameter(Mandatory=$false)]
    [string]$windowsISO = "windowsserver2012.iso" # Name of vCenter Server    
)



Connect-VIServer $vcenter # connects with current user credentials

# Find Windows Install ISO in datastore
$winISOPath = Get-ChildItem -Path "vmstore:\DataCenterName\DataStoreName\SubfolderName\$windowsISO"

Get-VM $VMName | Get-CDDrive| Set-CDDrive -Connected $true -IsoPath $winISOPath

