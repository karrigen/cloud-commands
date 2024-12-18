# all instances registered with Stack Monitoring
oci stack-monitoring resource list `
    --compartment-id "$compartment_id" `
    --region 'iad' `
    --query 'data.items[*].{name:name,id:id, displayName:"display-name",hostname:"host-name",state:"lifecycle-state"}' `
    | ConvertFrom-Json | Sort-Object state | format-table 

# production only 
oci stack-monitoring resource list `
    --compartment-id "$compartment_id" `
    --region 'iad' `
    --query 'data.items[*].{hostname:"host-name",state:"lifecycle-state"}' `
    | ConvertFrom-Json | Sort-Object hostname | format-table  | Out-String -Stream | Select-String -Pattern "1P"

# remove instance from Stack Monitoring
oci stack-monitoring resource delete `
    --region 'iad' `
    --resource-id "ocid1.stackmonitoringresource.oc1.iad.amaaaaaaqcppfhyaoisactysqjcnbgcq2ez5mlvuixbuahuod5ogkkx5ydsq"

# use oci search resource structured-search
oci search resource structured-search `
    --region 'iad'  `
    --query-text "QUERY StackMonitoringResource resources where lifeCycleState =~ 'ACTIVE'" `
    --query 'data.items[*]."display-name"' `
    --limit 1000 `
    | ConvertFrom-Json | sort | select-string "i9"

## management agent
# list management agent
oci search resource structured-search `
    --region 'iad' `
    --query-text "QUERY ManagementAgent resources where lifeCycleState =~ 'ACTIVE'" `
    --query 'data.items[*]."display-name"' `
    --limit 1000 `
	| ConvertFrom-Json | sort

# first item	
oci management-agent agent list --compartment-id $compartment_id --region iad --query 'data[0]'

oci management-agent agent list `
    --compartment-id $compartment_id `
    --region iad  `
    --query 'data[*].{status:"availability-status",displayName:"display-name",host:host}' `
    | ConvertFrom-Json | Sort-Object displayName | format-table 

# agent name only 
oci management-agent agent list `
    --compartment-id $compartment_id `
    --region iad  `
    --query 'data[*].{displayName:"display-name"}' `
    | ConvertFrom-Json | sort displayName 
