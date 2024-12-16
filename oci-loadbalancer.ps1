## LB
# first lb
oci lb load-balancer list --all --compartment-id $compartment_id --region 'syd' --query 'data[0]' 

# all lb with IP and ID, sort by name
oci lb load-balancer list --all `
    --compartment-id $compartment_id `
    --region 'syd' `
    --query 'sort_by(data[*].{name:"display-name", IP:"ip-addresses"[*]."ip-address" | [0], id:"id"}, &name)' `
    --output table  

# check hostname on all lb
oci lb load-balancer list --all `
    --compartment-id $compartment_id `
    --region 'iad' `
    --query 'data[].{name:"display-name",hostnames:hostnames,backend:"backend-sets"}'
    
# number of lb
oci lb load-balancer list --all --compartment-id $compartment_id --region 'syd' --query 'length(data)'

## BACKEND SET
$lb_id = <loadbalancer_id>
# first backend set    
oci lb backend-set list --all --region "syd" --load-balancer-id "$lb_id" --query 'data[0]'

# all backend set with certificate
oci lb backend-set list --all `
    --region "syd" `
    --load-balancer-id "$lb_id" `
    --query 'sort_by(data[*].{name:"name", backend:"backends"[*]."name" | [0], cert:"ssl-configuration"."certificate-name"}, &name)' `
    --output table

# check for all lb in one region
$lb_ids = oci lb load-balancer list --all `
    --compartment-id "$compartment_id" `
    --region "syd" `
    --query 'data[].id' | jq -r '.[]'
foreach ($i in $lb_ids) { 
    oci lb backend-set list --all `
    --region "$syd" `
    --load-balancer-id "$i" `
    --query 'sort_by(data[*].{name:"name", backend:"backends"[*]."name" | [0], cert:"ssl-configuration"."certificate-name"}, &name)' `
    --output table
    echo ''
}

#!/bin/bash
function bs-health() {
    oci lb backend-set-health get \
    --region $1 \
    --backend-set-name $bs \
    --load-balancer-id $lb \
    --query "data.status" | jq -r ''
}
bs="BS_Prod_Domino_aob1"
lb="ocid1.loadbalancer.oc1.ap-sydney-1.aaaaaaaastehcdmn4sca6eqr63h24zflgy3oo5x54istrwgt7m4btuuqq43q"
oci lb backend-set-health get \
    --region "syd" \
    --backend-set-name $bs \
    --load-balancer-id $lb \
    --query "data.status" | jq -r ''
    
## Network load balancer
oci nlb network-load-balancer list --all `
    --compartment-id  $compartment_id `
    --region 'syd' `
    --query 'data.items[*].{name:"display-name", PublicIP:"ip-addresses"[*]."ip-address" | [0], PrivateIP:"ip-addresses"[*]."ip-address" | [1], id:"id"}' `
    --output table
$regions=get-content regions.txt
$compartment=get-content compartment.txt
foreach ($i in $regions) {
    $i
    foreach ($j in $compartment) {  
        oci nlb network-load-balancer list --all `
            --compartment-id  $j `
            --region $i `
            --query 'data.items[*].{name:"display-name",compartment:"compartment-id"}' `
            --output table
    }
}
# cert service managed cert
oci certs-mgmt certificate list --all `
    --compartment-id $compartment_id  `
    --lifecycle-state ACTIVE `
    --query 'data.items[*].{name:"name","signature-algorithm":"signature-algorithm","key-algorithm":"key-algorithm",notAfter:"current-version-summary"."validity"."time-of-validity-not-after", notBefore:"current-version-summary"."validity"."time-of-validity-not-before"}' `
    --output table
oci certs-mgmt certificate list --region 'iad' --compartment-id $compartment_id --all --lifecycle-state ACTIVE --query 'data.items[*].{name:"name"}' --output table

# load balancer managed cert
oci lb certificate list --all `
    --region "syd" `
    --load-balancer-id ocid1.loadbalancer.oc1.ap-sydney-1.aaaaaaaantpbzgfzpv7qhkni5p2zuka7ztmcxfwuw6peajdtlu5whbucbvqa `
    --query 'data[*]."certificate-name"' `
    | jq  -r '.[]'
for i in $(cat id); do
    oci lb load-balancer list --all\
        -compartment-id $compartment_id \
        --region 'iad' \
        --query "data[?id==$i].\"display-name\"" \
        | jq  -r '.[]' 
    oci lb certificate list --all \
        --load-balancer-id $lb \
        --query 'data[*]."certificate-name"'
done
# create new load balancer managed cert
oci lb certificate create \
    --load-balancer-id ocid1.loadbalancer.oc1.ap-sydney-1.aaaaaaaantpbzgfzpv7qhkni5p2zuka7ztmcxfwuw6peajdtlu5whbucbvqa \
    --certificate-name wild-integrumsystems.com-2025 \
    --ca-certificate-file ca.pem \
    --private-key-file private.pem \
    --public-certificate-file public.pem
# update backend set
$bs=BS_Prod_Domino_oci09005
oci lb backend-set update \
    --load-balancer-id $lb \
    --backend-set-name $bs \
    --policy  ROUND_ROBIN \
    --backends file://./backends.json \
    --health-checker-protocol TCP \
    --ssl-certificate-name wild-integrumsystems.com-2025-bs
    --health-checker-interval-in-ms 1000
    --health-checker-port 443
    --health-checker-retries 3
    --health-checker-timeout-in-ms 300
# load balancer in all regions all compartments
$regions=get-content regions.txt
foreach ($i in $regions) {
    oci search resource structured-search --region $i --query-text "QUERY LoadBalancer resources" --query 'sort_by(data.items[*].{name:"display-name",compartmentID:"compartment-id",state:"lifecycle-state"},&name)' --output table
}


# Load balancer rule set
oci lb rule-set list `
    --region 'lhr' `
    --load-balancer-id ocid1.loadbalancer.oc1.uk-london-1.aaaaaaaahvqzlha5gtauptgevqqnitdr6ufjq2xjmxl2hpl367kmvpxrkuva `
    --query 'data[].name'
oci lb rule-set list `
    --region 'lhr' `
    --load-balancer-id ocid1.loadbalancer.oc1.uk-london-1.aaaaaaaahvqzlha5gtauptgevqqnitdr6ufjq2xjmxl2hpl367kmvpxrkuva `
    --query 'data[].items[*]'
oci lb rule-set list `
    --region 'lhr' `
    --load-balancer-id ocid1.loadbalancer.oc1.uk-london-1.aaaaaaaahvqzlha5gtauptgevqqnitdr6ufjq2xjmxl2hpl367kmvpxrkuva `
    --query 'data[].items[*].{action:action,attri_name:conditions[]."attribute-name"[] | [0],attri_value:conditions[]."attribute-value"[] | [0]}'
oci lb rule-set create  --generate-full-command-json-input  > example.json
oci lb rule-set create `
    --name 'allowed_ips' `
    --load-balancer-id ocid1.loadbalancer.oc1.ap-sydney-1.aaaaaaaauqaqwczxstuohwjhbgmxt6sx2o7cet2qj54qnai7vi5u3bee2jba `
    --items file://example.json
