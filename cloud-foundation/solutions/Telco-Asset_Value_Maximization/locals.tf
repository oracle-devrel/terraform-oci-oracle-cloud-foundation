# Copyright © 2024, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}

data oci_identity_regions regions {
}

data "oci_objectstorage_namespace" "os" {
  compartment_id = var.tenancy_ocid
}

data "template_file" "ad_names" {
  count    = length(data.oci_identity_availability_domains.ADs.availability_domains)
  template = lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name")
}

data "oci_core_images" "linux_image" {
  compartment_id    = var.compartment_id
  operating_system  = "Oracle Linux"
  shape             = "VM.Standard2.1"
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

locals{
  ad_names                          = compact(data.template_file.ad_names.*.rendered)
  public_subnet_availability_domain = local.ad_names[0]
  service_name_prefix               = replace(var.service_name, "/[^a-zA-Z0-9]/", "")

  region_map = {
    for r in data.oci_identity_regions.regions.regions :
    r.name => r.key
  }

  home_region_for_oac = lookup(
    local.region_map, var.region
  )


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
      is_mtls_connection_required = true
      subnet_id                   = null
      nsg_ids                     = null
      defined_tags                = {}
  },
}

# Create Oracle Analytics Cloud
  oac_params = { 
    oac = {
      compartment_id                             = var.compartment_id,
      analytics_instance_feature_set             = var.analytics_instance_feature_set
      analytics_instance_license_type            = var.analytics_instance_license_type
      analytics_instance_hostname                = var.Oracle_Analytics_Instance_Name
      analytics_instance_idcs_access_token       = var.analytics_instance_idcs_access_token
      analytics_instance_capacity_capacity_type  = var.analytics_instance_capacity_capacity_type
      analytics_instance_capacity_value          = var.analytics_instance_capacity_value
      analytics_instance_network_endpoint_details_network_endpoint_type = "public"
      subnet_id                                  = null
      vcn_id                                     = null
      analytics_instance_network_endpoint_details_whitelisted_ips = ["0.0.0.0/0"]
      analytics_instance_network_endpoint_details_whitelisted_vcns_id = lookup(module.network-vcn.vcns,"vcn").id,
      whitelisted_ips                            = ["0.0.0.0/0"]
      defined_tags                               = {}
  }
}


# Create Object Storage Buckets
  bucket_params = { 
    data_bucket = {
      compartment_id   = var.compartment_id,
      name             = var.bucket_name
      access_type      = var.bucket_access_type
      storage_tier     = var.bucket_storage_tier
      events_enabled   = var.bucket_events_enabled
      defined_tags     = {}
  }
}

# # Big Data Service:
bds_params = {
  bds_deploy = {
    compartment_id = var.compartment_id,
    cluster_admin_password  = var.big_data_cluster_admin_password
    cluster_public_key = var.big_data_cluster_public_key
    cluster_version = var.big_data_cluster_version
    display_name     = var.big_data_display_name
    is_cloud_sql_configured = true
    is_high_availability = var.big_data_is_high_availability
    is_secure = var.big_data_is_secure
    master_node = [
      {
        shape                    = var.big_data_master_node_spape
        subnet_id                = lookup(module.network-subnets.subnets,"public-subnet").id,
        block_volume_size_in_gbs = var.big_data_master_node_block_volume_size_in_gbs
        number_of_nodes          = var.big_data_master_node_number_of_nodes
      },
    ]
    util_node = [
      {
        shape                    = var.big_data_util_node_shape
        subnet_id                = lookup(module.network-subnets.subnets,"public-subnet").id,
        block_volume_size_in_gbs = var.big_data_util_node_block_volume_size_in_gbs
        number_of_nodes          = var.big_data_util_node_number_of_nodes
      },
    ]
    worker_node = [
      {
        shape                    = var.big_data_worker_node_shape
        subnet_id                = lookup(module.network-subnets.subnets,"public-subnet").id,
        block_volume_size_in_gbs = var.big_data_worker_node_block_volume_size_in_gbs
        number_of_nodes          = var.big_data_worker_node_number_of_nodes
      },
    ]
    defined_tags     = {}
  }
}

# Create Data Catalog
  datacatalog_params = {
    datacatalog = {
      compartment_id                = var.compartment_id,
      catalog_display_name          = var.catalog_display_name
      defined_tags                  = {}
  }
}


# Create Instance
  instance_params = {
    vnc-instance = {
      availability_domain = 1
      compartment_id = var.compartment_id
      display_name   = var.bastion_instance_display_name
      shape          = var.bastion_instance_shape
      defined_tags   = {}
      freeform_tags  = {}
      subnet_id      = lookup(module.network-subnets.subnets,"public-subnet").id
      vnic_display_name = ""
      assign_public_ip  = true
      hostname_label    = ""
      nsg_ids           = [lookup(module.network-security-groups.nsgs,"public-nsgs-list").id]
      source_type = "image"
      source_id   = var.bastion_instance_image_ocid[var.region]
      metadata = {
        ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
      }
      fault_domain = ""
      provisioning_timeout_mins = "30"
    }
}


