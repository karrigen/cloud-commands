# BOOT volume
oci bv boot-volume list `
    --compartment-id $compartment_id `
    --region 'syd' `
    --query 'data[].{name:"display-name", "size(G)":"size-in-gbs", volumeID:"id"}' `
    | convertFrom-json | sort-object -property name | format-table

# first BOOT volume    
oci bv boot-volume list --compartment-id $compartment_id --region 'syd' --query 'data[0]'

# all BOOT volumes in one region
oci search resource structured-search `
    --query-text "QUERY Volume resources" `
    --region "syd" `
    --query 'data.items[].{name:"display-name",drive:"freeform-tags"."drive_letter",instance:"freeform-tags"."instance", compartment:"compartment-id"}' `
    | convertFrom-json | sort-object -property name | format-table

# BLOCK volume    
oci bv volume list `
    --compartment-id "$compartment_id" `
    --region "syd" `
    --query 'data[].{name:"display-name",id:id}' `
    | convertFrom-json | sort-object -property name | format-table

# BLOCK voume with extended attributes
oci search resource structured-search `
    --query-text "QUERY Volume resources return allAdditionalFields" `
    --region syd `
    --query 'data.items[0]' 
    
# List BLOCK volumes for each region
Foreach ($i in get-content regions.txt){
    $i
    oci search resource structured-search `
	--query-text "QUERY Volume resources" `
	--region $i --query 'data.items[].{name:"display-name",drive:"freeform-tags"."drive_letter", compartment:"compartment-id",type:"resource-type"}' `
	| convertFrom-json | sort-object -property name | format-table
} 

# BLOCK volume attachment
oci compute volume-attachment list `
    --compartment-id "$compartment_id"`
    --region "syd" `
    --query 'data[].{type:"attachment-type",name:"display-name",ipv4:ipv4,volume:"volume-id",status:"lifecycle-state"}' `
    | convertFrom-json | sort-object -property name | format-table

# BLOCK volume backup
oci search resource structured-search `
    --query-text "QUERY VolumeBackup resources" `
    --region 'syd' `
    --query 'data.items[].{name:"display-name",volume:"freeform-tags"."bv_name",drive:"freeform-tags"."drive_letter",filesystem:"freeform-tags"."filesystem",instance:"freeform-tags"."instance"}' 
    | convertFrom-json | sort-object -property instance,volume | format-table
