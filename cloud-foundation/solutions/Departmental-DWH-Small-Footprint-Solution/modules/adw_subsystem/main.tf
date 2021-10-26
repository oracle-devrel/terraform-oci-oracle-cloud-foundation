# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "adw" {
  source = "../../../../../cloud-foundation/modules/cloud-foundation-library/database/adw"
  adw_params = { 
    adw = {
      compartment_id              = var.compartment_id,
      adw_cpu_core_count          = var.adw_cpu_core_count,
      adw_size_in_tbs             = var.adw_size_in_tbs,
      adw_db_name                 = var.adw_db_name,
      adw_db_workload             = var.adw_db_workload,
      adw_db_version              = var.adw_db_version,
      adw_enable_auto_scaling     = var.adw_enable_auto_scaling,
      adw_is_free_tier            = var.adw_is_free_tier,
      adw_license_model           = var.adw_license_model,
      database_admin_password     = var.database_admin_password,
      database_wallet_password    = var.database_wallet_password,
      # subnet_id                   = var.subnet_ocid,
      # nsg_ids                     = var.nsg_ids,
      defined_tags                = var.defined_tags
  },
 }
}

  

  