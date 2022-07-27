<#
    Script to do Post-Testing on VM to be migrated

    Version 1.0

    Run this on Destination Hyper-V Host

    Designed for VMs running on SMB storage (like Nutanix environments)

#>
param( 
    # Parameter help description
    [Parameter(Mandatory=$true)]
    [string]$VMName, # Name of VM to be migrated

    [Parameter(Mandatory=$false)]
    [string]$NAS = "ntnx-dc2cluster.rathbones.net", # Name of Nutanix/SOFS Storage Cluster

    [Parameter(Mandatory=$false)]
    [string]$Container = "ctr1",  # Name of Nutanix Container/Share

    [Parameter(Mandatory=$false)]
    [string]$VMSizeFile = ".\Wx_VMSizes.csv", # File with VMName and T-Shirt sizes

    [Parameter(Mandatory=$false)]
    [string]$VMHost = $env:COMPUTERNAME,  # Destination VMHost

    [Parameter(Mandatory=$false)]
    [string]$Cluster = "dc2nuxcluster.rathbones.net"  # Destination Cluster
    
)


# Paths on Nutanix
$vmPath = "\\$NAS\$Container\$VMname"

$preEvents = Import-Clixml $($vmPath + "\" + $VMName +"pre-event.xml")
$preServices = Import-Clixml $($vmPath +  "\" + $VMName +"pre-service.xml")

$postEvents = Invoke-Command -ComputerName $VMName -ScriptBlock { get-eventlog -logname System -EntryType Error -After (get-date).AddDays(-1)}
$postServices = Invoke-Command -ComputerName $VMName -ScriptBlock { get-Service | ?{$_.Status -eq "Running"}}


Write-Host "Comparing Services Running Before and After Migration:" -ForegroundColor Yellow
Write-Host " "
Compare-Object -ReferenceObject $preServices -DifferenceObject $postServices

Write-Host "Comparing EventLog Errors Before and After Migration:" -ForegroundColor Yellow
Write-Host " "
if( !($preEvents -eq $null) ){
    Compare-Object -ReferenceObject $preEvents -DifferenceObject $postEvents
} else {
    Write-Host "Following new Error events founds that were not present before:"
    Write-Host " "
    $postEvents | ft EventID, EntryType, TimeGenerated, Message -AutoSize
}
