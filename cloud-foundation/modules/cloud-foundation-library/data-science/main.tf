## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_datascience_project" "this" {
  for_each       = var.datascience_params
  compartment_id = each.value.compartment_id
  description    = each.value.project_description
  display_name   = each.value.project_display_name
}

resource "oci_datascience_notebook_session" "this" {
  for_each       = var.notebook_params
  compartment_id = each.value.compartment_id
  notebook_session_configuration_details {
    shape     = each.value.notebook_session_notebook_session_configuration_details_shape
    subnet_id = each.value.subnet_id

    block_storage_size_in_gbs = each.value.notebook_session_notebook_session_configuration_details_block_storage_size_in_gbs
  }

  project_id = oci_datascience_project.this[each.value.project_name].id

  display_name = each.value.notebook_session_display_name
}


