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

# upload
curl -v -X PUT --data-binary '@<full file path>' <your PAR URL><file name>
# example
curl -v -X PUT --data-binary @/filepath/20201218_STG_CASA_TXNS_1.csv https://objectstorage.us-phoenix-1.oraclecloud.com/p/IWWPtdM1MNr_VG-I2p5YJldIxnNgAwbMHdrTfnqr3rM/n/oraclegbudevcorp/b/fsgbu_aml_cndevcorp_qufspr/o/20201218_STG_CASA_TXNS_1.csv


