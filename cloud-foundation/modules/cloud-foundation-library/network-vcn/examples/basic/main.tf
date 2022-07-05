


# inputs


# outputs


# logic


# resource or mixed module blocks


module "vcn" {
    # pick a source type - github url with path and git tag is recommended for production code. local path is used for sub-module development and customization
    # source = "https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation//cloud-foundation/modules/cloud-foundation-library/netowrk-vcn/module?ref=v1.2.0"
    source = "../../module"

    compartment_id = var.tenancy_ocid
    vcn_display_name = "MyVCN"
    create_nat_gateway = true 
    create_internet_gateway = true
}