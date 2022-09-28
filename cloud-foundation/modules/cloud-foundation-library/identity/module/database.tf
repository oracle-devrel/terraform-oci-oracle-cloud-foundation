# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


# inputs

variable "create_database_persona" {
  type        = bool
  default     = false
  description = "if true, creates a Database-Admins group to manage Database resources in a specific compartment. It also creates a Database-Service group"
}
variable "database_name" {
  type = string 
  default = "Database"
  description = "optional custom name for database identity resources"
}


/* expected defined values 
local.enclosing_compartment - compartment OCID
var.tenancy_ocid - tenancy OCID
var.allow_compartment_deletion - bool
local.prefix - string

*/

# outputs

output "database_compartment" {
    value = var.create_database_persona ? oci_identity_compartment.database[0].id : null
    description = "ocid of the database compartment"
}



# logic

locals {
  database_name = "${local.prefix}${var.database_name}"
}


# resource or mixed module blocks

resource "oci_identity_compartment" "database" {
  count          = var.create_database_persona ? 1 : 0
  compartment_id = local.enclosing_compartment
  description    = "Landing Zone compartment for all database related resources."
  name           = local.database_name
  enable_delete  = var.allow_compartment_deletion
}

resource "oci_identity_group" "database" {
  count          = var.create_database_persona ? 1 : 0
  compartment_id = var.tenancy_ocid
  description    = "Landing Zone group for managing databases in compartment ${oci_identity_compartment.database[0].name}."
  name           = "${local.database_name}-Admins"
}

resource "oci_identity_group" "database_service" {
  count          = var.create_database_persona ? 1 : 0
  compartment_id = var.tenancy_ocid
  description    = "Landing Zone group for users of the database team to access databases in comparment ${oci_identity_compartment.database[0].name}."
  name           = "${local.database_name}-Service"
}

resource "oci_identity_policy" "database" {
  count          = var.create_database_persona ? 1 : 0
  compartment_id = oci_identity_compartment.database[0].id
  description    = "Landing Zone policy for ${oci_identity_group.database[0].name}'s group and ${oci_identity_group.database_service[0].name} to manage database related services in Landing Zone compartment ${oci_identity_compartment.database[0].name}."
  name           = local.database_name
  statements     = concat(
      # database team in database compartment
      formatlist("allow group ${oci_identity_group.database[0].name} to %s in compartment ${oci_identity_compartment.database[0].name}", [
        "read all-resources", "manage database-family", "manage autonomous-database-family", "manage alarms", "manage metrics",
        "manage object-family", "manage orm-stacks", "manage orm-jobs", "manage orm-config-source-providers", "read audit-events",
        "read work-requests", "manage instance-family", "manage bastion-session", "read instance-agent-plugins",
        "manage cloudevents-rules",
      ]),

      # database users in database compartment
      formatlist("allow group ${oci_identity_group.database_service[0].name} to %s in compartment ${oci_identity_compartment.database[0].name}", [
        "read autonomous-database-family", "read database-family"
      ])
    )
}