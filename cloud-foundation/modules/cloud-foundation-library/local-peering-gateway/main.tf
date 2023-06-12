# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_local_peering_gateway" "requestor_lpgs" {
  for_each       = var.lpg_params
  display_name   = each.value.display_name
  compartment_id = each.value.compartment_id
  vcn_id         = each.value.vcn_id1
  peer_id        = oci_core_local_peering_gateway.acceptor_lpgs[each.value.display_name].id
}

resource "oci_core_local_peering_gateway" "acceptor_lpgs" {
  for_each       = var.lpg_params
  display_name   = each.value.display_name
  compartment_id = each.value.compartment_id
  vcn_id         = each.value.vcn_id2
}
