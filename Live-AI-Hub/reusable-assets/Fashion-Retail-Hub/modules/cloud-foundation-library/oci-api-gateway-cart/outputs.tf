# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "gateway_id" {
  value = oci_apigateway_gateway.this.id
}

output "gateway_display_name" {
  value = oci_apigateway_gateway.this.display_name
}

output "gateway_hostname" {
  value = oci_apigateway_gateway.this.hostname
}

output "deployment_id" {
  value = oci_apigateway_deployment.this.id
}

output "deployment_display_name" {
  value = oci_apigateway_deployment.this.display_name
}

output "deployment_endpoint" {
  value = oci_apigateway_deployment.this.endpoint
}

output "routes" {
  value = concat(
    [
      for r in var.stock_routes :
      "${oci_apigateway_deployment.this.endpoint}${r.path}"
    ],
    [
      for r in var.http_routes :
      "${oci_apigateway_deployment.this.endpoint}${r.path}"
    ]
  )
}