/**
* Variables file with defaults. These can be overridden from environment variables TF_VAR_<variable name>
*/

// Following are generally configured in environment variables - please use env_vars_template to create env_vars and source it as:
// source ./env_vars
// before running terraform init
variable "tenancy_ocid" {
  type        = string
  description = "tenancy id"
}
variable "region" {
    type        = string
    description = "tenancy id"
}

variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}

variable "compartment_ocid" {
  type        = string
  description = "compartment for instances"
}

// Note: This is the opc user's SSH public key text and not the key file path.
variable "ssh_public_key" {
  type        = string
  description = "public key for ssh access"
}

variable "service_name" {
  type        = string
  description = "prefix for stack resources"
}

variable "instance_image_id" {
   default = "ocid1.image.oc1..aaaaaaaaekrkzphkao4azbsteebkrltx7apo64h5zjbuarldeagjmw2ub44q"
}

variable "network_compartment_id" {
  type    = string
  default = ""
  description = "compartment for network resources"
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

variable "wls_admin_password_ocid" {
  type        = string
  default     = ""
  description = "weblogic admin password"
}

# Port for channel Extern on Admin Server
variable "wls_extern_admin_port" {
  type    = string
  default = "7001"
  description = "weblogic console port"
}

# Port for channel SecureExtern on Admin Server
variable "wls_extern_ssl_admin_port" {
  type    = string
  default = "7002"
  description = "weblogic console ssl port"
}

# Default channel ports for Admin Server
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

# Default channel ports for Managed Server
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

# Port for extern channel on Managed Server
variable "wls_ms_port" {
  type    = string
  default = "9073"
  description = "weblogic managed server port"
}

# Port for SecureExtern channel on Managed Server
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

/*
********************
General Parameters
********************
*/

// PROD or DEV mode
variable "mode" {
  default = "PROD"
}

variable "log_level" {
  type    = string
  default = "INFO"
}

variable "create_policies" {
  type = bool
  default = true
}

variable "use_baselinux_marketplace_image" {
  type = bool
  default = true
  description = "flag to indicate marketplace bastion image will be used for bastion instance"
}

variable "bastion_instance_image_id" {
  type = string
  default = ""
  description = "Image ocid for bastion instance"
}

#Note: special chars string denotes empty values for tags for validation purposes
#otherwise zipmap function in main.tf fails first for empty strings before validators executed.
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

variable "atp_db_compartment_id" {
  default = ""
  description = "value for ATP database compartment ocid"
}

variable "atp_db_id" {
  default = ""
  description = "value for ATP database ocid"
}


variable "atp_db_password_ocid" {
  default = ""
  description = "value for ATP database password ocid"
}


/*
********************
ATP Parameters for AppDB
********************
*/


variable "app_atp_db_id" {
  default = ""
  description = "value for ATP database ocid"
}

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
* Network related variables
*/

variable "vcn_name" {
  default = ""
  description = "Name of new virtual cloud network"
}

variable "existing_vcn_id" {
  default = ""
  description = "OCID of existing virtual cloud network"
}


variable "wls_availability_domain_name" {
  type        = string
  default     = ""
  description = "availablility domain for weblogic vm instances"
}

// Specify an LB AD 1 if lb is requested
variable "lb_subnet_1_availability_domain_name" {
  type        = string
  default = ""
  description = "availablility domain for load balancer"
}

// Specify an LB AD 2 if lb is requested
variable "lb_subnet_2_availability_domain_name" {
  type        = string
  default = ""
  description = "availablility domain for load balancer"
}

variable "vcn_cidr" {
  default = "172.0.0.0/16"
  description = "CIDR for new virtual cloud network"
}

variable "add_load_balancer" {
  type = bool
  default = false
  description = "Adds of load balancer to stack"
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

variable "use_regional_subnet" {
  type = bool
  default = true
  description = "Indicates use of regional subnets (preferred) instead of AD specific subnets"
}

variable "assign_weblogic_public_ip" {
  type = bool
  default = false
  description = "Indicates use of private subnets"
}

variable "bastion_subnet_cidr" {
  default = ""
  description = "CIDR for bastion subnet"
}

variable "bastion_subnet_name" {
  default = "bsubnet"
}

variable "wls_subnet_id" {
  default = ""
  description = "OCID for existing subnet for weblogic instances"
}

variable "is_bastion_instance_required" {
  default = true
  description = "Creates bastion for the stack"
}

# existing bastion instance support
variable "existing_bastion_instance_id" {
  type    = string
  default = ""
  description = "OCID for existing bastion instance"
}

variable "bastion_ssh_private_key" {
  type    = string
  default = ""
  description = "Private ssh key for existing bastion instance"
}

variable "lb_subnet_id" {
  default = ""
  description = "OCID for existing regional or AD subnet for primary load balancer"
}

variable "lb_subnet_backend_id" {
  default = ""
  description = "OCID for existing AD subnet for secondary load balancer"
}

variable "bastion_subnet_id" {
  default = ""
  description = "OCID for existing subnet for bastion instance"
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

variable "mp_baselinux_instance_image_id" {
  default = "ocid1.image.oc1..aaaaaaaaz2lna7kxzzcyaocm36as5xvqy7unzvbnknexgp76n5g3cv4bdadq"
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