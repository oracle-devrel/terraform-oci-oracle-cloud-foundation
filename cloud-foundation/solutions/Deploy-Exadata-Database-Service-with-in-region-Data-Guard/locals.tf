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
  ad_names                          = compact(data.template_file.ad_names.*.rendered)
  public_subnet_availability_domain = local.ad_names[0]

  ## Creates the VCN "vcn with the CIDR BLOCK 10.0.0.0/16"
  vcns-lists = {
    vcn = {
      compartment_id    = var.compartment_id
      cidr              = var.vcn_cidr
      dns_label         = "vcn"
      is_create_igw     = true
      is_attach_drg     = false // put true if you want to have drg attached !
      block_nat_traffic = false
      subnets           = {}
      defined_tags      = {}
      freeform_tags     = {}
    }
  }

  #creates the subnet "public-subnet - 10.0.0.0/24 and private-subnet - 10.0.1.0/24"
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
          compartment_id      = var.compartment_id,
          vcn_id              = lookup(module.network-vcn.vcns, "vcn").id,
          availability_domain = ""
          cidr                = var.public_subnet_cidr,
          dns_label           = "public",
          private             = false,
          dhcp_options_id     = "",
          security_list_ids   = [module.network-security-lists.security_lists["public_security_list"].id],
          defined_tags        = {}
          freeform_tags       = {}
        }
        private-subnet = {
          compartment_id      = var.compartment_id,
          vcn_id              = lookup(module.network-vcn.vcns, "vcn").id,
          availability_domain = ""
          cidr                = var.private_subnet_cidr,
          dns_label           = "private",
          private             = true,
          dhcp_options_id     = "",
          security_list_ids   = [module.network-security-lists.security_lists["private_security_list"].id],
          defined_tags        = {}
          freeform_tags       = {}
        }
        backup-subnet = {
          compartment_id      = var.compartment_id,
          vcn_id              = lookup(module.network-vcn.vcns, "vcn").id,
          availability_domain = ""
          cidr                = var.backup_subnet_cidr,
          dns_label           = "backup",
          private             = true,
          dhcp_options_id     = "",
          security_list_ids   = [module.network-security-lists.security_lists["private_security_list"].id],
          defined_tags        = {}
          freeform_tags       = {}
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
      vcn_id         = lookup(module.network-vcn.vcns, "vcn").id,
      subnet_id      = lookup(module.network-subnets.subnets, "public-subnet").id,
      route_table_id = "",
      route_rules = [{
        is_create         = true,
        destination       = "0.0.0.0/0",
        destination_type  = "CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn.internet_gateways, lookup(module.network-vcn.vcns, "vcn").id).id,
        description       = ""
      }],
      defined_tags = {}
    },
    private_route_table-nat-sgw = {
      compartment_id = var.compartment_id,
      vcn_id         = lookup(module.network-vcn.vcns, "vcn").id,
      subnet_id      = lookup(module.network-subnets.subnets, "private-subnet").id,
      route_table_id = "",
      route_rules = [
        {
          is_create         = true,
          destination       = "0.0.0.0/0",
          destination_type  = "CIDR_BLOCK",
          network_entity_id = lookup(module.network-vcn.nat_gateways, lookup(module.network-vcn.vcns, "vcn").id).id,
          description       = ""
        },
        {
          is_create         = true,
          destination       = lookup(data.oci_core_services.sgw_services.services[0], "cidr_block"),
          destination_type  = "SERVICE_CIDR_BLOCK",
          network_entity_id = lookup(module.network-vcn.service_gateways, lookup(module.network-vcn.vcns, "vcn").id).id,
          description       = ""
        }
      ],
      defined_tags = {}
    }
  }

  network-routing-attachment = {
    "" = {
      compartment_id = var.compartment_id,
      vcn_id         = lookup(module.network-vcn.vcns, "vcn").id,
      subnet_id      = lookup(module.network-subnets.subnets, "public-subnet").id,
      route_table_id = lookup(module.network-routing.subnets_route_tables, "public_route_table-igw").id,
      route_rules    = [],
      defined_tags   = {}
    }
    "" = {
      compartment_id = var.compartment_id,
      vcn_id         = lookup(module.network-vcn.vcns, "vcn").id,
      subnet_id      = lookup(module.network-subnets.subnets, "backup-subnet").id,
      route_table_id = lookup(module.network-routing.subnets_route_tables, "private_route_table-nat-sgw").id,
      route_rules    = [],
      defined_tags   = {}
    }
  }

  #create security list - opening port 22 ssh and port 80 - http
  security_lists = {
    public_security_list = {
      vcn_id         = lookup(module.network-vcn.vcns, "vcn").id,
      compartment_id = var.compartment_id,
      defined_tags   = {}
      ingress_rules = concat([{
        stateless = false
        protocol  = "6" // tcp
        src       = "0.0.0.0/0"
        src_type  = "CIDR_BLOCK",
        src_port  = null,
        dst_port  = { min = 22, max = 22 },
        icmp_type = null,
        icmp_code = null
        }],
        [{
          stateless = false
          protocol  = "6" // tcp
          src       = "0.0.0.0/0"
          src_type  = "CIDR_BLOCK",
          src_port  = null,
          dst_port  = { min = 443, max = 443 },
          icmp_type = null,
          icmp_code = null
        }],
        [{
          stateless = false
          protocol  = "6" // tcp
          src       = "0.0.0.0/0"
          src_type  = "CIDR_BLOCK",
          src_port  = null,
          dst_port  = { min = 80, max = 80 },
          icmp_type = null,
          icmp_code = null
        }],
        [{
          stateless = false
          protocol  = "all"
          src       = "0.0.0.0/0"
          src_type  = "CIDR_BLOCK",
          src_port  = null,
          dst_port  = null,
          icmp_type = null,
          icmp_code = null
      }]),
      egress_rules = [{
        stateless = false,
        protocol  = "all",
        dst       = "0.0.0.0/0",
        dst_type  = "CIDR_BLOCK",
        src_port  = null,
        dst_port  = null,
        icmp_type = null,
        icmp_code = null
      }],
    }
    private_security_list = {
      vcn_id         = lookup(module.network-vcn.vcns, "vcn").id,
      compartment_id = var.compartment_id,
      defined_tags   = {}
      ingress_rules = concat([{
        stateless = false
        protocol  = "all"
        src       = var.vcn_cidr,
        src_type  = "CIDR_BLOCK",
        src_port  = null,
        dst_port  = null,
        icmp_type = null,
        icmp_code = null
        }],
        [{
          stateless = false
          protocol  = "6"
          src       = var.vcn_cidr,
          src_type  = "CIDR_BLOCK",
          src_port  = null,
          dst_port  = { min = 22, max = 22 },
          icmp_type = null,
          icmp_code = null
        }],
        [{
          stateless = false
          protocol  = "17"
          src       = var.vcn_cidr,
          src_type  = "CIDR_BLOCK",
          src_port  = null,
          dst_port  = { min = 3306, max = 3306 },
          icmp_type = null,
          icmp_code = null
        }],
        [{
          stateless = false
          protocol  = "all"
          src       = "0.0.0.0/0"
          src_type  = "CIDR_BLOCK",
          src_port  = null,
          dst_port  = null,
          icmp_type = null,
          icmp_code = null
      }]),
      egress_rules = [{
        stateless = false,
        protocol  = "all",
        dst       = "0.0.0.0/0",
        dst_type  = "CIDR_BLOCK",
        src_port  = null,
        dst_port  = null,
        icmp_type = null,
        icmp_code = null
      }]
    }
  }

  # Create Bastion
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
      nsg_ids             = []
      source_type         = "image"
      source_id           = var.bastion_source_image_id[var.region]
      metadata = {
        ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
      }
      fault_domain              = ""
      provisioning_timeout_mins = "30"
    }
  }

  ############################################################

  #########
  # Exadata Infrastructure:
  #########

  #############  FIRST AD
  # Create Exadata Infrastrucutre in First AD
  exadata_infrastructure_firstAD = {
    exadata_infrastructure_firstAD = {
      availability_domain = var.exadata_infrastructure_first_availability_domain
      compartment_id      = var.compartment_id
      display_name        = var.exadata_infrastructure_firstAD_display_name
      shape               = var.exadata_infrastructure_firstAD_shape
      email               = var.exadata_infrastructure_firstAD_email
      defined_tags        = {}
      freeform_tags       = {}
      hours_of_day        = null
      preference          = var.exadata_infrastructure_firstAD_preference
      weeks_of_month      = null
    }
  }

  # Create Cloud VM Cluster in First AD
  cloud_vm_cluster_firstAD = {
    cloud_vm_cluster_firstAD = {
      backup_subnet_id                = lookup(module.network-subnets.subnets, "backup-subnet").id
      cloud_exadata_infrastructure_id = module.exadata_infrastructure_firstAD.cloud_exadata_infrastructure_id[0]
      compartment_id                  = var.compartment_id
      cpu_core_count                  = var.cloud_vm_cluster_firstAD_cpu_core_count
      display_name                    = var.cloud_vm_cluster_firstAD_display_name
      gi_version                      = var.cloud_vm_cluster_firstAD_gi_version
      hostname                        = var.cloud_vm_cluster_firstAD_hostname
      ssh_public_keys                 = [module.keygen.OPCPrivateKey.public_key_openssh]
      subnet_id                       = lookup(module.network-subnets.subnets, "private-subnet").id
      cluster_name                    = var.cloud_vm_cluster_firstAD_cluster_name
      data_storage_percentage         = var.cloud_vm_cluster_firstAD_data_storage_percentage
      defined_tags                    = {}
      domain                          = null
      freeform_tags                   = {}
      is_local_backup_enabled         = var.cloud_vm_cluster_firstAD_is_local_backup_enabled
      is_sparse_diskgroup_enabled     = var.cloud_vm_cluster_firstAD_is_sparse_diskgroup_enabled
      license_model                   = var.cloud_vm_cluster_firstAD_license_model
      nsg_ids                         = []
      scan_listener_port_tcp          = var.cloud_vm_cluster_firstAD_scan_listener_port_tcp
      scan_listener_port_tcp_ssl      = var.cloud_vm_cluster_firstAD_scan_listener_port_tcp_ssl
      time_zone                       = var.cloud_vm_cluster_firstAD_time_zone
    }
  }

  # Create the DB Home and database in First AD
  database_db_home_firstAD = {
    database_db_home_firstAD = {
      admin_password = var.database_db_home_firstAD_admin_password
      defined_tags   = {}
      freeform_tags  = {}
      db_version     = var.database_db_home_firstAD_db_version
      display_name   = var.database_db_home_firstAD_display_name
      db_name        = var.database_db_home_firstAD_db_name
      source         = var.database_db_home_firstAD_source
      vm_cluster_id  = module.cloud_vm_cluster_firstAD.cloud_vm_cluster_id[0]
    }
  }


  #############  SECOND AD
  # Create Exadata Infrastrucutre in Second AD
  exadata_infrastructure_secondAD = {
    exadata_infrastructure_secondAD = {
      availability_domain = var.exadata_infrastructure_second_availability_domain
      compartment_id      = var.compartment_id
      display_name        = var.exadata_infrastructure_secondAD_display_name
      shape               = var.exadata_infrastructure_secondAD_shape
      email               = var.exadata_infrastructure_secondAD_email
      defined_tags        = {}
      freeform_tags       = {}
      hours_of_day        = null
      preference          = var.exadata_infrastructure_secondAD_preference
      weeks_of_month      = null
    }
  }

  # Create Cloud VM Cluster in Second AD
  cloud_vm_cluster_secondAD = {
    cloud_vm_cluster_secondAD = {
      backup_subnet_id                = lookup(module.network-subnets.subnets, "backup-subnet").id
      cloud_exadata_infrastructure_id = module.exadata_infrastructure_secondAD.cloud_exadata_infrastructure_id[0]
      compartment_id                  = var.compartment_id
      cpu_core_count                  = var.cloud_vm_cluster_secondAD_cpu_core_count
      display_name                    = var.cloud_vm_cluster_secondAD_display_name
      gi_version                      = var.cloud_vm_cluster_secondAD_gi_version
      hostname                        = var.cloud_vm_cluster_secondAD_hostname
      ssh_public_keys                 = [module.keygen.OPCPrivateKey.public_key_openssh]
      subnet_id                       = lookup(module.network-subnets.subnets, "private-subnet").id
      cluster_name                    = var.cloud_vm_cluster_secondAD_cluster_name
      data_storage_percentage         = var.cloud_vm_cluster_secondAD_data_storage_percentage
      defined_tags                    = {}
      domain                          = null
      freeform_tags                   = {}
      is_local_backup_enabled         = var.cloud_vm_cluster_secondAD_is_local_backup_enabled
      is_sparse_diskgroup_enabled     = var.cloud_vm_cluster_secondAD_is_sparse_diskgroup_enabled
      license_model                   = var.cloud_vm_cluster_secondAD_license_model
      nsg_ids                         = []
      scan_listener_port_tcp          = var.cloud_vm_cluster_secondAD_scan_listener_port_tcp
      scan_listener_port_tcp_ssl      = var.cloud_vm_cluster_secondAD_scan_listener_port_tcp_ssl
      time_zone                       = var.cloud_vm_cluster_secondAD_time_zone
    }
  }

  # Data Guard Association:
  database_data_guard_association = {
    database_data_guard_association = {
      creation_type                    = var.database_data_guard_association_creation_type
      database_admin_password          = var.database_db_home_firstAD_admin_password
      delete_standby_db_home_on_delete = true
      peer_vm_cluster_id               = module.cloud_vm_cluster_secondAD.cloud_vm_cluster_id[0]
      protection_mode                  = var.database_data_guard_association_protection_mode
      transport_type                   = var.database_data_guard_association_transport_type
    }
  }

  # # End


}
