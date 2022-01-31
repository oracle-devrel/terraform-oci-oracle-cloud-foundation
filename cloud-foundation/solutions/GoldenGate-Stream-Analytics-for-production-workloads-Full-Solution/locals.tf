# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
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

# Local Block
locals{
   ggsa_image                  = "ocid1.image.oc1..aaaaaaaavizlnldcwtsgu7ljrpdvg6633e5jafne73qqlheuk3fln7upzobq"
   mp_listing_id               = "ocid1.appcataloglisting.oc1..aaaaaaaaw3t6a3jhs3t6m2dr6sgvnjipxlrysnwafmvi7i4dzphungl3gdla"
   mp_listing_resource_id      = "ocid1.image.oc1..aaaaaaaavizlnldcwtsgu7ljrpdvg6633e5jafne73qqlheuk3fln7upzobq"
   mp_listing_resource_version = "19.1.0.0.6_v1.1"

  public_subnet_availability_domain = local.ad_names[0]
  ad_names                    = compact(data.template_file.ad_names.*.rendered)


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
      subnet_id                                  = lookup(module.network-subnets.subnets,"ggsa-ha-priv").id,
      vcn_id                                     = lookup(module.network-vcn.vcns,"ggsa-ha").id, 
      analytics_instance_network_endpoint_details_whitelisted_ips = var.analytics_instance_network_endpoint_details_whitelisted_ips
      analytics_instance_network_endpoint_details_whitelisted_vcns_id = lookup(module.network-vcn.vcns,"ggsa-ha").id,
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

#create the mount targets list 
fss_params = {
  MYSQL = {
    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
    compartment_id = var.compartment_id
    name           = "MYSQL"
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
  }
  KAFKA = {
    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
    compartment_id = var.compartment_id
    name           = "KAFKA"
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
  }
  SPARK = {
    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
    compartment_id = var.compartment_id
    name           = "SPARK"
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
  }
  GGBD = {
    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
    compartment_id = var.compartment_id
    name           = "GGBD"
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
  }
}

mt_params = {
  GGSMT = {
    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
    compartment_id = var.compartment_id
    name           = "GGSMT"
    subnet_id      = lookup(module.network-subnets.subnets,"ggsa-ha-priv").id
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
  }
}

export_params = {
  GGSMT = {
    export_set_name = "GGSMT"
    filesystem_name = "MYSQL"
    path            = "/u02/mysql"
    export_options = [
      {
        source   = "0.0.0.0/0"
        access   = "READ_WRITE"
        identity = "NONE"
        use_port = false
      }
    ]
  }
  GGSMT2 = {
    export_set_name = "GGSMT"
    filesystem_name = "KAFKA"
    path            = "/u02/kafka"
    export_options = [
      {
        source   = "0.0.0.0/0"
        access   = "READ_WRITE"
        identity = "NONE"
        use_port = false
      }
    ]
  }
  GGSMT3 = {
    export_set_name = "GGSMT"
    filesystem_name = "SPARK"
    path            = "/u02/spark"
    export_options = [
      {
        source   = "0.0.0.0/0"
        access   = "READ_WRITE"
        identity = "NONE"
        use_port = false
      }
    ]
  }
  GGSMT4 = {
    export_set_name = "GGSMT"
    filesystem_name = "GGBD"
    path            = "/u02/ggbd"
    export_options = [
      {
        source   = "0.0.0.0/0"
        access   = "READ_WRITE"
        identity = "NONE"
        use_port = false
      }
    ]
  }
 }


#create the VM's for the solution 
instance_params = { 
  #Create the Web-Tier-and-Bastion Instance
  bastion = {
    availability_domain = 1
    compartment_id = var.compartment_id
    display_name   = "Web-Tier-and-Bastion"
    shape          = var.bastion_shape
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
    subnet_id         = lookup(module.network-subnets.subnets,"ggsa-ha-pub").id
    vnic_display_name = ""
    assign_public_ip  = true
    hostname_label    = ""
    source_type = "image"
    source_id   = local.ggsa_image
    metadata = {
      ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
    }
    fault_domain = ""
    provisioning_timeout_mins = "30"
  }

#create Workers and Masters instances
  ggsa-ha-worker1 = {
    availability_domain = 1
    compartment_id = var.compartment_id
    display_name   = "ggsa-ha-worker1"
    shape          = var.worker1_shape
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
    subnet_id        = lookup(module.network-subnets.subnets,"ggsa-ha-priv").id
    vnic_display_name = ""
    assign_public_ip = false
    hostname_label   = ""
    source_type = "image"
    source_id   = local.ggsa_image
    metadata = {
      ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
    }
    fault_domain = ""
    provisioning_timeout_mins = "30"
  }
  ggsa-ha-worker2 = {
    availability_domain = 2
    compartment_id = var.compartment_id
    display_name   = "ggsa-ha-worker2"
    shape          = var.worker2_shape
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
    subnet_id        = lookup(module.network-subnets.subnets,"ggsa-ha-priv").id
    vnic_display_name = ""
    assign_public_ip = false
    hostname_label   = ""
    source_type = "image"
    source_id   = local.ggsa_image
    metadata = {
      ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
    }
    fault_domain = ""
    provisioning_timeout_mins = "30"
  }
  ggsa-ha-worker3 = {
    availability_domain = 3
    compartment_id = var.compartment_id
    display_name   = "ggsa-ha-worker3" 
    shape          = var.worker3_shape
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
    subnet_id        = lookup(module.network-subnets.subnets,"ggsa-ha-priv").id
    vnic_display_name = ""
    assign_public_ip = false
    hostname_label   = ""
    source_type = "image"
    source_id   = local.ggsa_image
    metadata = {
      ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
    }
    fault_domain = ""
    provisioning_timeout_mins = "30"
  }
  ggsa-ha-master1 = {
    availability_domain = 1
    compartment_id = var.compartment_id
    display_name   = "ggsa-ha-master1"
    shape          = var.master1_shape
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
    subnet_id        = lookup(module.network-subnets.subnets,"ggsa-ha-priv").id
    vnic_display_name = ""
    assign_public_ip = false
    hostname_label   = ""
    source_type = "image"
    source_id   = local.ggsa_image
    metadata = {
      ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
    }
    fault_domain = ""
    provisioning_timeout_mins = "30"
  }
  ggsa-ha-master2 = {
    availability_domain = 2
    compartment_id = var.compartment_id
    display_name   = "ggsa-ha-master2"
    shape          = var.master2_shape
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
    subnet_id        = lookup(module.network-subnets.subnets,"ggsa-ha-priv").id
    vnic_display_name = ""
    assign_public_ip = false
    hostname_label   = ""
    source_type = "image"
    source_id   = local.ggsa_image
    metadata = {
      ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
    }
    fault_domain = ""
    provisioning_timeout_mins = "30"
    }
  }

#creates the VCN "ggsa-ha with the CIDR BLOCK 10.0.0.0/16"
  vcns-lists = {
    ggsa-ha = { 
     compartment_id = var.compartment_id
     cidr           = var.vcn_cidr
     dns_label      = "ggsaha"
     is_create_igw  = true
     is_attach_drg  = false
     block_nat_traffic = false
     subnets  = {}  
     defined_tags   = {}
     freeform_tags = {}
    }
  }

#creates the subnet "ggsa-ha-pub - 10.0.0.0/24 and ggsa-ha-priv - 10.0.1.0/24"
  subnet-lists = { 
     "" = {
        compartment_id = var.compartment_id
        cidr           = var.vcn_cidr
        dns_label      = "ggsaha"
        is_create_igw  = false
        is_attach_drg  = false
        block_nat_traffic = false
     
        subnets  = { 
          ggsa-ha-pub = { 
	          compartment_id=var.compartment_id, 
            vcn_id=lookup(module.network-vcn.vcns,"ggsa-ha").id, 
            availability_domain=var.use_regional_subnet? "" : local.public_subnet_availability_domain,
	          cidr=var.public_subnet_cidr,
            dns_label="ggsahapub",
            private=false,
            dhcp_options_id="",
            security_list_ids=[module.network-security-lists.security_lists["ggsa-ha-public_security_list"].id],          
            defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
            freeform_tags = {}
          }
          ggsa-ha-priv = { 
	          compartment_id=var.compartment_id, 
            vcn_id=lookup(module.network-vcn.vcns,"ggsa-ha").id, 
            availability_domain=var.use_regional_subnet? "" : local.public_subnet_availability_domain,
	          cidr=var.private_subnet_cidr, 
            dns_label="ggsahapriv",
            private=true,
            dhcp_options_id="",
            security_list_ids=[module.network-security-lists.security_lists["ggsa-ha-private_security_list"].id],          
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
    ggsa-ha-public = {
      compartment_id = var.compartment_id,
      vcn_id = lookup(module.network-vcn.vcns,"ggsa-ha").id,
      subnet_id = lookup(module.network-subnets.subnets,"ggsa-ha-pub").id,
      route_table_id = "",
      route_rules = [{
        is_create = true,
        destination       = "0.0.0.0/0",
        destination_type  = "CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn.internet_gateways, lookup(module.network-vcn.vcns,"ggsa-ha").id).id,
        description       = ""
      }],
        defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    }
  }

#create security list - opening port 22 ssh and port 80 - http
  security_lists = {
    ggsa-ha-public_security_list = {
        vcn_id = lookup(module.network-vcn.vcns,"ggsa-ha").id,
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
            dst_port      = {min = 8080, max=8080},
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
    ggsa-ha-private_security_list = {
        vcn_id = lookup(module.network-vcn.vcns,"ggsa-ha").id,
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
        vcn_id = lookup(module.network-vcn.vcns,"ggsa-ha").id,
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
        vcn_id = lookup(module.network-vcn.vcns,"ggsa-ha").id,
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
# End of local block
}