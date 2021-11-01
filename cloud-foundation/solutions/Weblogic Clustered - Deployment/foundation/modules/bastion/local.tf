#Local info needed

locals {

  ocpus = length(regexall("^.*Flex", var.instance_shape))>0 ? var.ocpu_count: lookup(data.oci_core_shapes.oci_shapes.shapes[0], "ocpus") 
  bastion_public_ssh_key= tls_private_key.opc_key.public_key_openssh
  bastion_private_ssh_key= tls_private_key.opc_key.private_key_pem
}

# Gets a list of Availability Domains in the tenancy
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}


data "template_file" "bastion_key_script" {
  template = "${file("./modules/bastion/templates/bastion-keys.tpl")}"

  vars = {
    pubKey     = local.bastion_public_ssh_key
  }
}

data "oci_core_shapes" "oci_shapes" {
  #Required
  compartment_id = var.compartment_ocid
  image_id = var.instance_image_id
  availability_domain = var.availability_domain
  filter {
    name ="name"
    values= ["${var.instance_shape}"]
  }
}