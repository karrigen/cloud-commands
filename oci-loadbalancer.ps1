## LB
# first lb
oci lb load-balancer list --all --compartment-id $compartment_id --region 'syd' --query 'data[0]' 

# all lb with IP and ID, sort by name
oci lb load-balancer list --all `
    --compartment-id $compartment_id `
    --region 'syd' `
    --query 'data[*].{name:"display-name", IP:"ip-addresses"[*]."ip-address" | [0], id:"id"}' `
    | convertFrom-json | sort-object -property name | format-table

# check hostname on all lb
oci lb load-balancer list --all `
    --compartment-id $compartment_id `
    --region 'iad' `
    --query 'data[].{name:"display-name",hostnames:hostnames,backend:"backend-sets"}'
    
# load balancer in all regions all compartments
foreach ($i in get-content regions.txt) {
    oci search resource structured-search `
    --region "$i" `
    --query-text "QUERY LoadBalancer resources" `
    --query 'data.items[*].{name:"display-name",compartmentID:"compartment-id",state:"lifecycle-state"}' `
    | convertFrom-json | sort-object -property name | format-table
}    

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
    --query 'data[*].{name:"name", backend:"backends"[*]."name" | [0], cert:"ssl-configuration"."certificate-name"}' `
    | convertFrom-json | sort-object -property name | format-table

# all lb in one region
$lb_ids = oci lb load-balancer list --all `
    --compartment-id "$compartment_id" `
    --region "syd" `
    --query 'data[].id' | jq -r '.[]'
foreach ($i in $lb_ids) { 
    oci lb backend-set list --all `
    --region 'syd' `
    --load-balancer-id "$i" `
    --query 'data[*].{name:"name", backend:"backends"[*]."name" | [0], cert:"ssl-configuration"."certificate-name"}'`
    | convertFrom-json | sort-object -property name | format-table
}


    
## NETWORK LB
oci nlb network-load-balancer list --all `
    --compartment-id  "$compartment_id" `
    --region 'syd' `
    --query 'data.items[*].{name:"display-name", PublicIP:"ip-addresses"[*]."ip-address" | [0], PrivateIP:"ip-addresses"[*]."ip-address" | [1], id:"id"}' `
    | convertFrom-json | sort-object -property name | format-table
    
foreach ($i in get-content regions.txt) {
    $i
    foreach ($j in get-content compartment.txt) {  
        oci nlb network-load-balancer list --all `
            --compartment-id  $j `
            --region $i `
            --query 'data.items[*].{name:"display-name",compartment:"compartment-id"}' `
            | convertFrom-json | sort-object -property name | format-table
    }
}

## CERTIFICATE
# certificate service managed cert
oci certs-mgmt certificate list --all `
    --compartment-id "$compartment_id" `
    --region 'syd' `
    --lifecycle-state ACTIVE `
    --query 'data.items[*].{name:"name","signature-algorithm":"signature-algorithm","key-algorithm":"key-algorithm",notAfter:"current-version-summary"."validity"."time-of-validity-not-after", notBefore:"current-version-summary"."validity"."time-of-validity-not-before"}' `
	| convertFrom-json | sort-object -property name | format-table
    

# load balancer managed cert
oci lb certificate list --all `
    --region 'syd' `
    --load-balancer-id ocid1.loadbalancer.oc1.ap-sydney-1.aaaaaaaantpbzgfzpv7qhkni5p2zuka7ztmcxfwuw6peajdtlu5whbucbvqa `
    --query 'data[*]."certificate-name"' `
    | jq  -r '.[]'
    
# on all lb in a region
foreach ($i in $lb_ids) {
    write-host $i
    oci lb certificate list --all `
        --region 'syd' `
        --load-balancer-id "$i" `
        --query 'data[*]."certificate-name"'
    write-host ''
}

# create new load balancer managed cert
oci lb certificate create `
    --load-balancer-id ocid1.loadbalancer.oc1.ap-sydney-1.aaaaaaaantpbzgfzpv7qhkni5p2zuka7ztmcxfwuw6peajdtlu5whbucbvqa `
    --certificate-name wild-integrumsystems.com-2025 `
    --ca-certificate-file ca.pem `
    --private-key-file private.pem `
    --public-certificate-file public.pem
    
# update backend set
$bs=BS_Prod_Domino_oci09005
oci lb backend-set update `
    --load-balancer-id $lb `
    --backend-set-name "$bs" `
    --policy  ROUND_ROBIN \
    --backends file://./backends.json `
    --health-checker-protocol TCP `
    --ssl-certificate-name wild-integrumsystems.com-2025-bs `
    --health-checker-interval-in-ms 1000 `
    --health-checker-port 443 `
    --health-checker-retries 3 `
    --health-checker-timeout-in-ms 300
    
## RULE SET
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


