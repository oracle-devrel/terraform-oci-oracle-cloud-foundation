#Tenancy details

variable "compartment_ocid" {}

variable "tenancy_ocid" {}

variable "service_name_prefix" {}

variable "allow_manual_domain_extension" {
  type = bool
}

variable "add_load_balancer" {
  type = bool
}

variable "lbCount" {}

variable "numWLSInstances" {}

variable "subnet_ocids" {
  type = list
}

variable "instance_private_ips" {
  type = list
}

variable "name" {
  default = "wls-loadbalancer"
}

variable "is_private" {
  default = "false"
}

variable "lb_max_bandwidth" {
  type = number
  default = 400
  description = "Maximum bandwidth for the load balancer"
}

variable "lb_min_bandwidth" {
  type        = number
  default     = 10
  description = "Minimum bandwidth for the load balancer"
}

variable "wls_ms_port" {}

variable "lb-protocol" {
  default = "HTTP"
}

variable "lb-lstr-port" {
  default = "80"
}

variable "lb-https-lstr-port" {
  default = "443"
}

variable "return_code" {
  default = "404"
}

variable "policy_weight" {
  default = "1"
}

variable "lb_backendset_name" {
  default = "wls-lb-backendset"
}

 variable "lb_policy" {
  default = "ROUND_ROBIN"
}

variable "is_idcs_selected" {}

variable "idcs_cloudgate_port" {}

variable "defined_tags" {
  type=map
  default = {}
}

variable "freeform_tags" {
  type=map
  default = {}
}
variable "lb_certificate_name" {
  type = string
  default = "demo_cert"
}

variable "public_certificate" {
  type = map
}

variable "private_key" {
  type = map
}




