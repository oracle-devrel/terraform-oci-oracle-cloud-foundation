# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


# resource "oci_core_drg" "this" {
#   count          = var.is_create_drg == true ? 1 : 0
#   compartment_id = var.compartment_id
#   display_name   = "${var.service_label}-drg"
# }


resource "oci_core_drg" "this" {
  for_each       = var.drg_params
  compartment_id = var.compartment_id
  display_name   = each.value.name
  defined_tags   = each.value.defined_tags
}





