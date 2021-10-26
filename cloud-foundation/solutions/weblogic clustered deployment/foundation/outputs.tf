# Output the private and public IPs of the instance
locals {
  async_prov_mode = !var.is_bastion_instance_required ? "Asynchronous provisioning is enabled. Connect to each compute instance and confirm that the file /u01/data/domains/${format("%s_domain", local.service_name_prefix)}/provisioningCompletedMarker exists. Details are found in the file /u01/logs/provisioning.log." : ""
  lb_subnet_id = lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${local.lb_subnet_name}", [""]) != [""] ? [lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${local.lb_subnet_name}").id] : [""]
  lb_backend_id = lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${local.lb_subnet_backend_name}", [""]) != [""] ? [lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${local.lb_subnet_backend_name}").id] : [""]
  wls_private_id = lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${var.wls_subnet_name}-private", [""]) != [""] ? [lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${var.wls_subnet_name}-private").id] : [""]
  wls_public_id = lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${var.wls_subnet_name}-public", [""]) != [""] ? [lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${var.wls_subnet_name}-public").id] : [""]
}



output "Virtual_Cloud_Network_Id" {
  value = module.network-vcn.vcns["${var.service_name}-${var.vcn_name}"].id
}

output "Virtual_Cloud_Network_CIDR" {
  value = module.network-vcn.vcns["${var.service_name}-${var.vcn_name}"].cidr_block
}

output "Is_VCN_Peered" {
  value = local.is_vcn_peering
}

output "Loadbalancer_Subnets_Id" {
  value = compact(
    concat(
      local.lb_subnet_id,
      local.lb_backend_id
    ),
  )
}

output "WebLogic_Subnet_Id" {
  value = distinct(
    compact(
      concat(
        local.wls_private_id,
        local.wls_public_id    
      ),
    ),
  )
}


locals {
  new_bastion_details=jsonencode(join(" ", formatlist(
    "{       Instance Id:%s,       Instance Name:%s,       Private IP:%s,       Public IP:%s       }",
    module.bastion.id,
    module.bastion.display_name,
    module.bastion.privateIp,
    module.bastion.publicIp,
  )))

  existing_bastion_details=jsonencode(join(" ", formatlist(
    "{       Instance Id:%s,       Instance Name:%s,       Private IP:%s,       Public IP:%s       }",
    data.oci_core_instance.existing_bastion_instance.*.id,
    data.oci_core_instance.existing_bastion_instance.*.display_name,
    data.oci_core_instance.existing_bastion_instance.*.private_ip,
    data.oci_core_instance.existing_bastion_instance.*.public_ip
  )))
}

output "Bastion_Instance" {
  value = var.existing_bastion_instance_id==""?local.new_bastion_details: local.existing_bastion_details
}

output "Provisioning_Status" {
  value = local.async_prov_mode
}


