# return all possbile attributes
oci search resource structured-search `
    --query-text 'QUERY instance resources return allAdditionalFields' `
    --query 'data.items[0]' `
    --region 'syd' 

# first instance
oci compute instance list --region "sin" --compartment-id "$compartment_id" --query 'data[0]' 

# restart instance by instance ID
oci compute instance action --instance-id <instance_OCID> --action reset

# all instances from all regions sort by compartment ID 
foreach ($i in get-content regions.txt) {
    $i
    oci search resource structured-search `
        --query-text "QUERY instance resources return region" `
        --region $i `
        --query 'sort_by(data.items[].{name:"display-name",compartment:"compartment-id"},&compartment)' `
        --output table
}
foreach ($i in $regions) {
    $i
    foreach ($compartment_id in get-content compartment.txt) {
        $compartment_id
        oci compute instance list `
            --compartment-id $compartment_id `
            --region $i `
            --query 'length(data)' 
    }
}

# dead one
oci search resource structured-search `
    --region 'iad' `
    --query-text "QUERY instance resources return region where lifeCycleState = 'TERMINATED'|| lifeCycleState = 'STOPPED'" `
    --query 'data.items[*].{name:"display-name",state:"lifecycle-state", region:"additional-details"."region"}' `
    --output table
    
# all in all compartments in a region
oci search resource structured-search `
    --region 'sin' `
    --query-text "QUERY instance resources return region where lifeCycleState = 'running'" `
    --query 'sort_by(data.items[].{name:"display-name",state:"lifecycle-state", region:"additional-details"."region", Environment:"defined-tags"."Hosting"."Environment",OS:"freeform-tags"."os",role:"freeform-tags"."role",ansible:"freeform-tags"."ansible_managed",terraform:"freeform-tags"."terraform_managed"},&name)'  `
    --output table
    
# all in one compartment in a region
oci compute instance list `
    --compartment-id $compartment_id `
    --region 'sin' `
    --query 'sort_by(data[*].{name:"display-name",state:"lifecycle-state",region:"additional-details"."region",Environment:"defined-tags"."Hosting"."Environment",OS:"freeform-tags"."os",role:"freeform-tags"."role",ansible:"freeform-tags"."ansible_managed",terraform:"freeform-tags"."terraform_managed"},&name)' `
    --output table    
    
# search for a cutomized role in a region
oci search resource structured-search `
    --query-text "QUERY instance resources return region where freeformTags.key = 'role' && freeformTags.value = 'integrum_domino_client_instance'" `
    --region 'syd' `
    --query 'data.items[]."display-name"' `
    | jq  -r '.[]' | sort
    

# count
oci compute instance list --compartment-id $compartment_id --region='syd' --query 'length(data)' 

# query by name
oci search resource structured-search `
    --query-text "QUERY instance resources return region where displayName =~ 'AB1CLDBA01'" `
    --region 'iad' `
    --query 'data.items[].{name:"display-name",state:"lifecycle-state", region:"additional-details"."region", Environment:"defined-tags"."Hosting"."Environment",OS:"freeform-tags"."os",role:"freeform-tags"."role",ansible:"freeform-tags"."ansible_managed",terraform:"freeform-tags"."terraform_managed"}' `
    --output table
    

# all managed by ansible in a region 
oci search resource structured-search `
    --region 'syd' `
    --query-text "QUERY instance resources return region where freeformTags.key = 'ansible_managed' && freeformTags.value =~ 'true'" `
    --query 'data.items[*].{name:"display-name",state:"lifecycle-state", region:"additional-details"."region", Environment:"defined-tags"."Hosting"."Environment",OS:"freeform-tags"."os",role:"freeform-tags"."role",ansible:"freeform-tags"."ansible_managed",terraform:"freeform-tags"."terraform_managed"}' `
    --output table
    

# all linux in a region
oci search resource structured-search `
    --region 'iad' `
    --query-text "QUERY instance resources return region where (lifeCycleState='running' && freeformTags.key = 'os' && freeformTags.value =~ 'linux' )" `
    --query 'data.items[]."display-name"' `
    | jq  -r '.[]' 
    

#  windows instance with memory
oci compute instance list  `
    --compartment-id "$compartment_id" `
    --region "syd" `
    --query 'sort_by(data[].{name:"display-name", memory:"shape-config"."memory-in-gbs"}, &name)' `
    --output table