## NETWORK
#  VCN
oci network vcn list `
    --compartment-id $compartment_id `
    --region 'syd' `
    --query 'data[].{CIDR:"cidr-block",networkName:"display-name",id:"id",state:"lifecycle-state"}' `
    | convertFrom-json | format-table

# subnet
oci network subnet list `
    --compartment-id $compartment_id `
    --region 'syd' `
    --query 'data[].{subnetName:"display-name",CIDR:"cidr-block",router:"virtual-router-ip",id:"id"}' `
    | convertFrom-json | sort-object -property subnetName | format-table

# route table
oci network route-table list `
    --region "syd" `
    --compartment-id "$compartment_id" `
    --query 'data[].{name:"display-name",id:id}' `
    | convertFrom-json | sort-object -property name | format-table

## NSG
# List all NSG 
oci network nsg list `
    --compartment-id "$compartment_id" `
    --region "syd" `
    --query 'data[].{name:"display-name",id:id}' `
    | convertFrom-json | sort-object -property name | format-table

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
	
	
## peering 
oci network remote-peering-connection list `
    --compartment-id $compartment_id `
    --region 'syd' `
    --query 'data[*].{name:"display-name", status:"peering-status", peer:"peer-region-name"}' `
    | convertFrom-json | sort-object -property name | format-table

## VPN connections
oci network ip-sec-connection list `
    --compartment-id $compartment_id `
    --region 'syd' `
    --query 'data[*].{name:"display-name",state:"lifecycle-state"}' `
    | convertFrom-json | sort-object -property name | format-table
    
    
## IP
# one instance
$region = 'syd'
$instance_id = oci search resource structured-search `
    --query-text "QUERY instance resources return region where displayName =~ 'YD1PWITG-ABES'" `
    --region "$region" `
    --query 'data.items[].identifier' | jq  -r '.[]'
$vnic_id = oci compute vnic-attachment list `
    --compartment-id $compartment_id `
    --region "$region" `
    --instance-id "$instance_id" `
    --query 'data[]."vnic-id"' | jq  -r '.[]'
oci network private-ip list `
    --region "$region" `
    --vnic-id  "$vnic_id" `
    --query 'data[].{ip:"ip-address", "is-primary":"is-primary",hostname:"hostname-label"}' `
    | convertFrom-json | sort-object -property { [System.Version]($_.ip) }


# all instances in one compartment
$region = 'sin'
$instance_ids = oci compute instance list `
    --compartment-id $compartment_id `
    --region "$region" `
    --query 'data[].id' | jq  -r '.[]'
foreach ($i in $instance_ids){
    $vnic_id = oci compute vnic-attachment list `
        --compartment-id $compartment_id `
        --region "$region" `
        --instance-id "$i" `
        --query 'data[]."vnic-id"' | jq  -r '.[]'
    oci network private-ip list `
        --region "$region" `
        --vnic-id  "$vnic_id" `
        --query 'data[].{ip:"ip-address", "is-primary":"is-primary",hostname:"hostname-label"}' `
	| convertFrom-json | sort-object -property { [System.Version]($_.ip) } | format-table
}
