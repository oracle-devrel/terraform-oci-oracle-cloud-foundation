# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_apigateway_gateway" "this" {
  compartment_id = var.compartment_id
  endpoint_type  = var.endpoint_type
  subnet_id      = var.subnet_id
  display_name   = var.gateway_display_name

  network_security_group_ids = var.network_security_group_ids
  defined_tags               = var.defined_tags
}

resource "oci_apigateway_deployment" "this" {
  compartment_id = var.compartment_id
  path_prefix    = var.path_prefix
  gateway_id     = oci_apigateway_gateway.this.id
  display_name   = var.deployment_display_name
  defined_tags   = var.defined_tags

  specification {
    logging_policies {
      access_log {
        is_enabled = var.enable_access_log
      }

      execution_log {
        is_enabled = true
        log_level  = var.execution_log_level
      }
    }

    dynamic "routes" {
      for_each = var.http_routes
      iterator = route

      content {
        path    = route.value.path
        methods = route.value.methods

        backend {
          type                       = "HTTP_BACKEND"
          url                        = route.value.url
          connect_timeout_in_seconds = route.value.connect_timeout
          read_timeout_in_seconds    = route.value.read_timeout
          send_timeout_in_seconds    = route.value.send_timeout
          is_ssl_verify_disabled     = route.value.is_ssl_verify_disabled
        }
      }
    }

    dynamic "routes" {
      for_each = var.stock_routes
      iterator = route

      content {
        path    = route.value.path
        methods = route.value.methods

        backend {
          type   = "STOCK_RESPONSE_BACKEND"
          status = route.value.status
          body   = route.value.body

          dynamic "headers" {
            for_each = route.value.headers
            iterator = header

            content {
              name  = header.value.name
              value = header.value.value
            }
          }
        }
      }
    }
  }
}