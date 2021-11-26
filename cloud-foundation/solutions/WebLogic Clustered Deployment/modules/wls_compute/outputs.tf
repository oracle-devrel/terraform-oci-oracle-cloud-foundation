output "WlsVersion" {
  value = "${var.wls_version}"
}

output "applyJRF" {
  value = "${local.is_apply_JRF}"
}

output "InstancePrivateIPs" {
  value = coalescelist (module.wls_no_jrf_instance.InstancePrivateIPs, module.wls-atp-instance.InstancePrivateIPs, tolist([""]))
}

output "InstancePublicIPs" {
  value = coalescelist (module.wls_no_jrf_instance.InstancePublicIPs, module.wls-atp-instance.InstancePublicIPs, tolist([""]))
}

output "InstanceOcids" {
  value = coalescelist (module.wls_no_jrf_instance.InstanceOcids, module.wls-atp-instance.InstanceOcids, tolist([""]))
}

output "display_names" {
  value = coalescelist (module.wls_no_jrf_instance.display_names, module.wls-atp-instance.display_names, tolist([""]))
}

output "InstanceShapes" {
  value = coalescelist (module.wls_no_jrf_instance.InstanceShapes, module.wls-atp-instance.InstanceShapes, tolist([""]))
}

output "AvailabilityDomains" {
  value = coalescelist (module.wls_no_jrf_instance.AvailabilityDomains, module.wls-atp-instance.AvailabilityDomains, tolist([""]))
}
