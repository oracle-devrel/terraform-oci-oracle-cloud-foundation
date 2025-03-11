# Copyright © 2025, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "adw_params" {
  type = map(object({
    compartment_id              = string
	  compute_model               = string
	  compute_count               = number
    size_in_tbs                 = number
    db_name                     = string
    db_workload                 = string
    db_version                  = string
    license_model               = string
    database_admin_password     = string
    database_wallet_password    = string
    enable_auto_scaling         = bool
    is_free_tier                = bool
    create_local_wallet         = bool
    is_mtls_connection_required = bool
    subnet_id                   = string
    data_safe_status            = string
    operations_insights_status  = string
    database_management_status  = string
    nsg_ids                     = list(string)
    defined_tags                = map(string)
  }))
}
