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

data "oci_objectstorage_namespace" "os" {
  compartment_id = var.tenancy_ocid
}

data "template_cloudinit_config" "bastion-config" {
  gzip          = true
  base64_encode = true
  # cloud-config configuration file.
  # /var/lib/cloud/instance/scripts/*
  part {
    filename     = "init.sh"
    content_type = "text/cloud-config"
    content      = file("${path.module}/scripts/bastion-bootstrap")
  }
}

locals {
  # Local to control subscription to Marketplace image.
  mp_subscription_enabled = var.mp_subscription_enabled ? 1 : 0
  informatica_image = "ocid1.image.oc1..aaaaaaaa7cz5dtoycldn2362uitvswgoozfxeahfpxusky67nsd6vxhxcvua"
  mp_listing_id = "ocid1.appcataloglisting.oc1..aaaaaaaanfkuyh67srgtyxv7lfzrec3yaauspa5petil2clgizlarqgkmxwa"
  mp_listing_resource_id = "ocid1.image.oc1..aaaaaaaa7cz5dtoycldn2362uitvswgoozfxeahfpxusky67nsd6vxhxcvua"
  mp_listing_resource_version = "November_2023.11"

  ad_names                          = compact(data.template_file.ad_names.*.rendered)
  public_subnet_availability_domain = local.ad_names[0]

  #Secure agent data
  iics_provider_oci   = var.iics_provider == var.iics_provider_enum["OCI"] ? true : false
  iics_provider_aws   = var.iics_provider == var.iics_provider_enum["AWS"] ? true : false
  iics_provider_azure = var.iics_provider == var.iics_provider_enum["Azure"] ? true : false
  iics_provider_gcp   = var.iics_provider == var.iics_provider_enum["GCP"] ? true : false
  
  iics_provider = (local.iics_provider_oci == true) ? "OCI" : (local.iics_provider_aws == true) ? "AWS" : (local.iics_provider_azure == true) ? "Azure" : (local.iics_provider_gcp == true) ? "GCP" : "OCI" 

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
      subnet_id                   = lookup(module.network-subnets.subnets,"private-subnet").id
      nsg_ids                     = null
      defined_tags                = {}
  },
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

#create Bastion for the solution 
bastion_instance_params = { 
  #Create the Bastion Instance
  informatica_bastion = {
    availability_domain = 1
    compartment_id = var.compartment_id
    display_name   = "informatica_bastion"
    shape          = var.bastion_shape
    defined_tags   = {}
    freeform_tags  = {}
    subnet_id         = lookup(module.network-subnets.subnets,"public-subnet").id
    vnic_display_name = ""
    assign_public_ip  = true
    hostname_label    = ""
    source_type   = "image"
    source_id     = var.bastion_instance_image_ocid[var.region]
    metadata = {
      ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
      user_data           = data.template_cloudinit_config.bastion-config.rendered
    }
    fault_domain = ""
    provisioning_timeout_mins = "30"
  }
}

#create Informatica Secure Agent instance
  informatica_secure_agent_params = {
  informatica_secure_agent = {
    availability_domain = 1
    compartment_id = var.compartment_id
    display_name   = var.informatica_secure_agent_display_name
    shape          = var.informatica_instance_shape
    defined_tags   = {}
    freeform_tags  = {}
    subnet_id        = lookup(module.network-subnets.subnets,"private-subnet").id
    vnic_display_name = ""
    assign_public_ip = false
    hostname_label = ""
    source_type = "image"
    source_id   = local.informatica_image
    metadata = {
      ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
      user_data = base64encode(templatefile(format("%s/%s", "./scripts", "install.sh"),
      {
        iics_provider = local.iics_provider
        iics_un       = var.iics_user
        iics_tk       = var.iics_token
        iics_gn       = var.iics_gn
        region        = var.region
        bucket_name   = var.bucket_name
        tenancy       = data.oci_identity_tenancy.tenancy.name
        db_name       = var.db_name
    }))
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
        defined_tags      = {}
    }
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
      },
      {
        is_create = true,
        destination       = lookup(data.oci_core_services.sgw_services.services[0], "cidr_block"),
        destination_type  = "SERVICE_CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn.service_gateways, lookup(module.network-vcn.vcns,"vcn").id).id,
        description       = ""
      }],
      defined_tags  = {}
    }
  }

#network routing attachment
network-routing-attachment = {
    "" = {
      compartment_id = var.compartment_id,
      vcn_id = lookup(module.network-vcn.vcns,"vcn").id,
      subnet_id = lookup(module.network-subnets.subnets,"public-subnet").id,
      route_table_id = lookup(module.network-routing.subnets_route_tables,"public_route_table").id,
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
            protocol  = "6" // tcp
            src           = "0.0.0.0/0"
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 5900, max=5900},
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "all",
            src           = "0.0.0.0/0"
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = null,
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "6" // tcp
            src           = "0.0.0.0/0"
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 3389, max=3389},
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
            protocol  = "all",
            src           = "0.0.0.0/0"
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = null,
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "all"
            src           = "0.0.0.0/0",
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = null
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

# End


}