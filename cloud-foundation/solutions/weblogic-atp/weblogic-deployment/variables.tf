/**
* Variables file with defaults. These can be overridden from environment variables TF_VAR_<variable name>
*/

// Following are generally configured in environment variables
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
  description = "compartment for weblogic instances"
}


/*
********************
* WLS Instance Config
********************
*/

// Note: This is the opc user's SSH public key text and not the key file path.
variable "ssh_public_key" {
  description = "public key for ssh access to weblogic instances"
}

variable "service_name" {
  type        = string
  description = "prefix for resources"
}

#Provide WLS custom image OCID
variable "instance_image_id" {}
variable "image_version" {
  default = "21.2.2-210519172750"
}

variable "network_compartment_id" {
  type    = string
  default = ""
  description = "compartment for network resources"
}

# Defines the number of instances to deploy
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

# WLS related input variables
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

variable "wls_cluster_mc_port" {
  type    = string
  default = "5555"
  description = "weblogic multi cluster port"
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

/* WLS Edition */

variable "wls_edition" {
  default = "EE"
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

variable "deploy_sample_app" {
  type    = bool
  default = true
}

variable "wls_ocpu_count" {
  type = number
  default = 1
  description = "OCPU count for wls instance"
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
********************
ATP Parameters for AppDB
********************
*/

variable "app_atp_db_compartment_id" {
  default = ""
  description = "value for ATP database compartment ocid"
}

variable "app_atp_db_id" {
  default = ""
  description = "value for ATP database ocid"
}

variable "app_atp_db_user" {
  default = ""
  description = "value for oci database user name"
}

variable "app_atp_db_level" {
  default = "low"
  description = "value for ATP database level"
}

variable "app_atp_db_password_ocid" {
  default = ""
  description = "value for ATP database password ocid"
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

variable "bastion_host" {
  description = "IP bastion"
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