

# inputs

variable "compartment" {
  type = string 
  description = "ocid of the compartment to create resources in."
}
variable "prefix" {
    type = string 
    default = null
    description = "the prefix to append to each resource's name"
}

variable "vcn" {
    type = string 
    description = "The OCID of an existing vcn to create the subnet in"
  
}
variable "vcn_cidrs" {
  type = list(string)
  description = "A list of cidr blocks to enable ICMP security rules to. Typically the list of cidr blocks from the vcn"
}


variable "service_gateway" {
 type = bool 
    default = true
    description = "if true(default), creates routes and SL rule to the Oracle Services Network via the VCNs SGW. Assumes 1 SGW in the vcn"
}
variable "service_gateway_id" {
  type = string 
  default = null 
  description = "optional variable to designate service gateway. Required if service gateway is true"
}
variable "service_cidr" {
  type = string 
  default = null 
  description = "optional variable used when the service gateway id is declared. This is the service cidr used by the service gateway"
}


variable "internet_access" {
    type = string
    default = "none"
    description = "Defines the level of internet access to give the subment. Valid values(gateway): full(IGW), nat(NGW), none"
}
variable "network_gateway_id" {
  type = string 
  default = null 
  description = "optional variable to designate a network (nat or internet) gateway. If null, but internet_access is full or nat, it will attempt to find the appropriate gateway via datasource"
}



# outputs

locals {
    cidr_blocks = local.vcn_cidrs

    service_gateway = var.service_gateway_id

    service_cidr =  var.service_cidr

    network_gateway =  var.network_gateway_id

}

# logic

# resource or mixed module blocks