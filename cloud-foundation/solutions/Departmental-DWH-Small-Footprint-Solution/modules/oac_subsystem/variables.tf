# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type    = string
}

variable "analytics_instance_feature_set" {
    type    = string
}

variable "analytics_instance_license_type" {
    type    = string
}

variable "analytics_instance_hostname" {
    type    = string
}
  
variable "analytics_instance_idcs_access_token" {
    type    = string
}

variable "analytics_instance_capacity_capacity_type" {
    type    = string
}

variable "analytics_instance_capacity_value" {
    type    = number
}

variable "defined_tags" {
  type    = map
  default = {}
}

variable "subnet_id" {}
variable "vcn_id" {}
variable "analytics_instance_network_endpoint_details_network_endpoint_type" {}
variable "analytics_instance_network_endpoint_details_whitelisted_vcns_id" {}

variable "whitelisted_ips" {
    type = list(string)
    default = []
}

variable "analytics_instance_network_endpoint_details_whitelisted_ips" {
    type = list(string)
    default = []
}





