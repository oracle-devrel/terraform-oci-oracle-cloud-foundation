#Foundation

locals {
  //async_prov_mode = !var.is_bastion_instance_required ? "Asynchronous provisioning is enabled. Connect to each compute instance and confirm that the file /u01/data/domains/${format("%s_domain", local.service_name_prefix)}/provisioningCompletedMarker exists. Details are found in the file /u01/logs/provisioning.log." : ""
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

/*output "Is_VCN_Peered" {
  value = local.is_vcn_peering
}*/

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


/*output "Provisioning_Status" {
  value = local.async_prov_mode
}*/



#Deployment

locals {
  admin_ip_address = local.assign_weblogic_public_ip? module.wls_compute.InstancePublicIPs[0] : module.wls_compute.InstancePrivateIPs[0]
  admin_console_app_url = format(
    "https://%s:%s/console",
    local.admin_ip_address,
    var.wls_extern_ssl_admin_port,
  )

  jdk_version = var.wls_version == "14.1.1.0" ? var.wls_14c_jdk_version : (var.wls_version == "11.1.1.7" ? "jdk7" : "jdk8")
  fmw_console_app_url = local.requires_JRF ? format(
    "https://%s:%s/em",
    local.admin_ip_address,
    var.wls_extern_ssl_admin_port,
  ) : ""
  sample_app_protocol = var.add_load_balancer ? "https" : "http"
  sample_app_url_wls_ip = var.deploy_sample_app? format(
    "https://%s:%s/sample-app",
    local.admin_ip_address,
    var.wls_ms_extern_ssl_port,
  ) : ""
  sample_app_url_lb_ip = var.deploy_sample_app && var.add_load_balancer ? format(
    "%s://%s/sample-app",
    local.sample_app_protocol,
    module.wls_lb.load_balancer_IP
  ) : ""
  sample_app_url = var.wls_edition != "SE" ? (var.deploy_sample_app && var.add_load_balancer ? local.sample_app_url_lb_ip : local.sample_app_url_wls_ip) : ""
  sample_idcs_app_url = var.deploy_sample_app && var.add_load_balancer && var.is_idcs_selected ? format(
    "%s://%s/__protected/idcs-sample-app",
    local.sample_app_protocol,
    module.wls_lb.load_balancer_id,
  ) : ""

  edition_map = zipmap(
    ["SE", "EE", "SUITE"],
    ["Standard Edition", "Enterprise Edition", "Suite Edition"],
  )
}

output "Load_Balancer_Ip" {
  value = var.add_load_balancer ? module.wls_lb.load_balancer_IP : ""
}

output "WebLogic_Instances" {
  value = jsonencode(join(" ", formatlist(
    "{       Instance Id:%s,       Instance name:%s,       Availability Domain:%s,       Instance shape:%s,       Private IP:%s,       Public IP:%s       }",
    module.wls_compute.InstanceOcids,
    module.wls_compute.display_names,
    module.wls_compute.AvailabilityDomains,
    module.wls_compute.InstanceShapes,
    module.wls_compute.InstancePrivateIPs,
    module.wls_compute.InstancePublicIPs,
  )))
}

output "WebLogic_Version" {
  value = format(
    "%s %s %s",
    module.wls_compute.WlsVersion,
    local.edition_map[upper(var.wls_edition)],
    local.requires_JRF ? local.is_atp_db || local.create_atp_db ? "(JRF with ATP DB)" : "" : "(Non JRF)",
  )
}

output "WebLogic_Server_Administration_Console" {
  value = local.admin_console_app_url
}

output "Fusion_Middleware_Control_Console" {
  value = local.fmw_console_app_url
}

output "Sample_Application" {
  value = local.sample_app_url
}

output "Sample_Application_protected_by_IDCS" {
  value = local.sample_idcs_app_url
}

output "Listing_Version" {
  value=local.image_version
}

output "JDK_Version" {
  value = local.jdk_version
}

