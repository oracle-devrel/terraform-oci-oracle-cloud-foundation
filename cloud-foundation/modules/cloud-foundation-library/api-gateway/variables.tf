# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "apigw_params" {
  type = map(object({
    compartment_id = string
    subnet_id      = string
    display_name   = string
    endpoint_type  = string
    defined_tags   = map(string)
  }))
}


variable "gwdeploy_params" {
  description = "API Gateway Deployment Params"
  type = map(object({
    compartment_id   = string
    gateway_name     = string
    display_name     = string
    path_prefix      = string
    access_log       = bool
    exec_log_lvl     = string
    defined_tags   = map(string)
    function_routes = list(object({
      type          = string
      path          = string
      methods       = list(string)
      function_id   = string
    }))
    http_routes = list(object({
      type            = string
      path            = string
      methods         = list(string)
      url             = string
      connect_timeout = number
      ssl_verify      = bool
      read_timeout    = number
      send_timeout    = number
    }))
    stock_routes = list(object({
      type    = string
      path    = string
      methods = list(string)
      status  = number
      body    = string
      headers = list(object({
        name  = string
        value = string
      }))
    }))
  }))
}
