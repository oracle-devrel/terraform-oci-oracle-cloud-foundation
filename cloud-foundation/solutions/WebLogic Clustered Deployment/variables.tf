variable "tenancy_ocid" {}
variable "region" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}


/*
*********************************
* WebLogic Instance Configuration
*********************************
*/

variable "create_policies" {
  type = bool
  default = true
}

variable "ssh_public_key" {
  description = "public key for ssh access to weblogic instances"
}

variable "service_name" {
  type        = string
  description = "prefix for resources"
}

#WebLogic custom image OCID
variable "instance_image_id" {}
variable "image_version" {
  default = ""
}

variable "network_compartment_id" {
  type    = string
  default = ""
  description = "compartment for network resources"
}

variable "wls_node_count" {
  type    = number
  default = "1"
  description = "number of weblogic managed servers"
}

variable "wls_node_count_limit" {
  type    = number
  default = "8"
  description = "Maximum number of weblogic managed servers"
}

variable "instance_shape" {
  type        = string
  description = "shape of weblogic VM instances"

}

variable "bastion_instance_shape" {
  type        = string
  default     = "VM.Standard2.1"
  description = "default shape of bastion VM instances"
}

variable "wls_admin_user" {
  type        = string
  default     = "weblogic"
  description = "weblogic admin user"
}

variable "wls_admin_password_ocid" {
  type        = string
  default     = ""
  description = "weblogic admin password"
}

variable "wls_nm_port" {
  type    = string
  default = "5556"
  description = "node manager port"
}

variable "wls_extern_admin_port" {
  type    = string
  default = "7001"
  description = "weblogic console port"
}

variable "wls_extern_ssl_admin_port" {
  type    = string
  default = "7002"
  description = "weblogic console ssl port"
}

variable "wls_cluster_mc_port" {
  type    = string
  default = "5555"
  description = "weblogic multi cluster port"
}

variable "wls_admin_port" {
  type    = string
  default = "9071"
  description = "weblogic default admin port"
}

variable "wls_ssl_admin_port" {
  type    = string
  default = "9072"
  description = "weblogic external admin ssl port"
}

variable "wls_ms_extern_port" {
  type    = string
  default = "7003"
  description = "weblogic managed server external HTTP port"
}

variable "wls_ms_extern_ssl_port" {
  type    = string
  default = "7004"
  description = "weblogic managed server external ssl port"
}

variable "wls_ms_port" {
  type    = string
  default = "9073"
  description = "weblogic managed server port"
}

variable "wls_ms_ssl_port" {
  type    = string
  default = "9074"
  description = "weblogic managed server ssl port"
}

variable "wls_expose_admin_port" {
  type = bool
  default = false
  description = "[WARNING] Selecting this option will expose the console to the internet if the default 0.0.0.0/0 CIDR is used. You should change the CIDR range below to allow access to a trusted IP range."
}

variable "wls_admin_port_source_cidr" {
  type = string
  default = "0.0.0.0/0"
  description = "Create a security list to allow access to the WebLogic Administration Console port to the source CIDR range. [WARNING] Keeping the default 0.0.0.0/0 CIDR will expose the console to the internet. You should change the CIDR range to allow access to a trusted IP range."
}

variable "allow_manual_domain_extension" {
  type = bool
  default = false
  description = "flag indicating that domain will be manually extended for managed servers"
}

/**
 * Supported versions:
 * 11g - 11.1.1.7
 * 12cRelease213 - 12.2.1.3
 * 12cRelease214 - 12.2.1.4
 * 14c - 14.1.1.0
 */
variable "wls_version" {
  default = "14.1.1.0"
}

/**
 * Supported versions for 14c:
 * jdk8
 * jdk11
 */
variable "wls_14c_jdk_version" {
  default = "jdk8"
}

variable "wls_edition" {
  default = "EE"
}


// PROD or DEV mode
variable "mode" {
  default = "PROD"
}

variable "log_level" {
  type    = string
  default = "INFO"
}

variable "deploy_sample_app" {
  type    = bool
  default = true
}

variable "wls_ocpu_count" {
  type = number
  default = 1
  description = "OCPU count for wls instance"
}

variable "defined_tag" {
  type    = string
  default = "~!@#$%^&*()"
  description = "defined resource tag name"
}

variable "defined_tag_value" {
  type    = string
  default = "~!@#$%^&*()"
  description = "defined resource tag value"
}

variable "free_form_tag" {
  type    = string
  default = "~!@#$%^&*()"
  description = "free form resource tag name"
}

variable "free_form_tag_value" {
  type    = string
  default = "~!@#$%^&*()"
  description = "free form resource tag value"
}


