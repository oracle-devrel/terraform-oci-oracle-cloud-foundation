# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


# inputs

variable "create_custom_persona" {
  type        = bool
  default     = false
  description = "if true, creates a custom set of persona resources based on the input provided"
}

variable "custom_persona_name" {
  type = string 
  default = ""
  description = "name of custom persona you wish to create. only used if create custom persona is true."
}

variable "create_custom_compartment" {
    type = bool 
    default = true 
    description = "if true creates a custom compartment. Otherwise uses enclosing/existing compartment to create other persona resources. only used if create custom persona is true."
}

variable "custom_policy_permissions" {
    type = list(string)
    default = ["read all-resources"]
    description = "List of policy permissions (verb + resource) to give to custom group. See docs for full policy syntax: https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policysyntax.htm"
}

/* expected defined values 
local.enclosing_compartment - compartment OCID
var.tenancy_ocid - tenancy OCID
var.allow_compartment_deletion - bool
local.prefix - string

*/


# outputs


# logic

locals {

    custom_persona_name = "${local.prefix}${var.custom_persona_name}"

    custom_compartment_name = (
      var.create_custom_persona
        ? var.create_custom_compartment 
          ? oci_identity_compartment.custom[0].name 
          : data.oci_identity_compartment.enclosing[0].name
        : null)
}


# resource or mixed module blocks

# if creating custom persona, either create a custom compartment or use the enclosing compartment
resource "oci_identity_compartment" "custom" {
  count          = var.create_custom_persona && var.create_custom_compartment ? 1 : 0
  compartment_id = local.enclosing_compartment
  description    = "Landing Zone compartment for all database related resources."
  name           = local.custom_persona_name
  enable_delete  = var.allow_compartment_deletion
}
data "oci_identity_compartment" "enclosing" {
  count = var.create_custom_persona && !var.create_custom_compartment ? 1 : 0
  id = local.enclosing_compartment
}


resource "oci_identity_group" "custom" {
  count          = var.create_custom_persona ? 1 : 0
  compartment_id = var.tenancy_ocid
  description    = "Landing Zone group for managing databases in compartment ${local.custom_compartment_name}."
  name           = local.custom_persona_name
}

resource "oci_identity_policy" "custom" {
  count          = var.create_custom_persona ? 1 : 0
  compartment_id = oci_identity_compartment.custom[0].id
  description    = "Landing Zone policy for ${oci_identity_group.custom[0].name}'s group  to manage a custom defined set of resources in Landing Zone compartment ${local.custom_compartment_name}."
  name           = local.custom_persona_name
  statements     = concat (
    formatlist("allow group ${oci_identity_group.custom[0].name} to %s in compartment ${local.custom_compartment_name}",
      var.custom_policy_permissions
       )
  )
}