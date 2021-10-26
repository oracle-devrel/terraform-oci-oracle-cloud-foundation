# # Copyright © 2021, Oracle and/or its affiliates.
# # All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_database_autonomous_database" "adw" {
  for_each = {
    for k,v in var.adw_params : k => v if v.compartment_id != ""
  } 
  admin_password           = each.value.database_admin_password
  compartment_id           = each.value.compartment_id
  cpu_core_count           = each.value.adw_cpu_core_count
  data_storage_size_in_tbs = each.value.adw_size_in_tbs
  db_name                  = each.value.adw_db_name
  display_name             = each.value.adw_db_name
  db_workload              = each.value.adw_db_workload
  db_version               = each.value.adw_db_version
  is_auto_scaling_enabled  = each.value.adw_enable_auto_scaling
  is_free_tier             = each.value.adw_is_free_tier
  license_model            = each.value.adw_license_model
  # subnet_id                = each.value.subnet_id
  # nsg_ids                  = each.value.nsg_ids 
  defined_tags             = each.value.defined_tags
}

resource "oci_database_autonomous_database_wallet" "autonomous_data_warehouse_wallet" {
  for_each               = var.adw_params
  autonomous_database_id = oci_database_autonomous_database.adw[each.key].id
  password               = each.value.database_wallet_password
  base64_encode_content  = true
}

