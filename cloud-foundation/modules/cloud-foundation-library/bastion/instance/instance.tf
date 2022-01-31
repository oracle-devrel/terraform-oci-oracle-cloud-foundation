# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_instance" "instance" {

  for_each = var.instance_params

    availability_domain = each.value.availability_domain
    compartment_id      = each.value.compartment_id
    display_name        = each.value.display_name
    shape               = each.value.shape

    defined_tags = each.value.defined_tags
    freeform_tags = each.value.freeform_tags

    create_vnic_details {
      subnet_id = each.value.create_vnic_details.subnet_id
      skip_source_dest_check = each.value.create_vnic_details.skip_source_dest_check
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
  
    timeouts {
      create = "${each.value.provisioning_timeout_mins}m"
    }

    #prevent any metadata changes to destroy instance
    lifecycle {
      ignore_changes = [metadata, shape, shape_config]
    }
}
