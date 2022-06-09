
# inputs

variable "tenancy_ocid" {
  type = string
  description = "ocid of the tenancy. all groups must be created in tenancy and some policies need to live there as well. if existing compartment is not defined, it will use the tenancy as the existing compartment"
}

variable "existing_compartment" {
  type = string 
  default = null 
  description = "Input: an existing compartment ocid or the tenancy ocid. Location in your existing compartment structure to create new branch of compartments"
}

variable "prefix" {
  type = string 
  default = ""
  description = "a string to prefix all resource names with. Required for multiple instances of IAM stack to create unqiue names"
  validation {
    condition     = can(regexall("^[A-Za-z][A-Za-z0-9]{1,7}$", var.prefix)) || length(var.prefix) == 0
    error_message = "Validation failed for prefix: value must contain alphanumeric characters only, starting with a letter up to a maximum of 8 characters."
  }
}

variable "enclosing_compartment_name" {
  type = string 
  default = null 
  description = "Input: name for your compartment to enclose the other compartments in. It will be attached to the Existing Compartment. If blank, will create compartments directly in the existing compartment"
}

variable "allow_compartment_deletion" {
  type = bool
  default = false
  description = "if true, allows terraform to delete compartments on a destroy command. if false, the compartment will not be deleted, but will be removed from tfstate file."
}

variable "with_identity_domains" {
  type = bool 
  default = false 
  description = "deployment will differ based on whether or not your tenancy uses Oracle Cloud Infrastructure Identity and Access Management (IAM) with identity domains"
}


# outputs 

output "enclosing_compartment" {
  value = local.enclosing_compartment
  description = "ocid of the enclosing compartment. Will return existing compartment if no enclosing compartment is created"
}


locals {
  enclosing_compartment = var.enclosing_compartment_name != null ? oci_identity_compartment.enclosing[0].id : local.existing_compartment

}


# logic


locals {
  existing_compartment = var.existing_compartment != null ? var.existing_compartment : var.tenancy_ocid
  prefix = var.prefix != "" ? "${var.prefix}-" : ""
}


# resource or mixed module blocks



resource "oci_identity_compartment" "enclosing" {
  count = var.enclosing_compartment_name != null ? 1 : 0
  compartment_id = local.existing_compartment
  description    = "Enclosing Landing Zone compartment for ${var.enclosing_compartment_name}"
  name           = "${local.prefix}${var.enclosing_compartment_name}"
  enable_delete  = var.allow_compartment_deletion
}