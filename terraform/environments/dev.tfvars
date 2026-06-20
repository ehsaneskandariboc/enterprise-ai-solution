environment = "dev"
location    = "eastus"
project     = "entai"

vnet_address_space = ["10.40.0.0/16"]

aks_node_count     = 2
aks_min_node_count = 2
aks_max_node_count = 4
aks_node_vm_size   = "Standard_D4s_v5"

cosmos_vector_dimensions = 1536

# The CI service principal currently has Contributor but not User Access
# Administrator, so it cannot create AcrPull role assignments. Set to true once
# that permission is granted to enable managed-identity pulls from ACR.
manage_acr_role_assignments = false

tags = {
  costCenter = "ai-platform"
}
