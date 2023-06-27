# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


terraform {
  required_version = ">= 0.14.0"
}

variable "tenancy_ocid" {
  type = string
  default = ""
}

variable "region" {
    type = string
    default = ""
}

variable "compartment_id" {
  type = string
  default = ""
}

variable "user_ocid" {
    type = string
    default = ""
}

variable "fingerprint" {
    type = string
    default = ""
}

variable "private_key_path" {
    type = string
    default = ""
}

# ADW Database Variables:

variable "db_name" {
  type    = string
  default = "MovieStreamWorkshop"
}

variable "db_password" {
  type = string
  default = "WlsAtpDb1234#"
}

variable "db_cpu_core_count" {
  type = number
  default = 1
}

variable "db_size_in_tbs" {
  type = number
  default = 1
}

variable "db_workload" {
  type = string
  default = "DW"
}

variable "db_version" {
  type = string
  default = "19c"
}

variable "db_enable_auto_scaling" {
  type = bool
  default = true
}

variable "db_is_free_tier" {
  type = bool
  default = false
}

variable "db_license_model" {
  type = string
  default = "LICENSE_INCLUDED"
}


variable "tag" {
  type    = string
  #default = "graph-get-started"
  default = "end-to-end"
}

variable "run_post_load_procedures" {
  type    = bool
  #default = false
  default = true
}