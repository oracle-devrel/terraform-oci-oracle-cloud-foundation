# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "adw" {
  source = "./modules/adw_subsystem"
    compartment_id           = var.compartment_id
    adw_cpu_core_count       = var.adw_cpu_core_count
    adw_size_in_tbs          = var.adw_size_in_tbs
    adw_db_name              = var.adw_db_name
    adw_db_workload          = var.adw_db_workload
    adw_db_version           = var.adw_db_version
    adw_enable_auto_scaling  = var.adw_enable_auto_scaling
    adw_is_free_tier         = var.adw_is_free_tier
    adw_license_model        = var.adw_license_model
    database_admin_password  = var.database_admin_password
    database_wallet_password = var.database_wallet_password
    # subnet_ocid              = lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${var.private_subnet_name}").id
    # nsg_ids                  = module.network-security-groups.nsgid
    defined_tags             = local.defined_tags
    # defined_tags             = var.adw_defined_tags
    # defined_tags  = { "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.release.name}" = "1.0",
    #                   "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.subsystem.name}" = "adw_subsystem",
    #                   "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.module.name}" = "adw"
    #                 }
}

module "oac" {
  source = "./modules/oac_subsystem"
    compartment_id                             = var.compartment_id
    analytics_instance_feature_set             = var.analytics_instance_feature_set
    analytics_instance_license_type            = var.analytics_instance_license_type
    analytics_instance_hostname                = var.analytics_instance_hostname
    analytics_instance_idcs_access_token       = var.analytics_instance_idcs_access_token
    analytics_instance_capacity_capacity_type  = var.analytics_instance_capacity_capacity_type
    analytics_instance_capacity_value          = var.analytics_instance_capacity_value
    analytics_instance_network_endpoint_details_network_endpoint_type = var.analytics_instance_network_endpoint_details_network_endpoint_type
    subnet_id = lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${var.private_subnet_name}").id
    vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id
    analytics_instance_network_endpoint_details_whitelisted_ips = var.analytics_instance_network_endpoint_details_whitelisted_ips
    analytics_instance_network_endpoint_details_whitelisted_vcns_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id
    whitelisted_ips                            = var.whitelisted_ips
    defined_tags                               = local.defined_tags
    # defined_tags                             = var.oac_defined_tags
    # defined_tags  = { "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.release.name}" = "1.0",
    #                   "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.subsystem.name}" = "oac_subsystem",
    #                   "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.module.name}" = "oac"
    #                 }
}

module "os" {
  source = "./modules/object-storage_subsystem"
    tenancy_ocid          = var.tenancy_ocid
    compartment_id        = var.compartment_id
    bucket_name           = var.bucket_name
    bucket_access_type    = var.bucket_access_type
    bucket_storage_tier   = var.bucket_storage_tier
    bucket_events_enabled = var.bucket_events_enabled
    defined_tags          = local.defined_tags
    # defined_tags          = var.os_defined_tags
    # defined_tags  = { "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.release.name}" = "1.0",
    #                   "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.subsystem.name}" = "objectstorage",
    #                   "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.module.name}" = "objectstorage"
    #                 }
}

module "datacatalog" {
  source = "./modules/datacatalog_subsystem"
      compartment_id           = var.compartment_id
      datacatalog_display_name = var.datacatalog_display_name
      defined_tags             = local.defined_tags
      # defined_tags             = var.datacatalog_defined_tags
      # defined_tags  = { "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.release.name}" = "1.0",
      #                   "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.subsystem.name}" = "datacatalog_subsystem",
      #                   "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.module.name}" = "datacatalog"
      #                 }
}

module "odi" {
  source = "./modules/odi_subsystem"
    compartment_id             = var.compartment_id
    display_name               = var.odi_display_name
    description                = var.odi_description
    defined_tags               = local.defined_tags
      # defined_tags          = var.os_defined_tags
    # defined_tags  = { "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.release.name}" = "1.0",
    #                   "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.subsystem.name}" = "objectstorage",
    #                   "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.module.name}" = "objectstorage"
    #                 }
}

module "network-vcn" {

  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"

  compartment_id = var.compartment_id
  service_label  = var.service_name
  service_gateway_cidr = lookup(data.oci_core_services.tf_services.services[0], "cidr_block")

