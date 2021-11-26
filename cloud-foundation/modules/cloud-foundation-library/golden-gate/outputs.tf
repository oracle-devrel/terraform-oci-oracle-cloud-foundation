## Copyright © 2021, Oracle and/or its affiliates. 
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
//
//output "deployment_backup_id" {
//  description = "returns a string"
//  value       = oci_golden_gate_deployment.this.deployment_backup_id
//}

//output "deployment_url" {
//  description = "returns a string"
//  value       = oci_golden_gate_deployment.this.deployment_url
//}
//output "private_ip_address" {
//  description = "returns a string"
//  value       = oci_golden_gate_deployment.this.private_ip_address
//}
//
//output "public_ip_address" {
//  description = "returns a string"
//  value       = oci_golden_gate_deployment.this.public_ip_address
//}
//
//output "state" {
//  description = "returns a string"
//  value       = oci_golden_gate_deployment.this.state
//}
//
//
//output "id" {
//  description = "returns a string"
//  value       = oci_golden_gate_deployment.this.id
//}
//
//output "is_healthy" {
//  description = "returns a bool"
//  value       = oci_golden_gate_deployment.this.is_healthy
//}
//
//output "is_latest_version" {
//  description = "returns a bool"
//  value       = oci_golden_gate_deployment.this.is_latest_version
//}
//
//output "is_public" {
//  description = "returns a bool"
//  value       = oci_golden_gate_deployment.this.is_public
//}
//
//output "lifecycle_details" {
//  description = "returns a string"
//  value       = oci_golden_gate_deployment.this.lifecycle_details
//}
//
//output "this" {
//  value = oci_golden_gate_deployment.this
//}
//output "defined_tags" {
//  description = "returns a map of string"
//  value       = oci_golden_gate_deployment.this.defined_tags
//}

//output "description" {
//  description = "returns a string"
//  value       = oci_golden_gate_deployment.this.description
//}
//
//output "fqdn" {
//  description = "returns a string"
//  value       = oci_golden_gate_deployment.this.fqdn
//}

//output "freeform_tags" {
//  description = "returns a map of string"
//  value       = oci_golden_gate_deployment.this.freeform_tags
//}

//output "nsg_ids" {
//  description = "returns a set of string"
//  value       = oci_golden_gate_deployment.this.nsg_ids
//}


//output "system_tags" {
//  description = "returns a map of string"
//  value       = oci_golden_gate_deployment.this.system_tags
//}
//
//output "time_created" {
//  description = "returns a string"
//  value       = oci_golden_gate_deployment.this.time_created
//}
//
//output "time_updated" {
//  description = "returns a string"
//  value       = oci_golden_gate_deployment.this.time_updated
//}

