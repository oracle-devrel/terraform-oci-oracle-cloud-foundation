# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type = string
}

variable "drgs" {
  type = map(string)
}

variable "cc_group" {
  type = map(object({
    compartment_id   = string
    name             = string
    defined_tags     = map(string)
  }))
}

variable "cc" {
  type = map(object({
    compartment_id        = string
    name                  = string
    location_name         = string
    port_speed_shape_name = string
    cc_group_name         = string
    defined_tags          = map(string)
  }))
}

variable "private_vc_no_provider" {
  type = map(object({
    compartment_id        = string
    name                  = string
    type                  = string
    bw_shape              = string
    cc_group_name         = string
    cust_bgp_peering_ip   = string
    oracle_bgp_peering_ip = string
    vlan                  = string
    drg                 = string
    defined_tags          = map(string)
  }))
}

variable "private_vc_with_provider" {
  type = map(object({
    compartment_id        = string
    name                  = string
    type                  = string
    bw_shape              = string
    cc_group_name         = string
    cust_bgp_peering_ip   = string
    oracle_bgp_peering_ip = string
    vlan                  = string
    drg                   = string
    private_service_id    = string
    private_service_key   = string
    defined_tags          = map(string)
  }))
}

variable "public_vc_no_provider" {
  type = map(object({
    compartment_id        = string
    name                  = string
    type                  = string
    bw_shape              = string
    cidr_block            = string
    cc_group_name         = string
    vlan                  = string
    defined_tags          = map(string)
  }))
}

variable "public_vc_with_provider" {
  type = map(object({
    compartment_id        = string
    name                  = string
    type                  = string
    bw_shape              = string
    cidr_block            = string
    cc_group_name         = string
    vlan                  = string
    private_service_id    = string
    private_service_key   = string
    defined_tags          = map(string)
  }))
}

variable "private_vc_with_provider_no_cross_connect_or_cross_connect_group_id" {
  type = map(object({
    compartment_id        = string
    name                  = string
    type                  = string
    bw_shape              = string
    cust_bgp_peering_ip   = string
    oracle_bgp_peering_ip = string
    drg                   = string
    defined_tags          = map(string)
  }))
}



