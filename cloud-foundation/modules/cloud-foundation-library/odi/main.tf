# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

  resource "oci_dataintegration_workspace" "this" {
    for_each = {
      for k,v in var.odi_params : k => v if v.compartment_id != ""
  } 
    #Required
    compartment_id    = each.value.compartment_id
    display_name      = each.value.display_name

    #Optional
    defined_tags = each.value.defined_tags
    description  = each.value.description
    # dns_server_ip = var.workspace_dns_server_ip
    # dns_server_zone = var.workspace_dns_server_zone
    # freeform_tags = each.value.freeform_tags
    # is_private_network_enabled = each.value.is_private_network_enabled
    is_private_network_enabled = false
    # subnet_id = each.value.subnet_id
    # vcn_id = each.value.vcn_id
}




