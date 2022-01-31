# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

resource "oci_file_storage_file_system" "this" {
  for_each            = var.fss_params
  availability_domain = each.value.availability_domain
  compartment_id      = each.value.compartment_id
  display_name        = each.value.name
  defined_tags        = each.value.defined_tags
  freeform_tags       = each.value.freeform_tags

# Here we have put a sleep becouse of this knows issue here: https://docs.oracle.com/en-us/iaas/Content/knownissues.htm#FS-MT  
# The Compartment Quotas feature introduces constraints that limit the number of concurrent operations that a tenancy can perform on file system and mount target resources in a region:
# 
# Each tenancy in a region can have 1 CreateFileSystem or ChangeFilesystemCompartment operation in progress at a time.
# Each tenancy in a region can have 1 CreateMountTarget or ChangeMountTargetCompartment operation in progress at a time.

# Sample error example

#  Error: 409-Conflict 
#  Provider version: 4.40.0, released on 2021-08-18.  
#  Service: File Storage System 
#  Error Message: Another filesystem is currently being provisioned, try again later 
#  OPC request ID: 08cdbcfa22bd1618f7c59b6c784c574d/D0703FEC7507DB939448D64253BBC0F8/AA11BA35A2B6FE2F2B18A25F4BEDF26C 
#  Suggestion: The resource is in a conflicted state. Please retry again or contact support for help with service: File Storage System
 
  provisioner "local-exec" {
    command = "sleep 15"
  }
}

resource "oci_file_storage_mount_target" "this" {
  for_each            = var.mt_params
  availability_domain = each.value.availability_domain
  display_name        = each.value.name
  compartment_id      = each.value.compartment_id
  subnet_id           = each.value.subnet_id
  defined_tags        = each.value.defined_tags
  freeform_tags       = each.value.freeform_tags
}

resource "oci_file_storage_export_set" "this" {
  for_each        = var.mt_params
  mount_target_id = oci_file_storage_mount_target.this[each.key].id
  display_name    = each.value.name
}

resource "oci_file_storage_export" "this" {
  for_each       = var.export_params
  export_set_id  = oci_file_storage_export_set.this[each.value.export_set_name].id
  file_system_id = oci_file_storage_file_system.this[each.value.filesystem_name].id
  path           = each.value.path

  dynamic "export_options" {
    iterator = exp_options
    for_each = each.value.export_options
    content {
      source                         = exp_options.value.source
      access                         = exp_options.value.access
      identity_squash                = exp_options.value.identity
      require_privileged_source_port = exp_options.value.use_port
    }
  }
}
