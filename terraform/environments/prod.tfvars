environment = "prod"
location    = "eastus"
project     = "entai"

vnet_address_space = ["10.50.0.0/16"]

aks_node_count     = 2
aks_min_node_count = 2
aks_max_node_count = 3
# DSv5 family has 0 quota on this subscription; DSv3 has 10 vCPUs available.
aks_node_vm_size = "Standard_D2s_v3"

# Serverless Consumption plan — avoids the 0 dedicated-VM quota on this sub.
function_plan_sku = "Y1"

cosmos_vector_dimensions = 1536

# The CI service principal currently has Contributor but not User Access
# Administrator, so it cannot create AcrPull role assignments. Set to true once
# that permission is granted to enable managed-identity pulls from ACR.
manage_acr_role_assignments = false

tags = {
  costCenter = "ai-platform"
}
