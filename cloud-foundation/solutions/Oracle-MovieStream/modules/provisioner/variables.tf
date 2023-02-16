# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "host" {}

variable "private_key" {}

variable "atp_url" {
    default = ""
}

variable "db_password" {
    default = ""
}

variable "conn_db" {
    default = ""
}

variable "db_name" {
  default = ""
}

variable "dbhostname" {
  default = ""
}

# variable "tag" {
#   default = ""
# }

# variable "run_post_load_procedures" {
#   default = ""
# }