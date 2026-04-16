# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_regions" "regions" {
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
  effective_oci_private_key_pem = (
    trimspace(var.oci_private_key_pem) != "" ? trimspace(var.oci_private_key_pem) :
    trimspace(var.private_key_path) != "" ? trimspace(file(var.private_key_path)) :
    ""
  )

  mongodb_hostname = var.mongo_mode == "atlas" ? module.mongodb_atlas[0].mongodb_hostname : ""
  mongodb_db_name  = var.mongo_mode == "atlas" ? module.mongodb_atlas[0].database_name : ""
  mongodb_username = var.mongo_mode == "atlas" ? var.mongodb_db_username : ""
  mongodb_password = var.mongo_mode == "atlas" ? var.mongodb_db_password : ""

  enable_mongodb_api = var.mongo_mode == "oracle_api" ? true : false

  # Create Autonomous Data Warehouse
  adw_params = {
    adw = {
      compartment_id              = var.compartment_id
      compute_model               = var.adw_db_compute_model
      compute_count               = var.adw_db_compute_count
      size_in_tbs                 = var.adw_db_size_in_tbs
      db_name                     = var.adw_db_name
      db_workload                 = var.adw_db_workload
      db_version                  = var.adw_db_version
      enable_auto_scaling         = var.adw_db_enable_auto_scaling
      is_free_tier                = var.adw_db_is_free_tier
      license_model               = var.adw_db_license_model
      create_local_wallet         = true
      database_admin_password     = var.adw_db_password
      database_wallet_password    = var.adw_db_password
      data_safe_status            = var.adw_db_data_safe_status
      operations_insights_status  = var.adw_db_operations_insights_status
      database_management_status  = var.adw_db_database_management_status
      is_mtls_connection_required = null
      subnet_id                   = null
      nsg_ids                     = null
      defined_tags                = {}
    },
    atp = {
      compartment_id              = var.compartment_id
      compute_model               = var.atp_db_compute_model
      compute_count               = var.atp_db_compute_count
      size_in_tbs                 = var.atp_db_size_in_tbs
      db_name                     = var.atp_db_name
      db_workload                 = var.atp_db_workload
      db_version                  = var.atp_db_version
      enable_auto_scaling         = var.atp_db_enable_auto_scaling
      is_free_tier                = var.atp_db_is_free_tier
      license_model               = var.atp_db_license_model
      create_local_wallet         = true
      database_admin_password     = var.atp_db_password
      database_wallet_password    = var.atp_db_password
      data_safe_status            = var.atp_db_data_safe_status
      operations_insights_status  = var.atp_db_operations_insights_status
      database_management_status  = var.atp_db_database_management_status
      enable_mongodb_api          = var.mongo_mode == "oracle_api"
      is_mtls_connection_required = var.mongo_mode == "oracle_api" ? true : null
      subnet_id                   = null
      nsg_ids                     = null
      whitelisted_ips             = var.mongo_mode == "oracle_api" ? ["0.0.0.0/0"] : null
      defined_tags                = {}
    },
  }

  # Create Object Storage Buckets
  bucket_params = {
    ai_files_bucket = {
      compartment_id = var.compartment_id
      name           = var.files_bucket_name
      access_type    = var.files_bucket_access_type
      storage_tier   = var.files_bucket_storage_tier
      events_enabled = var.files_bucket_events_enabled
      defined_tags   = {}
    }
    atp_creds_bucket = {
      compartment_id = var.compartment_id
      name           = var.atp_creds_bucket_name
      access_type    = var.atp_creds_bucket_access_type
      storage_tier   = var.atp_creds_bucket_storage_tier
      events_enabled = var.atp_creds_bucket_events_enabled
      defined_tags   = {}
    }
  }

  # Create Instance
  instance_params = {
    vnc-instance = {
      availability_domain = 1
      compartment_id      = var.compartment_id
      display_name        = var.bastion_instance_display_name
      shape               = var.bastion_instance_shape
      defined_tags        = {}
      freeform_tags       = {}
      subnet_id           = lookup(module.network-subnets.subnets, "public-subnet").id
      vnic_display_name   = ""
      assign_public_ip    = true
      hostname_label      = ""
      nsg_ids             = [lookup(module.network-security-groups.nsgs, "public-nsgs-list").id]
      source_type         = "image"
      source_id           = var.bastion_instance_image_ocid[var.region]
      metadata = {
        ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
      }
      fault_domain              = ""
      provisioning_timeout_mins = "30"
    }
  }

  vcns-lists = {
    vcn = {
      compartment_id    = var.compartment_id
      cidr              = var.vcn_cidr
      dns_label         = "vcn"
      is_create_igw     = true
      is_attach_drg     = false
      block_nat_traffic = false
      subnets           = {}
      defined_tags      = {}
      freeform_tags     = {}
    }
  }

  subnet-lists = {
    "" = {
      compartment_id    = var.compartment_id
      cidr              = var.vcn_cidr
      dns_label         = "vcn"
      is_create_igw     = false
      is_attach_drg     = false
      block_nat_traffic = false

      subnets = {
        public-subnet = {
          compartment_id      = var.compartment_id
          vcn_id              = lookup(module.network-vcn.vcns, "vcn").id
          availability_domain = ""
          cidr                = var.public_subnet_cidr
          dns_label           = "public"
          private             = false
          dhcp_options_id     = ""
          security_list_ids   = [module.network-security-lists.security_lists["public_security_list"].id]
          defined_tags        = {}
          freeform_tags       = {}
        }
        private-subnet = {
          compartment_id      = var.compartment_id
          vcn_id              = lookup(module.network-vcn.vcns, "vcn").id
          availability_domain = ""
          cidr                = var.private_subnet_cidr
          dns_label           = "private"
          private             = true
          dhcp_options_id     = ""
          security_list_ids   = [module.network-security-lists.security_lists["private_security_list"].id]
          defined_tags        = {}
          freeform_tags       = {}
        }
      }
      defined_tags  = {}
      freeform_tags = {}
    }
  }

  subnets_route_tables = {
    public_route_table-igw = {
      compartment_id = var.compartment_id
      vcn_id         = lookup(module.network-vcn.vcns, "vcn").id
      subnet_id      = lookup(module.network-subnets.subnets, "public-subnet").id
      route_table_id = ""
      route_rules = [{
        is_create         = true
        destination       = "0.0.0.0/0"
        destination_type  = "CIDR_BLOCK"
        network_entity_id = lookup(module.network-vcn.internet_gateways, lookup(module.network-vcn.vcns, "vcn").id).id
        description       = ""
      }]
      defined_tags = {}
    }
    private_route_table-nat = {
      compartment_id = var.compartment_id
      vcn_id         = lookup(module.network-vcn.vcns, "vcn").id
      subnet_id      = lookup(module.network-subnets.subnets, "private-subnet").id
      route_table_id = ""
      route_rules = [{
        is_create         = true
        destination       = "0.0.0.0/0"
        destination_type  = "CIDR_BLOCK"
        network_entity_id = lookup(module.network-vcn.nat_gateways, lookup(module.network-vcn.vcns, "vcn").id).id
        description       = ""
      }]
      defined_tags = {}
    }
  }

  network-routing-attachment = {
    "" = {
      compartment_id = var.compartment_id
      vcn_id         = lookup(module.network-vcn.vcns, "vcn").id
      subnet_id      = lookup(module.network-subnets.subnets, "public-subnet").id
      route_table_id = lookup(module.network-routing.subnets_route_tables, "public_route_table-igw").id
      route_rules    = []
      defined_tags   = {}
    }
  }

  security_lists = {
    public_security_list = {
      vcn_id         = lookup(module.network-vcn.vcns, "vcn").id
      compartment_id = var.compartment_id
      defined_tags   = {}
      ingress_rules = concat([{
        stateless = false
        protocol  = "6"
        src       = "0.0.0.0/0"
        src_type  = "CIDR_BLOCK"
        src_port  = null
        dst_port  = { min = 22, max = 22 }
        icmp_type = null
        icmp_code = null
        }],
        [{
          stateless = false
          protocol  = "6"
          src       = "0.0.0.0/0"
          src_type  = "CIDR_BLOCK"
          src_port  = null
          dst_port  = { min = 443, max = 443 }
          icmp_type = null
          icmp_code = null
        }],
        [{
          stateless = false
          protocol  = "6"
          src       = "0.0.0.0/0"
          src_type  = "CIDR_BLOCK"
          src_port  = null
          dst_port  = { min = 80, max = 80 }
          icmp_type = null
          icmp_code = null
        }],
        [{
          stateless = false
          protocol  = "all"
          src       = "0.0.0.0/0"
          src_type  = "CIDR_BLOCK"
          src_port  = null
          dst_port  = null
          icmp_type = null
          icmp_code = null
      }])
      egress_rules = [{
        stateless = false
        protocol  = "all"
        dst       = "0.0.0.0/0"
        dst_type  = "CIDR_BLOCK"
        src_port  = null
        dst_port  = null
        icmp_type = null
        icmp_code = null
      }]
    }
    private_security_list = {
      vcn_id         = lookup(module.network-vcn.vcns, "vcn").id
      compartment_id = var.compartment_id
      defined_tags   = {}
      ingress_rules = concat([{
        stateless = false
        protocol  = "all"
        src       = var.vcn_cidr
        src_type  = "CIDR_BLOCK"
        src_port  = null
        dst_port  = null
        icmp_type = null
        icmp_code = null
        }],
        [{
          stateless = false
          protocol  = "6"
          src       = var.vcn_cidr
          src_type  = "CIDR_BLOCK"
          src_port  = null
          dst_port  = { min = 22, max = 22 }
          icmp_type = null
          icmp_code = null
        }],
        [{
          stateless = false
          protocol  = "17"
          src       = var.vcn_cidr
          src_type  = "CIDR_BLOCK"
          src_port  = null
          dst_port  = { min = 3306, max = 3306 }
          icmp_type = null
          icmp_code = null
      }])
      egress_rules = [{
        stateless = false
        protocol  = "all"
        dst       = "0.0.0.0/0"
        dst_type  = "CIDR_BLOCK"
        src_port  = null
        dst_port  = null
        icmp_type = null
        icmp_code = null
      }]
    }
  }

  nsgs-lists = {
    public-nsgs-list = {
      vcn_id         = lookup(module.network-vcn.vcns, "vcn").id
      compartment_id = var.compartment_id
      defined_tags   = {}
      ingress_rules = {
        web_ingress = {
          is_create    = true
          description  = "web security ingress rule"
          protocol     = "6"
          stateless    = false
          src          = "0.0.0.0/0"
          src_type     = "CIDR_BLOCK"
          src_port_min = null
          src_port_max = null
          dst_port_min = 80
          dst_port_max = 80
          icmp_type    = null
          icmp_code    = null
        }
        all_ingress = {
          is_create    = true
          description  = "all security ingress rule"
          protocol     = "all"
          stateless    = false
          src          = "0.0.0.0/0"
          src_type     = "CIDR_BLOCK"
          src_port_min = null
          src_port_max = null
          dst_port_min = null
          dst_port_max = null
          icmp_type    = null
          icmp_code    = null
        }
      }
      egress_rules = {
        web_igw_egress = {
          is_create    = true
          description  = "web internet security egress rule"
          protocol     = "all"
          stateless    = false
          dst          = "0.0.0.0/0"
          dst_type     = "CIDR_BLOCK"
          src_port_min = null
          src_port_max = null
          dst_port_min = null
          dst_port_max = null
          icmp_type    = null
          icmp_code    = null
        }
      }
    }
    private-nsgs-list = {
      vcn_id         = lookup(module.network-vcn.vcns, "vcn").id
      compartment_id = var.compartment_id
      defined_tags   = {}
      ingress_rules = {
        ingress2 = {
          is_create    = true
          description  = "Parameters for customizing Network Security Group(s)."
          protocol     = "all"
          stateless    = false
          src          = var.private_subnet_cidr
          src_type     = "CIDR_BLOCK"
          dst_port_min = null
          dst_port_max = null
          src_port_min = null
          src_port_max = null
          icmp_type    = null
          icmp_code    = null
        }
      }
      egress_rules = {
        egress2 = {
          is_create    = true
          description  = "Parameters for customizing Network Security Group(s)."
          protocol     = "all"
          stateless    = false
          dst          = "0.0.0.0/0"
          dst_type     = "CIDR_BLOCK"
          dst_port_min = null
          dst_port_max = null
          src_port_min = null
          src_port_max = null
          icmp_type    = null
          icmp_code    = null
        }
      }
    }
  }
}