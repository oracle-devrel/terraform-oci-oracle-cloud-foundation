# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


terraform {
  required_version = ">= 0.15.0"
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

# Autonomous Database Configuration Variables

variable "db_name" {
  type    = string
  default = "ADWoipna"
}

variable "db_password" {
  type = string
  default = "<your-passwsord-here>"
}

variable "db_compute_model" {
  type    = string
  default = "ECPU"
}

variable "db_compute_count" {
  type = number
  default = 4
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
  default = "BRING_YOUR_OWN_LICENSE"
}

variable "db_data_safe_status" {
  type = string
  default = "NOT_REGISTERED"
}

variable "db_operations_insights_status" {
  type = string
  default = "NOT_ENABLED"
}

variable "db_database_management_status" {
  type = string
  default = "ENABLED"
}

# Object Storage Bucket

variable "logging_logs_bucket_name" {
    type    = string
    default = "Logging_Logs_bucket"
}

variable "logging_logs_access_type" {
    type    = string
    default  = "NoPublicAccess"
}

variable "logging_logs_storage_tier" {
    type    = string
    default = "Standard"
}
  
variable "logging_logs_events_enabled" {
    type    = bool
    default = false
}

# Networking variables

# VCN and subnet Variables

variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "service_name" {
  type        = string
  default     = "monitoringlevel1"
  description = "A prefix for policies and dynamic groups names - scope: to be unique names not duplicates"
}

# # End
