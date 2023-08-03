# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

#Project calls CIS Modules 

#Creates : 
#vcn - "hello-vcn - 10.0.0.0/16" ; 
#instance subnet - "hello-instance-subnet" - 10.0.1.0/24 
#atp subnet      - "hello-atp-endpoint-subnet" - 10.0.2.0/24
#Internet & NAT Gateway
module "network-vcn-subnets-gw" {

  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"

  compartment_id = var.compartment_id 
  service_label = ""
  service_gateway_cidr = lookup(data.oci_core_services.sgw_services.services[0], "cidr_block")

   vcns = {
     
    #Replace the key "hello-vcn" with the name desired
    hello-vcn = { 
     
     compartment_id = var.compartment_id
     cidr           = "10.0.0.0/16"
     dns_label      = "VCN"
     is_create_igw  = true
     is_attach_drg = false
     block_nat_traffic = false

     subnets  = { 
          hello-instance-subnet = { 
	          compartment_id=var.compartment_id, 
            vcn_id="", 
	          availability_domain=lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name"), 
	          cidr="10.0.1.0/24", 
            dns_label="sub1",
            private=false,
            dhcp_options_id="",
            security_list_ids=[],          
            defined_tags={}, 
	          freeform_tags={}
	        },
           hello-atp-endpoint-subnet = { 
	          compartment_id=var.compartment_id, 
            vcn_id="", 
	          availability_domain=lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name"), 
	          cidr="10.0.2.0/24", 
            dns_label="sub2",
            private=true,
            dhcp_options_id = "",
            prohibit_public_ip_on_vnic = true,
            security_list_ids=[],          
            defined_tags={}, 
	          freeform_tags={}
	        }
        }
     
     defined_tags = {}
     freeform_tags = {}
    }
  }
}

#Create routing table attached to vcn and subnets to route traffic via IGW/NAT
module "network-routing" {

  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-routing"

  compartment_id = var.compartment_id 

  subnets_route_tables = {

    hello-routetable-igw = {

      compartment_id = var.compartment_id,
      vcn_id = lookup(module.network-vcn-subnets-gw.vcns,"hello-vcn").id,
      subnet_id = lookup(module.network-vcn-subnets-gw.subnets,"hello-instance-subnet").id,
      route_table_id = "",
      route_rules = [{
        is_create = true,
        destination       = "0.0.0.0/0",
        destination_type  = "CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn-subnets-gw.internet_gateways, lookup(module.network-vcn-subnets-gw.vcns,"hello-vcn").id).id,
        description       = ""
      }],
      defined_tags = {}
    },
    hello-routetable-nat = {

      compartment_id = var.compartment_id,
      vcn_id = lookup(module.network-vcn-subnets-gw.vcns,"hello-vcn").id,
      subnet_id = lookup(module.network-vcn-subnets-gw.subnets,"hello-atp-endpoint-subnet").id,
      route_table_id = "",
      route_rules = [{
        is_create = true,
        destination       = "0.0.0.0/0",
        destination_type  = "CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn-subnets-gw.nat_gateways, lookup(module.network-vcn-subnets-gw.vcns,"hello-vcn").id).id,
        description       = ""
      }],
      defined_tags = {}
    }
  } 
}

#Create NSGs - opening port 22 ssh and port 80 - http
module "network-nsgs" {

  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/security"
  compartment_id = var.compartment_id 
  ports_not_allowed_from_anywhere_cidr = [3390,4500]

  #nsgs lists map
  nsgs = {
    web-nsg = {
        vcn_id = lookup(module.network-vcn-subnets-gw.vcns,"hello-vcn").id,
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
              dst = "atp-nsg",
              dst_type      = "NSG_NAME",
              src_port_min  = null,
              src_port_max  = null,
              dst_port_min  = null, 
              dst_port_max  = null,
              icmp_type     = null,
              icmp_code     = null
            }
          }
    },
    ssh-nsg = {
          vcn_id = lookup(module.network-vcn-subnets-gw.vcns,"hello-vcn").id,
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
    atp-nsg = {
        vcn_id = lookup(module.network-vcn-subnets-gw.vcns,"hello-vcn").id,
        ingress_rules = { 
          atp_ingress = {
            is_create = true,
            description = "atp security ingress rule",
            protocol  = "6", // tcp
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
          atp_ingress_port = {
            is_create = true,
            description = "atp security ingress rule",
            protocol  = "6", // tcp
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
              protocol  = "6", // tcp
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
    }
  }
}

#Generate instance public/private key pair
module "keygen" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/keygen"
  display_name = "keygen"
  subnet_domain_name = "hello-instance-subnet"
}

#Create ATP Database with Endpoint in private subnet
module "database-atp" {

  source = "../../../cloud-foundation/modules/cloud-foundation-library/database/atp"

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_id

  autonomous_database_cpu_core_count="2"
  autonomous_database_db_name="helloAtp"
  autonomous_database_admin_password="V2xzQXRwRGIxMjM0Iw=="
  autonomous_database_data_storage_size_in_tbs="1"

  nsg_ids                                = [lookup(module.network-nsgs.nsgs,"atp-nsg").id]
  subnet_id                             = lookup(module.network-vcn-subnets-gw.subnets,"hello-atp-endpoint-subnet").id

}

#Create Web Server - compute instance
module "web-instance" {

  source = "../../../cloud-foundation/modules/cloud-foundation-library/instance"

  instance_params = { 

  hello-web-instance = {

    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")

    compartment_id = var.compartment_id
    display_name   = "Hello Web Server"
    shape          = "VM.Standard2.1"

    defined_tags  = {}
    freeform_tags = {}

    subnet_id        = lookup(module.network-vcn-subnets-gw.subnets,"hello-instance-subnet").id
    vnic_display_name     = ""
    assign_public_ip = true
    hostname_label   = ""
    nsg_ids          = [lookup(module.network-nsgs.nsgs,"web-nsg").id]

    ocpus = 1

    source_type = "image"
    source_id   = local.oracle_linux

    metadata = {
      ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
    }
    
    are_legacy_imds_endpoints_disabled = true
    fault_domain = ""

    provisioning_timeout_mins = "30"

    }
  }
}

#Connect to instance and execute provision of web server
module "provisioner" {

  source = "./modules/provisioner"

  host = module.web-instance.InstancePublicIPs[0]
  private_key = module.keygen.OPCPrivateKey["private_key_pem"]
  atp_url = module.database-atp.url
  db_password = base64decode("V2xzQXRwRGIxMjM0Iw==")
} 