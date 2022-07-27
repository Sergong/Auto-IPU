<#
    Script to do Post-Testing on VM to be migrated

    Version 1.0

    Run this on Management Host

    Designed to store results on local drive of Management Station (requires C:\VMLogs directory)

#>
param( 
    # Parameter help description
    [Parameter(Mandatory=$true)]
    [string]$VMName # Name of VM to be migrated    
)


# Path for storing pre-test results.
$vmPath = "C:\VMLogs\$VMname"

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
