# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}

data "template_file" "ad_names" {
  count    = length(data.oci_identity_availability_domains.ADs.availability_domains)
  template = lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name")
}

data "oci_core_services" "sgw_services" {
  filter {
    name   = "cidr_block"
    values = ["all-.*-services-in-oracle-services-network"]
    regex  = true
  }
}

data "oci_identity_region_subscriptions" "home_region_subscriptions" {
  tenancy_id = var.tenancy_ocid

  filter {
    name   = "is_home_region"
    values = [true]
  }
}

locals {
  ggsa_image                  = "ocid1.image.oc1..aaaaaaaavizlnldcwtsgu7ljrpdvg6633e5jafne73qqlheuk3fln7upzobq"
  mp_listing_id               = "ocid1.appcataloglisting.oc1..aaaaaaaaw3t6a3jhs3t6m2dr6sgvnjipxlrysnwafmvi7i4dzphungl3gdla"
  mp_listing_resource_id      = "ocid1.image.oc1..aaaaaaaavizlnldcwtsgu7ljrpdvg6633e5jafne73qqlheuk3fln7upzobq"
  mp_listing_resource_version = "19.1.0.0.6_v1.1"

  ad_names                         = compact(data.template_file.ad_names.*.rendered)
  public_subnet_availability_domain = local.ad_names[0]
  service_name_prefix               = replace(var.service_name, "/[^a-zA-Z0-9]/", "")


# Create Autonomous Data Warehouse
  adw_params = { 
    adw = {
      compartment_id              = var.compartment_id,
      adw_cpu_core_count          = var.adw_cpu_core_count,
      adw_size_in_tbs             = var.adw_size_in_tbs,
      adw_db_name                 = var.adw_db_name,
      adw_db_workload             = var.adw_db_workload,
      adw_db_version              = var.adw_db_version,
      adw_enable_auto_scaling     = var.adw_enable_auto_scaling,
      adw_is_free_tier            = var.adw_is_free_tier,
      adw_license_model           = var.adw_license_model,
      database_admin_password     = var.database_admin_password,
      database_wallet_password    = var.database_wallet_password,
      defined_tags                = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  },
}


# Create Oracle Analytics Cloud
  oac_params = { 
    oac = {
      compartment_id                             = var.compartment_id,
      analytics_instance_feature_set             = var.analytics_instance_feature_set,
      analytics_instance_license_type            = var.analytics_instance_license_type,
      analytics_instance_hostname                = var.analytics_instance_hostname,
      analytics_instance_idcs_access_token       = var.analytics_instance_idcs_access_token,
      analytics_instance_capacity_capacity_type  = var.analytics_instance_capacity_capacity_type,
      analytics_instance_capacity_value          = var.analytics_instance_capacity_value,
      analytics_instance_network_endpoint_details_network_endpoint_type = var.analytics_instance_network_endpoint_details_network_endpoint_type
      subnet_id                                  = lookup(module.network-subnets.subnets,"private-subnet").id,
      vcn_id                                     = lookup(module.network-vcn.vcns,"vcn").id,
      analytics_instance_network_endpoint_details_whitelisted_ips = var.analytics_instance_network_endpoint_details_whitelisted_ips
      analytics_instance_network_endpoint_details_whitelisted_vcns_id = lookup(module.network-vcn.vcns,"vcn").id,
      whitelisted_ips                            = var.whitelisted_ips
      defined_tags                               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}


# Create Object Storage Buckets
  bucket_params = { 
    data_bucket = {
      compartment_id   = var.compartment_id,
      name             = var.data_bucket_name,
      access_type      = var.data_bucket_access_type,
      storage_tier     = var.data_bucket_storage_tier,
      events_enabled   = var.data_bucket_events_enabled,
      defined_tags     = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
    dataflow_logs_bucket  = {
      compartment_id   = var.compartment_id,
      name             = var.dataflow_logs_bucket_name,
      access_type      = var.dataflow_logs_bucket_access_type,
      storage_tier     = var.dataflow_logs_bucket_storage_tier,
      events_enabled   = var.dataflow_logs_bucket_events_enabled,
      defined_tags     = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}


# Create Data Catalog
  datacatalog_params = { 
    datacatalog = {
      compartment_id        = var.compartment_id,
      catalog_display_name  = var.datacatalog_display_name,
      defined_tags          = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    }
  }


#Create Oracle Cloud Infrastructure Data Integration service
  odi_params = { 
    odi = {
      compartment_id   = var.compartment_id,
      display_name     = var.odi_display_name,
      description      = var.odi_description,
      defined_tags     = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}


# OCI DataScience
datascience_params = {
    machine_learning_platform = {
      compartment_id             = var.compartment_id
      project_description        = var.project_description
      project_display_name       = var.project_display_name
      defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    }
}

notebook_params = {
    notebook_session = {
      compartment_id             = var.compartment_id
      notebook_session_notebook_session_configuration_details_shape = var.notebook_session_notebook_session_configuration_details_shape
      subnet_id                  = lookup(module.network-subnets.subnets,"public-subnet").id,
      project_name               = "machine_learning_platform"
      notebook_session_notebook_session_configuration_details_block_storage_size_in_gbs = var.notebook_session_notebook_session_configuration_details_block_storage_size_in_gbs
      notebook_session_display_name = var.notebook_session_display_name
      defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}


# OCI Golgen Gate
deployment_params = {
  deployment1 = {
    compartment_id          = var.compartment_id
    cpu_core_count          = var.goden_gate_cpu_core_count
    deployment_type         = var.goden_gate_deployment_type
    subnet_id               = lookup(module.network-subnets.subnets,"public-subnet").id,
    license_model           = var.golden_gate_license_model
    display_name            = var.goden_gate_display_name
    is_auto_scaling_enabled = var.goden_gate_is_auto_scaling_enabled
    defined_tags            = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }

    ogg_data = [
      {
        admin_password  = var.goden_gate_admin_password
        admin_username  = var.goden_gate_admin_username
        deployment_name = var.goden_gate_deployment_name
    }]
  }
}


# OCI Streaming
streaming_params = {
    Test_Stream = {
      name           = var.stream_name
      partitions     = var.stream_partitions
      compartment_id = var.compartment_id
      retention_in_hours = var.stream_retention_in_hours
      stream_pool_id     = ""
      stream_pool_name   = var.stream_pool_name
      defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}

streaming_pool_params = {
    Test_Stream_Pool = {
      compartment_id = var.compartment_id
      name           = var.stream_pool_name
      defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
      kafka_settings = [
        {
          auto_create_topics_enable = false
          log_retention_hours       = 24
          num_partitions            = 1
        },
      ]
  }
}

service_connector = {}


# OCI DATA FLOW
dataflow_params = {
    dataflowapp = {
      compartment_id             = var.compartment_id
      application_display_name   = var.application_display_name
      application_driver_shape   = var.application_driver_shape
      application_executor_shape = var.application_executor_shape
      application_file_uri       = var.application_file_uri
      application_language       = var.application_language
      application_num_executors  = var.application_num_executors
      application_spark_version  = var.application_spark_version
      application_class_name     = var.application_class_name
      defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}


# API GATEWAY CONFIGURATION:
apigw_params = {
  apigw = {
    compartment_id = var.compartment_id,
    endpoint_type  = "PUBLIC"
    subnet_id      = lookup(module.network-subnets.subnets,"public-subnet").id,
    display_name   = var.apigw_display_name
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}

gwdeploy_params = {
  api_deploy1 = {
    compartment_id = var.compartment_id,
    gateway_name     = "apigw"
    display_name     = var.apigwdeploy_display_name
    path_prefix      = "/tf"
    access_log       = true
    exec_log_lvl     = "WARN"
    defined_tags     = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }

    function_routes = []

    http_routes = [
      {
        type            = "http"
        path            = "/http"
        methods         = ["GET", ]
        url             = "http://152.67.128.232/"
        ssl_verify      = true
        connect_timeout = 60
        read_timeout    = 40
        send_timeout    = 10
      },
    ]
    stock_routes = [
      {
        methods = ["GET", ]
        path    = "/stock"
        type    = "stock_response"
        status  = 200
        body    = "The API GW deployment was successful."
        headers = [
          {
            name  = "Content-Type"
            value = "text/plain"
          },
        ]

      },
    ]

  }
}


# Ai Anomaly Detection CONFIGURATION:
ai_anomaly_detection_project_params = {
  Lakehouse_project = {
    compartment_id = var.compartment_id,
    description    = var.ai_anomaly_detection_project_description
    display_name   = var.ai_anomaly_detection_project_display_name
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}

ai_anomaly_detection_data_asset_params = {
  Lakehouse_project = {
    compartment_id   = var.compartment_id,
    project_name     = var.ai_anomaly_detection_data_asset_project_name
    data_source_type = var.ai_anomaly_detection_data_asset_data_source_type
    bucket           = var.ai_anomaly_detection_data_asset_bucket
    measurement_name = var.ai_anomaly_detection_data_asset_measurement_name
    object           = var.ai_anomaly_detection_data_asset_object
    influx_version   = var.ai_anomaly_detection_data_asset_influx_version
    description      = var.ai_anomaly_detection_data_asset_description
    display_name     = var.ai_anomaly_detection_data_asset_display_name
    defined_tags     = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}

ai_anomaly_detection_model_params = {}


# # Big Data Service:
bds_params = {
  bds_deploy = {
    compartment_id = var.compartment_id,
    cluster_admin_password  = var.big_data_cluster_admin_password
    cluster_public_key = var.big_data_cluster_public_key
    cluster_version = var.big_data_cluster_version
    display_name     = var.big_data_display_name
    is_high_availability = var.big_data_is_high_availability
    is_secure = var.big_data_is_secure
    master_node = [
      {
        shape                    = var.big_data_master_node_spape
        subnet_id                = lookup(module.network-subnets.subnets,"public-subnet").id,
        block_volume_size_in_gbs = var.big_data_master_node_block_volume_size_in_gbs
        number_of_nodes          = var.big_data_master_node_number_of_nodes
      },
    ]
    util_node = [
      {
        shape                    = var.big_data_util_node_shape
        subnet_id                = lookup(module.network-subnets.subnets,"public-subnet").id,
        block_volume_size_in_gbs = var.big_data_util_node_block_volume_size_in_gbs
        number_of_nodes          = var.big_data_util_node_number_of_nodes
      },
    ]
    worker_node = [
      {
        shape                    = var.big_data_worker_node_shape
        subnet_id                = lookup(module.network-subnets.subnets,"public-subnet").id,
        block_volume_size_in_gbs = var.big_data_worker_node_block_volume_size_in_gbs
        number_of_nodes          = var.big_data_worker_node_number_of_nodes
      },
    ]
    defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}


# Create the mount targets list 
fss_params = {
  MYSQL = {
    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
    compartment_id = var.compartment_id
    name           = "MYSQL"
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
  }
  KAFKA = {
    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
    compartment_id = var.compartment_id
    name           = "KAFKA"
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
  }
  SPARK = {
    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
    compartment_id = var.compartment_id
    name           = "SPARK"
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
  }
  GGBD = {
    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
    compartment_id = var.compartment_id
    name           = "GGBD"
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
  }
}

mt_params = {
  GGSMT = {
    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
    compartment_id = var.compartment_id
    name           = "GGSMT"
    subnet_id      = lookup(module.network-subnets.subnets,"private-subnet").id
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
  }
}

export_params = {
  GGSMT = {
    export_set_name = "GGSMT"
    filesystem_name = "MYSQL"
    path            = "/u02/mysql"
    export_options = [
      {
        source   = "0.0.0.0/0"
        access   = "READ_WRITE"
        identity = "NONE"
        use_port = false
      }
    ]
  }
  GGSMT2 = {
    export_set_name = "GGSMT"
    filesystem_name = "KAFKA"
    path            = "/u02/kafka"
    export_options = [
      {
        source   = "0.0.0.0/0"
        access   = "READ_WRITE"
        identity = "NONE"
        use_port = false
      }
    ]
  }
  GGSMT3 = {
    export_set_name = "GGSMT"
    filesystem_name = "SPARK"
    path            = "/u02/spark"
    export_options = [
      {
        source   = "0.0.0.0/0"
        access   = "READ_WRITE"
        identity = "NONE"
        use_port = false
      }
    ]
  }
  GGSMT4 = {
    export_set_name = "GGSMT"
    filesystem_name = "GGBD"
    path            = "/u02/ggbd"
    export_options = [
      {
        source   = "0.0.0.0/0"
        access   = "READ_WRITE"
        identity = "NONE"
        use_port = false
      }
    ]
  }
 }


# Create the VM's for the solution 
instance_params = { 
  #Create the Web-Tier-and-Bastion Instance
  bastion = {
    availability_domain = 1
    compartment_id = var.compartment_id
    display_name   = "Web-Tier-and-Bastion"
    shape          = var.bastion_shape
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
    subnet_id         = lookup(module.network-subnets.subnets,"public-subnet").id  
    vnic_display_name = ""
    assign_public_ip  = true
    hostname_label    = ""
    source_type = "image"
    source_id   = local.ggsa_image
    metadata = {
      ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
    }
    fault_domain = ""
    provisioning_timeout_mins = "30"
  }

#create Workers and Masters instances
  ggsa-ha-worker1 = {
    availability_domain = 1
    compartment_id = var.compartment_id
    display_name   = "ggsa-ha-worker1"
    shape          = var.worker1_shape
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
    subnet_id        = lookup(module.network-subnets.subnets,"private-subnet").id,
    vnic_display_name = ""
    assign_public_ip = false
    hostname_label   = ""
    source_type = "image"
    source_id   = local.ggsa_image
    metadata = {
      ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
    }
    fault_domain = ""
    provisioning_timeout_mins = "30"
  }
  ggsa-ha-worker2 = {
    availability_domain = 2
    compartment_id = var.compartment_id
    display_name   = "ggsa-ha-worker2"
    shape          = var.worker2_shape
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
    subnet_id        = lookup(module.network-subnets.subnets,"private-subnet").id,
    vnic_display_name = ""
    assign_public_ip = false
    hostname_label   = ""
    source_type = "image"
    source_id   = local.ggsa_image
    metadata = {
      ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
    }
    fault_domain = ""
    provisioning_timeout_mins = "30"
  }
  ggsa-ha-worker3 = {
    availability_domain = 3
    compartment_id = var.compartment_id
    display_name   = "ggsa-ha-worker3" 
    shape          = var.worker3_shape
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
    subnet_id        = lookup(module.network-subnets.subnets,"private-subnet").id,
    vnic_display_name = ""
    assign_public_ip = false
    hostname_label   = ""
    source_type = "image"
    source_id   = local.ggsa_image
    metadata = {
      ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
    }
    fault_domain = ""
    provisioning_timeout_mins = "30"
  }
  ggsa-ha-master1 = {
    availability_domain = 1
    compartment_id = var.compartment_id
    display_name   = "ggsa-ha-master1"
    shape          = var.master1_shape
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
    subnet_id        = lookup(module.network-subnets.subnets,"private-subnet").id,
    vnic_display_name = ""
    assign_public_ip = false
    hostname_label   = ""
    source_type = "image"
    source_id   = local.ggsa_image
    metadata = {
      ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
    }
    fault_domain = ""
    provisioning_timeout_mins = "30"
  }
  ggsa-ha-master2 = {
    availability_domain = 2
    compartment_id = var.compartment_id
    display_name   = "ggsa-ha-master2"
    shape          = var.master2_shape
    defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags  = {}
    subnet_id        = lookup(module.network-subnets.subnets,"private-subnet").id,
    vnic_display_name = ""
    assign_public_ip = false
    hostname_label   = ""
    source_type = "image"
    source_id   = local.ggsa_image
    metadata = {
      ssh_authorized_keys = module.keygen.OPCPrivateKey.public_key_openssh
    }
    fault_domain = ""
    provisioning_timeout_mins = "30"
    }
  }


##### Calling the network modules that are required for this solution ######
## Created the DRG that will be used for our VCN.
drg_params = {
  mgmt_drg = {
    name         = var.drg_name
    cidr_rt      = var.drg_cidr_rt
    defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}


## FASTCONNECT CONFIGURATION:
private_vc_with_provider_no_cross_connect_or_cross_connect_group_id = {
  private_vc_with_provider_no_cross_connect_or_cross_connect_group_id = {
    compartment_id        = var.compartment_id,
    name                  = var.private_fastconnect_name
    type                  = var.private_fastconnect_type
    bw_shape              = var.private_fastconnect_bw_shape
    cust_bgp_peering_ip   = var.private_fastconnect_cust_bgp_peering_ip
    oracle_bgp_peering_ip = var.private_fastconnect_oracle_bgp_peering_ip
    drg                   = var.private_fastconnect_drg
    defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}

cc_group = {}
cc = {}
private_vc_no_provider = {}
private_vc_with_provider = {}
public_vc_no_provider    = {}
public_vc_with_provider  = {}


## Creates the VCN "vcn with the CIDR BLOCK 10.0.0.0/16"
  vcns-lists = {
    vcn = { 
     compartment_id = var.compartment_id
     cidr           = var.vcn_cidr
     dns_label      = "vcn"
     is_create_igw  = true
     is_attach_drg  = true // put true if you want to have drg attached !
     block_nat_traffic = false
     subnets  = {}  
     defined_tags   = {}
     freeform_tags  = {}
    }
}

#creates the subnet "public-subnet - 10.0.0.0/24 and private-subnet - 10.0.1.0/24"
  subnet-lists = { 
     "" = {
        compartment_id = var.compartment_id
        cidr           = var.vcn_cidr
        dns_label      = "vcn"
        is_create_igw  = false
        is_attach_drg  = false
        block_nat_traffic = false
     
        subnets  = { 
          public-subnet = { 
	          compartment_id=var.compartment_id, 
            vcn_id=lookup(module.network-vcn.vcns,"vcn").id, 
            availability_domain=var.use_regional_subnet? "" : local.public_subnet_availability_domain,
	          cidr=var.public_subnet_cidr,
            dns_label="public",
            private=false,
            dhcp_options_id="",
            security_list_ids=[module.network-security-lists.security_lists["public_security_list"].id],
            defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
            freeform_tags = {}
          }
          private-subnet = { 
	          compartment_id=var.compartment_id, 
            vcn_id=lookup(module.network-vcn.vcns,"vcn").id, 
            availability_domain=var.use_regional_subnet? "" : local.public_subnet_availability_domain,
	          cidr=var.private_subnet_cidr, 
            dns_label="private",
            private=true,
            dhcp_options_id="",
            security_list_ids=[module.network-security-lists.security_lists["private_security_list"].id],
            defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
            freeform_tags = {}
	        }
        }
        defined_tags  = {}
        freeform_tags = {}
    }
  }

#create routing table attached to vcn and subnet to route traffic via IGW
  subnets_route_tables = {
    public_route_table = {
      compartment_id = var.compartment_id,
      vcn_id=lookup(module.network-vcn.vcns,"vcn").id,
      subnet_id = lookup(module.network-subnets.subnets,"public-subnet").id,
      route_table_id = "",
      route_rules = [{
        is_create = true,
        destination       = "0.0.0.0/0",
        destination_type  = "CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn.internet_gateways, lookup(module.network-vcn.vcns,"vcn").id).id,
        description       = ""
      }],
        defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    }
  }

#create security list - opening port 22 ssh and port 80 - http
  security_lists = {
    public_security_list = {
        vcn_id = lookup(module.network-vcn.vcns,"vcn").id,
        compartment_id = var.compartment_id,
        defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
        ingress_rules = concat([{
            stateless = false
            protocol  = "6" // tcp
            src           = "0.0.0.0/0"
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 22, max= 22},
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "6" // tcp
            src           = "0.0.0.0/0"
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 443, max=443},
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "6" // tcp
            src           = "0.0.0.0/0"
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 80, max=80},
            icmp_type     = null,
            icmp_code     = null
          }]),
        egress_rules = [{
           stateless     = false,
           protocol      = "all",
           dst           = "0.0.0.0/0",
           dst_type      = "CIDR_BLOCK",
           src_port      = null,
           dst_port     = null,
           icmp_type    = null,
           icmp_code    = null
         }],
      }
    private_security_list = {
        vcn_id = lookup(module.network-vcn.vcns,"vcn").id,
        compartment_id = var.compartment_id,
        defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
        ingress_rules = concat([{
            stateless = false
            protocol  = "all"
            src           = var.vcn_cidr,
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = null,
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "6"
            src           = var.vcn_cidr,
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 22, max=22},
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "17"
            src           = var.vcn_cidr,
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 3306, max=3306},
            icmp_type     = null,
            icmp_code     = null
          }]),
        egress_rules = [{
           stateless     = false,
           protocol      = "all",
           dst           = "0.0.0.0/0",
           dst_type      = "CIDR_BLOCK",
           src_port      = null,
            dst_port     = null,
            icmp_type    = null,
            icmp_code    = null
         }]
      }
    }

# Create Network Security lists - public and private
 nsgs-lists = {
   public-nsgs-list = {
        vcn_id = lookup(module.network-vcn.vcns,"vcn").id,
        compartment_id = var.compartment_id,
        defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
        ingress_rules = { ingress1 = {
          is_create    = true,
          description  = "Parameters for customizing Network Security Group(s).",
          protocol     = "all",
          stateless    = false,
          src          = var.public_subnet_cidr,
          src_type     = "CIDR_BLOCK",
          dst_port_min = null,
          dst_port_max = null,
          src_port_min = null,
          src_port_max = null,
          icmp_type    = null,
          icmp_code    = null
      }},
      egress_rules = { egress1 = {
          is_create    = true,
          description  = "Parameters for customizing Network Security Group(s).",
          protocol     = "all",
          stateless    = false,
          dst          = "0.0.0.0/0",
          dst_type     = "CIDR_BLOCK",
          dst_port_min = null,
          dst_port_max = null,
          src_port_min = null,
          src_port_max = null,
          icmp_type    = null,
          icmp_code    = null
      }},
   }
  private-nsgs-list = {
        vcn_id = lookup(module.network-vcn.vcns,"vcn").id,
        compartment_id = var.compartment_id,
        defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
        ingress_rules = { ingress2 = {
          is_create    = true,
          description  = "Parameters for customizing Network Security Group(s).",
          protocol     = "all",
          stateless    = false,
          src          = var.private_subnet_cidr,
          src_type     = "CIDR_BLOCK",
          dst_port_min = null,
          dst_port_max = null,
          src_port_min = null,
          src_port_max = null,
          icmp_type    = null,
          icmp_code    = null
      }},
        egress_rules = { egress2 = {
          is_create    = true,
          description  = "Parameters for customizing Network Security Group(s).",
          protocol     = "all",
          stateless    = false,
          dst          = "0.0.0.0/0",
          dst_type     = "CIDR_BLOCK",
          dst_port_min = null,
          dst_port_max = null,
          src_port_min = null,
          src_port_max = null,
          icmp_type    = null,
          icmp_code    = null
      }}
  }
 }

  dynamic_groups = {
      "${local.service_name_prefix}-FullDataLakeFunctionsServiceDynamicGroup" = {
        description = "Functions Service Dynamic Group"
        compartment_id = var.tenancy_ocid
        matching_rule = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${var.compartment_id}'}"
      },
      "${local.service_name_prefix}-FullDataLakeDataScienceDynamicGroup" =  {
        description    = "DS Dynamic Group"
        compartment_id = var.tenancy_ocid
        matching_rule  = "ALL {resource.type = 'datasciencenotebooksession', resource.compartment.id = '${var.compartment_id}'}"
      },
  }

  policies = { 
    "${local.service_name_prefix}-FullDataLakePolicies" = { 
      compartment_id = var.tenancy_ocid,
      description    = "List of Policies Required for the Full Data Lake Solution",
      statements     =  [
    "allow dynamic-group ${local.service_name_prefix}-FullDataLakeFunctionsServiceDynamicGroup to manage all-resources in tenancy",
    "allow dynamic-group ${local.service_name_prefix}-FullDataLakeDataScienceDynamicGroup to manage data-science-family in tenancy", 
    "allow dynamic-group ${local.service_name_prefix}-FullDataLakeDataScienceDynamicGroup to manage object-family in tenancy", 
    "allow service datascience to use virtual-network-family in tenancy",
    "allow service dataintegration to manage virtual-network-family in compartment id ${var.compartment_id}",
    "allow service datacatalog to manage virtual-network-family in compartment id ${var.compartment_id}",
    "allow service datacatalog to {VNIC_READ, VNIC_ATTACH, VNIC_DETACH, VNIC_CREATE, VNIC_DELETE,VNIC_ATTACHMENT_READ, SUBNET_READ, VCN_READ, SUBNET_ATTACH, SUBNET_DETACH, INSTANCE_ATTACH_SECONDARY_VNIC, INSTANCE_DETACH_SECONDARY_VNIC} in compartment id ${var.compartment_id}",
    "allow service datacatalog to read object-family in compartment id ${var.compartment_id}",
    "allow service bdsprod to {VNIC_READ, VNIC_ATTACH, VNIC_DETACH, VNIC_CREATE, VNIC_DELETE,VNIC_ATTACHMENT_READ, SUBNET_READ, VCN_READ, SUBNET_ATTACH, SUBNET_DETACH, INSTANCE_ATTACH_SECONDARY_VNIC, INSTANCE_DETACH_SECONDARY_VNIC} in compartment id ${var.compartment_id}",
    "allow service FaaS to use virtual-network-family in tenancy",
    "allow service FaaS to manage repos in tenancy",
    "allow group Administrators to manage tag-namespaces in compartment id ${var.compartment_id}",
    "allow group Administrators to use virtual-network-family in compartment id ${var.compartment_id}",
    "allow group Administrators to use object-family in compartment id ${var.compartment_id}",
    "allow group Administrators to manage virtual-network-family in compartment id ${var.compartment_id}",
    "allow group Administrators to manage bds-instance in compartment id ${var.compartment_id}",
    "allow group Administrators to read instances in compartment id ${var.compartment_id}",
    "allow group Administrators to manage database-family in compartment id ${var.compartment_id}",
    "allow group Administrators to manage data-catalog-family in compartment id ${var.compartment_id}",
    "allow group Administrators to manage dis-family in compartment id ${var.compartment_id}",
    "allow group Administrators to manage mysql-family in compartment id ${var.compartment_id}",
    "allow group Administrators to manage buckets in tenancy",
    "allow group Administrators to manage objects in tenancy",
    "allow group Administrators to read buckets in tenancy",
    "allow group Administrators to read objectstorage-namespaces in tenancy",
    "allow group Administrators to inspect compartments in tenancy",
    "allow group Administrators to use virtual-network-family in tenancy",
    "allow group Administrators to manage data-science-family in tenancy",
    "allow group Administrators to use cloud-shell in tenancy",
    "allow group Administrators to read metrics in tenancy",
    "allow group Administrators to manage functions-family in tenancy",
    "allow group Administrators to use functions-family in tenancy",
    "allow group Administrators to manage ai-service-anomaly-detection-family in tenancy",
    "allow group Administrators to manage ai-service-anomaly-detection-project in tenancy",
    "allow group Administrators to manage ai-service-anomaly-detection-model in tenancy",
    "allow group Administrators to manage ai-service-anomaly-detection-data-asset in tenancy",
    "allow group Administrators to manage ai-service-anomaly-detection-private-endpoint in tenancy",
    "allow group Administrators to manage streampools in tenancy",
    "allow group Administrators to manage streams in tenancy",
    "allow group Administrators to manage connect-harness in tenancy", 
    "allow group Administrators to manage stream-family in tenancy",
    "allow group Administrators to manage objects in tenancy where all {target.bucket.name = '${var.dataflow_logs_bucket_name}', any {request.permission = 'OBJECT_CREATE', request.permission = 'OBJECT_INSPECT'}}"]
    },
  }
  

# End


}


