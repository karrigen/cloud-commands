$startTime = Get-Date

# save region names to list
$regions = @('FRA','IAD','LHR','SIN','SYD','YUL','YYZ')	

# construct query text
$querytext="QUERY instance resources return region, timeMaintenanceRebootDue where timeMaintenanceRebootDue > 'Now' sorted by timeMaintenanceRebootDue desc" 

""
Write-Host "Start printing VMs maintenance reboot time for each region..."
""
foreach ($i in $regions)
{
    # call query on each region
    write-host  "$i..."
    oci search resource structured-search `
    --query-text $querytext `
    --query 'data.items[].{name:"display-name",state:"lifecycle-state",reboottime:"additional-details"."timeMaintenanceRebootDue", region:"additional-details"."region"}' `
    --region $i `
    | ConvertFrom-Json | format-table  
    ""
}

Write-Host "Done!"

$endTime = Get-Date
$executionTime = $endTime - $startTime
Write-Host "Script execution time: $executionTime"


    

    



