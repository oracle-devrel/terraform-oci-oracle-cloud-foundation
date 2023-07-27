# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "database_db_home" {
  type = map(object({
    admin_password   = string
    defined_tags     = map(string)
    freeform_tags    = map(string)
    db_version       = string
    display_name     = string
    db_name          = string
    source           = string
    vm_cluster_id    = string
  }))
}
