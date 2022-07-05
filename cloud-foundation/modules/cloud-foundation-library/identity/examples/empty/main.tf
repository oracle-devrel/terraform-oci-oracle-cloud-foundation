


# inputs


# outputs


# logic


# resource or mixed module blocks


module "identity" {
    # pick a source type - github url with path and git tag is recommended for production code. local path is used for sub-module development and customization
    # source = "https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation//cloud-foundation/modules/cloud-foundation-library/identity/module?ref=v1.2.0"
    source = "../../module"

    tenancy_ocid = var.tenancy_ocid


}