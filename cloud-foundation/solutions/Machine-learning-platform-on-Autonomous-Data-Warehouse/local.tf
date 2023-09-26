# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}

data "template_file" "ad_names" {
  count    = length(data.oci_identity_availability_domains.ADs.availability_domains)
  template = lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name")
}

data "oci_core_services" "sgw_services" {
  filter {
    name   = "cidr_block"
    values = ["all-.*-services-in-oracle-services-network"]
    regex  = true
  }
}

data "oci_identity_region_subscriptions" "home_region_subscriptions" {
  tenancy_id = var.tenancy_ocid

  filter {
    name   = "is_home_region"
    values = [true]
  }
}

locals {

# Create Autonomous Data Warehouse
  adw_params = { 
    adw = {
      compartment_id              = var.compartment_id
      compute_model               = var.db_compute_model
      compute_count               = var.db_compute_count
      size_in_tbs                 = var.db_size_in_tbs
      db_name                     = var.db_name
      db_workload                 = var.db_workload
      db_version                  = var.db_version
      enable_auto_scaling         = var.db_enable_auto_scaling
      is_free_tier                = var.db_is_free_tier
      license_model               = var.db_license_model
      create_local_wallet         = true
      database_admin_password     = var.db_password
      database_wallet_password    = var.db_password
      data_safe_status            = var.db_data_safe_status
      operations_insights_status  = var.db_operations_insights_status
      database_management_status  = var.db_database_management_status
      is_mtls_connection_required = null
      subnet_id                   = null
      nsg_ids                     = null
      defined_tags                = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  },
}

# Create Oracle Analytics Cloud
  oac_params = { 
    oac = {
      compartment_id                             = var.compartment_id,
      analytics_instance_feature_set             = var.analytics_instance_feature_set,
      analytics_instance_license_type            = var.analytics_instance_license_type,
      analytics_instance_hostname                = var.analytics_instance_hostname,
      analytics_instance_idcs_access_token       = var.analytics_instance_idcs_access_token,
      analytics_instance_capacity_capacity_type  = var.analytics_instance_capacity_capacity_type,
      analytics_instance_capacity_value          = var.analytics_instance_capacity_value,
      analytics_instance_network_endpoint_details_network_endpoint_type = var.analytics_instance_network_endpoint_details_network_endpoint_type
      subnet_id                                  = lookup(module.network-subnets.subnets,"private_subnet").id,
      vcn_id                                     = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id
      analytics_instance_network_endpoint_details_whitelisted_ips = var.analytics_instance_network_endpoint_details_whitelisted_ips
      analytics_instance_network_endpoint_details_whitelisted_vcns_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id
      whitelisted_ips                            = var.whitelisted_ips
      defined_tags                               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}

# Create Object Storage Buckets
  bucket_params = { 
    bucket = {
      compartment_id   = var.compartment_id,
      name             = var.bucket_name,
      access_type      = var.bucket_access_type,
      storage_tier     = var.bucket_storage_tier,
      events_enabled   = var.bucket_events_enabled,
      defined_tags     = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}

# Create Data Catalog
  datacatalog_params = { 
    datacatalog = {
      compartment_id        = var.compartment_id,
      catalog_display_name  = var.datacatalog_display_name,
      defined_tags          = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}

#Create Oracle Cloud Infrastructure Data Integration service
  odi_params = { 
    odi = {
      compartment_id   = var.compartment_id,
      display_name     = var.odi_display_name,
      description      = var.odi_description,
      defined_tags     = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}

 # Create the VCN required for this solution
  vcns-lists = { for x in range(local.vcn) : "${var.service_name}-${var.vcn_name}" => {
     compartment_id = var.compartment_id
     cidr           = var.vcn_cidr
     dns_label      = format("%svcn",substr((var.service_name), 0, 10))
     is_create_igw  = true
     is_attach_drg  = false
     block_nat_traffic = false
     subnets  = {}  
     defined_tags  = {}
     freeform_tags = {}
    }
  }

# Create the subnets required for this solutin
  subnet-lists = { 
     "" = {
        compartment_id = var.compartment_id
        cidr           = var.vcn_cidr
        dns_label      = format("%svcn",substr((var.service_name), 0, 10))
        is_create_igw  = false
        is_attach_drg  = false
        block_nat_traffic = false
     
        subnets  = { 
          public_subnet = { 
	          compartment_id=var.compartment_id, 
            vcn_id=lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id
            availability_domain=var.use_regional_subnet? "" : local.public_subnet_availability_domain,
	          cidr=var.public_subnet_cidr, 
            dns_label=replace("${var.public_subnet_name}-${substr(uuid(), -7, -1)}", "-",""),
            private=false,
            dhcp_options_id="",
            security_list_ids=[module.network-security-lists.security_lists["public_security_list"].id],          
            defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
            freeform_tags = {}
          }
          private_subnet = { 
	          compartment_id=var.compartment_id, 
            vcn_id=lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id
            availability_domain=var.use_regional_subnet? "" : local.public_subnet_availability_domain,
            cidr = local.private_subnet_cidr,
            dns_label=replace(format("%s-%s", var.private_subnet_name, substr(strrev(var.service_name), 0, 7)), "-",""),
            private=true,
            dhcp_options_id="",
            security_list_ids=[module.network-security-lists.security_lists["private_security_list"].id],          
            defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
            freeform_tags = {}
	        }
        }
        defined_tags  = {}
        freeform_tags = {}
    }
  }


# Create routing table attached to vcn and subnet to route traffic via IGW
  subnets_route_tables = {
    "${local.service_name_prefix}-routetable-out" = {
      compartment_id = var.compartment_id,
      vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id
      subnet_id = lookup(module.network-subnets.subnets,"public_subnet").id,
      route_table_id = "",
      route_rules = [{
        is_create = true,
        destination       = "0.0.0.0/0",
        destination_type  = "CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn.internet_gateways, lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id).id,
        description       = ""
      }],
      defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    }
    "${local.service_name_prefix}-routetable" = {
      compartment_id = var.compartment_id,
      vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id,
      subnet_id = lookup(module.network-subnets.subnets,"private_subnet").id,
      route_table_id = "",
      route_rules = concat( [],
          [  
            {
            is_create = true
            destination       = lookup(data.oci_core_services.sgw_services.services[0], "cidr_block"),
            destination_type  = "SERVICE_CIDR_BLOCK",
            network_entity_id = lookup(module.network-vcn.service_gateways, lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id).id,
            description       = ""
        }
        ]),
      defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    }
  }


# Create security lists - public - opening port 22 ssh and port 80 and 443 and private one
  security_lists = {
    public_security_list = {
        vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id
        compartment_id = var.compartment_id,
        defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
        ingress_rules = concat([{
            stateless = false
            protocol  = "6" // tcp
            src       = var.anywhere_cidr,
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 22, max= 22},
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "6" // tcp
            src    = var.anywhere_cidr,
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 80, max=80},
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "6" // tcp
            src    = "0.0.0.0/0"
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 443, max=443},
            icmp_type     = null,
            icmp_code     = null
          }]),
        egress_rules = [{
           stateless     = false,
           protocol      = "all",
           dst           = var.anywhere_cidr,
           dst_type      = "CIDR_BLOCK",
           src_port      = null,
           dst_port     = null,
           icmp_type    = null,
           icmp_code    = null
         }],
      }
    private_security_list = {
        vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id
        compartment_id = var.compartment_id,
        defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
        ingress_rules = concat([{
            stateless = false
            protocol  = "6"
            src        = var.public_subnet_cidr,
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = null,
            icmp_type     = null,
            icmp_code     = null
          }]),
        egress_rules = [{
           stateless     = false,
           protocol      = "all",
           dst           = var.anywhere_cidr,
           dst_type      = "CIDR_BLOCK",
           src_port      = null,
            dst_port     = null,
            icmp_type    = null,
            icmp_code    = null
         }]
      }
    }

# Create Network Security lists - public and private

 nsgs-lists = {
   public-nsgs-list = {
        vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id
        compartment_id = var.compartment_id,
        defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
        ingress_rules = { ingress1 = {
          is_create    = true,
          description  = "Parameters for customizing Network Security Group(s).",
          protocol     = "all",
          stateless    = false,
          src          = var.public_subnet_cidr,
          src_type     = "CIDR_BLOCK",
          dst_port_min = null,
          dst_port_max = null,
          src_port_min = null,
          src_port_max = null,
          icmp_type    = null,
          icmp_code    = null
      }},
      egress_rules = { egress1 = {
          is_create    = true,
          description  = "Parameters for customizing Network Security Group(s).",
          protocol     = "all",
          stateless    = false,
          dst          = var.anywhere_cidr,
          dst_type     = "CIDR_BLOCK",
          dst_port_min = null,
          dst_port_max = null,
          src_port_min = null,
          src_port_max = null,
          icmp_type    = null,
          icmp_code    = null
      }},
   }
  private-nsgs-list = {
        vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id
        compartment_id = var.compartment_id,
        defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
        ingress_rules = { ingress2 = {
          is_create    = true,
          description  = "Parameters for customizing Network Security Group(s).",
          protocol     = "all",
          stateless    = false,
          src          = var.private_subnet_cidr,
          src_type     = "CIDR_BLOCK",
          dst_port_min = null,
          dst_port_max = null,
          src_port_min = null,
          src_port_max = null,
          icmp_type    = null,
          icmp_code    = null
      }},
        egress_rules = { egress2 = {
          is_create    = true,
          description  = "Parameters for customizing Network Security Group(s).",
          protocol     = "all",
          stateless    = false,
          dst          = var.anywhere_cidr,
          dst_type     = "CIDR_BLOCK",
          dst_port_min = null,
          dst_port_max = null,
          src_port_min = null,
          src_port_max = null,
          icmp_type    = null,
          icmp_code    = null
      }}
  }
 }

# #   # Remove all characters from the service_name that dont satisfy the criteria:
# #   # must start with letter, must only contain letters and numbers and length between 1,8
# #   # See https://github.com/google/re2/wiki/Syntax - regex syntax supported by replace()
  service_name_prefix = replace(var.service_name, "/[^a-zA-Z0-9]/", "")
  ad_names                    = compact(data.template_file.ad_names.*.rendered)
  public_subnet_availability_domain = local.ad_names[0]
  num_ads = length(
    data.oci_identity_availability_domains.ADs.availability_domains,
  )
  is_single_ad_region = local.num_ads == 1 ? true : false
  use_existing_subnets    = false
  is_vcn_peering = false
  assign_public_ip = var.assign_public_ip || var.subnet_type == "Use Public Subnet" ? true : false
  public_subnet_cidr     = var.public_subnet_cidr == "" && var.vcn_name != "" && ! local.assign_public_ip ? local.is_vcn_peering ? "11.0.6.0/24" : "10.0.6.0/24" : var.public_subnet_cidr
  private_subnet_cidr    = var.private_subnet_cidr == "" && var.vcn_name != "" ? local.is_vcn_peering ? "11.0.3.0/24" : "10.0.3.0/24" : var.private_subnet_cidr
  vcn = var.vcn_name !="" && local.use_existing_subnets==false ? 1:0

# End
 
}





