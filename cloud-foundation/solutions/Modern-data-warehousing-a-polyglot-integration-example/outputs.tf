# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "ADW_Service_Console_URL" {
  value = module.adw.ADW_Service_Console_URL
}

output "Analytics_URL" {
  value = module.oac.Analytics_URL
}

output "Instructions" {
  value = "Please use the ADW URL to login by using the user admin and the password that you have provided."
}

output "Buckets" {
  value = module.os.buckets
}

output "DataCatalog" {
  value = module.datacatalog.datacatalog
}

output "Odi" {
  value = module.odi.odi
}

output "Datascience" {
  value = module.datascience.datascience
}

output "Notebook" {
  value = module.datascience.notebook
}

output "deployment_id" {
  value = module.golden_gate_deployment.deployment_id
}

output "private_ip" {
  value = module.golden_gate_deployment.deployment_ip
}

output "deployment_url" {
  value = module.golden_gate_deployment.deployment_url
}

output "golgen_gate_console" {
  value = "The GoldenGate console is only accessible through a private URL from a Compute instance using the same VCN as the GoldenGate deployment, or through a bastion host."
}