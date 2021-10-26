data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_tenancy" "tenancy" {
  #Required
  tenancy_id = "${var.tenancy_ocid}"
}

locals {

  num_ads = length(
    data.oci_identity_availability_domains.ADs.availability_domains,
  )
  is_single_ad_region = local.num_ads == 1 ? true : false
}

data "oci_identity_regions" "home-region" {
  filter {
    name   = "key"
    values = ["${data.oci_identity_tenancy.tenancy.home_region_key}"]
  }
}

data "oci_core_instance" "existing_bastion_instance" {
  count = var.existing_bastion_instance_id != "" ? 1: 0

  instance_id = var.existing_bastion_instance_id
}

data "template_file" "ad_names" {
  count    = length(data.oci_identity_availability_domains.ADs.availability_domains)
  template =  (length(regexall("^.*Flex", var.instance_shape))>0 || (tonumber(lookup(data.oci_limits_limit_values.compute_shape_service_limits[count.index].limit_values[0], "value")) > 0))?lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name"):""
}

data "oci_limits_limit_values" "compute_shape_service_limits" {
    count    = length(data.oci_identity_availability_domains.ADs.availability_domains)
    #Required
    compartment_id = var.tenancy_ocid
    service_name = "compute"

    #Optional
    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name")
    #format of name field -vm-standard2-2-count
    #ignore flex shapes
    name = length(regexall("^.*Flex", var.instance_shape))>0?"":format("%s-count",replace(var.instance_shape, ".", "-"))
}

data "oci_core_subnet" "wls_subnet" {

  count = var.wls_subnet_id == "" ? 0 : 1

  #Required
  subnet_id = var.wls_subnet_id
}

data "oci_core_subnet" "bastion_subnet" {

  count = var.bastion_subnet_id == "" ? 0 : 1

  #Required
  subnet_id = var.bastion_subnet_id
}

# For querying availability domains given subnet_id
data "oci_core_subnet" "lb_subnet_id" {

  count = var.lb_subnet_id == "" ? 0 : 1

  #Required
  subnet_id = var.lb_subnet_id
}

data "oci_core_subnet" "lb_subnet_backend_id" {
  count = var.lb_subnet_backend_id == "" ? 0 : 1

  #Required
  subnet_id = var.lb_subnet_backend_id
}

data "oci_core_services" "tf_services" {
  filter {
    name   = "cidr_block"
    values = ["all-.*-services-in-oracle-services-network"]
    regex  = true
  }
}

data "oci_core_vcns" "tf_vcns" {
  #Required
  compartment_id = var.compartment_ocid
}


