#Foundation

module "network-vcn" {

  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"

  compartment_id = local.network_compartment_id 
  service_label = var.service_name
  service_gateway_cidr = lookup(data.oci_core_services.tf_services.services[0], "cidr_block")

   vcns = {for x in range(local.vcnsCount) : "${var.service_name}-${var.vcn_name}" => { 
     
     compartment_id = local.network_compartment_id
     cidr           = var.vcn_cidr
     dns_label      = format("%svcn",substr((var.service_name), 0, 10))
     is_create_igw  = (var.vcn_name=="" || local.use_existing_subnets) ? false : true
     is_attach_drg = false
     block_nat_traffic = var.is_idcs_selected && !local.assign_weblogic_public_ip && var.vcn_name!="" ? true : false

     subnets  = {subnet={compartment_id="", vcn_id="", availability_domain="", cidr="", dns_label="",private=false,dhcp_options_id="",security_list_ids=[""], defined_tags={}, freeform_tags={}}}

     defined_tags = local.defined_tags
     freeform_tags = local.freeform_tags
    }
  }
}

module "network-subnets" {

  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"

  compartment_id = local.network_compartment_id 
  service_label = var.service_name
  service_gateway_cidr = "all-.*-services-in-oracle-services-network"

   vcns = {for x in range (local.use_existing_subnets ? 0 : 1) : "" => { 
     
     compartment_id = local.network_compartment_id
     cidr           = var.vcn_cidr
     dns_label      = format("%svcn",substr((var.service_name), 0, 10))
     is_create_igw  = false
     is_attach_drg  = false
     block_nat_traffic = var.is_idcs_selected && !local.assign_weblogic_public_ip && var.vcn_name!="" ? true : false
     
     subnets           =  {for k, v in local.create_subnets: k => {
      compartment_id    = v.compartment_id,
      vcn_id            = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id
      availability_domain = v.availability_domain,
      cidr              = v.cidr,
      dns_label         = v.dns_label,
      private           = v.private,
      dhcp_options_id   = v.dhcp_options_id,
      security_list_ids = null,
      defined_tags      = v.defined_tags,
      freeform_tags     = v.freeform_tags
     } if v.compartment_id != ""
     }

     defined_tags = local.defined_tags
     freeform_tags = local.freeform_tags
    }
  }
}

module "network-routing" {

  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-routing"

  compartment_id = local.network_compartment_id 

  subnets_route_tables = {
    "${local.service_name_prefix}-routetable-out" = {
      compartment_id = local.network_compartment_id,
      vcn_id = var.vcn_name != "" ? lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id : var.existing_vcn_id,
      subnet_id = var.lb_subnet_id == "" ? lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${local.lb_subnet_name}").id : var.lb_subnet_id,
      route_table_id = "",
      route_rules = [{
        is_create = true,
        destination       = "0.0.0.0/0",
        destination_type  = "CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn.internet_gateways, lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id).id,
        description       = ""
      }],
      defined_tags = local.defined_tags
      },
    "${local.service_name_prefix}-routetable" = {
      compartment_id = local.network_compartment_id,
      vcn_id = var.vcn_name != "" ? lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id : var.existing_vcn_id,
      subnet_id = var.wls_subnet_id == "" ? lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${var.wls_subnet_name}-private").id : var.wls_subnet_id,
      route_table_id = "",
      route_rules = concat( [],
         var.is_idcs_selected?
        [  
          {
            is_create = true,
            destination       =  "0.0.0.0/0",
            destination_type  = "CIDR_BLOCK",
            network_entity_id = lookup(module.network-vcn.nat_gateways, lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id).id,
            description       = ""
          }] : []
          , 
          [
            {
            is_create = true
            destination       = lookup(data.oci_core_services.tf_services.services[0], "cidr_block"),
            destination_type  = "SERVICE_CIDR_BLOCK",
            network_entity_id = lookup(module.network-vcn.service_gateways, lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id).id,
            description       = ""
        }
        ]),
      defined_tags = local.defined_tags
    }
  } 
}

module "network-nsgs" {

  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/security"
  compartment_id = var.compartment_ocid 
  ports_not_allowed_from_anywhere_cidr = [3390,4500]

  #nsgs lists map
  nsgs = local.create_nsgs

}

module "network-dhcp-options" {

  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/security"

  compartment_id = local.network_compartment_id

  dhcp_options = {for x in range( local.use_existing_subnets ? 0 : 1 ) : "${var.service_name}-${var.dhcp_options_name}" => { 
      vcn_id         = var.vcn_name != "" ? lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id : var.existing_vcn_id,
      compartment_id = local.network_compartment_id,
      options = {
        type = "DomainNameServer"
        server_type = "VcnLocalPlusInternet"
      },
      defined_tags = local.defined_tags,
      freeform_tags = local.freeform_tags
    } 
  }
}

module "dynamic_groups" {

  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/iam/iam-dynamic-group"

  dynamic_groups = {
    for k,v in local.wls-dynamic_groups : k => v if v.compartment_id != "" 
  }

}

