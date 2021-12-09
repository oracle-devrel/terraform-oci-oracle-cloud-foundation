# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.
variable "lb-params" {
  type = map(object({
    shape          = string
    compartment_id = string
    subnet_ids  = list(string)
    maximum_bandwidth_in_mbps = string
    minimum_bandwidth_in_mbps = string
    display_name  = string
    is_private    = string
    defined_tags  = map(string)
    freeform_tags = map(string)
}))
}


variable "lb-backendset-params" {
  type = map(object({
    name       = string
    load_balancer_id         = string
    policy                   = string
    port       = string
    protocol   = string
    response_body_regex      = string
    url_path                 = string
    return_code              = string
  }))
}

variable "lb-listener-https-params" {
  type = map(object({
    load_balancer_id         = string
    name                     = string
    default_backend_set_name = string
    port                     = string
    protocol                 = string
    rule_set_names           = list(string)

    idle_timeout_in_seconds  = string

    certificate_name = string
    verify_peer_certificate = string
  }))
}

variable "lb-backend-params" {
   type = map(object({
     load_balancer_id = string
     backendset_name  = string
     ip_address       = string
     port             = string
     backup           = string
     drain            = string
     offline          = string
     weight           = string
   }))
}

variable "SSL_headers-params" {
   type = map(object({
   load_balancer_id = string
    name             = string
    SSLitems = list(map(object({
      action = string
      header = string
      value = string
    })))
    countSSL = number
   }))
}

variable "demo_certificate-params" {
   type = map(object({
    certificate_name = string
    load_balancer_id = string
    #Optional
    public_certificate = string
    private_key        = string
   }))
}