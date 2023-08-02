# # Copyright © 2023, Oracle and/or its affiliates.
# # All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "adw_params" {
  type = map(object({
    compartment_id           = string
    adw_cpu_core_count       = number
    adw_size_in_tbs          = number
    adw_db_name              = string
    adw_db_workload          = string
    adw_db_version           = string
    adw_enable_auto_scaling  = bool
    adw_is_free_tier         = bool
    adw_license_model        = string
    data_safe_status         = string
    database_admin_password  = string
    database_wallet_password = string
    subnet_id                = string
    nsg_ids                  = list(string)
    defined_tags             = map(string)
  }))
}


    
    

    