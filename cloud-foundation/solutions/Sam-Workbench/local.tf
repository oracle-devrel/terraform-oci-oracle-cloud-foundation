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

data "template_cloudinit_config" "ui-config" {
  gzip          = true
  base64_encode = true
  # cloud-config configuration file.
  # /var/lib/cloud/instance/scripts/*
  part {
    filename     = "init.sh"
    content_type = "text/cloud-config"
    content      = file("${path.module}/scripts/ui-bootstrap")
  }
}

locals {
  ad_names                          = compact(data.template_file.ad_names.*.rendered)
  public_subnet_availability_domain = local.ad_names[0]

# Create Autonomous Data Warehouse
  adw_params = { 
    adw = {
      compartment_id              = var.compartment_id,
      cpu_core_count              = var.db_cpu_core_count
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
      is_mtls_connection_required = true
      subnet_id                   = lookup(module.network-subnets.subnets,"private-subnet").id
      nsg_ids                     = []
      defined_tags                = {}
  },
}


# Create the Bastion Instance
bastion_instance_params = { 
  bastion = {
    availability_domain = 1
    compartment_id = var.compartment_id
    display_name   = var.bastion_display_name
    shape          = var.bastion_server_shape
    defined_tags   = {}
    freeform_tags  = {}
    subnet_id         = lookup(module.network-subnets.subnets,"public-subnet").id
    vnic_display_name = ""
    assign_public_ip  = true
    hostname_label    = ""
    source_type   = "image"
    source_id     = var.ui_data_server[var.region]
    metadata = {
      ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
      user_data           = data.template_cloudinit_config.bastion-config.rendered
    }
    fault_domain = ""
    provisioning_timeout_mins = "30"
  }
}


# Create UI Data Server instance
  ui_data_server_params = {
  ui_data_server = {
    availability_domain = 1
    compartment_id = var.compartment_id
    display_name   = var.ui_data_server_display_name
    shape          = var.ui_data_server_shape
    defined_tags   = {}
    freeform_tags  = {}
    subnet_id        = lookup(module.network-subnets.subnets,"private-subnet").id
    vnic_display_name = ""
    assign_public_ip = false
    hostname_label   = ""
    source_type = "image"
    source_id   = var.ui_data_server[var.region]
    metadata = {
      ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
      user_data           = data.template_cloudinit_config.ui-config.rendered
    }
    fault_domain = ""
    provisioning_timeout_mins = "30"
    ocpus = var.ui_data_server_ocpus
    memory_in_gbs = var.ui_data_server_memory_in_gbs
    }
  }


# OCI Streaming
streaming_params = {
    Test_Stream = {
      name               = var.stream_name
      partitions         = var.stream_partitions
      compartment_id     = var.compartment_id
      retention_in_hours = var.stream_retention_in_hours
      stream_pool_id     = ""
      stream_pool_name   = var.stream_pool_name
      defined_tags       = {}
  }
}
streaming_pool_params = {
    Test_Stream_Pool = {
      compartment_id = var.compartment_id
      name           = var.stream_pool_name
      defined_tags   = {}
      kafka_settings = [
        {
          auto_create_topics_enable = false
          log_retention_hours       = 24
          num_partitions            = 1
        },
      ]
  }
}

service_connector = {}

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


# Calling the Load Balancer module

  lb-params = { 
    lbsam = {
      shape          = var.load_balancer_shape
      compartment_id = var.compartment_id
      subnet_ids = [lookup(module.network-subnets.subnets,"public-subnet").id]
      network_security_group_ids = [lookup(module.network-security-groups.nsgs,"public-nsgs-list").id]
      maximum_bandwidth_in_mbps = var.load_balancer_maximum_bandwidth_in_mbps
      minimum_bandwidth_in_mbps = var.load_balancer_minimum_bandwidth_in_mbps
      display_name  = var.load_balancer_display_name
      is_private    = false
      defined_tags  = {}
      freeform_tags = {}
    }
}

  lb-backendset-params = {
    listener-ui = {
      name             = "listener-ui"
      load_balancer_id = module.lb.load_balancer_id
      policy           = "ROUND_ROBIN"
      port                = "8000"
      protocol            = "TCP"
      response_body_regex = ""
      url_path            = null
      return_code         = null
      certificate_ids     = null
      certificate_name    = null
      cipher_suite_name   = null
      protocols           = null
      trusted_certificate_authority_ids = null
      server_order_preference           = null
      verify_depth                      = null
      verify_peer_certificate           = false
   }
    listener-data = {
      name             = "listener-data"
      load_balancer_id = module.lb.load_balancer_id
      policy           = "ROUND_ROBIN"
      port                = "8088"
      protocol            = "TCP"
      response_body_regex = ""
      url_path            = null
      return_code         = null
      certificate_ids     = null
      certificate_name    = null
      cipher_suite_name   = null
      protocols           = null
      trusted_certificate_authority_ids = null
      server_order_preference           = null
      verify_depth                      = null
      verify_peer_certificate           = false
   }
}

  lb-listener-https-params = { 
    lb-listener-ui = {
      load_balancer_id         = module.lb.load_balancer_id
      name                     = "listener-ui"
      default_backend_set_name = module.lb-backendset.BackendsetNames[1]
      port                     = "443"
      protocol                 = "HTTP"
      rule_set_names           = [module.SSL_headers.SSLHeadersNames[0]]
      certificate_name         = module.lb-demo_certificate.CertificateNames[0]
      idle_timeout_in_seconds  = "10"
      verify_peer_certificate  = false
  }
    lb-listener-data = {
      load_balancer_id         = module.lb.load_balancer_id
      name                     = "listener-data"
      default_backend_set_name = module.lb-backendset.BackendsetNames[0]
      port                     = "1443"
      protocol                 = "HTTP"
      rule_set_names           = [module.SSL_headers.SSLHeadersNames[0]]
      certificate_name         = module.lb-demo_certificate.CertificateNames[0]
      idle_timeout_in_seconds  = "10"
      verify_peer_certificate  = false
  }
}

    lb-backend-params = {
      listener-ui = {
        load_balancer_id = module.lb.load_balancer_id
        backendset_name  = module.lb-backendset.BackendsetNames[1]
        ip_address       = module.ui_data_server.InstancePrivateIPs[0]
        port             = "8000"
        backup           = false
        drain            = false
        offline          = false
        weight           = "1"
    }
      listener-data = {
        load_balancer_id = module.lb.load_balancer_id
        backendset_name  = module.lb-backendset.BackendsetNames[0]
        ip_address       = module.ui_data_server.InstancePrivateIPs[0]
        port             = "8088"
        backup           = false
        drain            = false
        offline          = false
        weight           = "1"
    }
}

    SSL_headers-params = { 
      lb-SSLHeaders = {
        load_balancer_id = module.lb.load_balancer_id
        name             = "SSLHeaders"
        SSLitems = [{item={
          action = "ADD_HTTP_REQUEST_HEADER"
          header = "Proxy-SSL"
          value  = "true"
        }},
        {item={
          action = "ADD_HTTP_REQUEST_HEADER"
          header = "is_ssl"
          value  = "ssl"
      }}]
      countSSL = 2
    }
}

    demo_certificate-params = { 
      lb-certificate = {
        certificate_name   = "demo_cert"
        load_balancer_id   = module.lb.load_balancer_id
        public_certificate = module.keygen.CertPem.cert_pem
        private_key        = module.keygen.SSPrivateKey.private_key_pem
        ca_certificate     = module.keygen.CertPem.cert_pem
        passphrase         = null
    }
}

# End


}