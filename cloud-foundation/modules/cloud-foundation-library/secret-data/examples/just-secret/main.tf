


# inputs

variable "secret_compartment" {
  
}

variable "secret" {
  type = string

}

# outputs

output "secrets" {
    value = module.secret.contents
}

# logic

# resource or mixed module blocks


module "secret" {
    # pick a source type - github url with path and git tag is recommended for production code. local path is used for sub-module development and customization
    # source = https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation//cloud-foundation/modules/cloud-foundation-library/secret-data/module?ref=v1.2.0
    source = "../../module"



    secret_ocids = { "mysecret" = var.secret}

}