module "policies" {

  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/security/policies"

  policies = {
    for k,v in local.wls-policies : k => v if v.compartment_id != "" 
  }

}

module "bastions" {

  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/security/bastion"
  bastions = {
    "bastionInstance" = {
      name = "${local.service_name_prefix}Instance"
      compartment_id = local.compartment_ocid
      target_subnet_id = local.assign_weblogic_public_ip ? lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${var.wls_subnet_name}-public").id : lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${var.wls_subnet_name}-private").id
      client_cidr_block_allow_list = [var.anywhere_cidr]
      max_session_ttl_in_seconds = 3600
    }
  }
  sessions = {}
}

#Deployment

module "database-atp" {

  source = "../../../cloud-foundation/modules/cloud-foundation-library/database/atp"

  count = local.create_atp_db ? 1 : 0 

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = local.compartment_ocid

  autonomous_database_cpu_core_count = var.autonomous_database_cpu_core_count
  autonomous_database_db_name = var.autonomous_database_db_name
  autonomous_database_admin_password = var.autonomous_database_admin_password
  autonomous_database_data_storage_size_in_tbs = var.autonomous_database_data_storage_size_in_tbs
}

module "keygen" {

  source = "../../../cloud-foundation/modules/cloud-foundation-library/keygen"
  
  display_name = var.add_load_balancer ? "${local.service_name_prefix}-${local.lb_subnet_name}" : ""
  subnet_domain_name = var.add_load_balancer ? lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${local.lb_subnet_name}").subnet_domain_name : ""
}

module "wls_compute" {
  source                        = "./modules/wls_compute"
  tf_script_version             = var.image_version
  tenancy_ocid                  = var.tenancy_ocid
  compartment_ocid              = local.compartment_ocid
  instance_image_ocid           = var.instance_image_id
  numWLSInstances                = var.wls_node_count
  availability_domain           = local.wls_availability_domain
  subnet_ocid                   = local.assign_weblogic_public_ip ? lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${var.wls_subnet_name}-public").id : lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${var.wls_subnet_name}-private").id
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
  existing_vcn_id               = module.network-vcn.vcns["${var.service_name}-${var.vcn_name}"].id
  nsg_ids                       = !local.assign_weblogic_public_ip ? [lookup(module.network-nsgs.nsgs,"wls-internal-nsg").id,lookup(module.network-nsgs.nsgs,"wls-ms-nsg").id, lookup(module.network-nsgs.nsgs,"wls-ms-external-nsg").id] : [lookup(module.network-nsgs.nsgs,"wls-nsg").id, lookup(module.network-nsgs.nsgs,"wls-internal-nsg").id,lookup(module.network-nsgs.nsgs,"wls-ms-nsg").id, lookup(module.network-nsgs.nsgs,"wls-ms-external-nsg").id]

  db_user     = local.db_user
  db_password = local.db_password
  db_port     = var.atp_db_port

  network_compartment_id         = var.network_compartment_id
  service_name_prefix            = local.service_name_prefix

  atp_db_level   = var.atp_db_level
  atp_db_id      = var.create_atp_db ? module.database-atp[0].atp_db_id : trimspace(var.atp_db_id)
  is_atp_db      = var.create_atp_db ? module.database-atp[0].is_atp_db : var.is_atp_db

  mode      = var.mode
  log_level = var.log_level

  deploy_sample_app = local.deploy_sample_app

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

  source = "./modules/wls_lb"

  lbCount           = local.lbCount
  add_load_balancer = var.add_load_balancer
  compartment_ocid  = local.network_compartment_id
  tenancy_ocid      = var.tenancy_ocid
  subnet_ocids = compact(
    concat(
      compact(tolist([lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${local.lb_subnet_name}").id])),
      compact(tolist(lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${local.lb_subnet_backend_name}", [""]) != [""] ? [lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${local.lb_subnet_backend_name}").id] : [""])),
    ),
  )
  network_security_group_ids = [lookup(module.network-nsgs.nsgs,"lb-nsg").id]
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

module "sessions" {

    source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/security/bastion"
    bastions = {}
    sessions = {for x in range(var.wls_node_count) : "session-${x}" => { 
      session_type = "PORT_FORWARDING",
      bastion_id = lookup(module.bastions.bastions_details,"${local.service_name_prefix}Instance").id,
      ssh_public_key = module.keygen.OPCPrivateKey["public_key_openssh"],
      private_instance_id = module.wls_compute.InstanceOcids["${x}"],
      private_ip_address = module.wls_compute.InstancePrivateIPs["${x}"],
      user_name = "opc",
      port = "22",
      display_name = "session-${x}"
    }
  }

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
  bastion_host_private_key     = module.keygen.OPCPrivateKey["private_key_pem"]
 
  bastion_host = "host.bastion.${var.region}.oci.oraclecloud.com"
  bastion_user = module.sessions.sessions_details["session-0"].bastion_user_name
  assign_public_ip             = local.assign_weblogic_public_ip

}
