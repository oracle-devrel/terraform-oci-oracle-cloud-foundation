
variable "ssh_private_key" {
  type = string
}

variable "host_ips" {
  type = list
}

variable "numWLSInstances" {}

variable "mode" {}

variable "bastion_host" {
  default = ""
}

variable "bastion_host_private_key" {
  default = ""
}

variable "assign_public_ip" {
  type    = bool
  default = true
}

variable "existing_bastion_instance_id" {
  type = string
}