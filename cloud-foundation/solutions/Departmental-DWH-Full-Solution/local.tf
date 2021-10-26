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

data "oci_core_services" "tf_services" {
  filter {
    name   = "cidr_block"
    values = ["all-.*-services-in-oracle-services-network"]
    regex  = true
  }
}

# resource "oci_identity_tag_namespace" "namespace" {
#    provider       = oci
#    compartment_id = var.compartment_id
#    description    = "cloudfoundationorcl"
#    name           = "cloudfoundationorcl-deploy-adw-oac"
   
#    provisioner "local-exec" {
#      command = "sleep 60"
#   }
# }

# resource "oci_identity_tag" "release" {
#     provider         = oci
#     description      = "release"
#     name             = "release"
#     tag_namespace_id = oci_identity_tag_namespace.namespace.id

#   provisioner "local-exec" {
#     command = "sleep 60"
#   }
# }

# resource "oci_identity_tag" "solution" {
#     provider         = oci
#     description      = "solution"
#     name             = "solution"
#     tag_namespace_id = oci_identity_tag_namespace.namespace.id

#   provisioner "local-exec" {
#     command = "sleep 60"
#   }
# }

# resource "oci_identity_tag" "subsystem" {
#     provider         = oci
#     description      = "subsystem"
#     name             = "subsystem"
#     tag_namespace_id = oci_identity_tag_namespace.namespace.id

#   provisioner "local-exec" {
#     command = "sleep 60"
#   }
# }

# resource "oci_identity_tag" "module" {
#     provider         = oci
#     description      = "module"
#     name             = "module"
#     tag_namespace_id = oci_identity_tag_namespace.namespace.id

#   provisioner "local-exec" {
#     command = "sleep 60"
#   }
# }

