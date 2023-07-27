# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_drg" "requestor_drg" {
  count          = var.requestor_region == var.acceptor_region ? 0 : 1
  provider       = oci.requestor
  compartment_id = var.compartment_id
}

resource "oci_core_drg_attachment" "requestor_drg_attachment" {
  count    = var.requestor_region == var.acceptor_region ? 0 : 1
  provider = oci.requestor
  drg_id   = oci_core_drg.requestor_drg[0].id
  vcn_id   = var.vcns[var.rpg_params[count.index].vcn_name_requestor].id
}

resource "oci_core_remote_peering_connection" "requestor" {
  count            = var.requestor_region == var.acceptor_region ? 0 : 1
  provider         = oci.requestor
  compartment_id   = var.compartment_id
  drg_id           = oci_core_drg.requestor_drg[0].id
  display_name     = "remotePeeringConnectionRequestor"
  peer_id          = oci_core_remote_peering_connection.acceptor[0].id
  peer_region_name = var.acceptor_region
}

resource "oci_core_drg" "acceptor_drg" {
  count          = var.requestor_region == var.acceptor_region ? 0 : 1
  provider       = oci.acceptor
  compartment_id = var.compartment_id
}

resource "oci_core_drg_attachment" "acceptor_drg_attachment" {
  count    = var.requestor_region == var.acceptor_region ? 0 : 1
  provider = oci.acceptor
  drg_id   = oci_core_drg.acceptor_drg[0].id
  vcn_id   = var.vcns2[var.rpg_params[count.index].vcn_name_acceptor].id
}

resource "oci_core_remote_peering_connection" "acceptor" {
  count          = var.requestor_region == var.acceptor_region ? 0 : 1
  provider       = oci.acceptor
  compartment_id = var.compartment_id
  drg_id         = oci_core_drg.acceptor_drg[0].id
  display_name   = "remotePeeringConnectionAcceptor"
}