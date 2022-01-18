# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_apigateway_gateway" "this" {
  for_each       = var.apigw_params
  compartment_id = each.value.compartment_id
  endpoint_type  = each.value.endpoint_type
  subnet_id      = each.value.subnet_id
  display_name   = each.value.display_name
  defined_tags   = each.value.defined_tags
}

data "oci_apigateway_gateways" "existing" {
  for_each       = var.apigw_params
  compartment_id = each.value.compartment_id
}

resource "oci_apigateway_deployment" "this" {
  for_each       = var.gwdeploy_params
  compartment_id = each.value.compartment_id
  path_prefix    = each.value.path_prefix
  gateway_id     = oci_apigateway_gateway.this[each.value.gateway_name].id
  display_name   = each.value.display_name
  defined_tags   = each.value.defined_tags

  specification {

    logging_policies {
      access_log {
        is_enabled = each.value.access_log
      }

      execution_log {
        is_enabled = each.value.exec_log_lvl != null ? true : false
        log_level  = each.value.exec_log_lvl != null ? each.value.exec_log_lvl : null
      }
    }

    dynamic "routes" {
      iterator = routes
      for_each = (lookup(each.value, "function_routes", null) != null) ? each.value.function_routes : []

      content {
        methods = routes.value.methods
        path    = routes.value.path
        backend {
          type        = local.backend_types[routes.value.type]
          function_id = routes.value.function_id
        }
      }
    }

    dynamic "routes" {
      iterator = routes
      for_each = (lookup(each.value, "http_routes", null) != null) ? each.value.http_routes : []

      content {
        methods = routes.value.methods
        path    = routes.value.path

        backend {
          type                       = local.backend_types[routes.value.type]
          url                        = routes.value.url
          is_ssl_verify_disabled     = routes.value.ssl_verify
          connect_timeout_in_seconds = routes.value.connect_timeout
          read_timeout_in_seconds    = routes.value.read_timeout
          send_timeout_in_seconds    = routes.value.send_timeout
        }
      }
    }

    dynamic "routes" {
      iterator = routes
      for_each = (lookup(each.value, "stock_routes", null) != null) ? each.value.stock_routes : []

      content {
        methods = routes.value.methods
        path    = routes.value.path

        backend {
          type   = local.backend_types[routes.value.type]
          status = routes.value.status
          body   = routes.value.body
          dynamic "headers" {
            iterator = headers
            for_each = routes.value.type == "stock_response" ? routes.value.headers : []
            content {
              name  = headers.value.name
              value = headers.value.value
            }
          }
        }
      }
    }

  }
}

data "oci_apigateway_deployments" "existing" {
  for_each       = var.gwdeploy_params
  compartment_id = each.value.compartment_id
}

locals {
  backend_types = {
    function       = "ORACLE_FUNCTIONS_BACKEND"
    http           = "HTTP_BACKEND"
    stock_response = "STOCK_RESPONSE_BACKEND"
  }
}