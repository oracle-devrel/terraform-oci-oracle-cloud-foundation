
variable "compartment_id" {}

variable "tags" {
description = "CloudFoundationORCL"
type = list(object({
  tag_namespace = string
  tag_namespace_description = string
  tag_name = list(string)
  }))
}