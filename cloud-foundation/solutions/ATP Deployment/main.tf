module "network-vcn-subnets-gw" {

  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"

  compartment_id = var.compartment_id 
  service_label = ""
  service_gateway_cidr = lookup(data.oci_core_services.sgw_services.services[0], "cidr_block")

   vcns = {
     
    #Replace the key "deploy-vcn" with the name desired
    deploy-vcn = { 
     
     compartment_id = var.compartment_id
     cidr           = "10.0.0.0/16"
     dns_label      = "VCN"
     is_create_igw  = true
     is_attach_drg = false
     block_nat_traffic = false

     subnets  = { 
          deploy-instance-subnet = { 
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
          deploy-atp-endpoint-subnet = { 
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
	        },        
          deploy-lb-subnet = { 
	          compartment_id=var.compartment_id, 
            vcn_id="", 
	          availability_domain="", 
	          cidr="10.0.3.0/24", 
            dns_label="sub3",
            private=false,
            dhcp_options_id="",
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

    deploy-routetable-igw = {

      compartment_id = var.compartment_id,
      vcn_id = lookup(module.network-vcn-subnets-gw.vcns,"deploy-vcn").id,
      subnet_id = lookup(module.network-vcn-subnets-gw.subnets,"deploy-instance-subnet").id,
      route_table_id = "",
      route_rules = [{
        is_create = true,
        destination       = "0.0.0.0/0",
        destination_type  = "CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn-subnets-gw.internet_gateways, lookup(module.network-vcn-subnets-gw.vcns,"deploy-vcn").id).id,
        description       = ""
      }],
      defined_tags = {}
    },
    deploy-routetable-nat = {

      compartment_id = var.compartment_id,
      vcn_id = lookup(module.network-vcn-subnets-gw.vcns,"deploy-vcn").id,
      subnet_id = lookup(module.network-vcn-subnets-gw.subnets,"deploy-atp-endpoint-subnet").id,
      route_table_id = "",
      route_rules = [{
        is_create = true,
        destination       = "0.0.0.0/0",
        destination_type  = "CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn-subnets-gw.nat_gateways, lookup(module.network-vcn-subnets-gw.vcns,"deploy-vcn").id).id,
        description       = ""
      }],
      defined_tags = {}
    }
  } 
}

module "routing-attachment" {

  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-routing"

  compartment_id = var.compartment_id 

   subnets_route_tables = {
    "" = {
      compartment_id = var.compartment_id,
      vcn_id = lookup(module.network-vcn-subnets-gw.vcns,"deploy-vcn").id,
      subnet_id = lookup(module.network-vcn-subnets-gw.subnets,"deploy-lb-subnet").id,
      route_table_id = lookup(module.network-routing.subnets_route_tables,"deploy-routetable-igw").id,
      route_rules = [],
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
        vcn_id = lookup(module.network-vcn-subnets-gw.vcns,"deploy-vcn").id,
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
          vcn_id = lookup(module.network-vcn-subnets-gw.vcns,"deploy-vcn").id,
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
        vcn_id = lookup(module.network-vcn-subnets-gw.vcns,"deploy-vcn").id,
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
        vcn_id = lookup(module.network-vcn-subnets-gw.vcns,"deploy-vcn").id,
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
    }
  }
}

#Generate instance public/private key pair
module "keygen" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/keygen"
  display_name = "deploy-lb-subnet"
  subnet_domain_name = lookup(module.network-vcn-subnets-gw.subnets,"deploy-lb-subnet").subnet_domain_name
}

module "lb" {

  source = "../../../cloud-foundation/modules/cloud-foundation-library/lb"
   
   lb-params = {
    "lb-adb" = {
    shape          = "flexible"
    compartment_id = var.compartment_id
    subnet_ids = [lookup(module.network-vcn-subnets-gw.subnets,"deploy-lb-subnet").id]
    network_security_group_ids = [lookup(module.network-nsgs.nsgs,"lb-nsg").id]
    maximum_bandwidth_in_mbps = 400
    minimum_bandwidth_in_mbps = 10
    display_name  = "atp-lb"
    is_private    = false
    defined_tags  = {}
    freeform_tags = {}
    }
   }
}

module "lb-backendset" {

  source = "../../../cloud-foundation/modules/cloud-foundation-library/lb"

  lb-backendset-params = {
    "lb-backendset" = {
      name             = "lb-backendset"
      load_balancer_id = module.lb.load_balancer_id
      policy           = "ROUND_ROBIN"
      port                = "443"
      protocol            = "HTTP"
      response_body_regex = ""
      url_path            = "/"
      return_code         = "302"
      certificate_ids = null
      certificate_name = module.lb-demo_certificate.CertificateNames[0]
      cipher_suite_name = "oci-default-ssl-cipher-suite-v1"
      protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      trusted_certificate_authority_ids = null
      server_order_preference = null
      verify_depth = null
      verify_peer_certificate = false
   }
  }
}

module "lb-listener-https" {

  source = "../../../cloud-foundation/modules/cloud-foundation-library/lb"

  lb-listener-https-params = { 
    "lb-listener" = {
      load_balancer_id         = module.lb.load_balancer_id
      name                     = "https"
      default_backend_set_name = module.lb-backendset.BackendsetNames[0]
      port                     = "443"
      protocol                 = "HTTP"
      rule_set_names           = [module.SSL_headers.SSLHeadersNames[0]]
      idle_timeout_in_seconds = "10"
      certificate_name = module.lb-demo_certificate.CertificateNames[0]
      verify_peer_certificate = false
  }
}
}

module "lb-backend" {

  source = "../../../cloud-foundation/modules/cloud-foundation-library/lb"

    lb-backend-params = {
      "lb-backend" = {
        load_balancer_id = module.lb.load_balancer_id
        backendset_name  = module.lb-backendset.BackendsetNames[0]
        ip_address       = module.database-atp.private_endpoint_ip
        port             = "443"
        backup           = false
        drain            = false
        offline          = false
        weight           = "1"

    }
}
}

module "SSL_headers" {

  source = "../../../cloud-foundation/modules/cloud-foundation-library/lb"

    SSL_headers-params = { 
      "lb-SSLHeaders" = {
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
}

module "lb-demo_certificate" {

  source = "../../../cloud-foundation/modules/cloud-foundation-library/lb"
    
    demo_certificate-params = { 
    
      "lb-certificate" = {

        certificate_name = "demo_cert"
        load_balancer_id = module.lb.load_balancer_id

        public_certificate = module.keygen.CertPem.cert_pem
        private_key        = module.keygen.SSPrivateKey.private_key_pem
        ca_certificate     = module.keygen.CertPem.cert_pem
        passphrase         = null
    }
}
}


#Create ATP Database with Endpoint in private subnet
module "database-atp" {

  source = "../../../cloud-foundation/modules/cloud-foundation-library/database/atp"

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_id

  autonomous_database_cpu_core_count="2"
  autonomous_database_db_name="deployAtp"
  autonomous_database_admin_password="V2xzQXRwRGIxMjM0Iw=="
  autonomous_database_data_storage_size_in_tbs="1"

  nsg_ids                                = [lookup(module.network-nsgs.nsgs,"atp-nsg").id]
  subnet_id                             = lookup(module.network-vcn-subnets-gw.subnets,"deploy-atp-endpoint-subnet").id
  is_mtls_connection_required           = false
}

#Create Web Server - compute instance
module "web-instance" {

  source = "../../../cloud-foundation/modules/cloud-foundation-library/instance"

  instance_params = { 

  deploy-web-instance = {

    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")

    compartment_id = var.compartment_id
    display_name   = "ATP Web Server"
    shape          = "VM.Standard2.1"

    defined_tags  = {}
    freeform_tags = {}

    subnet_id        = lookup(module.network-vcn-subnets-gw.subnets,"deploy-instance-subnet").id
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
  conn_db = module.database-atp.db_connection[0].profiles[1].value
} 


