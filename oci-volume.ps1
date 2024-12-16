# BOOT volume
oci bv boot-volume list `
    --compartment-id $compartment_id `
    --region 'syd' `
    --query 'sort_by(data[].{instance:"freeform-tags".instance, size:"size-in-gbs", volumeID:"id"},&instance)' `
    --output table

# first BOOT volume    
oci bv boot-volume list --compartment-id $compartment_id --region 'syd' --query 'data[0]'

# all BOOT volumes in one region
oci search resource structured-search `
    --query-text "QUERY Volume resources" `
    --region "syd" `
    --query 'sort_by(data.items[].{name:"display-name",drive:"freeform-tags"."drive_letter",instance:"freeform-tags"."instance", compartment:"compartment-id"},&name)' `
    --output table 

# BLOCK volume    
oci bv volume list `
    --compartment-id "$compartment_id" `
    --region "syd" `
    --query 'sort_by(data[].{name:"display-name",id:id},&name)' `
    --output table

# BLOCK voume with extended attributes
oci search resource structured-search `
    --query-text "QUERY Volume resources return allAdditionalFields" `
    --region syd `
    --query 'data.items[0]' 
    
# List BLOCK volumes for each region
Foreach ($i in get-content regions.txt){
    $i
    oci search resource structured-search --query-text "QUERY Volume resources" --region $i --query 'data.items[].{name:"display-name",drive:"freeform-tags"."drive_letter", compartment:"compartment-id",type:"resource-type"}' --output table 
} 

# BLOCK volume attachment
oci compute volume-attachment list `
    --compartment-id "$compartment_id" `
    --region "syd" `
    --query 'sort_by(data[].{type:"attachment-type",name:"display-name",ipv4:ipv4,volume:"volume-id",status:"lifecycle-state"},&name)' `
    --output table --all

# BLOCK volume backup
oci search resource structured-search `
    --query-text "QUERY VolumeBackup resources" `
    --region 'syd' `
    --query 'data.items[].{displayname:"display-name",volume:"freeform-tags"."bv_name",drive:"freeform-tags"."drive_letter",filesystem:"freeform-tags"."filesystem",instance:"freeform-tags"."instance"}' `
    --output table