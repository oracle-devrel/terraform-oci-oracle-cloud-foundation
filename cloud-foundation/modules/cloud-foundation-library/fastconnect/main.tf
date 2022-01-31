# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


data "oci_core_fast_connect_provider_services" "this" {
    compartment_id = var.compartment_id
}

resource "oci_core_cross_connect_group" "this" {
  for_each       = var.cc_group
  compartment_id = each.value.compartment_id
  display_name   = each.value.name
  defined_tags   = each.value.defined_tags
}

resource "oci_core_cross_connect" "this" {
  for_each               = var.cc
  compartment_id         = each.value.compartment_id
  location_name          = each.value.location_name
  port_speed_shape_name  = each.value.port_speed_shape_name
  cross_connect_group_id = oci_core_cross_connect_group.this[each.value.cc_group_name].id
  display_name           = each.value.name
  defined_tags           = each.value.defined_tags
}

resource "oci_core_virtual_circuit" "private_vc_no_provider" {
  for_each             = var.private_vc_no_provider
  compartment_id       = each.value.compartment_id
  type                 = each.value.type
  bandwidth_shape_name = each.value.bw_shape
  display_name         = each.value.name
  defined_tags         = each.value.defined_tags
  cross_connect_mappings {
    cross_connect_or_cross_connect_group_id = oci_core_cross_connect_group.this[each.value.cc_group_name].id
    customer_bgp_peering_ip                 = each.value.cust_bgp_peering_ip
    oracle_bgp_peering_ip                   = each.value.oracle_bgp_peering_ip
    vlan                                    = each.value.vlan
  }
  gateway_id = var.drgs[each.value.drg]
}

resource "oci_core_virtual_circuit" "private_vc_with_provider" {
  for_each             = var.private_vc_with_provider
  compartment_id       = each.value.compartment_id
  type                 = each.value.type
  bandwidth_shape_name = each.value.bw_shape
  display_name         = each.value.name
  defined_tags         = each.value.defined_tags
  cross_connect_mappings {
    cross_connect_or_cross_connect_group_id = oci_core_cross_connect_group.this[each.value.cc_group_name].id
    customer_bgp_peering_ip                 = each.value.cust_bgp_peering_ip
    oracle_bgp_peering_ip                   = each.value.oracle_bgp_peering_ip
    vlan                                    = each.value.vlan
  }
  gateway_id                  = var.drgs[each.value.drg]
  provider_service_id         = each.value.provider_service_id
  provider_service_key_name   = each.value.provider_service_key_name
}

resource "oci_core_virtual_circuit" "public_vc_no_provider" {
  for_each             = var.public_vc_no_provider
  compartment_id       = each.value.compartment_id
  type                 = each.value.type
  bandwidth_shape_name = each.value.bw_shape
  public_prefixes {
    cidr_block = each.value.cidr_block
  }
  display_name         = each.value.name
  defined_tags         = each.value.defined_tags
  cross_connect_mappings {
    cross_connect_or_cross_connect_group_id = oci_core_cross_connect_group.this[each.value.cc_group_name].id
    vlan                                    = each.value.vlan
  }
}

resource "oci_core_virtual_circuit" "public_vc_with_provider" {
  for_each             = var.public_vc_with_provider
  compartment_id       = each.value.compartment_id
  type                 = each.value.type
  bandwidth_shape_name = each.value.bw_shape
  public_prefixes {
    cidr_block = each.value.cidr_block
  }
  display_name         = each.value.name
  defined_tags         = each.value.defined_tags
  cross_connect_mappings {
    cross_connect_or_cross_connect_group_id = oci_core_cross_connect_group.this[each.value.cc_group_name].id
    vlan                                    = each.value.vlan
  }
  provider_service_id         = each.value.provider_service_id
  provider_service_key_name   = each.value.provider_service_key_name
}


resource "oci_core_virtual_circuit" "private_vc_with_provider_no_cross_connect_or_cross_connect_group_id" {
  for_each             = var.private_vc_with_provider_no_cross_connect_or_cross_connect_group_id
  compartment_id       = each.value.compartment_id
  type                 = each.value.type
  bandwidth_shape_name = each.value.bw_shape
  display_name         = each.value.name
  defined_tags         = each.value.defined_tags
  cross_connect_mappings {
    customer_bgp_peering_ip   = each.value.cust_bgp_peering_ip
    oracle_bgp_peering_ip     = each.value.oracle_bgp_peering_ip
  }
  gateway_id          = var.drgs[each.value.drg]
  provider_service_id = data.oci_core_fast_connect_provider_services.this.fast_connect_provider_services.0.id
}



