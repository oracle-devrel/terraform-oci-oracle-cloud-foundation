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
  default = "ADWSecureAgentOCI"
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


# Object Storage Variables:

variable "bucket_name" {
  type    = string
  default = "InformaticaSecureAgentOCI"
}

variable "bucket_access_type" {
    type    = string
    default  = "ObjectRead"
}

variable "bucket_storage_tier" {
    type    = string
    default = "Standard"
}
  
variable "bucket_events_enabled" {
    type    = bool
    default = false
}

# Informatica Secure Agent Instance variables
# More information regarding shapes can be found here:
# https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm

variable "informatica_instance_shape" {
  default = "VM.Standard2.4" # Example instance shape: VM.Standard2.4
}

variable "informatica_secure_agent_display_name" {
  default = "InformaticaVMOCI"
}

#  Informatica Intelligent Data Management Cloud Variables 

variable "iics_user" {
  description = "The user name to access Informatica Intelligent Data Management Cloud"
  default     = ""
}

variable "iics_token" {
  description = "Paste the Secure Agent install token that you get from the IDMC Administrator service"
  default     = ""
}

variable "iics_gn" {
  description = "Name of the Secure Agent group. If your account does not contain the group specified or if you do not specify a group name, the Secure Agent is assigned to an unnamed group"
  default     = ""
}

variable "iics_provider" {
  description = "The data center location for the deployment. Choose the data center location based on the user details registered in Informatica Intelligent Data Management Cloud"
  default = "Oracle Cloud Infrastructure"
    # default = "Amazon Web Services"
    # default = "Microsoft Azure"
    # default = "Google Cloud"
}

variable "iics_provider_enum" {
  type = map
  default = {
    OCI    = "Oracle Cloud Infrastructure"
    AWS    = "Amazon Web Services"
    Azure  = "Microsoft Azure"
    GCP    = "Google Cloud"
  }
}

variable "mp_subscription_enabled" {
  description = "Subscribe to Marketplace listing?"
  type        = bool
  //default     = false
  default     = true
}


# Networking variables

# VCN and subnet Variables

variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.0.0/24"
}

