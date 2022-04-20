variable "region" {
  type = string
}

variable "tenancy_ocid" {}

variable "compartment_ocid" {}

variable "availability_domain" {}

variable "subnet_ocid" {}

variable "compute_name_prefix" {
  default = "wls-instance"
}

variable "vnic_prefix" {
  default = "wls"
}


variable "network_compartment_id" {}

variable "service_name_prefix" {}

variable "wls_subnet_id" {}

variable "existing_vcn_id" {
  default = ""
}

variable "ssh_public_key" {
  type = string
}

variable "numWLSInstances" {
  type    = string
  default = "1"
}

variable "instance_image_ocid" {}

variable "wls_admin_user" {
  type = string
}

variable "wls_domain_name" {
  type = string
}

variable "wls_admin_server_name" {
  type = string
}

variable "wls_admin_password" {
  type = string
}

variable "bootStrapFile" {
  type    = string
  default = "./modules/wls_compute/userdata/bootstrap"
}

variable "instance_shape" {
  type = string
}

variable "wls_ocpu_count" {
  type = number
  default = 1
  description = "OCPU count for wls instance"
}


variable "wls_extern_admin_port" {
  default = "7001"
}

variable "wls_extern_ssl_admin_port" {
  default = "7002"
}

variable "provisioning_timeout_mins" {
  default = 30
}

variable "wls_admin_server_wait_timeout_mins" {
  default = 30
}

variable "wls_admin_port" {
  default = "9071"
}

variable "wls_admin_ssl_port" {
  default = "9072"
}

variable "wls_nm_port" {
  default = "5556"
}

variable "wls_provisioning_timeout" {
  default = "10"
}

variable "wls_cluster_name" {
  default = "jcsoci_cluster"
}

variable "wls_ms_port" {
  default = "9074"
}

variable "wls_ms_extern_port" {
  default = "7003"
}

variable "wls_ms_extern_ssl_port" {
  default = "9073"
}

variable "wls_ms_ssl_port" {
  default = "7004"
}

variable "wls_ms_server_name" {
  default = "jcsoci_server_"
}

variable "wls_cluster_mc_port" {
  default = "5555"
}

variable "wls_machine_name" {
  default = "jcsoci_machine_"
}

/*
********************
DB Config
********************
*/
variable "db_password" {
  default = ""
}

variable "db_user" {
  default = ""
}

variable "db_port" {
  default = "1521"
}

/*
********************
ATP DB Config
********************
*/

variable "atp_db_id" {}


variable "atp_db_level" {}

variable "rcu_component_list" {
  default = "MDS,WLS,STB,IAU_APPEND,IAU_VIEWER,UCSUMS,IAU,OPSS"
}

variable "is_atp_db"{}

variable "wls_edition" {
  default = "EE"
}

variable "mode" {}

variable "tf_script_version" {}

variable "wls_version" {}

variable "wls_14c_jdk_version" {}

variable "wls_version_to_fmw_map" {
  type = map

  default = {
    "12.2.1.3" = "/u01/zips/jcs/FMW/12.2.1.3.0/fmiddleware.zip"
    "12.2.1.4" = "/u01/zips/jcs/FMW/12.2.1.4.0/fmiddleware.zip"
    "11.1.1.7" = "/u01/zips/jcs/FMW/11.1.1.7.0/fmiddleware.zip"
    "14.1.1.0" = "/u01/zips/jcs/FMW/14.1.1.0.0/fmiddleware.zip"
  }
}

variable "wls_version_to_jdk_map" {
  type = map

  default = {
    "12.2.1.3" = "/u01/zips/jcs/JDK8.0/jdk.zip"
    "12.2.1.4" = "/u01/zips/jcs/JDK8.0/jdk.zip"
    "11.1.1.7" = "/u01/zips/jcs/JDK7.0/jdk.zip"
  }
}

variable "wls_14c_to_jdk_map" {
  type = map

  default = {
    "jdk8" = "/u01/zips/jcs/JDK8.0/jdk.zip"
    "jdk11" = "/u01/zips/jcs/JDK11.0/jdk.zip"
  }
}

variable "vmscripts_path" {
  default = "/u01/zips/TF/wlsoci-vmscripts.zip"
}

variable "wls_version_to_rcu_component_list_map" {
  type = map

  default = {
    "12.2.1.3" = "MDS,WLS,STB,IAU_APPEND,IAU_VIEWER,UCSUMS,IAU,OPSS"
    "12.2.1.4" = "MDS,WLS,STB,IAU_APPEND,IAU_VIEWER,UCSUMS,IAU,OPSS"
    "11.1.1.7" = "IAU,IAUOES,MDS,OPSS"
  }
}

variable "log_level" {
  default = "INFO"
}

variable "rebootFile" {
  type    = string
  default = "./modules/wls_compute/userdata/reboot"
}

variable "num_volumes" {
  type    = string
  default = "1"
}

variable "volume_size" {
  default = "50"
}

