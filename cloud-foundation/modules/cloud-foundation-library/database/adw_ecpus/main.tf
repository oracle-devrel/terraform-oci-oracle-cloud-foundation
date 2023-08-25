# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  adw_download_wallet = { for key, value in var.adw_params : key => value if value.create_local_wallet == true }
}

resource "oci_database_autonomous_database_wallet" "autonomous_database_wallet" {
  for_each               = var.adw_params
  autonomous_database_id = oci_database_autonomous_database.adw[each.key].id
  password               = each.value.database_wallet_password
  base64_encode_content  = "true"
}

resource "local_file" "autonomous_data_warehouse_wallet_file" {
  for_each       = local.adw_download_wallet
  content_base64 = oci_database_autonomous_database_wallet.autonomous_database_wallet[each.key].content
  filename       = "${path.cwd}/wallet_${each.value.db_name}.zip"
}

resource "oci_database_autonomous_database" "adw" {
  for_each                    = var.adw_params
  admin_password              = each.value.database_admin_password
  compartment_id              = each.value.compartment_id
	compute_model               = each.value.compute_model
	compute_count               = each.value.compute_count
  data_storage_size_in_tbs    = each.value.size_in_tbs
  db_name                     = each.value.db_name
  display_name                = each.value.db_name
  db_workload                 = each.value.db_workload
  db_version                  = each.value.db_version
  license_model               = each.value.license_model
  is_mtls_connection_required = each.value.is_mtls_connection_required
  subnet_id                   = each.value.subnet_id
  nsg_ids                     = each.value.nsg_ids 
  defined_tags                = each.value.defined_tags
  is_auto_scaling_enabled     = each.value.enable_auto_scaling
  is_free_tier                = each.value.is_free_tier
}
