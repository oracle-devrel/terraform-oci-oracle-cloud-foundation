output "WlsVersion" {
  value = "${var.wls_version}"
}

output "applyJRF" {
  value = "${local.is_apply_JRF}"
}

output "InstancePrivateIPs" {
  value = coalescelist (module.wls-instances.InstancePrivateIPs, tolist([""]))
}

output "InstancePublicIPs" {
  value = coalescelist (module.wls-instances.InstancePublicIPs, tolist([""]))
}

output "InstanceOcids" {
  value = coalescelist (module.wls-instances.InstanceOcids, tolist([""]))
}

output "display_names" {
  value = coalescelist (module.wls-instances.display_names, tolist([""]))
}

output "InstanceShapes" {
  value = coalescelist (module.wls-instances.InstanceShapes, tolist([""]))
}

output "AvailabilityDomains" {
  value = coalescelist (module.wls-instances.AvailabilityDomains, tolist([""]))
}
