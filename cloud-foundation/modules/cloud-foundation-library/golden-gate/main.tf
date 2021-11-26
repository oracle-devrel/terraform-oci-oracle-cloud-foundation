## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_golden_gate_deployment" "this" {
  for_each                = var.deployment_params
  compartment_id          = var.compartment_ids[each.value.compartment]
  cpu_core_count          = each.value.cpu_core_count
  deployment_type         = each.value.deployment_type
  subnet_id               = var.subnet_ids[each.value.subnet_id]
  license_model           = each.value.license_model
  display_name            = each.value.display_name
  is_auto_scaling_enabled = each.value.is_auto_scaling_enabled
  // fqdn = each.value.fqdn
  // freeform_tags = each.value.freeform_tags
  // is_public = each.value.is_public
  // nsg_ids = each.value.nsg_ids
  // defined_tags = each.value.defined_tags
  // deployment_backup_id = each.value.deployment_backup_id
  // description = each.value.description
  dynamic "ogg_data" {
    iterator = ogg_data
    for_each = each.value.ogg_data
    content {
      admin_password  = ogg_data.value.admin_password
      admin_username  = ogg_data.value.admin_username
      deployment_name = ogg_data.value.deployment_name
    }
  }

  //  dynamic "timeouts" {
  //    for_each = var.timeouts
  //    content {
  //      create = timeouts.value.create
  //      delete = timeouts.value.delete
  //      update = timeouts.value.update
  //    }
  //  }

}