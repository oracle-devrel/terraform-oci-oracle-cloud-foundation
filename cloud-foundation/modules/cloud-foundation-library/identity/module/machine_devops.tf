# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


# inputs

variable "enable_devops" {
    default = false
    type = bool
    description = "if true, allows for the creation of dynamic groups and policies enabling multiple devops resources to access required resources in the application compartment. Note: this is a top level toggle. You will additionally need to toggle on the parts of the devops service you wish to use"
}


variable "enable_build_pipelines" {
  default = false 
  type = bool 
}
variable "enable_managed_builds" {
  default = false
  type = bool
}
variable "enable_artifact_delivery" {
  default = false 
  type = bool 
}
variable "enable_trigger_deployment" {
  default = false 
  type = bool 
}
variable "enable_ADM" {
  default = false 
  type = bool 
}
# code and external repos might belong under build pipelines or might be seperate
variable "enable_mirrored_repos" {
  default = false 
  type = bool
  description = "if true, "
}
variable "enable_external_repos" {
  default = false 
  type = bool # TODO: might required code repos enabled, might be mutually exclusive
}



variable "enable_deploy_pipelines" {
  default = false 
  type = bool
}
variable "target_environment_OKE" {
  default = false 
  type = bool
}
variable "target_environment_compute" {
  default = false 
  type = bool
}
variable "target_environment_functions" {
  default = false 
  type = bool
}


/* expected values 
oci_identity_compartment.application - resource
    - id and name

oci_identity_compartment.security - resource
    - id and name
*/

# outputs


# logic

locals {

  deploy_targets = concat(
    var.target_environment_OKE ? ["read all-artifacts", "manage cluster"] : [],
    var.target_environment_compute ? ["read all-artifacts", "read instance-family", "use instance-agent-command-family", "use load-balancers"] : [], 
    #TODO: LBs could be in application compartment or network compartment
    var.target_environment_functions ? ["manage fn-function", "read fn-app", "use fn-invocation"] : [],
  )

  build_rules = concat (
    var.enable_mirrored_repos || var.enable_managed_builds || var.enable_artifact_delivery || var.enable_trigger_deployment ? ["manage devops-family"] : [],
    var.enable_managed_builds || var.enable_artifact_delivery || var.enable_trigger_deployment ? ["use ons-topics"] : [],
    var.enable_artifact_delivery ? ["manage repos", "manage generic-artifacts",] : [],
    var.enable_ADM ? ["use adm-knowledge-bases", "manage adm-vulnerability-audits"] : [], # TODO: where would ADM live? application or security
  )

  build_rules_security = concat(
    var.enable_mirrored_repos || var.enable_external_repos || var.enable_managed_builds ? ["read secret-family"] : []
  )

}


# resource or mixed module blocks



# Deploy pipelines
resource "oci_identity_dynamic_group" "deploy_pipelines" {
    count = var.enable_devops && var.enable_deploy_pipelines ? 1 : 0
    compartment_id = var.tenancy_ocid
    description = "all Deploy pipelines in ${oci_identity_compartment.application[0].name} compartment"
    matching_rule = "All {resource.type = 'devopsdeploypipeline', resource.compartment.id = 'oci_identity_compartment.application[0].id'}"
    name = "${oci_identity_compartment.application[0].name}-deploy-pipelines"
}

resource "oci_identity_policy" "deploy_pipelines" {
    count = var.enable_devops && var.enable_deploy_pipelines  ? 1 : 0

    compartment_id = oci_identity_compartment.application[0].id
    description = "enables deploy pipeline dynamic group to deploy to the desired target types in ${oci_identity_compartment.application[0].name} compartment"
    name = "${oci_identity_compartment.application[0].name}-deploy-pipelines"
    statements = concat(
      formatlist("allow dynamic-group ${oci_identity_dynamic_group.deploy_pipelines[0].name} to %s in compartment ${oci_identity_compartment.application[0].name}",
        local.deploy_targets
      ),
    )
}

# compute instances
# if compute instances are one of the desired target environments, it also needs a dynamic group to work properly
resource "oci_identity_dynamic_group" "compute" {
    count = var.enable_devops && var.enable_deploy_pipelines && var.target_environment_compute ? 1 : 0
    compartment_id = var.tenancy_ocid
    description = "all compute instances in ${oci_identity_compartment.application[0].name} compartment"
    matching_rule = "All {instance.compartment.id = 'oci_identity_compartment.application[0].id'}"
    name = "${oci_identity_compartment.application[0].name}-compute"
}

resource "oci_identity_policy" "compute" {
    count = var.enable_devops && var.enable_deploy_pipelines && var.target_environment_compute ? 1 : 0

    compartment_id = oci_identity_compartment.application[0].id
    description = "enables compute dynamic group to work with devops service in ${oci_identity_compartment.application[0].name} compartment"
    name = "${oci_identity_compartment.application[0].name}-compute"
    statements = concat(
      formatlist("allow dynamic-group ${oci_identity_dynamic_group.compute[0].name} to %s in compartment ${oci_identity_compartment.application[0].name}", [
        "read generic-artifacts", "use instance-agent-command-execution-family"
      ]),
    )
}

# all devops services
resource "oci_identity_dynamic_group" "devops_services" {
    count = var.enable_devops && var.enable_build_pipelines ? 1 : 0
    compartment_id = var.tenancy_ocid
    description = "all Devops services (build, deploy, repo, connection, and trigger) in ${oci_identity_compartment.application[0].name} compartment"
    matching_rule = "All {resource.compartment.id = 'oci_identity_compartment.application[0].id', Any {resource.type = 'devopsdeploypipeline', resource.type = 'devopsbuildpipeline', resource.type = 'devopsrepository', resource.type = 'devopsconnection', resource.type = 'devopstrigger'}}"
    name = "${oci_identity_compartment.application[0].name}-devops-services"
}

resource "oci_identity_policy" "devops_services" {
    count = var.enable_devops && var.enable_deploy_pipelines ? 1 : 0

    compartment_id = oci_identity_compartment.application[0].id
    description = "enables devops services dynamic group to work with devops service in ${oci_identity_compartment.application[0].name} compartment"
    name = "${oci_identity_compartment.application[0].name}-devops-services"
    statements = concat(
      formatlist("allow dynamic-group ${oci_identity_dynamic_group.devops_services[0].name} to %s in compartment ${oci_identity_compartment.application[0].name}",
        local.build_rules
      ),
    )
}

resource "oci_identity_policy" "devops_services_security" {
    count = var.enable_devops && var.enable_deploy_pipelines && (var.enable_mirrored_repos || var.enable_external_repos || var.enable_managed_builds) ? 1 : 0

    compartment_id = oci_identity_compartment.security[0].id
    description = "enables devops services dynamic group to read secret-family in ${oci_identity_compartment.security[0].name} compartment"
    name = "${oci_identity_compartment.security[0].name}-devops-services-security"
    statements = concat(
      formatlist("allow dynamic-group ${oci_identity_dynamic_group.devops_services[0].name} to %s in compartment ${oci_identity_compartment.security[0].name}",
        local.build_rules_security
      ),
    )
}




