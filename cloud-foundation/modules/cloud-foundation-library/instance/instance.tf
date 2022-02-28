# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_instance" "these" {

  for_each = var.instance_params

    availability_domain = each.value.availability_domain
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
      nsg_ids          = each.value.nsg_ids
    }

    shape_config {
      #Optional
      ocpus = each.value.ocpus 
    }

    source_details {
      source_type = each.value.source_type
      source_id   = each.value.source_id
    }

    metadata = each.value.metadata
  
    instance_options {
      are_legacy_imds_endpoints_disabled = each.value.are_legacy_imds_endpoints_disabled
    }
  
    fault_domain = each.value.fault_domain
  
    timeouts {
      create = "${each.value.provisioning_timeout_mins}m"
    }

    lifecycle {
      ignore_changes = [metadata, shape, shape_config]
    }
}
