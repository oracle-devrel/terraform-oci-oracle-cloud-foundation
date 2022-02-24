variable "bv_params" {
  type = map(object({
    ad                   = string
    compartment_id       = string
    display_name         = string
    bv_size              = number
    defined_tags         = map(string)
    freeform_tags        = map(string)
  }))
}

variable "bv_attach_params" {
  type = map(object({
    display_name         = string
    attachment_type      = string
    instance_id          = string
    volume_id            = string
  }))
}

