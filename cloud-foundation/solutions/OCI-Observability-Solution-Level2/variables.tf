# Copyright © 2022, Oracle and/or its affiliates.
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

# Autonomous Database Configuration Variables

variable "adw_cpu_core_count" {
    type = number
    default = 1
}

variable "adw_size_in_tbs" {
    type = number
    default = 1
}

variable "adw_db_name" {
    type = string
    default = "ADWoipnm"
}

variable "adw_db_workload" {
    type = string
    default = "DW"
}

variable "adw_db_version" {
    type = string
    default = "19c"
}

variable "adw_enable_auto_scaling" {
    type = bool
    default = true
}

variable "adw_is_free_tier" {
    type = bool
    default = false
}

variable "adw_license_model" {
    type = string
    default = "BRING_YOUR_OWN_LICENSE"
}

variable "database_admin_password" {
  type = string
  default = "<your-passwsord-here>"
}

variable "database_wallet_password" {
  type = string
  default = "<your-passwsord-here>"
}

variable "adw_data_safe_status" {
  type = string
  default = "REGISTERED"
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

variable "sch_logs_bucket_name" {
    type    = string
    default = "Sch_Logs_bucket"
}

variable "sch_logs_access_type" {
    type    = string
    default  = "NoPublicAccess"
}

variable "sch_logs_storage_tier" {
    type    = string
    default = "Standard"
}
  
variable "sch_logs_events_enabled" {
    type    = bool
    default = false
}

# Variable for the database management service - managed group - required for the ansible module

variable "managed_database_group_name" {
  type    = string
  default = "My_manage_Group"
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
  default     = "monitoringlevel2"
  description = "A prefix for policies and dynamic groups names - scope: to be unique names not duplicates"
}

# # don't modify any other variables (below) - it may cause that the solution will not work propertly.

variable "use_regional_subnet" {
  type = bool
  default = true
  description = "Indicates use of regional subnets (preferred) instead of AD specific subnets"
}

# # End
