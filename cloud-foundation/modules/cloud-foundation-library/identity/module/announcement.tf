# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


# inputs

variable "create_announcement_persona" {
  type        = bool
  default     = false
  description = "if true, creates a group for reading console annoucements in the tenancy"
}

/* expected defined values 
var.tenancy_ocid - tenancy OCID

*/

# outputs


# logic


# resource or mixed module blocks


resource "oci_identity_group" "announcement" {
  count          = var.create_announcement_persona ? 1 : 0
  compartment_id = var.tenancy_ocid
  description    = "Landing Zone group for reading Console announcements."
  name           = "announcement_group"

}

resource "oci_identity_policy" "announcement" {
  count          = var.create_announcement_persona ? 1 : 0
  compartment_id = var.tenancy_ocid
  description    = "Landing Zone ${oci_identity_group.announcement[0].name}'s root compartment policy."
  name           = "announcement_policy"
  statements = ["allow group ${oci_identity_group.announcement[0].name} to read announcements in tenancy",
  "allow group ${oci_identity_group.announcement[0].name} to use cloud-shell in tenancy"]
}