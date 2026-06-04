# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "org_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "atlas_region" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = false
}

variable "database_name" {
  type = string
}

# variable "allowed_cidr_block" {
#   type = string
# }