variable "volume_map" {
  type = list

  default = [
    {
      volume_mount_point = "/u01/app"
      display_name       = "middleware"
      device             = "/dev/sdb"
    },
    {
      volume_mount_point = "/u01/data"
      display_name       = "data"
      device             = "/dev/sdc"
    }
  ]
}

variable "deploy_sample_app" {
  type    = bool
  default = true
}

variable "volume_info_file" {
  default = "/tmp/volumeInfo.json"
}

variable "domain_dir" {
  default = "/u01/data/domains"
}

variable "logs_dir" {
  default = "/u01/logs"
}

variable "assign_public_ip" {
  type = bool
}

variable "opc_key" {
  type = map
}

variable "oracle_key" {
  type = map
}

variable "status_check_timeout_duration_secs" {
  default = "1800"
}

/*
********************
IDCS Support
********************
*/
variable "is_idcs_selected" {
  type = bool
}
variable "idcs_host" {}
variable "idcs_port" {}
variable "idcs_tenant" {}
variable "idcs_client_id" {}
variable "idcs_cloudgate_port" {}
variable "idcs_client_secret" {}
variable "idcs_app_prefix" {}

variable "idcs_artifacts_file" {
  default = "/u01/data/.idcs_artifacts.txt"
}
variable "idcs_conf_app_info_file" {
  default = "/tmp/.idcs_conf_app_info.txt"
}
variable "idcs_ent_app_info_file" {
  default = "/tmp/.idcs_ent_app_info.txt"
}
variable "idcs_cloudgate_info_file" {
  default = "/tmp/.idcs_cloudgate_info.txt"
}
variable "idcs_cloudgate_config_file" {
  default = "/u01/data/cloudgate_config/appgateway-env"
}
variable "idcs_cloudgate_docker_image_tar" {
  default = "/u01/zips/jcs/app_gateway_docker/19.3.3/app-gateway-docker-image.tar.gz"
}
variable "idcs_cloudgate_docker_image_version" {
  default = "19.3.3-3.2003312252"
}
variable "idcs_cloudgate_docker_image_name" {
  default = "opc-delivery.docker.oraclecorp.com/idcs/appgateway"
}
variable "lbip" {}
variable "is_idcs_internal" {
  default = "false"
}
variable "is_idcs_untrusted" {
  type    = bool
  default = false
}
variable "idcs_ip" {
  default = ""
}

variable "defined_tags" {
  type    = map
  default = {}
}

variable "freeform_tags" {
  type    = map
  default = {}
}

variable "use_regional_subnet" {
  type = bool
}

variable "volume_name" {}

variable "allow_manual_domain_extension" {
  type        = bool
  default     = false
  description = "flag indicating that domain will be manually extended for managed servers"
}
variable "add_loadbalancer" {
  type = bool
}

variable "is_lb_private" {
  type = bool
}
variable "load_balancer_id" {
}

variable "patching_tool_key" {
  default = "wiPECMve6esBkBF0g6c5mQ=="
  type = string
}

variable "supported_patching_actions" {
  type = string
  default = "setup,list,info,download,apply,upgrade"
}

variable "supported_patching_actions_11g" {
  type = string
  default = "setup,list,info,download,upgrade"
}

variable "disable_legacy_metadata_endpoint" {
  type = bool
  default = true
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_fault_domains" "wls_fault_domains" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
}

data "oci_database_autonomous_database" "atp_db" {
  count = var.is_atp_db?1:0
  autonomous_database_id = var.atp_db_id
}

data "template_file" "key_script" {
  template = file("./modules/wls_compute/templates/keys.tpl")

  vars = {
    pubKey     = var.opc_key["public_key_openssh"]
    oracleKey  = var.oracle_key["public_key_openssh"]
    oraclePriKey = var.oracle_key["private_key_pem"]
  }
}

data "oci_core_subnet" "wls_subnet" {
  count = var.wls_subnet_id == "" ? 0 : 1
  subnet_id = var.wls_subnet_id
}

data "template_file" "ad_names" {
  count    = length(data.oci_identity_availability_domains.ADs.availability_domains)
  template =  (length(regexall("^.*Flex", var.instance_shape))>0 || (tonumber(lookup(data.oci_limits_limit_values.compute_shape_service_limits[count.index].limit_values[0], "value")) > 0))?lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name"):""
}

data "oci_limits_limit_values" "compute_shape_service_limits" {
    count    = length(data.oci_identity_availability_domains.ADs.availability_domains)
    compartment_id = var.tenancy_ocid
    service_name = "compute"

    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name")

    name = length(regexall("^.*Flex", var.instance_shape))>0?"":format("%s-count",replace(var.instance_shape, ".", "-"))
}

data "oci_core_shapes" "oci_shapes" {
  count    = length(data.oci_identity_availability_domains.ADs.availability_domains)
  compartment_id = var.compartment_ocid
  image_id = var.instance_image_ocid
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name")
  filter {
    name ="name"
    values= ["${var.instance_shape}"]
  }
}


variable nsg_ids {
  type = list(string)
  default = []
}
