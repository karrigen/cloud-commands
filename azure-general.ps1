# list all subscriptions and tenants
az account list --query "[].{SubscriptionName:name, SubscriptionID:id, TenantID:tenantId}" --output table

# login with specific tenant
az login --tenant <TenantID>

# change to specific subscription
az account set --subscription <SubscriptionID>

# list all subscription in one Tenant
az account subscription list --query "[].{name:displayName,ID:subscriptionId}" -o table
az account subscription list --query "[].subscriptionId" | ConvertFrom-Json

# storage account - check TSL version and KIND
$SubscriptionID = <SubscriptionID>
az storage account list `
	--subscription $SubscriptionID  `
	--query "[?minimumTlsVersion != 'TLS1_2'].{name:name,minimumTlsVersion:minimumTlsVersion,kind:kind}" -o table
az storage account list `
	--subscription $SubscriptionID `
	--query "[].{name:name,minimumTlsVersion:minimumTlsVersion,kind:kind}" -o table
	
foreach ($i in (get-content subscriptionid.txt)) {
    echo "$i"
    az storage account list --subscription "$i" --query "[?minimumTlsVersion != 'TLS1_2'].{name:name,minimumTlsVersion:minimumTlsVersion,kind:kind}" -o table
}

# diagnostic settings for one agw
az monitor diagnostic-settings list `
	--resource <agwName> `
	--resource-group <resourceGroupName> `
	--resource-type Microsoft.Network/applicationGateways

# diagnostic setting for all agw in one resource group
$gateway = az network application-gateway list `
	--resource-group <resourceGroupName> `
	--query '[].{name:name}' -o tsv
foreach ($i in $gateway)
{
	az monitor diagnostic-settings list --resource $i --resource-group <resourceGroupName> --resource-type Microsoft.Network/applicationGateways --query '[].{name:name}' -o tsv
}

