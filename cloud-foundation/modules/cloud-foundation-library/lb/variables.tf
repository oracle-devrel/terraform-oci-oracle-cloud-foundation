variable "lb-params" {
  type = map(object({
    shape          = string
    compartment_id = string
    subnet_ids  = list(string)
    network_security_group_ids = list(string)
    maximum_bandwidth_in_mbps = string
    minimum_bandwidth_in_mbps = string
    display_name  = string
    is_private    = string
    defined_tags  = map(string)
    freeform_tags = map(string)
}))
  default = {empty={shape="", compartment_id="", subnet_ids=[""], network_security_group_ids= [""], maximum_bandwidth_in_mbps="", minimum_bandwidth_in_mbps="",display_name="", is_private="",defined_tags={}, freeform_tags={}}}
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
    certificate_ids = list(string) 
    certificate_name = string
    cipher_suite_name = string
    protocols = list(string)
    server_order_preference = string
    trusted_certificate_authority_ids = list(string)
    verify_depth = string
    verify_peer_certificate = string
    }))

  default = {
    empty={name="", load_balancer_id="", policy="", port="", protocol="",response_body_regex="", url_path="", return_code="", 
        certificate_ids = null,
        certificate_name = null,
        cipher_suite_name = null,
        protocols = null,
        trusted_certificate_authority_ids = null,
        server_order_preference = null,
        verify_depth = null,
        verify_peer_certificate = null}
  }
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

  default = {
      empty={load_balancer_id = "", name = "", default_backend_set_name = "", port  = "", protocol = "", rule_set_names=[""], idle_timeout_in_seconds="",certificate_name="",verify_peer_certificate=""}
  }
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
  default = {empty={load_balancer_id="", backendset_name="",ip_address="",port="",backup="", drain="", offline="", weight=""}}
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
  default = {empty={load_balancer_id="", name="", SSLitems=[{item={action="",header="",value=""}}],countSSL=0}}
}

variable "demo_certificate-params" {
   type = map(object({
    certificate_name = string
    load_balancer_id = string
    #Optional
    public_certificate = string
    private_key        = string
    ca_certificate     = string 
    passphrase         = string
   }))
 default = {empty={certificate_name = "", load_balancer_id = "", public_certificate = "", private_key = "",
 ca_certificate = null, passphrase = null}}
}