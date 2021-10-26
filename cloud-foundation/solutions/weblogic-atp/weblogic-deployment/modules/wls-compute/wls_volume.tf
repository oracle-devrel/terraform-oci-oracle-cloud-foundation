
module "middleware-volume" {
  source = "../../../../../../cloud-foundation/modules/cloud-foundation/volume"
  bv_params = {for x in range(var.numWLSInstances) : "${var.compute_name_prefix}-mw-block-${x}" => { 
      ad                   = var.use_regional_subnet?local.ad_names[x % length(local.ad_names)]:var.availability_domain
      compartment_id       = var.compartment_ocid
      display_name         = "${var.compute_name_prefix}-mw-block-${x}"
      bv_size              = var.volume_size
      defined_tags         = var.defined_tags
      freeform_tags        = var.freeform_tags
    }
  }

  bv_attach_params = {empty={display_name="", attachment_type="", instance_id="", volume_id="" }}
}

module "data-volume" {
  source = "../../../../../../cloud-foundation/modules/cloud-foundation/volume"
  bv_params = {for x in range(var.numWLSInstances) : "${var.compute_name_prefix}-data-block-${x}" => {
      ad                   = var.use_regional_subnet?local.ad_names[x % length(local.ad_names)]:var.availability_domain
      compartment_id       = var.compartment_ocid
      display_name         = "${var.compute_name_prefix}-data-block-${x}"
      bv_size              = var.volume_size
      defined_tags         = var.defined_tags
      freeform_tags        = var.freeform_tags
    } 
  }
  bv_attach_params = {empty={display_name="", attachment_type="", instance_id="", volume_id=""}}
}

module "middleware_volume_attach" {
  source = "../../../../../../cloud-foundation/modules/cloud-foundation/volume"
   
  bv_params = {empty={ad = "", compartment_id = "", display_name = "", bv_size  = 0, defined_tags = {def=""}, freeform_tags = {free=""}}}

  bv_attach_params = {for x in range(!local.is_apply_JRF || local.is_atp_db ? var.numWLSInstances * var.num_volumes: 0) : "${var.compute_name_prefix}-block-volume-attach-${x}" => { 
      display_name    = "${var.compute_name_prefix}-block-volume-attach-${x}"
      attachment_type = "iscsi"
      instance_id     = local.is_atp_db ? module.wls-atp-instance.InstanceOcids[x / var.num_volumes]:module.wls_no_jrf_instance.InstanceOcids[x / var.num_volumes]
      volume_id       = module.middleware-volume.DataVolumeOcids[x / var.num_volumes]
    }
  }
}

module "data_volume_attach" {
  source = "../../../../../../cloud-foundation/modules/cloud-foundation/volume"

  bv_params = {empty={ad = "", compartment_id = "", display_name = "", bv_size  = 0, defined_tags = {def=""}, freeform_tags = {free=""}}}

  bv_attach_params = {for x in range(!local.is_apply_JRF || local.is_atp_db ? var.numWLSInstances * var.num_volumes: 0) : "${var.compute_name_prefix}-block-volume-attach-${x}" => { 
      display_name    = "${var.compute_name_prefix}-block-volume-attach-${x}"
      attachment_type = "iscsi"
      instance_id     = local.is_atp_db ? module.wls-atp-instance.InstanceOcids[x / var.num_volumes]:module.wls_no_jrf_instance.InstanceOcids[x / var.num_volumes]
      volume_id       = module.data-volume.DataVolumeOcids[x / var.num_volumes]
    }
  }
}