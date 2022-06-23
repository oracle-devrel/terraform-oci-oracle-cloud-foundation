

# inputs

# cred persona can manage users in IAM, but can't modify groups/policies
# IAM admins can do everything else in IAM but managing users
variable "create_identity_persona" {
  type        = bool
  default     = false
  description = "if true, creates an IAM group to manage IAM resources minus users in the tenancy and a credential group to manage iam users credentials in the tenancy. Always created at tenancy level"
}

/* expected defined values 
var.tenancy_ocid - tenancy OCID
var.allow_compartment_deletion - bool

*/

# outputs


# logic


# resource or mixed module blocks


# iam
# uses root as compartment

resource "oci_identity_group" "iam" {
  count          = var.create_identity_persona ? 1 : 0
  compartment_id = var.tenancy_ocid
  description    = "Landing Zone group for managing IAM resources minus users in the tenancy."
  name           = "iam"
}

resource "oci_identity_policy" "iam" {
  count          = var.create_identity_persona ? 1 : 0
  compartment_id = var.tenancy_ocid
  description    = "${oci_identity_group.iam[0].name}'s policy"
  name           = "iam"
  statements = concat(
    formatlist("allow group ${oci_identity_group.iam[0].name} to %s in tenancy", [
      # inspect
      "inspect users", "inspect groups", "inspect identity-providers",
      # read
      "read audit-events",
      # use 
      "use cloud-shell",
      # manage
      "manage dynamic-groups", "manage authentication-policies", "manage network-sources", "manage quota",
      "manage tag-defaults", "manage tag-namespaces", "manage orm-stacks", "manage orm-jobs", "manage orm-config-source-providers",
      "manage policies", "manage compartments",
    ]),
    ["allow group ${oci_identity_group.iam[0].name} to manage groups in tenancy where all {target.group.name != 'Administrators', target.group.name != '${oci_identity_group.cred[0].name}'}",
      "allow group ${oci_identity_group.iam[0].name} to manage identity-providers in tenancy where any {request.operation = 'AddIdpGroupMapping', request.operation = 'DeleteIdpGroupMapping'}",
    ]
  )
}

# cred
# uses root as compartment

resource "oci_identity_group" "cred" {
  count          = var.create_identity_persona ? 1 : 0
  compartment_id = var.tenancy_ocid
  description    = "Landing Zone group for managing iam users credentials in the tenancy."
  name           = "cred"
}

resource "oci_identity_policy" "cred" {
  count          = var.create_identity_persona ? 1 : 0
  compartment_id = var.tenancy_ocid
  description    = "${oci_identity_group.cred[0].name}'s policy"
  name           = "cred"
  statements = concat(
    formatlist("Allow group ${oci_identity_group.cred[0].name} to %s in tenancy", [
      # inspect
      "inspect users", "inspect groups",
      # use
      "use cloud-shell"
    ]),
    ["Allow group ${oci_identity_group.cred[0].name} to manage users in tenancy  where any {request.operation = 'ListApiKeys',request.operation = 'ListAuthTokens',request.operation = 'ListCustomerSecretKeys',request.operation = 'UploadApiKey',request.operation = 'DeleteApiKey',request.operation = 'UpdateAuthToken',request.operation = 'CreateAuthToken',request.operation = 'DeleteAuthToken',request.operation = 'CreateSecretKey',request.operation = 'UpdateCustomerSecretKey',request.operation = 'DeleteCustomerSecretKey',request.operation = 'UpdateUserCapabilities'}", ]
  )
}