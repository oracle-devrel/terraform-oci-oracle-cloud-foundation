# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.



# inputs

variable "network_compartment" {
  type = string
}

variable "vcn" {
    type = string
}

# outputs


# logic


# resource or mixed module blocks


module "subnet" {
    # pick a source type - github url with path and git tag is recommended for production code. local path is used for sub-module development and customization
    # source = "github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation//cloud-foundation/modules/cloud-foundation-library/network-subnet/module?ref=<input latest git tag>"
    source = "../../module"

    compartment = var.network_compartment
    vcn = var.vcn
    prefix = "ebs"
    internet_access = "nat"
    ssh_cidr = "0.0.0.0/0"
    cidr_block = "10.0.1.0/24"
    /*
    custom_tcp_ingress_rules = { lb = {
        source_cidr   = "10.0.0.0/24",
        min = 8081,
        max = 8081,
    }}
    */
}