locals {

  compartment_ocid = var.compartment_ocid
  is_atp_db        = trimspace(var.atp_db_id) == "" && trimspace(var.atp_db_password_ocid) == "" ? false : true
  is_atp_appdb     = trimspace(var.app_atp_db_id) == "" ? false : true
  home_region      = lookup(data.oci_identity_regions.home-region.regions[0], "name")

  // Default DB user for ATP DB is admin
  db_password                  = local.is_atp_db ? var.atp_db_password_ocid : ""

  is_vcn_peering = false

  assign_weblogic_public_ip = var.assign_weblogic_public_ip || var.subnet_type == "Use Public Subnet" ? true : false

  bastion_subnet_cidr     = var.bastion_subnet_cidr == "" && var.vcn_name != "" && ! local.assign_weblogic_public_ip ? local.is_vcn_peering ? "11.0.6.0/24" : "10.0.6.0/24" : var.bastion_subnet_cidr
  wls_subnet_cidr         = var.wls_subnet_cidr == "" && var.vcn_name != "" ? local.is_vcn_peering ? "11.0.3.0/24" : "10.0.3.0/24" : var.wls_subnet_cidr
  lb_subnet_subnet_cidr   = var.lb_subnet_cidr == "" && var.vcn_name != "" ? local.is_vcn_peering ? "11.0.4.0/24" : "10.0.4.0/24" : var.lb_subnet_cidr
  lb_subnet_backend_subnet_cidr = var.lb_subnet_backend_cidr == "" && var.vcn_name != "" ? local.is_vcn_peering ? "11.0.5.0/24" : "10.0.5.0/24" : var.lb_subnet_backend_cidr
  use_existing_subnets    = var.wls_subnet_id == "" && var.lb_subnet_id == "" && var.lb_subnet_backend_id == "" ? false : true

  # Remove all characters from the service_name that dont satisfy the criteria:
  # must start with letter, must only contain letters and numbers and length between 1,8
  # See https://github.com/google/re2/wiki/Syntax - regex syntax supported by replace()
  service_name_prefix = replace(var.service_name, "/[^a-zA-Z0-9]/", "")

  use_regional_subnet     = (var.use_regional_subnet && var.subnet_span == "Regional Subnet")
  network_compartment_id  = var.network_compartment_id == "" ? var.compartment_ocid : var.network_compartment_id


  #Availability Domains
  ad_names                    = compact(data.template_file.ad_names.*.rendered)
  bastion_availability_domain = var.bastion_subnet_id != "" ? (local.use_regional_subnet ? local.ad_names[0] : data.oci_core_subnet.bastion_subnet[0].availability_domain) : (local.use_regional_subnet ? local.ad_names[0] : var.wls_availability_domain_name)
  #for existing wls subnet, get AD from the subnet
  wls_availability_domain      = local.use_regional_subnet ? local.ad_names[0] : (var.wls_subnet_id == "" ? var.wls_availability_domain_name : data.oci_core_subnet.wls_subnet[0].availability_domain)
  lb_availability_domain_name1 = var.lb_subnet_id != "" ? (local.use_regional_subnet ? "" : data.oci_core_subnet.lb_subnet_id[0].availability_domain) : var.lb_subnet_1_availability_domain_name
  lb_availability_domain_name2 = var.lb_subnet_backend_id != "" ? (local.use_regional_subnet ? "" : data.oci_core_subnet.lb_subnet_backend_id[0].availability_domain) : var.lb_subnet_2_availability_domain_name

  #map of Tag key and value
  #special chars string denotes empty values for tags for validation purposes
  #otherwise zipmap function below fails first for empty strings before validators executed
  use_defined_tags = var.defined_tag == "~!@#$%^&*()" && var.defined_tag_value == "~!@#$%^&*()" ? false : true

  use_freeform_tags = var.free_form_tag == "~!@#$%^&*()" && var.free_form_tag_value == "~!@#$%^&*()" ? false : true

  #ignore defaults of special chars if tags are not provided
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

  atp_db = {
    is_atp         = local.is_atp_db
    compartment_id = var.atp_db_compartment_id
  }

  lbCount = var.add_load_balancer ? 1 : 0

  lb_subnet_name = var.is_lb_private ? "lbprist" : "lbpubst"
  lb_subnet_backend_name = var.is_lb_private ? "lbpristbackend" : "lbpubstbackend"

  vcnsCount = var.vcn_name !="" && local.use_existing_subnets==false ? 1:0
     
  bastion_security_list_id = compact(
    concat(
      [module.network-security-lists.security_lists[!local.assign_weblogic_public_ip ? "${var.service_name}-bastion-security-list" : "${var.service_name}-wls-security-list"].id],
      [module.network-security-lists.security_lists["${var.service_name}-wls-ms-security-list"].id]
    ),
  )
    
  private_wls_security_list_id = compact(
    concat(
      [module.network-security-lists.security_lists["${var.service_name}-wls-bastion-security-list"].id],
      [module.network-security-lists.security_lists["${var.service_name}-internal-security-list"].id],
      [module.network-security-lists.security_lists["${var.service_name}-wls-ms-security-list"].id]
    ),
  )
  
  public_wls_security_list_id = compact(
    concat(
      [module.network-security-lists.security_lists[!local.assign_weblogic_public_ip ? "${var.service_name}-bastion-security-list" : "${var.service_name}-wls-security-list"].id],
      [module.network-security-lists.security_lists["${var.service_name}-wls-ms-security-list"].id],
      [module.network-security-lists.security_lists["${var.service_name}-internal-security-list"].id]
    ),
  )
  
  exists_lb_subnet = var.add_load_balancer && var.lb_subnet_id == "" ? true : false
  exists_lb_backend_subnet = var.add_load_balancer && var.lb_subnet_backend_id == "" && ! var.is_lb_private && ! local.use_regional_subnet && ! local.is_single_ad_region ? true : false
  exists_bastion_subnet = ! local.assign_weblogic_public_ip && var.bastion_subnet_id == "" && var.is_bastion_instance_required && var.existing_bastion_instance_id == "" ? true : false
  exists_wls_private_subnet = ! local.assign_weblogic_public_ip && var.wls_subnet_id == "" ? true : false
  exists_wls_public_subnet = local.assign_weblogic_public_ip && var.wls_subnet_id == "" ? true : false

  lb_subnet = {
        exists = {compartment_id=local.network_compartment_id, 
                  availability_domain=var.use_regional_subnet? "" : var.lb_subnet_1_availability_domain_name,
                  cidr = local.lb_subnet_subnet_cidr,
                  dns_label = replace(format("%s-%s", local.lb_subnet_name, substr(strrev(var.service_name), 0, 7)), "-",""),
                  private=var.is_lb_private,
                  dhcp_options_id=module.network-dhcp-options.dhcp_options["${var.service_name}-${var.dhcp_options_name}"].id,
                  security_list_ids=[module.network-security-lists.security_lists["${var.service_name}-lb-security-list"].id],
                  defined_tags=local.defined_tags,
                  freeform_tags=local.freeform_tags}
        not_exists = {compartment_id="", availability_domain="", cidr="", dns_label="",private=false,dhcp_options_id="",security_list_ids=[""], defined_tags={}, freeform_tags={}}

    }

  lb_subnet_backend = {
        exists = {compartment_id=local.network_compartment_id, 
                  availability_domain=var.use_regional_subnet? "" : var.lb_subnet_2_availability_domain_name,
                  cidr = local.lb_subnet_backend_subnet_cidr,
                  dns_label=replace(format("%s-%s", local.lb_subnet_name, substr(strrev(var.service_name), 0, 7)), "-",""),
                  private=var.is_lb_private,
                  dhcp_options_id=module.network-dhcp-options.dhcp_options["${var.service_name}-${var.dhcp_options_name}"].id,
                  security_list_ids=[module.network-security-lists.security_lists["${var.service_name}-lb-security-list"].id],
                  defined_tags=local.defined_tags,
                  freeform_tags=local.freeform_tags}
        not_exists = {compartment_id="", availability_domain="", cidr="", dns_label="",private=false,dhcp_options_id="",security_list_ids=[""], defined_tags={}, freeform_tags={}}

    }

  bastion = {
       exists = {compartment_id=local.network_compartment_id, 
                 availability_domain=var.use_regional_subnet? "" : local.bastion_availability_domain,
                 cidr = local.bastion_subnet_cidr,
                 dns_label=replace("${var.bastion_subnet_name}-${substr(uuid(), -7, -1)}", "-",""),
                 private=var.is_lb_private,
                 dhcp_options_id=module.network-dhcp-options.dhcp_options["${var.service_name}-${var.dhcp_options_name}"].id,
                 security_list_ids=local.bastion_security_list_id,
                 defined_tags=local.defined_tags,
                 freeform_tags=local.freeform_tags}
        not_exists = {compartment_id="", availability_domain="", cidr="", dns_label="",private=false,dhcp_options_id="",security_list_ids=[""], defined_tags={}, freeform_tags={}}
    }

  wls_private = {
          exists = {compartment_id=local.network_compartment_id, 
                    availability_domain=var.use_regional_subnet? "" : var.wls_availability_domain_name,
                    cidr = local.wls_subnet_cidr,
                    dns_label=replace(format("%s-%s", var.wls_subnet_name, substr(strrev(var.service_name), 0, 7)), "-",""),
                    private=true,
                    dhcp_options_id=module.network-dhcp-options.dhcp_options["${var.service_name}-${var.dhcp_options_name}"].id,
                    security_list_ids=local.private_wls_security_list_id,
                    defined_tags=local.defined_tags,
                    freeform_tags=local.freeform_tags}
          not_exists={compartment_id="", availability_domain="", cidr="", dns_label="",private=false,dhcp_options_id="",security_list_ids=[""], defined_tags={}, freeform_tags={}}
    }

  wls_public = {
          exists =  {compartment_id=local.network_compartment_id, 
                     availability_domain=var.use_regional_subnet? "" : var.wls_availability_domain_name,
                     cidr = local.wls_subnet_cidr,
                     dns_label=replace(format("%s-%s", var.wls_subnet_name, substr(strrev(var.service_name), 0, 7)), "-","")
                     private=false,
                     dhcp_options_id=module.network-dhcp-options.dhcp_options["${var.service_name}-${var.dhcp_options_name}"].id,
                     security_list_ids=local.public_wls_security_list_id,
                     defined_tags=local.defined_tags,
                     freeform_tags=local.freeform_tags}
          not_exists = {compartment_id="", availability_domain="", cidr="", dns_label="",private=false,dhcp_options_id="",security_list_ids=[""], defined_tags={}, freeform_tags={}}
    }

  existing_lb_subnet = local.lb_subnet[local.exists_lb_subnet ? "exists" : "not_exists"]
  existing_lb_backend_subnet = local.lb_subnet_backend[local.exists_lb_backend_subnet ? "exists": "not_exists"]
  existing_bastion_subnet = local.bastion[local.exists_bastion_subnet ? "exists" : "not_exists"]
  existing_wls_private_subnet = local.wls_private[local.exists_wls_private_subnet ? "exists" : "not_exists"]
  existing_wls_public_subnet = local.wls_public[local.exists_wls_public_subnet ? "exists" : "not_exists"]

  create_subnets = {"${local.service_name_prefix}-${local.lb_subnet_name}"=local.existing_lb_subnet,"${local.service_name_prefix}-${local.lb_subnet_backend_name}"=local.existing_lb_backend_subnet,"${local.service_name_prefix}-${var.bastion_subnet_name}"=local.existing_bastion_subnet,"${local.service_name_prefix}-${var.wls_subnet_name}-private"=local.existing_wls_private_subnet, "${local.service_name_prefix}-${var.wls_subnet_name}-public"=local.existing_wls_public_subnet}

  #for security rules
  port_for_ingress_lb_security_list = 443
  lb_destination_cidr               = var.is_lb_private ? var.bastion_subnet_cidr : var.anywhere_cidr

  #if LB is requested and regional or single ad region, source: single lb subnet cidr
  #if LB is requested and non regional,  source: primary and secondary lb subnet cidrs
  #if no lb open it to anywhere,  source:"0.0.0.0/0"
  wls_ms_source_cidrs         = var.add_load_balancer ? ((local.use_regional_subnet || local.is_single_ad_region) ? [var.lb_subnet_cidr] : [var.lb_subnet_cidr, var.lb_subnet_backend_cidr]) : [var.anywhere_cidr]
  wls_admin_port_source_cidrs = var.wls_expose_admin_port ? [var.wls_admin_port_source_cidr] : []

  wls-security-list-def  = {
    exists = {
        vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id,
        compartment_id = local.network_compartment_id,
        defined_tags = local.defined_tags,
        ingress_rules = concat([
          {
            stateless     = false,
            protocol      = "6",
            src           = var.anywhere_cidr,
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 22, max = 22},
            icmp_type     = null,
            icmp_code     = null
        }],[for x in range(length (local.wls_admin_port_source_cidrs)) :
          {
            stateless = false
            protocol  = "6" // tcp
            src    = local.wls_admin_port_source_cidrs[x]
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = var.wls_ssl_admin_port, max=var.wls_ssl_admin_port},
            icmp_type     = null,
            icmp_code     = null
          }]),
        egress_rules = [
         {
           stateless     = false,
           protocol      = "all",
           dst           = var.anywhere_cidr,
           dst_type      = "CIDR_BLOCK",
           src_port      = null,
            dst_port     = null,
            icmp_type    = null,
            icmp_code    = null
         }]
        }
    not_exists = {vcn_id="", compartment_id="", defined_tags = {}, ingress_rules=[], egress_rules=[]}
    }

    wls-internal-security-list-def = {
       exists = {
        vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id,
        compartment_id = local.network_compartment_id,
        defined_tags = local.defined_tags,
        ingress_rules = [
          {
            stateless     = false,
            protocol      = "6",
            src           = var.wls_subnet_cidr,
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = null,
            icmp_type     = null,
            icmp_code     = null
        }],
        egress_rules = [
         {
           stateless     = false,
           protocol      = "all",
           dst           = var.anywhere_cidr,
           dst_type      = "CIDR_BLOCK",
           src_port      = null,
            dst_port     = null,
            icmp_type    = null,
            icmp_code    = null
         }]
        }
       not_exists = {vcn_id="", compartment_id="", defined_tags = {}, ingress_rules=[], egress_rules=[]}
    }

    wls-ms-security-list-def = {
       exists = {
        vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id,
        compartment_id = local.network_compartment_id,
        defined_tags = local.defined_tags,
        ingress_rules = concat([for x in range(length (local.wls_ms_source_cidrs)) :
          {
            stateless = false
            protocol  = "6" // tcp
            src    = local.wls_ms_source_cidrs[x]
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = var.add_load_balancer ? var.wls_ms_extern_port : var.wls_ms_extern_ssl_port, max=var.add_load_balancer ? var.wls_ms_extern_port : var.wls_ms_extern_ssl_port},
            icmp_type     = null,
            icmp_code     = null
          }],
          [for x in range(length (local.wls_ms_source_cidrs)) :
          {
            stateless = false
            protocol  = "6" // tcp
            src    = local.wls_ms_source_cidrs[x]
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = var.is_idcs_selected ? var.idcs_cloudgate_port: var.wls_ms_extern_ssl_port, max=var.is_idcs_selected ? var.idcs_cloudgate_port : var.wls_ms_extern_ssl_port},
            icmp_type     = null,
            icmp_code     = null
          }]),
        egress_rules = []
        }
       not_exists = {vcn_id="", compartment_id="", defined_tags = {}, ingress_rules=[], egress_rules=[]}
    }

     lb-security-list-def = {
       exists = {
        vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id,
        compartment_id = local.network_compartment_id,
        defined_tags = local.defined_tags,
        ingress_rules = [
          {
            stateless     = false,
            protocol      = "6",
            src           = local.lb_destination_cidr
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min=local.port_for_ingress_lb_security_list, max=local.port_for_ingress_lb_security_list},
            icmp_type     = null,
            icmp_code     = null
        }],
        egress_rules = [
         {
           stateless     = false,
           protocol      = "all",
           dst           = var.anywhere_cidr,
           dst_type      = "CIDR_BLOCK",
           src_port      = null,
            dst_port     = null,
            icmp_type    = null,
            icmp_code    = null
         }]
        }
       not_exists = {vcn_id="", compartment_id="", defined_tags = {}, ingress_rules=[], egress_rules=[]}
    }

    wls-bastion-security-list-def = {
       exists = {
        vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id,
        compartment_id = local.network_compartment_id,
        defined_tags = local.defined_tags,
        ingress_rules = [
          {
            stateless     = false,
            protocol      = "6",
            src           = var.bastion_subnet_cidr
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = null,
            icmp_type     = null,
            icmp_code     = null
        }],
        egress_rules = [
         {
           stateless     = false,
           protocol      = "all",
           dst           = var.anywhere_cidr,
           dst_type      = "CIDR_BLOCK",
           src_port      = null,
            dst_port     = null,
            icmp_type    = null,
            icmp_code    = null
         }]
        }
       not_exists = {vcn_id="", compartment_id="", defined_tags = {}, ingress_rules=[], egress_rules=[]}
    }

    wls-security-list = local.wls-security-list-def[local.use_existing_subnets ? "not_exists" : "exists"]
    wls-internal-security-list = local.wls-internal-security-list-def[local.use_existing_subnets ? "not_exists" : "exists"]
    wls-ms-security-list = local.wls-ms-security-list-def[local.use_existing_subnets ? "not_exists" : "exists"]
    lb-security-list = local.lb-security-list-def[var.add_load_balancer && local.use_existing_subnets == false ? "exists" : "not_exists"]
    wls-bastion-security-list = local.wls-bastion-security-list-def[!local.assign_weblogic_public_ip && !local.use_existing_subnets && var.existing_bastion_instance_id =="" && var.is_bastion_instance_required ? "exists" : "not_exists"]
  
    wls-security-lists = {    
     !local.assign_weblogic_public_ip ? "${var.service_name}-bastion-security-list" : "${var.service_name}-wls-security-list" = local.wls-security-list,
     "${var.service_name}-internal-security-list" = local.wls-internal-security-list,
     "${var.service_name}-wls-ms-security-list" = local.wls-ms-security-list,
     "${var.service_name}-lb-security-list" = local.lb-security-list,
     "${var.service_name}-wls-bastion-security-list" = local.wls-bastion-security-list
    }

#for policies
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
  atp_policy_statement = ((local.atp_db.is_atp || var.app_atp_db_id != "") && var.create_policies) ? "Allow dynamic-group ${local.principal_group} to manage autonomous-transaction-processing-family in compartment id ${var.compartment_ocid}" : ""

   wls-dynamic_groups = {
      "${local.service_name_prefix}-principal-group" = var.create_policies ? {
        description = "dynamic group to allow access to resources"
        compartment_id = var.tenancy_ocid
        matching_rule = "ALL { ${format("instance.compartment.id='%s'", var.compartment_ocid)} }"
      } : {description = "", compartment_id="", matching_rule=""},
      "${local.service_name_prefix}-osms-instance-principal-group" = var.create_policies ? {
        description    = "dynamic group to allow instances to call osms services"
        compartment_id = var.tenancy_ocid
        matching_rule  = format("ANY { %s }",join(", ", formatlist("instance.id='%s'",compact(concat([module.bastion.id])))))
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
    "${local.service_name_prefix}-atp-policy" = (local.atp_db.is_atp || var.app_atp_db_id != "") && var.create_policies ? {
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

}


