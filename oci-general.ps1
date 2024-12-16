# user
oci iam user list `
    --query 'sort_by(data[].{name:name,status:"lifecycle-state",MFA:"is-mfa-activated","time-created":"time-created"}, &name)' `
    --output table

# region
oci iam region-subscription list --output table
oci iam region-subscription list --query 'data[]."region-key"' | jq  -r '.[]'

# compartment
oci iam compartment list --all --output table --query "data[*].{CompartmentName: name, CompartmentID: id}"
oci iam compartment list --compartment-id-in-subtree TRUE --all --query "data[*].{CompartmentName: name, CompartmentID: id}" --output table
oci iam compartment list --compartment-id-in-subtree TRUE --all --query "data[?name=='Infrastructure']"

# availability-domain
oci iam availability-domain list --query 'data[*].name' --region 'syd' | jq  -r '.[]' 

# all resources can be used by "oci search resource structured-search"
oci search resource-type list --query 'data[*].name' --all | jq  -r '.[]' 