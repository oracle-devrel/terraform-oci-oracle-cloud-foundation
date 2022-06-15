


# inputs
variable "vault" {
  type = string
}

variable "key" {
  type = string
}

# outputs


# logic



# resource or mixed module blocks


module "string-secret" {
    # pick a source type - github url with path and git tag is recommended for production code. local path is used for sub-module development and customization
    # source = https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation//cloud-foundation/modules/cloud-foundation-library/secret/module?ref=v1.2.0
    source = "../../module"

    compartment = var.tenancy_ocid

    secrets = {
        "mySecret" = {
        contents  = "Hello World",
        description = "description",
        }
  }

}

module "list-secrets" {
    # pick a source type - github url with path and git tag is recommended for production code. local path is used for sub-module development and customization
    # source = https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation//cloud-foundation/modules/cloud-foundation-library/secret/module?ref=v1.2.0
    source = "../../module"

    compartment = var.tenancy_ocid
    existing_vault = var.vault
    existing_AES_key = var.key


    secrets = {
        "listSecret1" = {
        contents  = ["Hello World"],
        description = "description",
        },
        "listSecret2" = {
        contents  = ["value1", "value2"],
        description = "description",
        },

  }

}

module "map-secret" {
    # pick a source type - github url with path and git tag is recommended for production code. local path is used for sub-module development and customization
    # source = https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation//cloud-foundation/modules/cloud-foundation-library/secret/module?ref=v1.2.0
    source = "../../module"

    compartment = var.tenancy_ocid
    existing_vault = var.vault
    existing_AES_key = var.key


    secrets = {
        "mapSecret1" = {
        contents  = {"Hello World" = "ocid"},
        description = "description",
        },
        "mapSecret2" = {
        contents  = {"value1" = "ocid1", "value2" = "ocid2"},
        description = "description",
        },

  }

}