/*
********************
ATP Parameters
********************
*/

variable "is_atp_db" {
  default = "false"
  description = "if atp will be present"
}

variable "create_atp_db" {
  default = "false"
  description = "if atp will be created"
}

variable "atp_db_compartment_id" {
  default = ""
  description = "value for ATP database compartment ocid"
}

variable "atp_db_id" {
  default = ""
  description = "value for ATP database ocid"
}

variable "atp_db_level" {
  default = "low"
  description = "value for ATP database level"
}

variable "atp_db_password_ocid" {
  default = ""
  description = "value for ATP database password ocid"
}

variable "atp_db_port" {
  default = "1521"
  description = "value for atp database port"
}

variable "autonomous_database_cpu_core_count"{}

variable "autonomous_database_db_name" {}

variable autonomous_database_admin_password {}

variable autonomous_database_data_storage_size_in_tbs {}


/*
 * IDCS variables
 */

variable "is_idcs_selected" {
  type = bool
  default = false
  description = "Indicates that idcs has to be provisioned"
}

variable "idcs_host" {
  default = "identity.oraclecloud.com"
  description = "value for idcs host"

}

variable "idcs_port" {
  default = "443"
  description = "value for idcs port"
}

variable "idcs_tenant" {
  default = ""
  description = "value for idcs tenant"
}

variable "idcs_client_id" {
  default = ""
  description = "value for idcs client id"
}

variable "idcs_client_secret_ocid" {
  default = ""
  description = "value for idcs client secret ocid"
}

variable "idcs_cloudgate_port" {
  default = "9999"
  description = "value for idcs cloud gate port"
}

/**
* Networking
*/

variable "existing_vcn_id" {
  default = ""
  description = "OCID of existing virtual cloud network"
}


variable "wls_availability_domain_name" {
  type        = string
  default     = ""
  description = "availablility domain for weblogic vm instances"
}

variable "lb_subnet_1_availability_domain_name" {
  type        = string
  default = ""
  description = "availablility domain for load balancer"
}

variable "lb_subnet_2_availability_domain_name" {
  type        = string
  default = ""
  description = "availablility domain for load balancer"
}

variable "add_load_balancer" {
  type = bool
  default = false
  description = "Adds of load balancer to stack"
}

variable "use_regional_subnet" {
  type = bool
  default = true
  description = "Indicates use of regional subnets (preferred) instead of AD specific subnets"
}

variable "volume_name" {
  default = ""
}

variable "assign_weblogic_public_ip" {
  type = bool
  default = false
  description = "Indicates use of private subnets"
}

variable "wls_subnet_id" {
  default = ""
  description = "OCID for existing subnet for weblogic instances"
}

variable "bastion_ssh_private_key" {
  type    = string
  default = ""
  description = "Private ssh key for existing bastion instance"
}

variable "bastion_subnet_id" {
  default = ""
  description = "OCID for existing subnet for bastion instance"
}

variable "lb_subnet_id" {
  default = ""
  description = "OCID for existing regional or AD subnet for primary load balancer"
}

variable "lb_subnet_backend_id" {
  default = ""
  description = "OCID for existing AD subnet for secondary load balancer"
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

variable "is_lb_private" {
  type = bool
  default = false
  description = "Indicates use of private load balancer"
}


#Foundation

variable "vcn_name" {
  default = ""
  description = "Name of new virtual cloud network"
}


variable "vcn_cidr" {
  default = "172.0.0.0/16"
  description = "CIDR for new virtual cloud network"
}


variable "wls_subnet_name" {
  default = "wls-subnet"
}

variable "wls_subnet_cidr" {
  default = ""
}

variable "lb_subnet_name" {
  default = "lb-sbnet"
}

variable "lb_subnet_cidr" {
  default = ""
}

variable "lb_subnet_backend_name" {
  default = "lb-sbnet-backend"
}

variable "lb_subnet_backend_cidr" {
  default = ""
}

variable "bastion_subnet_cidr" {
  default = ""
  description = "CIDR for bastion subnet"
}

variable "bastion_subnet_name" {
  default = "bsubnet"
}

variable "is_bastion_instance_required" {
  default = true
  description = "Creates bastion for the stack"
}

variable "existing_bastion_instance_id" {
  type    = string
  default = ""
  description = "OCID for existing bastion instance"
}

variable "linux_instance_image_id" {
  default = ""
}

variable "subnet_type" {
  default = "Use Private Subnet"
}

variable "subnet_span" {
  default = "Regional Subnet"
}

variable "compartment_policy_id" {}

variable anywhere_cidr {
  default = "0.0.0.0/0"
}

variable "dhcp_options_name" {
  default = "dhcpOptions"
}