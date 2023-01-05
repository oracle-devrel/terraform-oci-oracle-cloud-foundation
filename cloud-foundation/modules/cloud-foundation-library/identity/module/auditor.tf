# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


# inputs

variable "create_auditor_persona" {
  type        = bool
  default     = false
  description = "if true, creates a group to audit the tenancy"
}

/* expected defined values 
var.tenancy_ocid - tenancy OCID

*/

# outputs


# logic


# resource or mixed module blocks


resource "oci_identity_group" "auditor" {
  count          = var.create_auditor_persona ? 1 : 0
  compartment_id = var.tenancy_ocid
  description    = "Landing Zone group for auditing the tenancy."
  name           = "auditor_group"

}

resource "oci_identity_policy" "auditor" {
  count          = var.create_auditor_persona ? 1 : 0
  compartment_id = var.tenancy_ocid
  description    = "Landing Zone ${oci_identity_group.auditor[0].name}'s root compartment policy."
  name           = "auditor_policy"
  statements = concat(
    #tenancy-wide
    formatlist("allow group ${oci_identity_group.auditor[0].name} to %s in tenancy", [
      # inspect everything
      "inspect all-resources",
      # read compute
      "read instances", "read instance-configurations",
      # read networking
      "read load-balancers", "read nat-gateways", "read public-ips", "read network-security-groups",
      # read storage
      "read file-family", "read buckets",
      # read iam/security
      "read resource-availability", "read vss-family", "read audit-events", "read users", "read usage-budgets", "read usage-reports",
      # command line access
      "use cloud-shell",
    ])

  )



}