# # Copyright © 2021, Oracle and/or its affiliates.
# # All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "INSTRUCTIONS" {
  value = "Please scroll up, before completing the deployment and save all the informations regarding connectivity, users, passwords"
}

output "OSA_UI" {
  value = "You can access OSA UI using https://<Web-Tier-and-Bastion>/osa"
}

output "Spark_UI" {
  value = "Access Spark UI using https://<Web-Tier-and-Bastion>/spark"
}

output "compute_linux_instances" {
  value = module.compute.linux_instances
}

output "all_instances" {
  value = module.compute.all_instances
}

output "all_private_ips" {
  value = module.compute.all_private_ips
}

output "fss_filesystems" {
  value = module.fss.filesystems
}

output "fss_mount_targets" {
  value = module.fss.mount_targets
}