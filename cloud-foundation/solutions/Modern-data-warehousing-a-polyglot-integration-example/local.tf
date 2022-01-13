# Copyright © 2022, Oracle and/or its affiliates.
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
  ad_names                         = compact(data.template_file.ad_names.*.rendered)
  public_subnet_availability_domain = local.ad_names[0]
  service_name_prefix               = replace(var.service_name, "/[^a-zA-Z0-9]/", "")

# Create Autonomous Data Warehouse
  adw_params = { 
    adw = {
      compartment_id              = var.compartment_id,
      adw_cpu_core_count          = var.adw_cpu_core_count,
      adw_size_in_tbs             = var.adw_size_in_tbs,
      adw_db_name                 = var.adw_db_name,
      adw_db_workload             = var.adw_db_workload,
      adw_db_version              = var.adw_db_version,
      adw_enable_auto_scaling     = var.adw_enable_auto_scaling,
      adw_is_free_tier            = var.adw_is_free_tier,
      adw_license_model           = var.adw_license_model,
      database_admin_password     = var.database_admin_password,
      database_wallet_password    = var.database_wallet_password,
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
      subnet_id                                  = lookup(module.network-subnets.subnets,"private-subnet").id,
      vcn_id                                     = lookup(module.network-vcn.vcns,"vcn").id,
      analytics_instance_network_endpoint_details_whitelisted_ips = var.analytics_instance_network_endpoint_details_whitelisted_ips
      analytics_instance_network_endpoint_details_whitelisted_vcns_id = lookup(module.network-vcn.vcns,"vcn").id,
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

# OCI DataScience
datascience_params = {
    machine_learning_platform = {
      compartment_id             = var.compartment_id
      project_description        = var.project_description
      project_display_name       = var.project_display_name
      defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}
notebook_params = {
    notebook_session = {
      compartment_id             = var.compartment_id
      notebook_session_notebook_session_configuration_details_shape = var.notebook_session_notebook_session_configuration_details_shape
      subnet_id                  = lookup(module.network-subnets.subnets,"public-subnet").id,
      project_name               = var.project_name
      notebook_session_notebook_session_configuration_details_block_storage_size_in_gbs = var.notebook_session_notebook_session_configuration_details_block_storage_size_in_gbs
      notebook_session_display_name = var.notebook_session_display_name
      defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}

# OCI Golgen Gate
deployment_params = {
  deployment1 = {
    compartment_id          = var.compartment_id
    cpu_core_count          = var.goden_gate_cpu_core_count
    deployment_type         = var.goden_gate_deployment_type
    subnet_id               = lookup(module.network-subnets.subnets,"public-subnet").id,
    license_model           = var.golden_gate_license_model
    display_name            = var.goden_gate_display_name
    is_auto_scaling_enabled = var.goden_gate_is_auto_scaling_enabled
    defined_tags            = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    ogg_data = [
      {
        admin_password  = var.goden_gate_admin_password
        admin_username  = var.goden_gate_admin_username
        deployment_name = var.goden_gate_deployment_name
    }]
  }
}

# Creates the VCN "vcn with the CIDR BLOCK 10.0.0.0/16"
  vcns-lists = {
    vcn = { 
     compartment_id = var.compartment_id
     cidr           = var.vcn_cidr
     dns_label      = "vcn"
     is_create_igw  = true
     is_attach_drg  = false
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
            availability_domain=var.use_regional_subnet? "" : local.public_subnet_availability_domain,
	          cidr=var.public_subnet_cidr,
            dns_label="public",
            private=false,
            dhcp_options_id="",
            security_list_ids=[module.network-security-lists.security_lists["public_security_list"].id],
            defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
            freeform_tags = {}
          }
          private-subnet = { 
	          compartment_id=var.compartment_id, 
            vcn_id=lookup(module.network-vcn.vcns,"vcn").id, 
            availability_domain=var.use_regional_subnet? "" : local.public_subnet_availability_domain,
	          cidr=var.private_subnet_cidr, 
            dns_label="private",
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

#create routing table attached to vcn and subnet to route traffic via IGW
  subnets_route_tables = {
    public_route_table = {
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
        defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    }
  }

#create security list - opening port 22 ssh and port 80 - http
  security_lists = {
    public_security_list = {
        vcn_id = lookup(module.network-vcn.vcns,"vcn").id,
        compartment_id = var.compartment_id,
        defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
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
        defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
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
          dst          = "0.0.0.0/0",
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
        vcn_id = lookup(module.network-vcn.vcns,"vcn").id,
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

  dynamic_groups = {
      "${local.service_name_prefix}-DSDynamicGroup" =  {
        description    = "DS Dynamic Group"
        compartment_id = var.tenancy_ocid
        matching_rule  = "ALL {resource.type = 'datasciencenotebooksession', resource.compartment.id = '${var.compartment_id}'}"
      },
  }

   policies = { 
    "${local.service_name_prefix}-StreamingDataSciencePolicies" = { 
      compartment_id = var.tenancy_ocid,
      description    = "List of Policies Required for this solution",
      statements     =  [
    "allow group Administrators to manage buckets in tenancy",
    "allow group Administrators to manage objects in tenancy",
    "allow group Administrators TO read buckets in tenancy",
    "allow group Administrators to read objectstorage-namespaces in tenancy",
    "allow group Administrators to inspect compartments in tenancy",
    "allow group Administrators to use virtual-network-family in tenancy",
    "allow group Administrators to manage data-science-family in tenancy",
    "allow group Administrators to use cloud-shell in tenancy",
    "allow group Administrators to read metrics in tenancy",
    "allow group Administrators to manage tag-namespaces in compartment id ${var.compartment_id}",
    "allow group Administrators to use virtual-network-family in compartment id ${var.compartment_id}",
    "allow group Administrators to use object-family in compartment id ${var.compartment_id}",
    "allow service dataintegration to use virtual-network-family in compartment id ${var.compartment_id}",
    "allow dynamic-group ${local.service_name_prefix}-DSDynamicGroup to manage data-science-family in tenancy", 
    "allow service datascience to use virtual-network-family in tenancy",
    "allow dynamic-group ${local.service_name_prefix}-DSDynamicGroup to manage object-family in tenancy", 
    "allow dynamic-group ${local.service_name_prefix}-DSDynamicGroup to manage objects in compartment id ${var.compartment_id}", 
    "allow service FaaS to use virtual-network-family in tenancy"]
    },
  }

# End

}





