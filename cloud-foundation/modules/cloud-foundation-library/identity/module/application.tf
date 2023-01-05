# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


# input

# the set of personas needed only for certain applications


variable "create_application_persona" {
    type = bool
    default = false
}

variable "application_name" {
    type = string 
    default = "Application"
    description = "optional custom name for application identity resources"
}

variable "application_type" {
    type = string 
    default = "generic"
    description = "defines the policies applied to each group. Valid values are \"generic\" and \"ebs\" "
}

variable "application_environments" { # rename environments
    type = list(string)
    default = []
    description = "creates sub personas from the main application compartment. Used to isolate admin teams."
}


/* expected defined values 
local.enclosing_compartment - compartment OCID
var.tenancy_ocid - tenancy OCID
var.allow_compartment_deletion - bool
local.prefix - string
var.with_identity_domains - bool

*/

# output

output "application_compartment" {
    value =  var.create_application_persona ? oci_identity_compartment.application[0].id : null 
    description = "ocid of the main application compartment"
}

output "appplication_environment_compartments" {
    value = {for compartment in oci_identity_compartment.environments: compartment.name => compartment.id}
    description = "map of application environment compartments ocid with environment name as key and ocid as value"
}

# logic

locals {

    application_name = "${local.prefix}${var.application_name}"

    environment_names = [for name in var.application_environments: "${local.application_name}-${name}"]

    # first symbol is group name
    # second symbol is a verb + resource type or list of verb + resource type
    # third symbol is compartment name

    # taken from Landing Zone
    app_statements = concat (
        formatlist("allow group %%s to %s in compartment %%s",[
        # manage
        # compute types
        "manage instance-family","manage functions-family", "manage cluster-family",
        # storage types
        "manage volume-family", "manage object-family", "manage repos", 
        #appdev services
        "manage api-gateway-family", "manage bastion-session", "manage streams", 
        # monitoring
        "manage ons-family", "manage alarms", "manage metrics", "manage logs", "manage cloudevents-rules",
        # Resource manager
        "manage orm-stacks", "manage orm-jobs", "manage orm-config-source-providers",
        #File Storage Service
        "manage file-systems", "manage export-sets",

        # read 
        "read all-resources", "read audit-events", "read work-requests",  "read instance-agent-plugins"
    ] ),

    var.application_type == "ebs" #adds additional database policy grants needed for ebs admins
        ? formatlist ("allow group %%s to %s in compartment %%s",[
            "manage database-family", "manage autonomous-database-family", "manage load-balancers", "manage tag-namespaces"
        ]) 
        : []
        
    )


    applied_statement = local.app_statements

}



# resource or mixed module blocks


# application persona

resource "oci_identity_compartment" "application" {
    count = var.create_application_persona ? 1 : 0
    compartment_id = local.enclosing_compartment
    description = "Landing Zone compartment for all resources related to application development: compute instances, storage, functions, OKE, API Gateway, streaming, and others."
    name = local.application_name
    enable_delete = var.allow_compartment_deletion
}

resource "oci_identity_group" "application" {
    count = var.create_application_persona ? 1 : 0
    compartment_id = var.tenancy_ocid
    description = "Landing Zone group for managing app development related services in compartment ${oci_identity_compartment.application[0].name}."
    name = local.application_name

}

resource "oci_identity_policy" "application" {
    count = var.create_application_persona ? 1 : 0
    compartment_id = oci_identity_compartment.application[0].id
    description = "Landing Zone ${oci_identity_group.application[0].name}'s compartment policy."
    name = local.application_name
    statements = [
        for s in local.applied_statement:
            format(s,oci_identity_group.application[0].name,oci_identity_compartment.application[0].name)
    ]

}


#  application persona

resource "oci_identity_group" "environments" {
    for_each =  toset(local.environment_names)

    compartment_id = var.tenancy_ocid
    description = "group for ebs admins"
    name = each.key
  
}

resource "oci_identity_compartment" "environments" {
    for_each =  oci_identity_group.environments

    compartment_id = oci_identity_compartment.application[0].id
    description = "compartment for ${each.key} application"
    name = each.key
    enable_delete = var.allow_compartment_deletion
}

resource "oci_identity_policy" "environments" {
    for_each =  oci_identity_compartment.environments

    compartment_id = each.value.id
    description = "${each.value.name}'s compartment policy"
    name = each.key
    statements = [
        for s in local.applied_statement:
            format(s,oci_identity_group.environments[each.key].name,each.value.name)
    ]
  
}

/*
module "ebs_environments" {
    for_each = toset(local.environment_names)

    source = "./modules/app_persona"

    tenancy_ocid = var.tenancy_ocid
    app_persona = {
        name = "${oci_identity_compartment.application[0].name}-${each.key}"
        persona_type = "application"
        parent_compartment_ocid = oci_identity_compartment.application[0].id
    }
}

*/