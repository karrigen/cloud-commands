# all metrics
oci monitoring metric list `
    --compartment-id $compartment_id --all `
    --query 'data[].{name:name,namespace:namespace}' `
    --output table

# low cpu usage
oci monitoring metric-data summarize-metrics-data `
    --region 'iad' `
    --compartment-id $compartment_id `
    --namespace oci_computeagent `
    --start-time 2024-12-15T00:00:00.000Z `
    --end-time 2024-12-17T00:00:00.000Z `
    --query-text "CpuUtilization[1d].mean() < 1" `
    --query 'data[].{compartment:"compartment-id",instance:dimensions.resourceDisplayName}' `
    | convertFrom-json | sort-object -property instance | format-table

# low memory usage
oci monitoring metric-data summarize-metrics-data `
    --region 'syd' `
    --compartment-id $compartment_id `
    --namespace oci_computeagent `
    --start-time 2024-12-15T00:00:00.000Z `
    --end-time 2024-12-16T00:00:00.000Z `
    --query-text "MemoryUtilization[1d].mean() < 10" `
    --query 'data[].{instance:dimensions.resourceDisplayName}'  `
    | jq  -r '.[].instance'

# low cpu usage all regions
$result = foreach ($i in get-content regions.txt) {
    $i
    foreach ($compartment_id in get-content compartment.txt) {
        $compartment_id
        oci monitoring metric-data summarize-metrics-data `
	    --region $i `
            --compartment-id $compartment_id `
	    --namespace oci_computeagent `
            --start-time 2024-05-30T00:00:00.000Z `
	    --end-time 2024-06-30T00:00:00.000Z `
            --query-text "CpuUtilization[1d].mean() < 1" `
	    --query 'sort_by(data[].{compartment:"compartment-id",instance:dimensions.resourceDisplayName},&instance)' `
            | jq  -r '.[].instance' 
    }
    echo ""
    echo "--------------------------------"
    echo ""
    echo ""
}
$result | out-file instance-lowCPU.txt


# low memory usage all regions
$result = foreach ($i in $regions) {
    $i
    foreach ($compartment_id in $compartment) {
        $compartment_id
        oci monitoring metric-data summarize-metrics-data `
	    --region $i `
            --compartment-id $compartment_id `
	    --namespace oci_computeagent `
            --start-time 2024-05-30T00:00:00.000Z `
	    --end-time 2024-06-30T00:00:00.000Z `
            --query-text "MemoryUtilization[1d].mean() < 10" `
	    --query 'sort_by(data[].{compartment:"compartment-id",instance:dimensions.resourceDisplayName},&instance)' `
            | jq  -r '.[].instance' 
    }
    echo ""
    echo "--------------------------------"
    echo ""
    echo ""
}
$result | out-file instance-lowMemory.txt
