

# inputs

variable "create_cost_persona" {
  type        = bool
  default     = false
  description = "if true, creates a group to manage cost/budgets in tenancy"
}

/* expected defined values 
var.tenancy_ocid - tenancy OCID

*/

# outputs


# logic


# resource or mixed module blocks

resource "oci_identity_group" "cost" {
  count          = var.create_cost_persona ? 1 : 0
  compartment_id = var.tenancy_ocid
  description    = "Landing Zone group for Cost Management."
  name           = "cost_group"

}

resource "oci_identity_policy" "cost_policy" {
  count          = var.create_cost_persona ? 1 : 0
  compartment_id = var.tenancy_ocid
  description    = "Landing Zone ${oci_identity_group.cost[0].name}'s root compartment policy."
  name           = "cost_policy"
  statements = ["define tenancy usage-report as ocid1.tenancy.oc1..aaaaaaaaned4fkpkisbwjlr56u7cj63lf3wffbilvqknstgtvzub7vhqkggq",
    "Allow group ${oci_identity_group.cost[0].name} to manage usage-report in tenancy",
    "Allow group ${oci_identity_group.cost[0].name} to manage usage-budgets in tenancy",
  "endorse group ${oci_identity_group.cost[0].name} to read objects in tenancy usage-report"]

}