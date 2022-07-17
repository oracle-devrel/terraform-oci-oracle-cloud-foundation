## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_data_safe_data_safe_private_endpoint" "this" {
    for_each       = var.oci_data_safe_private_endpoint_params
    compartment_id = each.value.compartment_id
    display_name   = each.value.display_name
    subnet_id      = each.value.subnet_id
    vcn_id         = each.value.vcn_id
    defined_tags   = each.value.defined_tags
    description    = each.value.description
    nsg_ids        = each.value.nsg_ids
}