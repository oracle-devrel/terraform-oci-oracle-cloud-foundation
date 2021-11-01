module "network-vcn" {

  source = "../../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"

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

  source = "../../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"

  compartment_id = local.network_compartment_id 
  service_label = var.service_name
  service_gateway_cidr = "all-.*-services-in-oracle-services-network"

   vcns = {for x in range(local.vcnsCount) : "" => { 
     
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
      security_list_ids = v.security_list_ids,
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

  source = "../../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-routing"

  compartment_id = local.network_compartment_id 

  subnets_route_tables = {
    "${local.service_name_prefix}-routetable-out" = {
      compartment_id = local.network_compartment_id,
      vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id,
      subnet_id = lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${local.lb_subnet_name}").id,
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
      vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id,
      subnet_id = lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${var.wls_subnet_name}-private").id,
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


module "network-routing-attachment" {

  source = "../../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-routing"

  compartment_id = local.network_compartment_id 

  subnets_route_tables = {
    "" = {
      compartment_id = local.network_compartment_id,
      vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id,
      subnet_id = lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${var.bastion_subnet_name}").id,
      route_table_id = lookup(module.network-routing.subnets_route_tables,"${local.service_name_prefix}-routetable-out").id,
      route_rules = ([]),
      defined_tags = local.defined_tags
      }
  } 
}

module "network-security-lists" {

  source = "../../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/security"
  compartment_id = local.network_compartment_id 
  ports_not_allowed_from_anywhere_cidr = [3390,4500]

  security_lists = {
    for k,v in local.wls-security-lists : k => v if v.compartment_id != "" 
  }
}

module "network-dhcp-options" {
  source = "../../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/security"

  compartment_id = local.network_compartment_id

  dhcp_options = {for x in range(local.is_vcn_peering ? 0 : (local.use_existing_subnets ? 0 : 1 ) ) : "${var.service_name}-${var.dhcp_options_name}" => { 
      vcn_id         = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id,
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

  source = "../../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/iam/iam-dynamic-group"

  dynamic_groups = {
    for k,v in local.wls-dynamic_groups : k => v if v.compartment_id != "" 
  }

}

module "policies" {

  source = "../../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/security/policies"

  policies = {
    for k,v in local.wls-policies : k => v if v.compartment_id != "" 
  }

}

module "bastion" {

  source = "./modules/bastion"

  tenancy_ocid                 = var.tenancy_ocid
  compartment_ocid             = local.compartment_ocid
  availability_domain          = local.bastion_availability_domain
  ssh_public_key               = file(var.ssh_public_key)
  bastion_subnet_ocid          = [lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${var.bastion_subnet_name}").id]
  instance_shape               = var.bastion_instance_shape
  instance_count               = local.assign_weblogic_public_ip ? 0 : 1
  is_bastion_instance_required = var.is_bastion_instance_required
  existing_bastion_instance_id = var.existing_bastion_instance_id
  region                       = var.region
  instance_name                = "${local.service_name_prefix}-bastion-instance"
  instance_image_id            = var.use_baselinux_marketplace_image ? var.mp_baselinux_instance_image_id : var.bastion_instance_image_id

  defined_tags        = local.defined_tags
  freeform_tags       = local.freeform_tags
  use_existing_subnet = var.bastion_subnet_id != ""
  wls_version         = var.wls_version

}




