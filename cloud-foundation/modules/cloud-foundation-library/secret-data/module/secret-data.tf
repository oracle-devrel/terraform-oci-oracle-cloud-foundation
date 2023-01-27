# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


# inputs


variable "secret_ocids"{
    type = map(string)
    default = {}
    description = "a map of strings where key is used for output reference. the ocid inside should refer to a secret's ocid"
}

variable "secret_names" {
    type = map(string)
    default = {}
    description = "an object map where key is used for output reference. The value pair should refer to a secret's full name. requires a compartment input as well"
}

variable "compartment" {
    type = string 
    default = null 
    description = "required for looking up secrets by name."
}


# outputs

output "contents" {
    value = {for key, value in local.secret_ocids :
        key => jsondecode(base64decode(data.oci_secrets_secretbundle.these[key].secret_bundle_content[0].content))
    }
    description = "secret contents decoded from base 64, and then from json. returned in a simple key-value map where key is the same name as your input maps"
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


# look up secrets by name to get their ocids
data "oci_vault_secrets" "these" {
    for_each = var.secret_names
            
    compartment_id = var.compartment

    name = each.value
}

# add secret names list to secret ocids
locals {

    secret_ocids = merge (var.secret_ocids, 
        {for key,value in var.secret_names: key => data.oci_vault_secrets.these[key].secret_id}
    )
  
}

#gets a secret bundle which is how you read from a secret
data "oci_secrets_secretbundle" "these" {
    for_each = local.secret_ocids

    secret_id = each.value
}

# used to get vault and key id - also in oci_vault_secrets datasource above, but not guaranteed to create that
data "oci_vault_secret" "this" {
    secret_id = data.oci_secrets_secretbundle.these[keys(local.secret_ocids)[0]].secret_id
}


# resource or mixed module blocks