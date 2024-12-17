# list all buckets
oci os bucket list `
    --compartment-id "$compartment_id" `
    --region 'syd' `
    --query 'data[].name' | jq  -r '.[]' 

# list bucket content
$bucket_name = "gcp-migration"
oci os object list `
    --region 'syd' `
    --bucket-name $bucket_name `
    --query 'data[].{name:name,size:size,tier:"storage-tier"}' `
    | convertFrom-json | sort-object -property name | format-table

# retrieve data
Invoke-WebRequest -URI <URI LINK>
