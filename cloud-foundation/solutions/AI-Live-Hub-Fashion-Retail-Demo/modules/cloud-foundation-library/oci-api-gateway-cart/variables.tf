# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "gateway_display_name" {
  type    = string
  default = "jc-iad-apigw-hub"
}

variable "deployment_display_name" {
  type    = string
  default = "fashion-store-cart-api"
}

variable "endpoint_type" {
  type    = string
  default = "PUBLIC"
}

variable "path_prefix" {
  type    = string
  default = "/v1"
}

variable "execution_log_level" {
  type    = string
  default = "INFO"
}

variable "enable_access_log" {
  type    = bool
  default = false
}

variable "network_security_group_ids" {
  type    = list(string)
  default = []
}

variable "defined_tags" {
  type    = map(string)
  default = {}
}

variable "http_routes" {
  type = list(object({
    path                   = string
    methods                = list(string)
    url                    = string
    connect_timeout        = number
    read_timeout           = number
    send_timeout           = number
    is_ssl_verify_disabled = bool
  }))
  default = []
}

variable "stock_routes" {
  type = list(object({
    path    = string
    methods = list(string)
    status  = number
    body    = string
    headers = list(object({
      name  = string
      value = string
    }))
  }))
  default = []
}