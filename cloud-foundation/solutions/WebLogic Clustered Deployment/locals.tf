data "oci_identity_tenancy" "tenancy" {
  tenancy_id = "${var.tenancy_ocid}"
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_services" "tf_services" {
  filter {
    name   = "cidr_block"
    values = ["all-.*-services-in-oracle-services-network"]
    regex  = true
  }
}

data "oci_core_vcns" "tf_vcns" {
  compartment_id = var.compartment_ocid
  display_name = var.vcn_name
}

data "oci_identity_regions" "home-region" {
  filter {
    name   = "key"
    values = ["${data.oci_identity_tenancy.tenancy.home_region_key}"]
  }
}

locals {

  num_ads = length(
    data.oci_identity_availability_domains.ADs.availability_domains,
  )
  is_single_ad_region = local.num_ads == 1 ? true : false
}

data "template_file" "ad_names" {
  count    = length(data.oci_identity_availability_domains.ADs.availability_domains)
  template =  (length(regexall("^.*Flex", var.instance_shape))>0 || (tonumber(lookup(data.oci_limits_limit_values.compute_shape_service_limits[count.index].limit_values[0], "value")) > 0))?lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name"):""
}

data "oci_limits_limit_values" "compute_shape_service_limits" {
    count    = length(data.oci_identity_availability_domains.ADs.availability_domains)
   
    compartment_id = var.tenancy_ocid
    service_name = "compute"

    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name")

    name = length(regexall("^.*Flex", var.instance_shape))>0?"":format("%s-count",replace(var.instance_shape, ".", "-"))
}

data "oci_core_subnet" "wls_subnet" {

  count = var.wls_subnet_id == "" ? 0 : 1
  subnet_id = var.wls_subnet_id
}

data "oci_core_subnet" "lb_subnet_id" {

  count = var.lb_subnet_id == "" ? 0 : 1
  subnet_id = var.lb_subnet_id
}

data "oci_core_subnet" "lb_subnet_backend_id" {

  count = var.lb_subnet_backend_id == "" ? 0 : 1
  subnet_id = var.lb_subnet_backend_id
}

