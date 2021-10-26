# Copyright © 2021, Oracle and/or its affiliates.
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
    default = "ADWiopa"
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
    default = "LICENSE_INCLUDED"
}

variable "database_admin_password" {
  type = string
  default = ""
}

variable "database_wallet_password" {
  type = string
  default = ""
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
    default = "AnalyicSD"
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

# Network

variable "service_name" {
  type        = string
  default     = "servicename"
  description = "prefix for stack resources"
}

variable "vcn_cidr" {
  default = "172.0.0.0/16"
  description = "CIDR for new virtual cloud network"
}

variable "vcn_name" {
  default     = "vcn"
  description = "Name of new virtual cloud network"
}

variable "public_subnet_cidr" {
  default = "172.0.0.128/27"
  description = "CIDR for bastion subnet"
}

variable "public_subnet_name" {
  default = "pub"
}

variable "private_subnet_cidr" {
  default = "172.0.0.32/27"
}

variable "private_subnet_name" {
  default = "priv"
}

# don't modify any other variables (below) - it may cause that the solution will not work propertly.

variable "use_regional_subnet" {
  type = bool
  default = true
  description = "Indicates use of regional subnets (preferred) instead of AD specific subnets"
}

variable "subnet_type" {
  default = "Use Private Subnet"
}

variable "public_subnet_id" {
  default = ""
  description = "OCID for existing subnet for bastion instance"
}

variable "private_subnet_id" {
  default = ""
  description = "OCID for existing subnet for weblogic instances"
}

variable "assign_public_ip" {
  type = bool
  default = false
  description = "Indicates use of private subnets"
}

variable "private_subnet_availability_domain_name" {
  type        = string
  default     = ""
  description = "availablility domain for weblogic vm instances"
}

variable "dhcp_options_name" {
  default = "dhcpOptions"
}

variable anywhere_cidr {
  default = "0.0.0.0/0"
}

# Define Tags


#Note: special chars string denotes empty values for tags for validation purposes
#otherwise zipmap function in main.tf fails first for empty strings before validators executed.

variable "defined_tag" {
  type    = string
  default = "~!@#$%^&*()"
  description = "defined resource tag name"
}

variable "defined_tag_value" {
  type    = string
  default = "~!@#$%^&*()"
  description = "defined resource tag value"
}

variable "free_form_tag" {
  type    = string
  default = "~!@#$%^&*()"
  description = "free form resource tag name"
}

variable "free_form_tag_value" {
  type    = string
  default = "~!@#$%^&*()"
  description = "free form resource tag value"
}

# End
