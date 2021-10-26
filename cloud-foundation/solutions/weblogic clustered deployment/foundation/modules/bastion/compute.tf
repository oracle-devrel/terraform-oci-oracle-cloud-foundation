
module bastion_instance {
  source = "../../../../../../cloud-foundation/modules/cloud-foundation/bastion/instance"

  instance_params = { for x in range( var.is_bastion_instance_required && var.existing_bastion_instance_id == "" ? var.instance_count : 0 ) : "${var.instance_name}-${x}" => {

    //assumption: it is the same ad as wls
    availability_domain = var.availability_domain

    compartment_id = var.compartment_ocid
    display_name   = var.instance_name
    shape          = var.instance_shape

    defined_tags  = var.defined_tags
    freeform_tags = var.freeform_tags

    create_vnic_details = {
      subnet_id              = var.bastion_subnet_ocid[0]
      skip_source_dest_check = true
    }

    ocpus = local.ocpus

    metadata = {
      ssh_authorized_keys = var.ssh_public_key
      user_data           = data.template_cloudinit_config.bastion-config.rendered
      variant             = var.patching_tool_key
      wls_version         = var.wls_version
      patching_actions    = var.patching_supported_actions
    }

    are_legacy_imds_endpoints_disabled = var.disable_legacy_metadata_endpoint

    source_type = "image"
    source_id   = var.instance_image_id

    provisioning_timeout_mins = "10"
  }
}

}