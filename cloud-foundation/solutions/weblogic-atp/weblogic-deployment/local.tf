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

locals {

  compartment_ocid = var.compartment_ocid
  is_atp_db        = trimspace(var.atp_db_id) == "" ? false : true
  create_atp_db    = trimspace(var.atp_db_password_ocid) != "" && local.is_atp_db == false ? true : false 
  is_atp_appdb     = trimspace(var.app_atp_db_id) == "" ? false : true
  home_region      = lookup(data.oci_identity_regions.home-region.regions[0], "name")

  // Deploy sample-app only if the edition is not SE
  deploy_sample_app = (var.deploy_sample_app && var.wls_edition != "SE")

  // Default DB user for ATP DB is admin
  db_user                      = local.is_atp_db || local.create_atp_db ? "ADMIN" : ""
  db_password                  = local.is_atp_db || local.create_atp_db ? var.atp_db_password_ocid : ""

  assign_weblogic_public_ip = var.assign_weblogic_public_ip ? true : false
  image_version        = var.image_version
  use_existing_subnets    = var.wls_subnet_id == "" && var.lb_subnet_id == "" && var.lb_subnet_backend_id == "" ? false : true

  # Remove all characters from the service_name that dont satisfy the criteria:
  # must start with letter, must only contain letters and numbers and length between 1,8
  # See https://github.com/google/re2/wiki/Syntax - regex syntax supported by replace()
  service_name_prefix = replace(var.service_name, "/[^a-zA-Z0-9]/", "")

  requires_JRF            = local.create_atp_db || local.is_atp_db ? true : false
  prov_type               = local.requires_JRF ? local.is_atp_db || local.create_atp_db ? "(JRF with ATP DB)" : "" : "(Non JRF)"
  use_regional_subnet     = var.use_regional_subnet
  network_compartment_id  = var.network_compartment_id == "" ? var.compartment_ocid : var.network_compartment_id


  #Availability Domains
  ad_names                    = compact(data.template_file.ad_names.*.rendered)
  #for existing wls subnet, get AD from the subnet
  wls_availability_domain      = local.use_regional_subnet ? local.ad_names[0] : (var.wls_subnet_id == "" ? var.wls_availability_domain_name : data.oci_core_subnet.wls_subnet[0].availability_domain)
  lb_availability_domain_name = var.lb_subnet_id != "" ? (local.use_regional_subnet ? "" : data.oci_core_subnet.lb_subnet_id[0].availability_domain) : var.lb_subnet_1_availability_domain_name
  lb_backend_availability_domain_name = var.lb_subnet_backend_id != "" ? (local.use_regional_subnet ? "" : data.oci_core_subnet.lb_subnet_backend_id[0].availability_domain) : var.lb_subnet_2_availability_domain_name

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
    is_atp         = local.create_atp_db ? true : local.is_atp_db
    compartment_id = var.atp_db_compartment_id
  }

  lbCount = var.add_load_balancer ? 1 : 0

}
