## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  deployments_id = {
    for instance in oci_golden_gate_deployment.this :
    instance.display_name => instance.deployment_backup_id
  }
  deployment_url = {
    for instance in oci_golden_gate_deployment.this :
    instance.display_name => instance.deployment_url
  }
  deployment_ip = {
    for instance in oci_golden_gate_deployment.this :
    instance.display_name => instance.private_ip_address
  }
}

output "deployment_id" {
  value = local.deployments_id
}

output "deployment_url" {
  value = local.deployment_url
}
output "deployment_ip" {
  value = local.deployment_ip
}
