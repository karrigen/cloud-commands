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

# example
Invoke-WebRequest -URI https://objectstorage.ap-sydney-1.oraclecloud.com/p/v7A9NRLLm2uFrHsqm2eAzARZa-o3I9KGasLActPGkSzWQEguPWxRIbS-jDNU0UlU/n/axitewuuaucy/b/gcp-migration/o/IMS15_YF.rar