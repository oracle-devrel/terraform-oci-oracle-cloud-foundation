# # Copyright © 2023, Oracle and/or its affiliates.
# # All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


# Autonomous Database Outputs:

output "ADW_Database_db_connection" {
  value = module.adw_database_private_endpoint.db_connection
}

output "ADW_Database_private_endpoint_ip" {
  value = module.adw_database_private_endpoint.private_endpoint_ip
}

output "Database_Actions" {
  value = module.adw_database_private_endpoint.url
}

output "graph_studio_url" {
  value = module.adw_database_private_endpoint.graph_studio_url
}

output "machine_learning_user_management_url" {
  value = module.adw_database_private_endpoint.machine_learning_user_management_url
}

output "database_fully_qualified_name" {
  value = module.adw_database_private_endpoint.database_fully_qualified_name
}

output "ADW_LOGIN" {
  value = "Please use the ADW URL to login by using the user admin and the password that you have provided."
}


# Object Storage Outputs:

output "Buckets" {
  value = module.os.buckets
}


# API Gateway Outputs:

output "Api_gateways" {
  value = module.api-gateway.gateways
}

output "Api_deployments" {
  value = module.api-gateway.deployments
}

output "Api_endpoints" {
  value = module.api-gateway.routes
}


# Streaming Outputs:

output "streaming_poolID" {
  value = module.streaming.streaming_poolID
}

output "streaming_ID" {
  value = module.streaming.streaming_ID
}


# Functions Outputs

output "apps" {
  value = module.functions.apps
}

output "functions" {
  value = module.functions.functions
}


# Data Catalog Outputs:

output "DataCatalog_Name" {
  value = toset(module.datacatalog[*].datacatalog)
}

output "datacatalog_data_asset_adw" {
  value = toset(module.datacatalog[*].datacatalog_data_asset_adw)
}

output "datacatalog_data_asset_object_storage" {
  value = toset(module.datacatalog[*].datacatalog_data_asset_object_storage)
}


# SSH private key Outputs:

output "generated_ssh_private_key_for_bastion" {
  value = nonsensitive(module.keygen.OPCPrivateKey["private_key_pem"])
}

resource "local_file" "private_key" {
    content  = module.keygen.OPCPrivateKey["private_key_pem"]
    filename = "private_key.pem"
    file_permission = 0600
}


# Bastion Service Outputs:

output "Bastion_service_details" {
  value = module.bastions.bastions_details
}

output "Bastion_service_sessions_details" {
  value = module.bastions.sessions_details
}


# Analytics Outputs:

output "Analytics_URL" {
  value = module.oac.Analytics_URL
}


# Data Integration Outputs:

output "Data_Integration_Service" {
  value = module.ocidi.odi
}


# Data Science Outputs:

output "Datascience" {
  value = module.datascience.datascience
}

output "Notebook" {
  value = module.datascience.notebook
}


# Data Flow Outputs:

output "dataflow_application" {
  value = module.dataflowapp.dataflow_application
}

output "dataflow_private_endpoint" {
  value = module.dataflowapp.dataflow_private_endpoint
}


# Waf Ouputs:

output "waf" {
  value = module.waf.waf
}


# Container artifacts Outputs:

output "containers_artifacts" {
  value = module.containers_artifacts.containers_artifacts
}


# Local Peeting Gatewat Outputs:

output "lpg_requestor" {
  value = module.local_peering_gateway.lpg_requestor
}

output "lpg_acceptor" {
  value = module.local_peering_gateway.lpg_acceptor
}


# Load Balancer Outputs:

output "load_balancer_IP" {
  value = module.lb.load_balancer_IP
}