locals {

# #   # Remove all characters from the service_name that dont satisfy the criteria:
# #   # must start with letter, must only contain letters and numbers and length between 1,8
# #   # See https://github.com/google/re2/wiki/Syntax - regex syntax supported by replace()
  service_name_prefix = replace(var.service_name, "/[^a-zA-Z0-9]/", "")
  # #   #Availability Domains
  ad_names                    = compact(data.template_file.ad_names.*.rendered)
  public_subnet_availability_domain = local.ad_names[0]

  num_ads = length(
    data.oci_identity_availability_domains.ADs.availability_domains,
  )

  is_single_ad_region = local.num_ads == 1 ? true : false
  use_existing_subnets    = false
  is_vcn_peering = false
  vcnsCount = var.vcn_name !="" && local.use_existing_subnets==false ? 1:0
  assign_public_ip = var.assign_public_ip || var.subnet_type == "Use Public Subnet" ? true : false

  public_subnet_cidr     = var.public_subnet_cidr == "" && var.vcn_name != "" && ! local.assign_public_ip ? local.is_vcn_peering ? "11.0.6.0/24" : "10.0.6.0/24" : var.public_subnet_cidr
  private_subnet_cidr    = var.private_subnet_cidr == "" && var.vcn_name != "" ? local.is_vcn_peering ? "11.0.3.0/24" : "10.0.3.0/24" : var.private_subnet_cidr
  
  public_subnet = {
       exists = {compartment_id=var.compartment_id, 
                 availability_domain=var.use_regional_subnet? "" : local.public_subnet_availability_domain,
                 cidr = local.public_subnet_cidr,
                 dns_label=replace("${var.public_subnet_name}-${substr(uuid(), -7, -1)}", "-",""),
                 private=false,
                 dhcp_options_id=module.network-dhcp-options.dhcp_options["${var.service_name}-${var.dhcp_options_name}"].id,
                 security_list_ids=local.public_security_list_id,
                 defined_tags=local.defined_tags,
                #  defined_tags=var.network_defined_tags,
                #  defined_tags  = { "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.release.name}" = "1.0",
                #                    "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.subsystem.name}" = "network",
                #                    "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.module.name}" = "vcn-basic"
                #                  }
                 freeform_tags=local.freeform_tags}
        not_exists = {compartment_id="", availability_domain="", cidr="", dns_label="",private=false,dhcp_options_id="",security_list_ids=[""], defined_tags={}, freeform_tags={}}
    }

  private_subnet = {
          exists = {compartment_id=var.compartment_id, 
                    availability_domain=var.use_regional_subnet? "" : var.private_subnet_availability_domain_name,
                    cidr = local.private_subnet_cidr,
                    dns_label=replace(format("%s-%s", var.private_subnet_name, substr(strrev(var.service_name), 0, 7)), "-",""),
                    private=true,
                    dhcp_options_id=module.network-dhcp-options.dhcp_options["${var.service_name}-${var.dhcp_options_name}"].id,
                    security_list_ids=local.private_security_list_id,
                    defined_tags=local.defined_tags,
                    # defined_tags=var.network_defined_tags,
                    # defined_tags  = { "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.release.name}" = "1.0",
                    #                   "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.subsystem.name}" = "network",
                    #                   "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.module.name}" = "vcn-basic"
                    #                 }
                    freeform_tags=local.freeform_tags}
          not_exists={compartment_id="", availability_domain="", cidr="", dns_label="",private=false,dhcp_options_id="",security_list_ids=[""], defined_tags={}, freeform_tags={}}
    }

  exists_public_subnet = ! local.assign_public_ip && var.public_subnet_id == "" ? true : false  
  exists_private_subnet = ! local.assign_public_ip && var.private_subnet_id == "" ? true : false

  existing_public_subnet = local.public_subnet[local.exists_public_subnet ? "exists" : "not_exists"]
  existing_private_subnet = local.private_subnet[local.exists_private_subnet ? "exists" : "not_exists"]

create_subnets = {"${local.service_name_prefix}-${var.public_subnet_name}"=local.existing_public_subnet,"${local.service_name_prefix}-${var.private_subnet_name}"=local.existing_private_subnet}

# Security Lists 

  public-security-list-def  = {
    exists = {
        vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id,
        compartment_id = var.compartment_id, 
        defined_tags=local.defined_tags,
        # defined_tags = var.security_defined_tags,
        # defined_tags  = { "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.release.name}" = "1.0",
        #                 "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.subsystem.name}" = "network",
        #                 "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.module.name}" = "security"                    
        #                 }
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
        }],
        [
          {
            stateless     = false,
            protocol      = "6",
            src           = var.anywhere_cidr,
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 80, max = 80},
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

    private-security-list-def = {
       exists = {
        vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id,
        compartment_id = var.compartment_id,
        defined_tags=local.defined_tags,
        # defined_tags = var.security_defined_tags,
        # defined_tags  = { "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.release.name}" = "1.0",
        #                 "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.subsystem.name}" = "network",
        #                 "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.module.name}" = "security"                    
        #                 }
        ingress_rules = [
          {
            stateless     = false,
            protocol      = "6",
            src           = var.public_subnet_cidr,
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

  public_security_list_id = compact(
    concat(
      [module.network-security-lists.security_lists["${var.service_name}-public-security-list"].id],
    ),
  )
    
 private_security_list_id = compact(
    concat(
      [module.network-security-lists.security_lists["${var.service_name}-private-security-list"].id],
    ),
  )

    public-security-list = local.public-security-list-def[local.use_existing_subnets ? "not_exists" : "exists"]
    private-security-list = local.private-security-list-def[local.use_existing_subnets ? "not_exists" : "exists"]
  
    security-lists = {    
     !local.assign_public_ip ? "${var.service_name}-public-security-list" : "${var.service_name}-public-security-list" = local.public-security-list,
     "${var.service_name}-private-security-list" = local.private-security-list,
    }


# NSG:
  public-nsgs-list-def  = {
    exists = {
      vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id,
      compartment_id = var.compartment_id,
      defined_tags=local.defined_tags,
      # defined_tags = var.security_defined_tags,
      # defined_tags  = { "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.release.name}" = "1.0",
      #                  "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.subsystem.name}" = "network",
      #                  "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.module.name}" = "security"                    
      # }
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
        dst          = var.anywhere_cidr,
        dst_type     = "CIDR_BLOCK",
        dst_port_min = null,
        dst_port_max = null,
        src_port_min = null,
        src_port_max = null,
        icmp_type    = null,
        icmp_code    = null
      }},
      }
    not_exists = {vcn_id="", ingress_rules=[], egress_rules=[]}
  }

### 
  private-nsgs-list-def = {
    exists = {
      vcn_id = lookup(module.network-vcn.vcns,"${var.service_name}-${var.vcn_name}").id,
      compartment_id = var.compartment_id,
      defined_tags=local.defined_tags,
      # defined_tags = var.security_defined_tags,
      # defined_tags  = { "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.release.name}" = "1.0",
      #                  "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.subsystem.name}" = "network",
      #                  "${oci_identity_tag_namespace.namespace.name}.${oci_identity_tag.module.name}" = "security"                    
      # }
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
        dst          = var.anywhere_cidr,
        dst_type     = "CIDR_BLOCK",
        dst_port_min = null,
        dst_port_max = null,
        src_port_min = null,
        src_port_max = null,
        icmp_type    = null,
        icmp_code    = null
      }}
      }
    not_exists = {vcn_id="", ingress_rules=[], egress_rules=[]}
  }


  public_nsg_list_id = compact(
    concat(
      [module.network-security-groups.nsgs["${var.service_name}-public-nsg-list"].id],
    ),
  )

   private_nsg_list_id = compact(
    concat(
      [module.network-security-groups.nsgs["${var.service_name}-private-nsg-list"].id],
    ),
  )

  public-nsg-list = local.public-nsgs-list-def[local.use_existing_subnets ? "not_exists" : "exists"]
  private-nsg-list = local.private-nsgs-list-def[local.use_existing_subnets ? "not_exists" : "exists"]
  nsgs-lists = {!local.assign_public_ip ? "${var.service_name}-public-nsg-list" : "${var.service_name}-public-nsg-list" = local.public-nsg-list,
     "${var.service_name}-private-nsg-list" = local.private-nsg-list,
  }

# Tags

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

}

