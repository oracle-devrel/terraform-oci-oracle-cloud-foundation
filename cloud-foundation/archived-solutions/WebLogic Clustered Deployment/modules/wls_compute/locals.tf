locals {
  
  host_label = "${var.compute_name_prefix}-${var.vnic_prefix}"
  ad_names   = compact(data.template_file.ad_names.*.rendered)

  is_atp_db         = var.is_atp_db
  is_apply_JRF      = local.is_atp_db ? true : false
  num_fault_domains = length(data.oci_identity_fault_domains.wls_fault_domains.fault_domains)
  
  }