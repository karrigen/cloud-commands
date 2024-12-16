## NETWORK
#  VCN
oci network vcn list `
    --compartment-id $compartment_id `
    --region 'syd' `
    --query 'data[].{CIDR:"cidr-block",networkName:"display-name",id:"id",state:"lifecycle-state"}' `
    --output table

# subnet
oci network subnet list `
    --compartment-id $compartment_id `
    --region 'syd' `
    --query 'sort_by(data[].{subnetName:"display-name",CIDR:"cidr-block",router:"virtual-router-ip",id:"id"},&router)' `
    --output table


# route table
oci network route-table list `
    --region "syd" `
    --compartment-id "$compartment_id" `
    --query 'sort_by(data[].{name:"display-name",id:id},&name)' `
    --output table


## NSG
# List all NSG 
oci network nsg list `
    --compartment-id "$compartment_id" `
    --region "syd" `
    --query 'sort_by(data[].{name:"display-name",id:id},&name)' `
    --output table

# rule
$nsgid = oci network nsg list --compartment-id "$compartment_id" --region "syd" --display-name "YD1PGDOM" --query 'data[].id' | jq -r '.[]'
oci network nsg rules list `
    --region "syd" `
    --nsg-id "$nsgid" `
    --all `
    --query 'data[].{description:description,protocol:protocol, direction:direction, "tcp-options":"tcp-options", "udp-options":"udp-options"}' |  ConvertFrom-Json | sort description | format-table  description,direction,protocol, @{label="tcp_dest_port";Expression={$_."tcp-options"."destination-port-range"}},@{label="tcp_source_port";Expression={$_."tcp-options"."source-port-range"}}, @{label="udp_dest_port";Expression={$_."udp-options"."destination-port-range"}}, @{label="udp_source_port";Expression={$_."udp-options"."source-port-range"}}

## DNS
# DNS resolver
oci dns resolver list `
    --compartment-id $compartment_id `
    --region 'syd'
    
# private view
oci dns view list `
    --compartment-id $compartment_id `
    --region 'syd'