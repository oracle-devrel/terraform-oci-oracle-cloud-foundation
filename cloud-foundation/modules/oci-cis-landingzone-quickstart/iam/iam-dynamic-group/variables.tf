
variable "dynamic_groups" {
  type = map(object({
    description    = string
    compartment_id = string
    matching_rule  = string
  }))
}  