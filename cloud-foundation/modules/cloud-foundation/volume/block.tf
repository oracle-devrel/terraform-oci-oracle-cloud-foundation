
resource "oci_core_volume" "block" {
  for_each = {
    for k,v in var.bv_params : k => v if v.compartment_id != ""
  } 
      availability_domain = each.value.ad
      compartment_id      = each.value.compartment_id
      display_name        = each.value.display_name
      size_in_gbs         = each.value.bv_size
      defined_tags        = each.value.defined_tags
      freeform_tags       = each.value.freeform_tags
}

resource "oci_core_volume_attachment" "block-volume-attach" {
    for_each = {
      for k,v in var.bv_attach_params : k => v if v.display_name != ""
  } 
      display_name    = each.value.display_name
      attachment_type = each.value.attachment_type
      instance_id     = each.value.instance_id
      volume_id       = each.value.volume_id

}

