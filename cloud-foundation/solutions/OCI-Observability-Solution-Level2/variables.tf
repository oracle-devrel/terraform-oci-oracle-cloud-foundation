# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


terraform {
  required_version = ">= 0.14.0"
}

# variable "tenancy_ocid" {
#   type = string
#   default = ""
# }

# variable "region" {
#     type = string
#     default = ""
# }

# variable "compartment_id" {
#   type = string
#   default = ""
# }

# variable "user_ocid" {
#     type = string
#     default = ""
# }

# variable "fingerprint" {
#     type = string
#     default = ""
# }

# variable "private_key_path" {
#     type = string
#     default = ""
# }


######################


variable "tenancy_ocid" {
    type = string
    default = "ocid1.tenancy.oc1..aaaaaaaaj4ccqe763dizkrcdbs5x7ufvmmojd24mb6utvkymyo4xwxyv3gfa"
    # default = "ocid1.tenancy.oc1..aaaaaaaaiyavtwbz4kyu7g7b6wglllccbflmjx2lzk5nwpbme44mv54xu7dq"
}

variable "region" {
    type = string
    # default = "uk-london-1"
    default = "us-ashburn-1"
}

variable "compartment_id" {
  type    = string
  default = "ocid1.compartment.oc1..aaaaaaaaza2vwcluoxu5dropj4o5p6aypze6o6ivnq63ijazn44gliiwzjaa"
  # default = "ocid1.compartment.oc1..aaaaaaaa26xyyc4x5dxevv7anxyfafbzmdqth2jutrid4kvdf5ddroogiq3a"
}

variable "user_ocid" {
    type = string
    default = "ocid1.user.oc1..aaaaaaaa4bjez27pyslznrrk5g24yiev24ld3ketha6tqj36f34lbbaddhiq"
    # default = "ocid1.user.oc1..aaaaaaaavbcyanmhbemhantfgvhl3deus6pqooqi5aadxttah3rx5lce7kza"
}

variable "fingerprint" {
    type = string
    default = "12:1d:7d:18:6d:a7:e3:fc:17:4c:30:a9:44:65:7d:00"
    # default = "12:1d:7d:18:6d:a7:e3:fc:17:4c:30:a9:44:65:7d:00"
}

variable "private_key_path" {
    type = string
    default = "/root/.oci/oci_api_key.pem"
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
  default = "Par0laMea123"
}

variable "database_wallet_password" {
  type = string
  default = "Par0laMea123"
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
