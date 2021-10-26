module "database-atp" {

  source = "../../../../cloud-foundation/modules/cloud-foundation/database/atp"

  count = local.create_atp_db ? 1 : 0 

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = local.compartment_ocid

  autonomous_database_cpu_core_count = var.autonomous_database_cpu_core_count
  autonomous_database_db_name = var.autonomous_database_db_name
  autonomous_database_admin_password = var.autonomous_database_admin_password
  autonomous_database_data_storage_size_in_tbs = var.autonomous_database_data_storage_size_in_tbs
}

module "keygen" {
  source = "../../../../cloud-foundation/modules/cloud-foundation/keygen"
  display_name = var.add_load_balancer ? data.oci_core_subnet.lb_subnet_id[0].display_name : ""
  subnet_domain_name = var.add_load_balancer ? data.oci_core_subnet.lb_subnet_id[0].subnet_domain_name : ""
}


module "wls_compute" {
  source                        = "./modules/wls-compute"
  tf_script_version             = var.image_version
  tenancy_ocid                  = var.tenancy_ocid
  compartment_ocid              = local.compartment_ocid
  instance_image_ocid           = var.instance_image_id
  numWLSInstances                = var.wls_node_count
  availability_domain           = local.wls_availability_domain
  subnet_ocid                   = var.wls_subnet_id
  region                        = var.region
  ssh_public_key                = file(var.ssh_public_key)
  instance_shape                = var.instance_shape
  wls_ocpu_count                = var.wls_ocpu_count
  wls_admin_user                = var.wls_admin_user
  wls_domain_name               = format("%s_domain", local.service_name_prefix)
  wls_admin_password            = var.wls_admin_password_ocid
  compute_name_prefix           = local.service_name_prefix
  volume_name                   = var.volume_name
  wls_nm_port                   = var.wls_nm_port
  wls_ms_server_name            = format("%s_server_", local.service_name_prefix)
  wls_admin_server_name         = format("%s_adminserver", local.service_name_prefix)
  wls_ms_port                   = var.wls_ms_port
  wls_ms_ssl_port               = var.wls_ms_ssl_port
  wls_ms_extern_ssl_port        = var.wls_ms_extern_ssl_port
  wls_ms_extern_port            = var.wls_ms_extern_port
  wls_cluster_name              = format("%s_cluster", local.service_name_prefix)
  wls_machine_name              = format("%s_machine_", local.service_name_prefix)
  wls_extern_admin_port         = var.wls_extern_admin_port
  wls_extern_ssl_admin_port     = var.wls_extern_ssl_admin_port
  wls_admin_port                = var.wls_admin_port
  wls_admin_ssl_port            = var.wls_ssl_admin_port
  wls_edition                   = var.wls_edition
  wls_subnet_id                 = var.wls_subnet_id
  is_idcs_selected              = var.is_idcs_selected
  idcs_host                     = var.idcs_host
  idcs_port                     = var.idcs_port
  idcs_tenant                   = var.idcs_tenant
  idcs_client_id                = var.idcs_client_id
  idcs_cloudgate_port           = var.idcs_cloudgate_port
  idcs_app_prefix               = local.service_name_prefix
  idcs_client_secret            = var.idcs_client_secret_ocid
  use_regional_subnet           = local.use_regional_subnet
  allow_manual_domain_extension = var.allow_manual_domain_extension
  add_loadbalancer              = var.add_load_balancer
  is_lb_private                 = var.is_lb_private
  load_balancer_id              = var.add_load_balancer ? module.wls_lb.load_balancer_id : "" 
  existing_vcn_id               = var.existing_vcn_id

  db_user     = local.db_user
  db_password = local.db_password
  db_port     = var.atp_db_port

  network_compartment_id         = var.network_compartment_id
  service_name_prefix            = local.service_name_prefix

  // ATP DB params
  atp_db_level   = var.atp_db_level
  atp_db_id      = var.create_atp_db ? module.database-atp[0].atp_db_id : trimspace(var.atp_db_id)
  is_atp_db      = var.create_atp_db ? module.database-atp[0].is_atp_db : var.is_atp_db
  app_atp_db_id  = trimspace(var.app_atp_db_id)


  // Dev or Prod mode
  mode      = var.mode
  log_level = var.log_level

  deploy_sample_app = local.deploy_sample_app

  // WLS version and artifacts
  wls_version = var.wls_version
  wls_14c_jdk_version = var.wls_14c_jdk_version

  assign_public_ip = local.assign_weblogic_public_ip
  opc_key          = module.keygen.OPCPrivateKey
  oracle_key       = module.keygen.OraclePrivateKey
  defined_tags     = local.defined_tags
  freeform_tags    = local.freeform_tags

  lbip             = var.add_load_balancer ? module.wls_lb.load_balancer_IP : ""
}

module "wls_lb" {
  source = "./modules/wls-lb"

  lbCount           = local.lbCount
  add_load_balancer = var.add_load_balancer
  compartment_ocid  = local.network_compartment_id
  tenancy_ocid      = var.tenancy_ocid
  subnet_ocids = compact(
    concat(
      compact(tolist([var.lb_subnet_id])),
      compact(tolist([var.lb_subnet_backend_id])),
    ),
  )
  instance_private_ips          = module.wls_compute.InstancePrivateIPs
  wls_ms_port                   = var.wls_ms_extern_port
  numWLSInstances                = var.wls_node_count
  name                          = "${local.service_name_prefix}-lb"
  lb_backendset_name            = "${local.service_name_prefix}-lb-backendset"
  is_idcs_selected              = var.is_idcs_selected
  idcs_cloudgate_port           = var.idcs_cloudgate_port
  defined_tags                  = local.defined_tags
  freeform_tags                 = local.freeform_tags
  is_private                    = var.is_lb_private
  allow_manual_domain_extension = var.allow_manual_domain_extension
  lb_max_bandwidth     = var.lb_max_bandwidth
  lb_min_bandwidth     = var.lb_min_bandwidth
  service_name_prefix  = local.service_name_prefix
  public_certificate   = var.add_load_balancer ? module.keygen.CertPem : "${tomap({"cert_pem"=""})}"
  private_key          = var.add_load_balancer ? module.keygen.SSPrivateKey : "${tomap({"private_key_pem"=""})}"
}

module "provisioners" {
  source = "./modules/provisioners"

  ssh_private_key = module.keygen.OPCPrivateKey["private_key_pem"]
  host_ips = coalescelist(
    compact(module.wls_compute.InstancePublicIPs),
    compact(module.wls_compute.InstancePrivateIPs),
    tolist([""])
  )
  numWLSInstances               = var.wls_node_count
  mode                         = var.mode
  bastion_host_private_key     = file(var.bastion_ssh_private_key)
  
  bastion_host = var.bastion_host
  assign_public_ip             = local.assign_weblogic_public_ip
  
  existing_bastion_instance_id = var.existing_bastion_instance_id
}
