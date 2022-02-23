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
   oracle_linux = lookup(data.oci_core_images.linux_image.images[1],"id")
}