
# inputs


# compartment
variable "compartment" {
  type = string 
  description = "OCID of the compartment to create resources in"
}

#vault vars
variable "existing_vault" {
    type = string 
    default = null
    description = "ocid of an existing vault. if left null, a vault will be created"
}
variable "vault_name" {
  type        = string
  description = "display name for vault"
  default     = "vault"
}
variable "vault_type" {
  type        = string
  description = "valid values: \"DEFAULT\" or \"VIRTUAL_PRIVATE\". Virtual Private vault only needed for greater isolation or backup requirements"
  default     = "DEFAULT"
}


#key vars

variable "existing_AES_key" {
  type = string 
  default = null 
  description = "ocid of an existing AES key. if left null, a key will be created"
}
variable "AES_key_name" {
    type = string
    default = "TFSecretKey"
    description = "display name for AES key"
}
variable "AES_key_length" {
    type = number 
    default = 32
    description = "length of AES key in BYTES. Valid values(corresponding bits): 16(128), 24(192), 32(256)"
}


# secret vars
variable "secrets" {
  type = map(object({
        contents  = any,
        description = string,
        #metadata = ?, # TODO: support metadata key-value pairs
  }))
  default = {}
  description = "a map of secret. name will be object key. contents will be jsonencoded and base64encoded and accepts and valid TF variable type. However, contents will need to be of the same type"
}




# outputs

output "vault_id" {
    value = local.vault_id
}
output "key_id" { 
    value = local.aes_key_id
}

output "secrets" {
  value = {for s in oci_vault_secret.these :
      s.secret_name => s.id}
}

# logic


locals {
  create_vault = var.existing_vault == null
  vault_id = local.create_vault ? oci_kms_vault.this[0].id : data.oci_kms_vault.this[0].id
  vault_endpoint = local.create_vault ? oci_kms_vault.this[0].management_endpoint : data.oci_kms_vault.this[0].management_endpoint
  vault = local.create_vault ? oci_kms_vault.this[0] : data.oci_kms_vault.this[0]

  create_aes_key = var.existing_AES_key == null
  aes_key_id = local.create_aes_key ? oci_kms_key.this[0].id : var.existing_AES_key

}


# resource or mixed module blocks

#creates vault
resource "oci_kms_vault" "this" {
    count = local.create_vault ? 1 : 0
    #Required
    compartment_id = var.compartment
    display_name = var.vault_name
    vault_type = var.vault_type

}
data "oci_kms_vault" "this" {
  count = !local.create_vault ? 1 : 0
  vault_id = var.existing_vault
}



# create master encryption key
resource "oci_kms_key" "this" {
  count = local.create_aes_key ? 1 : 0

    compartment_id =  var.compartment
    display_name = var.AES_key_name
    management_endpoint = local.vault_endpoint

    key_shape {
        algorithm = "AES"
        length = var.AES_key_length
    }

}



# needed to create unique name if secret contents is updated
resource "random_id" "secrets" {
  for_each = var.secrets
  keepers = {
    # Generate a new id each time we update the secret contents
    secret_contents = base64encode(jsonencode(each.value.contents))
  }

  byte_length = 8
}
# creates secret
resource "oci_vault_secret" "these" {
  for_each = var.secrets

    #Required
    compartment_id = var.compartment
    secret_content {
        #Required
        content_type = "BASE64"

        #Optional
        content = base64encode(jsonencode(each.value.contents))
        name = "${each.key}-${random_id.secrets[each.key].id}"
        stage = "CURRENT" 
    }
    secret_name = each.key
    vault_id = local.vault_id


    description = each.value.description
    key_id = local.aes_key_id
    #metadata = var.secret_metadata # TODO: expose as variable. takes key value pairs

}
