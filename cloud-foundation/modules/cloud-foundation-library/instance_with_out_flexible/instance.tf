# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}


resource "oci_core_instance" "instance" {

  for_each = var.instance_params

    availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[each.value.availability_domain - 1].name
    compartment_id      = each.value.compartment_id
    display_name        = each.value.display_name
    shape               = each.value.shape

    defined_tags = each.value.defined_tags
    freeform_tags = each.value.freeform_tags

    create_vnic_details {
      subnet_id        = each.value.subnet_id
      display_name     = each.value.vnic_display_name
      assign_public_ip = each.value.assign_public_ip
      hostname_label   = each.value.hostname_label
    }

    source_details {
      source_type = each.value.source_type
      source_id   = each.value.source_id
    }

    metadata = each.value.metadata
  
    fault_domain = each.value.fault_domain
  
    timeouts {
      create = "${each.value.provisioning_timeout_mins}m"
    }

    #prevent any metadata changes to destroy instance
    lifecycle {
      ignore_changes = [metadata, shape, shape_config]
    }
}