## Creates the VCN "vcn with the CIDR BLOCK 10.0.0.0/16"
  vcns-lists = {
    vcn = { 
     compartment_id = var.compartment_id
     cidr           = var.vcn_cidr
     dns_label      = "vcn"
     is_create_igw  = true
     is_attach_drg  = false // put true if you want to have drg attached !
     block_nat_traffic = false
     subnets  = {}  
     defined_tags   = {}
     freeform_tags  = {}
    }
}

#creates the subnet "public-subnet - 10.0.0.0/24 and private-subnet - 10.0.1.0/24"
  subnet-lists = { 
     "" = {
        compartment_id = var.compartment_id
        cidr           = var.vcn_cidr
        dns_label      = "vcn"
        is_create_igw  = false
        is_attach_drg  = false
        block_nat_traffic = false
     
        subnets  = { 
          public-subnet = { 
	          compartment_id=var.compartment_id, 
            vcn_id=lookup(module.network-vcn.vcns,"vcn").id, 
            availability_domain=""
	          cidr=var.public_subnet_cidr,
            dns_label="public",
            private=false,
            dhcp_options_id="",
            security_list_ids=[module.network-security-lists.security_lists["public_security_list"].id],
            defined_tags  = {}
            freeform_tags = {}
          }
          private-subnet = { 
	          compartment_id=var.compartment_id, 
            vcn_id=lookup(module.network-vcn.vcns,"vcn").id, 
            availability_domain=""
	          cidr=var.private_subnet_cidr, 
            dns_label="private",
            private=true,
            dhcp_options_id="",
            security_list_ids=[module.network-security-lists.security_lists["private_security_list"].id],
            defined_tags  = {}
            freeform_tags = {}
	        }
        }
        defined_tags  = {}
        freeform_tags = {}
    }
  }

#create routing table attached to vcn and subnet to route traffic via IGW
  subnets_route_tables = {
    public_route_table-igw = {
      compartment_id = var.compartment_id,
      vcn_id=lookup(module.network-vcn.vcns,"vcn").id,
      subnet_id = lookup(module.network-subnets.subnets,"public-subnet").id,
      route_table_id = "",
      route_rules = [{
        is_create = true,
        destination       = "0.0.0.0/0",
        destination_type  = "CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn.internet_gateways, lookup(module.network-vcn.vcns,"vcn").id).id,
        description       = ""
      }],
      defined_tags  = {}
    },
    private_route_table-nat = {
      compartment_id = var.compartment_id,
      vcn_id=lookup(module.network-vcn.vcns,"vcn").id,
      subnet_id = lookup(module.network-subnets.subnets,"private-subnet").id,
      route_table_id = "",
      route_rules = [{
        is_create = true,
        destination       = "0.0.0.0/0",
        destination_type  = "CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn.nat_gateways, lookup(module.network-vcn.vcns,"vcn").id).id,
        description       = ""
      }],
      defined_tags  = {}
    }
  }

network-routing-attachment = {
    "" = {
      compartment_id = var.compartment_id,
      vcn_id = lookup(module.network-vcn.vcns,"vcn").id,
      subnet_id = lookup(module.network-subnets.subnets,"public-subnet").id,
      route_table_id = lookup(module.network-routing.subnets_route_tables,"public_route_table-igw").id,
      route_rules = [],
      defined_tags = {}
    }
}

