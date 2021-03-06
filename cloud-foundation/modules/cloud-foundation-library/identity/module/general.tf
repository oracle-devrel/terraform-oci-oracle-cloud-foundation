

# inputs

variable "create_general_persona" {
  type = bool 
  default = false 
  description = "if true, creates a general-service group to grant certain read permissions across the tenancy. Always created at the tenancy level"
}

/* expected defined values 
var.tenancy_ocid - tenancy OCID

*/

# outputs


# logic


# resource or mixed module blocks

resource "oci_identity_policy" "general" {
  count          = var.create_general_persona ? 1 : 0
  compartment_id = var.tenancy_ocid
  description    = "general policy applying to any user"
  name           = "general"
  statements     = concat(formatlist("allow any-user to %s in tenancy", [
      "read app-catalog-listing", "read instance-images", "read repos", "inspect users", "inspect groups", "inspect dynamic-groups"
    ]))
}