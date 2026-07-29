# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_regions" "regions" {
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
  effective_oci_private_key_pem = (
    trimspace(var.oci_private_key_pem) != "" ? trimspace(var.oci_private_key_pem) :
    trimspace(var.private_key_path) != "" ? trimspace(file(var.private_key_path)) :
    ""
  )

  # Create Autonomous Data Warehouse
  adw_params = {
    adw = {
      compartment_id              = var.compartment_id
      compute_model               = var.adw_db_compute_model
      compute_count               = var.adw_db_compute_count
      size_in_tbs                 = var.adw_db_size_in_tbs
      db_name                     = var.adw_db_name
      db_workload                 = var.adw_db_workload
      db_version                  = var.adw_db_version
      enable_auto_scaling         = var.adw_db_enable_auto_scaling
      is_free_tier                = var.adw_db_is_free_tier
      license_model               = var.adw_db_license_model
      create_local_wallet         = true
      database_admin_password     = var.adw_db_password
      database_wallet_password    = var.adw_db_password
      data_safe_status            = var.adw_db_data_safe_status
      operations_insights_status  = var.adw_db_operations_insights_status
      database_management_status  = var.adw_db_database_management_status
      is_mtls_connection_required = null
      subnet_id                   = null
      nsg_ids                     = null
      defined_tags                = {}
    },
  }

  # Create Object Storage Buckets
  bucket_params = {
    ai_files_bucket = {
      compartment_id = var.compartment_id
      name           = var.files_bucket_name
      access_type    = var.files_bucket_access_type
      storage_tier   = var.files_bucket_storage_tier
      events_enabled = var.files_bucket_events_enabled
      defined_tags   = {}
    }
  }

# End

}