#create security list - opening port 22 ssh and port 80 - http
  security_lists = {
    public_security_list = {
        vcn_id = lookup(module.network-vcn.vcns,"vcn").id,
        compartment_id = var.compartment_id,
        defined_tags  = {}
        ingress_rules = concat([{
            stateless = false
            protocol  = "6" // tcp
            src           = "0.0.0.0/0"
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 22, max= 22},
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "6" // tcp
            src           = "0.0.0.0/0"
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 443, max=443},
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "6" // tcp
            src           = "0.0.0.0/0"
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 80, max=80},
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "all"
            src           = "0.0.0.0/0"
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = null,
            icmp_type     = null,
            icmp_code     = null
          }]),
        egress_rules = [{
           stateless     = false,
           protocol      = "all",
           dst           = "0.0.0.0/0",
           dst_type      = "CIDR_BLOCK",
           src_port      = null,
           dst_port     = null,
           icmp_type    = null,
           icmp_code    = null
         }],
      }
    private_security_list = {
        vcn_id = lookup(module.network-vcn.vcns,"vcn").id,
        compartment_id = var.compartment_id,
        defined_tags  = {}
        ingress_rules = concat([{
            stateless = false
            protocol  = "all"
            src           = var.vcn_cidr,
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = null,
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "6"
            src           = var.vcn_cidr,
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 22, max=22},
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "17"
            src           = var.vcn_cidr,
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 3306, max=3306},
            icmp_type     = null,
            icmp_code     = null
          }]),
        egress_rules = [{
           stateless     = false,
           protocol      = "all",
           dst           = "0.0.0.0/0",
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
        vcn_id = lookup(module.network-vcn.vcns,"vcn").id,
        compartment_id = var.compartment_id,
        defined_tags  = {}
        ingress_rules = { 
          web_ingress = {
            is_create = true,
            description = "web security ingress rule",
            protocol  = "6", // tcp
            stateless = false,
            src    = "0.0.0.0/0",
            src_type      = "CIDR_BLOCK",
            src_port_min  = null,
            src_port_max  = null,
            dst_port_min  = 80, 
            dst_port_max  = 80,
            icmp_type     = null,
            icmp_code     = null
          },
          all_ingress = {
            is_create = true,
            description = "all security ingress rule",
            protocol  = "all", 
            stateless = false,
            src       = "0.0.0.0/0",
            src_type      = "CIDR_BLOCK",
            src_port_min  = null,
            src_port_max  = null,
            dst_port_min  = null,
            dst_port_max  = null,
            icmp_type     = null,
            icmp_code     = null
          }
        },
        egress_rules = {
            web_igw_egress = {
              is_create = true,
              description = "web internet security egress rule",
              protocol  = "all", // tcp
              stateless = false,
              dst = "0.0.0.0/0",
              dst_type      = "CIDR_BLOCK",
              src_port_min  = null,
              src_port_max  = null,
              dst_port_min  = null, 
              dst_port_max  = null,
              icmp_type     = null,
              icmp_code     = null
            },
          }
   }
  private-nsgs-list = {
        vcn_id = lookup(module.network-vcn.vcns,"vcn").id,
        compartment_id = var.compartment_id,
        defined_tags  = {}
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
          dst          = "0.0.0.0/0",
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

policies = { 
    "${local.service_name_prefix}-TelcoPolicies" = { 
      compartment_id = var.tenancy_ocid,
      description    = "List of Policies Required for the Full Data Lake Solution",
      statements     =  [
    "allow service datacatalog to manage virtual-network-family in compartment id ${var.compartment_id}",
    "allow service datacatalog to {VNIC_READ, VNIC_ATTACH, VNIC_DETACH, VNIC_CREATE, VNIC_DELETE,VNIC_ATTACHMENT_READ, SUBNET_READ, VCN_READ, SUBNET_ATTACH, SUBNET_DETACH, INSTANCE_ATTACH_SECONDARY_VNIC, INSTANCE_DETACH_SECONDARY_VNIC} in compartment id ${var.compartment_id}",
    "allow service datacatalog to read object-family in compartment id ${var.compartment_id}",
    "allow service bdsprod to {VNIC_READ, VNIC_ATTACH, VNIC_DETACH, VNIC_CREATE, VNIC_DELETE,VNIC_ATTACHMENT_READ, SUBNET_READ, VCN_READ, SUBNET_ATTACH, SUBNET_DETACH, INSTANCE_ATTACH_SECONDARY_VNIC, INSTANCE_DETACH_SECONDARY_VNIC} in compartment id ${var.compartment_id}",
    "allow group Administrators to manage tag-namespaces in compartment id ${var.compartment_id}",
    "allow group Administrators to use virtual-network-family in compartment id ${var.compartment_id}",
    "allow group Administrators to use object-family in compartment id ${var.compartment_id}",
    "allow group Administrators to manage virtual-network-family in compartment id ${var.compartment_id}",
    "allow group Administrators to manage bds-instance in compartment id ${var.compartment_id}",
    "allow group Administrators to read instances in compartment id ${var.compartment_id}",
    "allow group Administrators to manage database-family in compartment id ${var.compartment_id}",
    "allow group Administrators to manage data-catalog-family in compartment id ${var.compartment_id}",
    "allow group Administrators to manage dis-family in compartment id ${var.compartment_id}",
    "allow group Administrators to manage buckets in tenancy",
    "allow group Administrators to manage objects in tenancy",
    "allow group Administrators to read buckets in tenancy",
    "allow group Administrators to read objectstorage-namespaces in tenancy",
    "allow group Administrators to inspect compartments in tenancy",
    "allow group Administrators to use virtual-network-family in tenancy",
    "allow group Administrators to use cloud-shell in tenancy",
    "allow group Administrators to read metrics in tenancy",
    ]
    },
  }
  

# End

}




