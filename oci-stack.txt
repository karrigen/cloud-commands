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

# remove from Stack Monitoring
oci stack-monitoring resource delete `
	--region 'iad' `
	--resource-id "ocid1.stackmonitoringresource.oc1.iad.amaaaaaaqcppfhyaoisactysqjcnbgcq2ez5mlvuixbuahuod5ogkkx5ydsq"