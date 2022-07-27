<#

  Script to launch unattended setup in VM

  Requires:
    - PowerCLI
    - Windows ISO must be present
    - Unattend File

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
$GuestCredential = Get-Credential -Message "Provide VM Admin Creds"

# Copy unattend file to c:\temp
Get-Item "unattend.xml" | Copy-VMGuestFile -Destination "c:\temp" -VM $VMName -LocalToGuest -GuestCredential $GuestCredential

# Figure out the drive letter of the ISO
$Script = @"
Get-CimInstance -ClassName Win32_CDROMDrive | Select-Object -Property Drive
"@
$result = invoke-VMScript -VM $VMName -ScriptText $Script -GuestCredential $GuestCredential
$cddrive = $result.VMScriptResult


# Create a Snapshot of the VM.
New-Snapshot -VM (get-VM $VMName) -Name "BeforeInplaceUpgrade"

# Launch setup.exe with unattend.xml file
$Script = @"
$global:cddrive\path\to\setup.exe /unattend:c:\temp\unattend.xml
"@
$result = invoke-VMScript -VM $VMName -ScriptText $Script -GuestCredential $GuestCredential
$result.VMScriptResult

