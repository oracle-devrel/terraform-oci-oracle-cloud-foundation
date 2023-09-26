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


locals{
  oracle_linux                      = lookup(data.oci_core_images.linux_image.images[1],"id")
  ad_names                          = compact(data.template_file.ad_names.*.rendered)
  public_subnet_availability_domain = local.ad_names[0]
  service_name_prefix               = replace(var.service_name, "/[^a-zA-Z0-9]/", "")


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
      defined_tags                = {}
  },
}

# # Create Data Catalog
#   datacatalog_params = {
#     datacatalog = {
#       compartment_id                = var.compartment_id,
#       catalog_display_name          = var.catalog_display_name
#       defined_tags                  = {}
#       dbusername                    = "admin" # "moviestream"
#       dbpassword                    = "WlsAtpDb1234#"  # "watchS0meMovies#"
#   }
# }

# Create Instance
  instance_params = {
    vnc-instance = {
      availability_domain = var.bastion_availability_domain
      compartment_id = var.compartment_id
      display_name   = var.bastion_instance_display_name
      shape          = var.bastion_instance_shape
      defined_tags   = {}
      freeform_tags  = {}
      subnet_id      = lookup(module.network-subnets.subnets,"public-subnet").id
      vnic_display_name = ""
      assign_public_ip  = true
      hostname_label    = ""
      source_type       = "image"
      source_id         = var.bastion_source_image_id[var.region]
      metadata = {
        ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
        user_data           = data.template_cloudinit_config.bastion-config.rendered
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
          deploy-lb-subnet = { 
	          compartment_id=var.compartment_id, 
            vcn_id=lookup(module.network-vcn.vcns,"vcn").id, 
	          availability_domain="", 
	          cidr="10.0.3.0/24", 
            dns_label="sub3",
            private=false,
            dhcp_options_id="",
            security_list_ids=[module.network-security-lists.security_lists["public_security_list"].id],
            defined_tags={}, 
	          freeform_tags={}
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
# #Create NSGs - opening port 22 ssh and port 80 - http
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
            web_atp_egress = {
              is_create = true,
              description = "web atp security egress rule",
              protocol  = "6", // tcp
              stateless = false,
              dst = "adw-nsg",
              dst_type      = "NSG_NAME",
              src_port_min  = null,
              src_port_max  = null,
              dst_port_min  = null, 
              dst_port_max  = null,
              icmp_type     = null,
              icmp_code     = null
            }
          }
   }
    ssh-nsg = {
          vcn_id = lookup(module.network-vcn.vcns,"vcn").id,
          ingress_rules = {
            ssh_ingress = {
              is_create = true,
              description = "ssh security ingress rule",
              protocol  = "6", // tcp
              stateless = false,
              src    = "0.0.0.0/0",
              src_type      = "CIDR_BLOCK",
              src_port_min  = null,
              src_port_max  = null,
              dst_port_min  = 22, 
              dst_port_max  = 22,
              icmp_type     = null,
              icmp_code     = null
            }
          },
          egress_rules = {
            ssh_egress = {
              is_create = true,
              description = "ssh security egress rule",
              protocol  = "6", // tcp
              stateless = false,
              dst = "0.0.0.0/0",
              dst_type      = "CIDR_BLOCK",
              src_port_min  = null,
              src_port_max  = null,
              dst_port_min  = null, 
              dst_port_max  = null,
              icmp_type     = null,
              icmp_code     = null
            }
          }
    },
    adw-nsg = {
        vcn_id = lookup(module.network-vcn.vcns,"vcn").id,
        ingress_rules = { 
          atp_ingress = {
            is_create = true,
            description = "atp security ingress rule",
            protocol  = "ALL", // tcp
            stateless = false,
            src    = "10.0.0.0/16",
            src_type      = "CIDR_BLOCK",
            src_port_min  = null,
            src_port_max  = null,
            dst_port_min  = 1522, 
            dst_port_max  = 1522,
            icmp_type     = null,
            icmp_code     = null
          },
          atp_ingress_1521 = {
            is_create = true,
            description = "atp security ingress rule",
            protocol  = "ALL", // tcp
            stateless = false,
            src    = "10.0.0.0/16",
            src_type      = "CIDR_BLOCK",
            src_port_min  = null,
            src_port_max  = null,
            dst_port_min  = 1521, 
            dst_port_max  = 1521,
            icmp_type     = null,
            icmp_code     = null
          },
          atp_ingress_port = {
            is_create = true,
            description = "atp security ingress rule",
            protocol  = "ALL", // tcp
            stateless = false,
            src    = "10.0.0.0/16",
            src_type      = "CIDR_BLOCK",
            src_port_min  = null,
            src_port_max  = null,
            dst_port_min  = 443, 
            dst_port_max  = 443,
            icmp_type     = null,
            icmp_code     = null
          }
        },
        egress_rules = {
            web_egress = {
              is_create = true,
              description = "atp security egress rule",
              protocol  = "ALL", // tcp
              stateless = false,
              dst = "10.0.0.0/16",
              dst_type      = "CIDR_BLOCK",
              src_port_min  = null,
              src_port_max  = null,
              dst_port_min  = null, 
              dst_port_max  = null,
              icmp_type     = null,
              icmp_code     = null
            }
          }
    },
    lb-nsg = {
        vcn_id = lookup(module.network-vcn.vcns,"vcn").id,
        ingress_rules = { 
          lb_igw_ingress = {
            is_create = true,
            description = "lb security ingress rule",
            protocol  = "all", 
            stateless = false,
            src    = "0.0.0.0/0",
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
            lb_igw_egress = {
              is_create = true,
              description = "lb internet security egress rule",
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
            lb_atp_egress = {
              is_create = true,
              description = "lb atp security egress rule",
              protocol  = "6", // tcp
              stateless = false,
              dst = "adw-nsg",
              dst_type      = "NSG_NAME",
              src_port_min  = null,
              src_port_max  = null,
              dst_port_min  = null, 
              dst_port_max  = null,
              icmp_type     = null,
              icmp_code     = null
            }
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

# End

}