   vcns = {for x in range(local.vcnsCount) : "${var.service_name}-${var.vcn_name}" => { 
     
     compartment_id = var.compartment_id
     cidr           = var.vcn_cidr
     dns_label      = format("%svcn",substr((var.service_name), 0, 10))
     is_create_igw  = (var.vcn_name=="" || local.use_existing_subnets) ? false : true
     is_attach_drg  = false
     block_nat_traffic = local.assign_public_ip && var.vcn_name!="" ? true : false

     subnets  = {subnet={compartment_id="", vcn_id="", availability_domain="", cidr="", dns_label="",private=false,dhcp_options_id="",security_list_ids=[""], defined_tags={}, freeform_tags={}}}

     defined_tags = local.defined_tags
    #  defined_tags = var.network_defined_tags
    #  defined_tags  = { "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.release.name}" = "1.0",
    #                    "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.subsystem.name}" = "network",
    #                    "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.module.name}" = "vcn-basic"
    #                  }
     freeform_tags = local.freeform_tags
    }
  }
}

module "network-subnets" {

  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"

  compartment_id = var.compartment_id
  service_label  = var.service_name
  service_gateway_cidr = "all-.*-services-in-oracle-services-network"

   vcns = {for x in range(local.vcnsCount) : "" => { 
     
     compartment_id = var.compartment_id
     cidr           = var.vcn_cidr
     dns_label      = format("%svcn",substr((var.service_name), 0, 10))
     is_create_igw  = false
     is_attach_drg  = false
     block_nat_traffic = local.assign_public_ip && var.vcn_name!="" ? true : false
     
     subnets            =  {for k, v in local.create_subnets: k => {
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
    #  defined_tags = var.network_defined_tags
    #  defined_tags  = { "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.release.name}" = "1.0",
    #                    "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.subsystem.name}" = "network",
    #                    "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.module.name}" = "vcn-basic"                      
    #   }
     freeform_tags = local.freeform_tags
    }
  }
}

module "network-routing" {

  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-routing"

  compartment_id = var.compartment_id

  subnets_route_tables = {
    "${local.service_name_prefix}-routetable-out" = {
      compartment_id = var.compartment_id,
      vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id,
      subnet_id = lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${var.public_subnet_name}").id,
      route_table_id = "",
      route_rules = [{
        is_create = true,
        destination       = "0.0.0.0/0",
        destination_type  = "CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn.internet_gateways, lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id).id,
        description       = ""
      }],
      defined_tags = local.defined_tags
      # defined_tags = var.routing_defined_tags
      # defined_tags  = { "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.release.name}" = "1.0",
      #                  "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.subsystem.name}" = "network",
      #                  "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.module.name}" = "vcn-routing"                      
      # }
      },
    "${local.service_name_prefix}-routetable" = {
      compartment_id = var.compartment_id,
      vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id,
      subnet_id = lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${var.private_subnet_name}").id,
      route_table_id = "",
      route_rules = concat( [],
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
      # defined_tags = var.routing_defined_tags
      # defined_tags  = { "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.release.name}" = "1.0",
      #                  "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.subsystem.name}" = "network",
      #                  "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.module.name}" = "vcn-routing"                      
      # }
    }
  } 
}

module "network-routing-attachment" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-routing"
  compartment_id = var.compartment_id

  subnets_route_tables = {
    "" = {
      compartment_id = var.compartment_id,
      vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id,
      subnet_id = lookup(module.network-subnets.subnets,"${local.service_name_prefix}-${var.public_subnet_name}").id,
      route_table_id = lookup(module.network-routing.subnets_route_tables,"${local.service_name_prefix}-routetable-out").id,
      route_rules = ([]),
      defined_tags = local.defined_tags
      # defined_tags = var.routing_defined_tags
      # defined_tags  = { "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.release.name}" = "1.0",
      #                  "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.subsystem.name}" = "network",
      #                  "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.module.name}" = "vcn-routing"                      
      # }
    }
  } 
}

module "network-security-lists" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/security"
  compartment_id = var.compartment_id
  ports_not_allowed_from_anywhere_cidr = [3390,4500]

  security_lists = {
    for k,v in local.security-lists : k => v if v.compartment_id != "" 
  }
}

module "network-dhcp-options" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/security"
  compartment_id = var.compartment_id

  dhcp_options = {for x in range(local.is_vcn_peering ? 0 : (local.use_existing_subnets ? 0 : 1 ) ) : "${var.service_name}-${var.dhcp_options_name}" => { 
      vcn_id         = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id,
      compartment_id = var.compartment_id,
      options = {
        type = "DomainNameServer"
        server_type = "VcnLocalPlusInternet"
      },
      defined_tags = local.defined_tags
      # defined_tags = var.security_defined_tags,
      # defined_tags  = { "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.release.name}" = "1.0",
      #                  "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.subsystem.name}" = "network",
      #                  "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.module.name}" = "security"                    
      # }
      freeform_tags = local.freeform_tags
    } 
  }
}

module "network-security-groups" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/security"
  compartment_id = var.compartment_id

  nsgs = {
    for k,v in local.nsgs-lists : k => v if v.compartment_id != "" 
  }
}

