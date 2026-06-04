# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "linux_image" {
  compartment_id    = var.compartment_id
  operating_system  = "Oracle Linux"
  shape             = "VM.Standard2.1"
}

data "oci_core_services" "sgw_services" {
  filter {
    name   = "cidr_block"
    values = ["all-.*-services-in-oracle-services-network"]
    regex  = true
  }
}

locals{
   oracle_linux = lookup(data.oci_core_images.linux_image.images[0],"id")

# Create Autonomous Data Warehouse
  adw_params = { 
    adw = {
      compartment_id              = var.compartment_id
      compute_model               = "ECPU"
      compute_count               = 4
      size_in_tbs                 = 1
      db_name                     = "helloAtp2"
      db_workload                 = "OLTP"
      db_version                  = "19c"
      enable_auto_scaling         = true
      is_free_tier                = false
      license_model               = "LICENSE_INCLUDED"
      create_local_wallet         = true
      database_admin_password     = "V2xzQXRwRGIxMjM0Iw=="
      database_wallet_password    = "V2xzQXRwRGIxMjM0Iw=="
      data_safe_status            = "NOT_REGISTERED"
      operations_insights_status  = "NOT_ENABLED"
      database_management_status  = "NOT_ENABLED"
      is_mtls_connection_required = null
      subnet_id                   = lookup(module.network-vcn-subnets-gw.subnets,"hello-atp-endpoint-subnet").id
      nsg_ids                     = [lookup(module.network-nsgs.nsgs,"atp-nsg").id]
      defined_tags                = {}
  },
}


}