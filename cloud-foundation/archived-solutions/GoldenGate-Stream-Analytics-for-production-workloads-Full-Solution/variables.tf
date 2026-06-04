# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# OCI API authentification credentials

terraform {
  required_version = ">= 0.15.0"
}

variable "tenancy_ocid" {
  default = ""
}

variable "user_ocid" {
  default = ""
}

variable "fingerprint" {
  default = ""
}

variable "private_key_path" {
  default = ""
}

variable "region" {
  default = ""
}

variable "compartment_id" {
  default = ""
}

# Autonomous Database Configuration Variables

variable "db_name" {
  type    = string
  default = "ADWipaGGSAFull"
}

variable "db_password" {
  type = string
  default = "<enter-password-here>"
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
  # default = "REGISTERED"
}

variable "db_operations_insights_status" {
  type = string
  default = "NOT_ENABLED"
  # default = "ENABLED"
}

variable "db_database_management_status" {
  type = string
  default = "NOT_ENABLED"
  # default = "ENABLED"
}

# Oracle Analytics Cloud Configuration

variable "analytics_instance_feature_set" {
    type    = string
    default = "ENTERPRISE_ANALYTICS"
}

variable "analytics_instance_license_type" {
    type    = string
    default = "LICENSE_INCLUDED"
}

variable "analytics_instance_hostname" {
    type    = string
    default = "AnalyticsXGGSAF"
}

variable "analytics_instance_idcs_access_token" {
    type    = string
    default = "copy-paste your token instead"
}

variable "analytics_instance_capacity_capacity_type" {
    type    = string
    default = "OLPU_COUNT"
}

variable "analytics_instance_capacity_value" {
    type    = number
    default = 1
}

variable "analytics_instance_network_endpoint_details_network_endpoint_type" {
    type    = string
    default = "public"
}

variable "whitelisted_ips" {
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "analytics_instance_network_endpoint_details_whitelisted_ips" {
  type = list(string)
  default = ["0.0.0.0/0"]
}


# Object Storage Bucket

variable "bucket_name" {
    type    = string
    default = "BucketOneGGSAF"
}

variable "bucket_access_type" {
    type    = string
    default  = "NoPublicAccess"
}

variable "bucket_storage_tier" {
    type    = string
    default = "Standard"
}
  
variable "bucket_events_enabled" {
    type    = bool
    default = false
}


# Data Catalog

variable "datacatalog_display_name" {
    type    = string
    default = "DataCatalogIP"
}


# Compute Configuration
# More information regarding shapes can be found here:
# https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm
# "Web-Tier-and-Bastion" variables

variable "bastion_shape" {
  default = "VM.Standard2.4"
}

# "Workers" variables

variable "worker1_shape" {
  default = "VM.Standard2.4"
}

variable "worker2_shape" {
  default = "VM.Standard2.4"
}

variable "worker3_shape" {
  default = "VM.Standard2.4"
}


# "Masters" variables

variable "master1_shape" {
  default = "VM.Standard2.4"
}

variable "master2_shape" {
  default = "VM.Standard2.4"
}


# Network variables

variable "vcn_cidr" {
  default = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
  default = "10.0.0.0/24"
}
variable "private_subnet_cidr" {
  default = "10.0.1.0/24"
}

# don't modify any other variables (below) - it may cause that the solution will not work propertly.

variable "use_regional_subnet" {
  type = bool
  default = true
  description = "Indicates use of regional subnets (preferred) instead of AD specific subnets"
}

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.0.0"
}