locals {

  #Foundation

  home_region      = lookup(data.oci_identity_regions.home-region.regions[0], "name")
  compartment_ocid = var.compartment_ocid
  network_compartment_id  = var.network_compartment_id == "" ? var.compartment_ocid : var.network_compartment_id
  use_existing_subnets    = var.wls_subnet_id == "" && var.lb_subnet_id == "" && var.lb_subnet_backend_id == "" ? false : true
  use_regional_subnet     = var.use_regional_subnet

  service_name_prefix = replace(var.service_name, "/[^a-zA-Z0-9]/", "")

  ad_names                    = compact(data.template_file.ad_names.*.rendered)
  
  wls_availability_domain      = local.use_regional_subnet ? local.ad_names[0] : (var.wls_subnet_id == "" ? var.wls_availability_domain_name : data.oci_core_subnet.wls_subnet[0].availability_domain)
  lb_availability_domain_name = var.lb_subnet_id != "" ? (local.use_regional_subnet ? "" : data.oci_core_subnet.lb_subnet_id[0].availability_domain) : var.lb_subnet_availability_domain_name
  lb_backend_availability_domain_name = var.lb_subnet_backend_id != "" ? (local.use_regional_subnet ? "" : data.oci_core_subnet.lb_subnet_backend_id[0].availability_domain) : var.lb_backend_subnet_availability_domain_name

  wls_subnet_cidr         = var.wls_subnet_cidr == "" && var.vcn_name != "" ? "10.0.3.0/24" : var.wls_subnet_cidr
  lb_subnet_subnet_cidr   = var.lb_subnet_cidr == "" && var.vcn_name != "" ? "10.0.4.0/24" : var.lb_subnet_cidr
  lb_subnet_backend_subnet_cidr = var.lb_subnet_backend_cidr == "" && var.vcn_name != "" ? "10.0.5.0/24" : var.lb_subnet_backend_cidr

  assign_weblogic_public_ip = var.assign_weblogic_public_ip ? true : false

  lb_subnet_name = var.is_lb_private ? "lbprivate" : "lbpublic"
  lb_subnet_backend_name = var.is_lb_private ? "lbbackendpriv" : "lbbackendpub"

  vcnsCount = var.vcn_name !="" && local.use_existing_subnets == false ? 1 : 0

  create_subnets = {
     "${local.service_name_prefix}-${local.lb_subnet_name}" = var.add_load_balancer && var.lb_subnet_id == "" ? {
         compartment_id=local.network_compartment_id, 
         availability_domain=var.use_regional_subnet? "" : var.lb_subnet_availability_domain_name, 
         cidr = local.lb_subnet_subnet_cidr, dns_label = replace(format("%s-%s", local.lb_subnet_name, 
         substr(strrev(var.service_name), 0, 7)), "-",""), 
         private=var.is_lb_private, 
         dhcp_options_id=module.network-dhcp-options.dhcp_options["${var.service_name}-${var.dhcp_options_name}"].id, 
         security_list_ids = null, 
         defined_tags=local.defined_tags, 
         freeform_tags=local.freeform_tags
        } : {compartment_id="", availability_domain="", cidr="", dns_label="",private=false,dhcp_options_id="",security_list_ids=[""], defined_tags={}, freeform_tags={}},
       "${local.service_name_prefix}-${local.lb_subnet_backend_name}"= var.add_load_balancer && var.lb_subnet_backend_id == "" && ! var.is_lb_private && ! local.use_regional_subnet && ! local.is_single_ad_region ? { 
          compartment_id=local.network_compartment_id, 
          availability_domain=var.use_regional_subnet? "" : var.lb_backend_subnet_availability_domain_name,
          cidr = local.lb_subnet_backend_subnet_cidr,
          dns_label=replace(format("%s-%s", local.lb_subnet_name, substr(strrev(var.service_name), 0, 7)), "-",""),
          private=var.is_lb_private,
          dhcp_options_id=module.network-dhcp-options.dhcp_options["${var.service_name}-${var.dhcp_options_name}"].id,
          security_list_ids = null,
          defined_tags=local.defined_tags,
          freeform_tags=local.freeform_tags
        } : {compartment_id="", availability_domain="", cidr="", dns_label="",private=false,dhcp_options_id="",security_list_ids=[""], defined_tags={}, freeform_tags={}},
      "${local.service_name_prefix}-${var.wls_subnet_name}-private"= ! local.assign_weblogic_public_ip && var.wls_subnet_id == "" ? {             
           compartment_id=local.network_compartment_id, 
           availability_domain=var.use_regional_subnet? "" : var.wls_availability_domain_name,
           cidr = local.wls_subnet_cidr,
           dns_label=replace(format("%s-%s", var.wls_subnet_name, substr(strrev(var.service_name), 0, 7)), "-",""),
           private=true,
           dhcp_options_id=module.network-dhcp-options.dhcp_options["${var.service_name}-${var.dhcp_options_name}"].id,
           security_list_ids = null,
           defined_tags=local.defined_tags,
           freeform_tags=local.freeform_tags
      } : {compartment_id="", availability_domain="", cidr="", dns_label="",private=false,dhcp_options_id="",security_list_ids=[""], defined_tags={}, freeform_tags={}},
      "${local.service_name_prefix}-${var.wls_subnet_name}-public" = local.assign_weblogic_public_ip && var.wls_subnet_id == "" ? {              
           compartment_id=local.network_compartment_id, 
           availability_domain=var.use_regional_subnet? "" : var.wls_availability_domain_name,
           cidr = local.wls_subnet_cidr,
           dns_label=replace(format("%s-%s", var.wls_subnet_name, substr(strrev(var.service_name), 0, 7)), "-","")
           private=false,
           dhcp_options_id=module.network-dhcp-options.dhcp_options["${var.service_name}-${var.dhcp_options_name}"].id,
           security_list_ids = null,
           defined_tags=local.defined_tags,
           freeform_tags=local.freeform_tags
      } : {compartment_id="", availability_domain="", cidr="", dns_label="",private=false,dhcp_options_id="",security_list_ids=[""], defined_tags={}, freeform_tags={}}
  }

  port_for_ingress_lb_security_list = 443

  wls_ms_source_cidrs         = var.add_load_balancer ? ((local.use_regional_subnet || local.is_single_ad_region) ? [var.lb_subnet_cidr] : [var.lb_subnet_cidr, var.lb_subnet_backend_cidr]) : [var.anywhere_cidr]
  wls_admin_port_source_cidrs = var.wls_expose_admin_port ? [var.wls_admin_port_source_cidr] : []
  wls_ports = concat(local.wls_admin_port_source_cidrs, [22])

// NSG
  create_nsgs = {
      wls-nsg = !local.use_existing_subnets ? {
        vcn_id = var.vcn_name != "" ? lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id : var.existing_vcn_id,
        ingress_rules = {
          for x in range(length (local.wls_ports)) : "wls_port_ingress_${x}" => { 
              is_create = true,
              description = "wls port ingress rule",
              protocol  = "6", // tcp
              stateless = false,
              src    = local.wls_ports[x] != 22 ? local.wls_ports[x] : var.anywhere_cidr,
              src_type      = "CIDR_BLOCK",
              src_port_min  = null,
              src_port_max  = null,
              dst_port_min  = local.wls_ports[x] != 22 ? var.wls_ssl_admin_port : 22, 
              dst_port_max  = local.wls_ports[x] != 22 ? var.wls_ssl_admin_port : 22,
              icmp_type     = null,
              icmp_code     = null
           }
        },
        egress_rules = {
            wls_egress = {
              is_create = true,
              description = "wls security egress rule",
              protocol  = "all", // tcp
              stateless = false,
              dst = var.anywhere_cidr,
              dst_type      = "CIDR_BLOCK",
              src_port_min  = null,
              src_port_max  = null,
              dst_port_min  = null, 
              dst_port_max  = null,
              icmp_type     = null,
              icmp_code     = null
            }
        }
      } : { vcn_id = "", ingress_rules={}, egress_rules={}},
    wls-internal-nsg = !local.use_existing_subnets ? {
      vcn_id = var.vcn_name != "" ? lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id : var.existing_vcn_id,
      ingress_rules = {
        wls-internal-ingress = {
           is_create = true,
           description = "wls internal security ingress rule",
           protocol  = "6", // tcp
           stateless = false,
           src    = var.wls_subnet_cidr,
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
        wls-internal-egress = {
          is_create = true,
          description = "wls internal security egress rule",
          protocol  = "all", // tcp
          stateless = false,
          dst = var.anywhere_cidr,
          dst_type      = "CIDR_BLOCK",
          src_port_min  = null,
          src_port_max  = null,
          dst_port_min  = null, 
          dst_port_max  = null,
          icmp_type     = null,
          icmp_code     = null
        }
      }
    } : {vcn_id = "", ingress_rules = {}, egress_rules = {}},
    wls-ms-nsg = !local.use_existing_subnets ? {
        vcn_id = var.vcn_name != "" ? lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id : var.existing_vcn_id,
        ingress_rules = {
          for x in range(length (local.wls_ms_source_cidrs)) : "wls_ms_ingress_${x}" => { 
              is_create = true,
              description = "wls ms ingress rule",
              protocol  = "6", // tcp
              stateless = false,
              src    = local.wls_ms_source_cidrs[x],
              src_type      = "CIDR_BLOCK",
              src_port_min  = null,
              src_port_max  = null,
              dst_port_min  = var.add_load_balancer ? var.wls_ms_extern_port : var.wls_ms_extern_ssl_port, 
              dst_port_max  = var.add_load_balancer ? var.wls_ms_extern_port : var.wls_ms_extern_ssl_port,
              icmp_type     = null,
              icmp_code     = null
           }
        },
        egress_rules = {}
    } : {vcn_id = "", ingress_rules = {}, egress_rules = {}},
    wls-ms-external-nsg = !local.use_existing_subnets ? {
        vcn_id = var.vcn_name != "" ? lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id : var.existing_vcn_id,
        ingress_rules = {
          for x in range(length (local.wls_ms_source_cidrs)) : "wls_ms_external_ingress_${x}" => { 
              is_create = true,
              description = "wls ms ingress rule",
              protocol  = "6", // tcp
              stateless = false,
              src    = local.wls_ms_source_cidrs[x],
              src_type      = "CIDR_BLOCK",
              src_port_min  = null,
              src_port_max  = null,
              dst_port_min  = var.is_idcs_selected ? var.idcs_cloudgate_port: var.wls_ms_extern_ssl_port, 
              dst_port_max  = var.is_idcs_selected ? var.idcs_cloudgate_port : var.wls_ms_extern_ssl_port,
              icmp_type     = null,
              icmp_code     = null
           }
        },
        egress_rules = {}
    }: {vcn_id = "", ingress_rules = {}, egress_rules = {}},
    lb-nsg = var.add_load_balancer && !local.use_existing_subnets ? {
      vcn_id = var.vcn_name != "" ? lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id : var.existing_vcn_id,
      ingress_rules = {
        lb-ingress = {
           is_create = true,
           description = "lb ingress rule",
           protocol  = "6", // tcp
           stateless = false,
           //src    = var.is_lb_private ? var.bastion_subnet_cidr : var.anywhere_cidr,
           src = var.anywhere_cidr,
           src_type      = "CIDR_BLOCK",
           src_port_min  = null,
           src_port_max  = null,
           dst_port_min  = local.port_for_ingress_lb_security_list, 
           dst_port_max  = local.port_for_ingress_lb_security_list,
           icmp_type     = null,
          icmp_code      = null
        }
      },
      egress_rules = {
        lb-egress = {
          is_create = true,
          description = "lb egress rule",
          protocol  = "all", // tcp
          stateless = false,
          dst = var.anywhere_cidr,
          dst_type      = "CIDR_BLOCK",
          src_port_min  = null,
          src_port_max  = null,
          dst_port_min  = null, 
          dst_port_max  = null,
          icmp_type     = null,
          icmp_code     = null
        }
      }
    } : {vcn_id = "", ingress_rules = {}, egress_rules = {}}   
  }

#Policies
  osms_group = lookup(module.dynamic_groups.dynamic_groups,"${local.service_name_prefix}-osms-instance-principal-group").name
  principal_group = lookup(module.dynamic_groups.dynamic_groups,"${local.service_name_prefix}-principal-group").name

  osms_policy_1 = var.create_policies ? "Allow dynamic-group ${local.osms_group} to use osms-managed-instances in compartment id ${var.compartment_ocid}" : ""
  osms_policy_2 = var.create_policies ? "Allow dynamic-group ${local.osms_group} to read instance-family in compartment id ${var.compartment_ocid}" : ""

  ss_policy_statement1 = var.create_policies ? "Allow dynamic-group ${local.principal_group} to read secret-bundles in compartment id ${var.compartment_ocid} where target.secret.id = '${var.wls_admin_password_ocid}'" : ""
  ss_policy_statement2 = var.create_policies && var.atp_db_password_ocid!=""? "Allow dynamic-group ${local.principal_group}  to read secret-bundles in compartment id ${var.compartment_ocid} where target.secret.id = '${var.atp_db_password_ocid}'" : ""
  ss_policy_statement3 = var.create_policies && var.idcs_client_secret_ocid!=""? "Allow dynamic-group ${local.principal_group}  to read secret-bundles in compartment id ${var.compartment_ocid} where target.secret.id = '${var.idcs_client_secret_ocid}'" : ""

  sv_policy_statement1 = var.create_policies ? "Allow dynamic-group ${local.principal_group} to manage volume-family in compartment id ${var.compartment_ocid}" : ""
  sv_policy_statement2 = var.create_policies ? "Allow dynamic-group ${local.principal_group} to manage instance-family in compartment id ${var.compartment_ocid}" : ""
  sv_policy_statement3 = (var.create_policies && var.network_compartment_id!= "") ? "Allow dynamic-group ${local.principal_group} to manage virtual-network-family in compartment id ${local.network_compartment_id}" : ""

  lb_policy_statement  = var.create_policies ? "Allow dynamic-group ${local.principal_group} to manage load-balancers in compartment id ${local.network_compartment_id}" : ""
  atp_policy_statement = (local.atp_db.is_atp && var.create_policies) ? "Allow dynamic-group ${local.principal_group} to manage autonomous-transaction-processing-family in compartment id ${var.compartment_ocid}" : ""

   wls-dynamic_groups = {
      "${local.service_name_prefix}-principal-group" = var.create_policies ? {
        description = "dynamic group to allow access to resources"
        compartment_id = var.tenancy_ocid
        matching_rule = "ALL { ${format("instance.compartment.id='%s'", var.compartment_ocid)} }"
      } : {description = "", compartment_id="", matching_rule=""},
      "${local.service_name_prefix}-osms-instance-principal-group" = var.create_policies ? {
        description    = "dynamic group to allow instances to call osms services"
        compartment_id = var.tenancy_ocid
        matching_rule  = format("ANY { %s }",join(", ", formatlist("instance.id='%s'",compact(concat([lookup(module.bastions.bastions_details,"${local.service_name_prefix}Instance").id])))))
      } : {description = "", compartment_id="", matching_rule=""}
    }

     wls-policies = {
    "${local.service_name_prefix}-secrets-policy" = var.create_policies ? { 
      compartment_id = var.compartment_policy_id 
      description    = "policy to allow access to secrets in vault",
      statements     = compact([local.ss_policy_statement1, local.ss_policy_statement2, local.ss_policy_statement3])
    } : {compartment_id="", description="", statements=[]},
    "${local.service_name_prefix}-osms-policy" = var.create_policies ? {
      compartment_id = var.compartment_policy_id 
      description    = "policy to allow osms agent to access os-management service",
      statements     = compact([local.osms_policy_1, local.osms_policy_2])
    }: {compartment_id="", description="", statements=[]},
    "${local.service_name_prefix}-service-policy" = var.create_policies ? {
      compartment_id = var.compartment_policy_id 
      description    = "policy to access compute instances and block storage volumes",
      statements     = compact([local.sv_policy_statement1, local.sv_policy_statement2, local.sv_policy_statement3])
    }: {compartment_id="", description="", statements=[]},
    "${local.service_name_prefix}-atp-policy" = local.atp_db.is_atp && var.create_policies ? {
      compartment_id = var.compartment_policy_id 
      description    = "policy to allow WebLogic Cloud service to manage ATP DB in compartment",
      statements     = [local.atp_policy_statement]
    }: {compartment_id="", description="", statements=[]},
    "${local.service_name_prefix}-lb-policy" = var.create_policies  && var.add_load_balancer ? {
      compartment_id = var.compartment_policy_id 
      description    = "policy to allow WebLogic Cloud service to manage load balancer in WLSC network compartment",
      statements     = [local.lb_policy_statement]
    } : {compartment_id="", description="", statements=[]}
  }


  #Deployment

  is_atp_db        = trimspace(var.atp_db_id) == "" ? false : true
  create_atp_db    = trimspace(var.atp_db_password_ocid) != "" && local.is_atp_db == false ? true : false 

  atp_db = {
    is_atp         = local.create_atp_db ? true : local.is_atp_db
    compartment_id = var.atp_db_compartment_id
  }

  lbCount = var.add_load_balancer ? 1 : 0

  deploy_sample_app = (var.deploy_sample_app && var.wls_edition != "SE")

  db_user                      = local.is_atp_db || local.create_atp_db ? "ADMIN" : ""
  db_password                  = local.is_atp_db || local.create_atp_db ? var.atp_db_password_ocid : ""

  image_version        = var.image_version

  requires_JRF            = local.create_atp_db || local.is_atp_db ? true : false
  
  use_defined_tags = var.defined_tag == "~!@#$%^&*()" && var.defined_tag_value == "~!@#$%^&*()" ? false : true

  use_freeform_tags = var.free_form_tag == "~!@#$%^&*()" && var.free_form_tag_value == "~!@#$%^&*()" ? false : true

  defined_tag         = false == local.use_defined_tags ? "" : var.defined_tag
  defined_tag_value   = false == local.use_defined_tags ? "" : var.defined_tag_value
  free_form_tag       = false == local.use_freeform_tags ? "" : var.free_form_tag
  free_form_tag_value = false == local.use_freeform_tags ? "" : var.free_form_tag_value

  defined_tags = zipmap(
    compact([trimspace(local.defined_tag)]),
    compact([trimspace(local.defined_tag_value)]),
  )
  freeform_tags = zipmap(
    compact([trimspace(local.free_form_tag)]),
    compact([trimspace(local.free_form_tag_value)]),
  )

}


