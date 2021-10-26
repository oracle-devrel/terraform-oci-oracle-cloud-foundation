# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {}
variable "adw_cpu_core_count" {}
variable "adw_size_in_tbs" {}
variable "adw_db_name" {}
variable "adw_db_workload" {}
variable "adw_db_version" {}
variable "adw_enable_auto_scaling" {}
variable "adw_is_free_tier" {}
variable "adw_license_model" {}
variable "database_admin_password" {}
variable "database_wallet_password" {}

# variable "subnet_ocid" {}

# variable "nsg_ids" {
#   type = list(string)
#   default = []
# }

variable "defined_tags" {
  type    = map
  default = {}
}
