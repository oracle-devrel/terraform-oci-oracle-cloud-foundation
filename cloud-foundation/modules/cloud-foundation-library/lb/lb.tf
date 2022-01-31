# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_load_balancer_load_balancer" "loadbalancer" {
  for_each = {
    for k,v in var.lb-params : k => v if v.display_name != ""
  } 
    shape          = each.value.shape
    compartment_id = each.value.compartment_id

  subnet_ids = each.value.subnet_ids
  
  shape_details {
    #Required
    maximum_bandwidth_in_mbps = each.value.maximum_bandwidth_in_mbps
    minimum_bandwidth_in_mbps = each.value.minimum_bandwidth_in_mbps
  }
  display_name  = each.value.display_name
  is_private    = each.value.is_private
  defined_tags  = each.value.defined_tags
  freeform_tags = each.value.freeform_tags
}

resource "oci_load_balancer_backend_set" "lb-backendset" {

  for_each = {
    for k,v in var.lb-backendset-params : k => v if v.name != ""
  } 
    name             = each.value.name
    load_balancer_id = each.value.load_balancer_id
    policy           = each.value.policy

  health_checker {
    port                = each.value.port
    protocol            = each.value.protocol
    response_body_regex = each.value.response_body_regex
    url_path            = each.value.url_path
    return_code         = each.value.return_code
  }

  # Set the session persistence to lb-session-persistence with all default values.
  lb_cookie_session_persistence_configuration {}

}

resource "oci_load_balancer_listener" "lb-listener-https" {
  for_each = {
    for k,v in var.lb-listener-https-params : k => v if v.name != ""
  }
    load_balancer_id         = each.value.load_balancer_id
    name                     = each.value.name
    default_backend_set_name = each.value.default_backend_set_name
    port                     = each.value.port
    protocol                 = each.value.protocol
    rule_set_names           = each.value.rule_set_names

    connection_configuration {
      idle_timeout_in_seconds = each.value.idle_timeout_in_seconds
    }
  
    ssl_configuration {
      #Required
      certificate_name = each.value.certificate_name
      verify_peer_certificate = each.value.verify_peer_certificate
    }
}

resource "oci_load_balancer_backend" "lb-backend" {
  for_each = {
    for k,v in var.lb-backend-params : k => v if v.backendset_name != ""
  }
    load_balancer_id = each.value.load_balancer_id
    backendset_name  = each.value.backendset_name
    ip_address       = each.value.ip_address
    port             = each.value.port
    backup           = each.value.backup
    drain            = each.value.drain
    offline          = each.value.offline
    weight           = each.value.weight

  lifecycle {
    ignore_changes = [offline]
  }
}

resource "oci_load_balancer_rule_set" "SSL_headers" {
 
  for_each = {
    for k,v in var.SSL_headers-params : k => v if v.name != ""
  }
    load_balancer_id = each.value.load_balancer_id
    name             = each.value.name

    dynamic "items" {
    iterator = it
     for_each = [ for k in range(each.value.countSSL) :
     {
       "action" : each.value.SSLitems[k].item.action
       "header" : each.value.SSLitems[k].item.header
       "value"  : each.value.SSLitems[k].item.value

     }]
       content{ 
        action = it.value.action
        header = it.value.header
        value  = it.value.value
    }
       }
    
}

resource "oci_load_balancer_certificate" "demo_certificate" {
  
  for_each = {
    for k,v in var.demo_certificate-params : k => v if v.certificate_name != ""
  }
  
    #Required
    certificate_name = each.value.certificate_name
    load_balancer_id = each.value.load_balancer_id

    #Optional
    public_certificate = each.value.public_certificate
    private_key        = each.value.private_key

    lifecycle {
      create_before_destroy = true
    }
}