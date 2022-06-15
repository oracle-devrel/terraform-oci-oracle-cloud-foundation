

# inputs

/*
variable "load_from_secrets" {
    type = bool
    default = true
}
*/

variable "secret_ocids"{
    type = map(string)
    default = {}
    description = "a map of objects where key is used for output reference. the ocid inside should refer to a secret's ocid"
}




#gets a secret bundle which is how you read from a secret
data "oci_secrets_secretbundle" "these" {
    for_each = var.secret_ocids

    secret_id = each.value
}

# used to get vault and key id - also in oci_vault_secrets datasource above, but not guaranteed to create that
data "oci_vault_secret" "this" {
    secret_id = data.oci_secrets_secretbundle.these[keys(var.secret_ocids)[0]].secret_id
}


# outputs

output "contents" {
    value = {for key, value in var.secret_ocids :
        key => jsondecode(base64decode(data.oci_secrets_secretbundle.these[key].secret_bundle_content[0].content))
    }
    description = "secret contents decoded from base 64, and then from json. returned in a simple key-value map where key is the same name as your input map"
}

output "vault" {
    value = data.oci_vault_secret.this.vault_id
    description = "the ocid of the vault that stores this secret"
}

output "key" {
    value = data.oci_vault_secret.this.key_id
    description = "the ocid of the key that encrypted this secret"
}

# logic


# resource or mixed module blocks