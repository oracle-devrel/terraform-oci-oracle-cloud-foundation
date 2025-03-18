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

locals{
  ad_names = compact(data.template_file.ad_names.*.rendered)
  conn_db  = module.adb.db_connection[0].profiles[1].value

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

# End

}
