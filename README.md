# cloud-commands
CLI commands for OCI Azure etc.

# region
oci iam region-subscription list --output table

# compartment
oci iam compartment list --all --output table --query "data[*].{CompartmentName: name, CompartmentID: id}"
oci iam compartment list --compartment-id-in-subtree TRUE --all --query "data[*].{CompartmentName: name, CompartmentID: id}" --output table
oci iam compartment list --compartment-id-in-subtree TRUE --all --query "data[?name=='Infrastructure']"

# availability-domain
oci iam availability-domain list --query 'data[*].name' --region syd | jq  -r '.[]' 

# all resources can be searched
oci search resource-type list --query 'data[*].name' --all | jq  -r '.[]' 
