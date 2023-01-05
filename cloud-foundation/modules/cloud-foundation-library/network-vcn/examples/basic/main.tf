# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.



# inputs


# outputs


# logic


# resource or mixed module blocks


module "vcn" {
    # pick a source type - github url with path and git tag is recommended for production code. local path is used for sub-module development and customization
    # source = "github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation//cloud-foundation/modules/cloud-foundation-library/network-vcn/module?ref=<input latest git tag>"
    source = "../../module"

    compartment_id = var.tenancy_ocid
    vcn_display_name = "MyVCN"
    create_nat_gateway = true 
    create_internet_gateway = true
}