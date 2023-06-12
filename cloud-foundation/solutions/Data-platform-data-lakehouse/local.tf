# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_regions" "oci_regions" {
  filter {
    name = "name" 
    values = [var.region]
  }
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

data "oci_objectstorage_namespace" "os" {
  compartment_id = var.tenancy_ocid
}

resource "random_id" "id" {
	  byte_length = 8
}

resource "null_resource" "Login2OCIR" {
  depends_on = [module.containers_artifacts]
  provisioner "local-exec" {
    command = "echo '${var.ocir_user_password}' |  docker login ${local.ocir_docker_repository} --username ${local.ocir_namespace}/${var.ocir_user_name} --password-stdin"
  }
}

resource "null_resource" "DecoderPush2OCIR" {
  depends_on = [module.containers_artifacts, null_resource.Login2OCIR]
  provisioner "local-exec" {
    command     = "image=$(docker images | grep decoder | awk -F ' ' '{print $3}') ; docker rmi -f $image &> /dev/null ; echo $image"
    working_dir = "functions/decoder"
  }
  provisioner "local-exec" {
    command     = "fn build --verbose"
    working_dir = "functions/decoder"
  }
  provisioner "local-exec" {
    command     = "image=$(docker images | grep decoder | awk -F ' ' '{print $3}') ; docker tag $image ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}:0.0.50"
    working_dir = "functions/decoder"
  }
  provisioner "local-exec" {
    command     = "docker push ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}:0.0.50"
    working_dir = "functions/decoder"
  }
}


locals {
  ad_names                          = compact(data.template_file.ad_names.*.rendered)
  public_subnet_availability_domain = local.ad_names[0]

  function_image         = "${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}:0.0.50"
  ocir_docker_repository = join("", [lower(lookup(data.oci_identity_regions.oci_regions.regions[0], "key")), ".ocir.io"])
  ocir_namespace         = lookup(data.oci_identity_tenancy.tenancy, "name")


# Create Autonomous Data Warehouse

  adw_params = { 
    adw = {
      compartment_id              = var.compartment_id,
      cpu_core_count              = var.db_cpu_core_count
      size_in_tbs                 = var.db_size_in_tbs
      db_name                     = var.db_name
      db_workload                 = var.db_workload
      db_version                  = var.db_version
      enable_auto_scaling         = var.db_enable_auto_scaling
      is_free_tier                = var.db_is_free_tier
      license_model               = var.db_license_model
      create_local_wallet         = true
      database_admin_password     = var.db_password
      database_wallet_password    = var.db_password
      is_mtls_connection_required = true
      subnet_id                   = lookup(module.network-subnets.subnets,"private_subnet_data").id
      nsg_ids                     = []
      defined_tags                = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  },
}


# Create Object Storage Buckets

  bucket_params = { 
    bronze_bucket = {
      compartment_id   = var.compartment_id,
      name             = var.bronze_bucket_name
      access_type      = var.bronze_bucket_access_type
      storage_tier     = var.bronze_bucket_storage_tier
      events_enabled   = var.bronze_bucket_events_enabled
      defined_tags     = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
    silver_bucket = {
      compartment_id   = var.compartment_id,
      name             = var.silver_bucket_name
      access_type      = var.silver_bucket_access_type
      storage_tier     = var.silver_bucket_storage_tier
      events_enabled   = var.silver_bucket_events_enabled
      defined_tags     = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
    gold_bucket = {
      compartment_id   = var.compartment_id,
      name             = var.gold_bucket_name
      access_type      = var.gold_bucket_access_type
      storage_tier     = var.gold_bucket_storage_tier
      events_enabled   = var.gold_bucket_events_enabled
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


# API GATEWAY CONFIGURATION:

apigw_params = {
  apigw = {
    compartment_id = var.compartment_id,
    endpoint_type  = "PRIVATE"
    subnet_id      = lookup(module.network-subnets.subnets,"private_subnet_application").id
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


# OCI Streaming

streaming_params = {
    Test_Stream = {
      name               = var.stream_name
      partitions         = var.stream_partitions
      compartment_id     = var.compartment_id
      retention_in_hours = var.stream_retention_in_hours
      stream_pool_id     = ""
      stream_pool_name   = var.stream_pool_name
      defined_tags       = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
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

service_connector = {
    Test_Stream = {
      compartment_id                 = var.compartment_id
      service_connector_display_name = var.service_connector_display_name
      service_connector_source_kind  = var.service_connector_source_kind
      service_connector_source_cursor_kind = var.service_connector_source_cursor_kind
      service_connector_target_kind = var.service_connector_target_kind
      service_connector_target_batch_rollover_size_in_mbs = var.service_connector_target_batch_rollover_size_in_mbs
      service_connector_target_batch_rollover_time_in_ms  = var.service_connector_target_batch_rollover_time_in_ms
      service_connector_target_bucket                     = var.service_connector_target_bucket
      service_connector_target_object_name_prefix         = var.service_connector_target_object_name_prefix
      service_connector_description                       = var.service_connector_description
      defined_tags                                        = {}
      service_connector_tasks_kind                        = var.service_connector_tasks_kind
      service_connector_tasks_batch_size_in_kbs           = var.service_connector_tasks_batch_size_in_kbs
      service_connector_tasks_batch_time_in_sec           = var.service_connector_tasks_batch_time_in_sec
      function_id                                         = lookup(module.functions.functions,"DecoderFn").ocid
  }
}


# OCI Functions

app_params = { 
    application = {
      compartment_id    = var.compartment_id,
      subnet_ids        = [lookup(module.network-subnets.subnets,"private_subnet_application").id]
      display_name      = var.app_display_name,
      defined_tags      = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}  

fn_params = {
    function = {
      function_app     = "application"
      display_name     = "DecoderFn"
      image            = local.function_image
      defined_tags     = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}


# Create Data Catalog

  datacatalog_params = {
    datacatalog = {
      compartment_id                = var.compartment_id,
      catalog_display_name          = var.catalog_display_name
      defined_tags                  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
      private_endpoint_dns_zones    = ["vcn.oraclevcn.com", module.adw_database_private_endpoint.private_endpoint[0]]
      subnet_id                     = lookup(module.network-subnets.subnets,"private_subnet_midtier").id
      adw_data_asset_display_name   = "${var.db_name}_data_asset"
      object_storage_data_asset_display_name = "${var.gold_bucket_name}_data_asset"
      # dbusername                    = "admin"
      # dbpassword                    = var.db_password
  }
}


# Create Bastion Service Cloud

  bastions_params = { 
    "private-bastion-service" = {
      name = var.private_bastion_service_name
      compartment_id = var.compartment_id
      target_subnet_id = lookup(module.network-subnets.subnets,"private_subnet_application").id
      client_cidr_block_allow_list = ["0.0.0.0/0"]
      max_session_ttl_in_seconds = 3600
    }
}

  sessions_params = {}


# Create Oracle Analytics Cloud

  oac_params = { 
    oac = {
      compartment_id                             = var.compartment_id,
      analytics_instance_feature_set             = var.analytics_instance_feature_set
      analytics_instance_license_type            = var.analytics_instance_license_type
      name                                       = var.Oracle_Analytics_Instance_Name
      analytics_instance_idcs_access_token       = var.analytics_instance_idcs_access_token
      analytics_instance_capacity_capacity_type  = var.analytics_instance_capacity_capacity_type
      analytics_instance_capacity_value          = var.analytics_instance_capacity_value
      analytics_instance_network_endpoint_details_network_endpoint_type = "private"
      subnet_id                                  = lookup(module.network-subnets.subnets,"private_subnet_application").id,
      vcn_id                                     = lookup(module.network-vcn.vcns,"vcn_1_workload").id, 
      analytics_instance_network_endpoint_details_whitelisted_ips = ["0.0.0.0/0"]
      analytics_instance_network_endpoint_details_whitelisted_vcns_id = lookup(module.network-vcn.vcns,"vcn_1_workload").id, 
      whitelisted_ips                            = ["0.0.0.0/0"]
      defined_tags                               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
      analytics_instance_private_access_channel_display_name = "private"
      analytics_instance_private_access_channel_private_source_dns_zones_dns_zone = ["vcn_1_workload.oraclevcn.com", "vcn_0_hub.oraclevcn.com"]
  }
}


#Create Oracle Cloud Infrastructure Data Integration service

  ocidi_params = { 
    ocidi = {
      compartment_id   = var.compartment_id,
      display_name     = var.ocidi_display_name,
      description      = var.ocidi_description,
      is_private_network_enabled = "true"
      subnet_id        = lookup(module.network-subnets.subnets,"private_subnet_midtier").id
      vcn_id           = lookup(module.network-vcn.vcns,"vcn_1_workload").id, 
      defined_tags     = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
      freeform_tags    = {}
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
      subnet_id                  = lookup(module.network-subnets.subnets,"private_subnet_midtier").id
      project_name               = "machine_learning_platform"
      notebook_session_notebook_session_configuration_details_block_storage_size_in_gbs = var.notebook_session_notebook_session_configuration_details_block_storage_size_in_gbs
      notebook_session_display_name = var.notebook_session_display_name
      defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    }
}


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
      freeform_tags  = {}
      logs_bucket_uri            = "oci://${var.dataflow_logs_bucket_name}@${lookup(data.oci_identity_tenancy.tenancy, "name")}/"
      dns_zones      = ["vcn.oraclevcn.com", module.adw_database_private_endpoint.private_endpoint[0]]
      subnet_id      = lookup(module.network-subnets.subnets,"private_subnet_midtier").id
      description    = "dataflowapp"
      display_name   = var.dataflow_display_name
      max_host_count = var.dataflow_max_host_count
      nsg_ids        =  null
  }
}


# Web application firewall

waf_params = {
  waf = {
    compartment_id   = var.compartment_id,
    backend_type     = "LOAD_BALANCER"
    display_name     = var.waf_display_name
    load_balancer_id = module.lb.load_balancer_id
    defined_tags     = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    freeform_tags    = {}
  }
}


# Calling the Containers & Artifacts module

containers_artifacts_params = {
  containers_artifacts_params = {
    compartment_id   = var.tenancy_ocid
    display_name     = var.ocir_repo_name
    is_immutable     = false
    is_public        = false
  }
}


##### Calling the network modules that are required for this solution ######
## Created the DRG that will be used for our VCN.
drg_params = {
  mgmt_drg = {
    name         = "mgmt_drg"
    cidr_rt      = var.drg_cidr_rt
    defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}


## Creates the VCN "vcn0 and vcn1"
  vcns-lists = {
    vcn_0_hub = { 
     compartment_id = var.compartment_id
     cidr           = var.vcn_0_hub_cidr
     dns_label      = "vcn0"
     is_create_igw  = true
     is_attach_drg  = true // put true if you want to have drg attached !
     block_nat_traffic = false
     subnets  = {}  
     defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
     freeform_tags  = {}
    }
    vcn_1_workload = { 
     compartment_id = var.compartment_id
     cidr           = var.vcn_1_workload_cidr
     dns_label      = "vcn1"
     is_create_igw  = true
     is_attach_drg  = false
     block_nat_traffic = false
     subnets  = {}  
     defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
     freeform_tags  = {}
    }
}

#creates the subnets for each vcn public subnet for vcn0 and and private subnets for vnc1 
  subnet-lists = { 
     "" = {
        compartment_id = var.compartment_id
        cidr           = var.vcn_0_hub_cidr
        dns_label      = "vcn0"
        is_create_igw  = false
        is_attach_drg  = false
        block_nat_traffic = false
     
        subnets  = { 
          public_subnet = { 
	          compartment_id=var.compartment_id, 
            vcn_id=lookup(module.network-vcn.vcns,"vcn_0_hub").id, 
            availability_domain=""
	          cidr=var.public_subnet_cidr_vcn0,
            dns_label="public",
            private=false,
            dhcp_options_id="",
            security_list_ids=[module.network-security-lists.security_lists["public_security_list"].id],
            defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
            freeform_tags = {}
          }
          private_subnet_application = { 
	          compartment_id=var.compartment_id, 
            vcn_id=lookup(module.network-vcn.vcns,"vcn_1_workload").id, 
            availability_domain=""
	          cidr=var.private_subnet_cidr_application_vnc1,
            dns_label="application",
            private=true,
            dhcp_options_id="",
            security_list_ids=[module.network-security-lists.security_lists["private_security_list"].id],
            defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
            freeform_tags = {}
          }
          private_subnet_midtier = { 
	          compartment_id=var.compartment_id, 
            vcn_id=lookup(module.network-vcn.vcns,"vcn_1_workload").id, 
            availability_domain=""
	          cidr=var.private_subnet_cidr_midtier_vnc1,
            dns_label="midtier",
            private=true,
            dhcp_options_id="",
            security_list_ids=[module.network-security-lists.security_lists["private_security_list"].id],
            defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
            freeform_tags = {}
          }
          private_subnet_data = { 
	          compartment_id=var.compartment_id, 
            vcn_id=lookup(module.network-vcn.vcns,"vcn_1_workload").id, 
            availability_domain=""
	          cidr=var.private_subnet_cidr_data_vnc1,
            dns_label="data",
            private=true,
            dhcp_options_id="",
            security_list_ids=[module.network-security-lists.security_lists["private_security_list"].id],
            defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
            freeform_tags = {}
          }
        }
        defined_tags  = {}
        freeform_tags = {}
    },
  }



#create routing table attached to vcn and subnet to route traffic via IGW
  subnets_route_tables = {
    public_route_table = {
      compartment_id = var.compartment_id,
      vcn_id=lookup(module.network-vcn.vcns,"vcn_0_hub").id,
      subnet_id = lookup(module.network-subnets.subnets,"public_subnet").id,
      route_table_id = "",
      route_rules = [{
        is_create = true,
        destination       = "0.0.0.0/0",
        destination_type  = "CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn.internet_gateways, lookup(module.network-vcn.vcns,"vcn_0_hub").id).id,
        description       = ""
      },
      {
        is_create = true,
        destination       = var.vcn_1_workload_cidr,
        destination_type  = "CIDR_BLOCK",
        network_entity_id = module.local_peering_gateway.lpg_requestor
        description       = ""
      }],
        defined_tags      = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    }
    private_route_table_nat_application = {
      compartment_id = var.compartment_id,
      vcn_id=lookup(module.network-vcn.vcns,"vcn_1_workload").id,
      subnet_id = lookup(module.network-subnets.subnets,"private_subnet_application").id,
      route_table_id = "",
      route_rules = [{
        is_create = true,
        destination       = "0.0.0.0/0",
        destination_type  = "CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn.nat_gateways, lookup(module.network-vcn.vcns,"vcn_1_workload").id).id,
        description       = ""
      },
      {
        is_create = true,
        destination       = lookup(data.oci_core_services.sgw_services.services[0], "cidr_block"),
        destination_type  = "SERVICE_CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn.service_gateways, lookup(module.network-vcn.vcns,"vcn_1_workload").id).id,
        description       = ""
      },
      {
        is_create = true,
        destination       = var.vcn_0_hub_cidr,
        destination_type  = "CIDR_BLOCK",
        network_entity_id = module.local_peering_gateway.lpg_acceptor
        description       = ""
      }],
      defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    }
    private_route_table_nat_midtier = {
      compartment_id = var.compartment_id,
      vcn_id=lookup(module.network-vcn.vcns,"vcn_1_workload").id,
      subnet_id = lookup(module.network-subnets.subnets,"private_subnet_midtier").id,
      route_table_id = "",
      route_rules = [{
        is_create = true,
        destination       = "0.0.0.0/0",
        destination_type  = "CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn.nat_gateways, lookup(module.network-vcn.vcns,"vcn_1_workload").id).id,
        description       = ""
      },
      {
        is_create = true,
        destination       = lookup(data.oci_core_services.sgw_services.services[0], "cidr_block"),
        destination_type  = "SERVICE_CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn.service_gateways, lookup(module.network-vcn.vcns,"vcn_1_workload").id).id,
        description       = ""
      },
      {
        is_create = true,
        destination       = var.vcn_0_hub_cidr,
        destination_type  = "CIDR_BLOCK",
        network_entity_id = module.local_peering_gateway.lpg_acceptor
        description       = ""
      }],
      defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    }
    private_route_table_nat_data = {
      compartment_id = var.compartment_id,
      vcn_id=lookup(module.network-vcn.vcns,"vcn_1_workload").id,
      subnet_id = lookup(module.network-subnets.subnets,"private_subnet_data").id,
      route_table_id = "",
      route_rules = [{
        is_create = true,
        destination       = "0.0.0.0/0",
        destination_type  = "CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn.nat_gateways, lookup(module.network-vcn.vcns,"vcn_1_workload").id).id,
        description       = ""
      },
      {
        is_create = true,
        destination       = lookup(data.oci_core_services.sgw_services.services[0], "cidr_block"),
        destination_type  = "SERVICE_CIDR_BLOCK",
        network_entity_id = lookup(module.network-vcn.service_gateways, lookup(module.network-vcn.vcns,"vcn_1_workload").id).id,
        description       = ""
      },
      {
        is_create = true,
        destination       = var.vcn_0_hub_cidr,
        destination_type  = "CIDR_BLOCK",
        network_entity_id = module.local_peering_gateway.lpg_acceptor
        description       = ""
      }],
      defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
    }
  }

#network routing attachment
network-routing-attachment = {
    "" = {
      compartment_id = var.compartment_id,
      vcn_id = lookup(module.network-vcn.vcns,"vcn_0_hub").id,
      subnet_id = lookup(module.network-subnets.subnets,"public_subnet").id,
      route_table_id = lookup(module.network-routing.subnets_route_tables,"public_route_table").id,
      route_rules = [],
      defined_tags = {}
    }
}

#create security list - opening port 22 ssh and port 80 - http
  security_lists = {
    public_security_list = {
        vcn_id = lookup(module.network-vcn.vcns,"vcn_0_hub").id,
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
          }],
          [{
            stateless = false
            protocol  = "6" // tcp
            src           = "0.0.0.0/0"
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 5900, max=5900},
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "all",
            src           = "0.0.0.0/0"
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = null,
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "6" // tcp
            src           = "0.0.0.0/0"
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 3389, max=3389},
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
        vcn_id = lookup(module.network-vcn.vcns,"vcn_1_workload").id,
        compartment_id = var.compartment_id,
        defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
        ingress_rules = concat([{
            stateless = false
            protocol  = "all"
            src           = var.vcn_0_hub_cidr,
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = null,
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "6"
            src           = var.vcn_0_hub_cidr,
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = {min = 22, max=22},
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "all",
            src           = "0.0.0.0/0"
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = null,
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "all"
            src           = "0.0.0.0/0",
            src_type      = "CIDR_BLOCK",
            src_port      = null,
            dst_port      = null
            icmp_type     = null,
            icmp_code     = null
          }],
          [{
            stateless = false
            protocol  = "17"
            src           = var.vcn_0_hub_cidr,
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
   public_nsgs_list = {
        vcn_id = lookup(module.network-vcn.vcns,"vcn_0_hub").id,
        compartment_id = var.compartment_id,
        defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
        ingress_rules = { ingress1 = {
          is_create    = true,
          description  = "Parameters for customizing Network Security Group(s).",
          protocol     = "all",
          stateless    = false,
          src          = var.public_subnet_cidr_vcn0,
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
  private_nsgs_list = {
        vcn_id = lookup(module.network-vcn.vcns,"vcn_1_workload").id,
        compartment_id = var.compartment_id,
        defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
        ingress_rules = { ingress2 = {
          is_create    = true,
          description  = "Parameters for customizing Network Security Group(s).",
          protocol     = "all",
          stateless    = false,
          src          = "0.0.0.0/0"
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


# Local Peering between VCN0 and VCN1
lpg_params = {
  lpg = {
    vcn_id1        = lookup(module.network-vcn.vcns,"vcn_1_workload").id
    vcn_id2        = lookup(module.network-vcn.vcns,"vcn_0_hub").id
    display_name   = "lpg"
    compartment_id = var.compartment_id
  }
}

# Calling the Load Balancer module

  lb-params = { 
    lboac = {
      shape          = var.load_balancer_shape
      compartment_id = var.compartment_id
      subnet_ids = [lookup(module.network-subnets.subnets,"public_subnet").id]
      network_security_group_ids = [lookup(module.network-security-groups.nsgs,"public_nsgs_list").id]
      maximum_bandwidth_in_mbps = var.load_balancer_maximum_bandwidth_in_mbps
      minimum_bandwidth_in_mbps = var.load_balancer_minimum_bandwidth_in_mbps
      display_name  = var.load_balancer_display_name
      is_private    = false
      defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
      freeform_tags = {}
    }
}

  lb-backendset-params = {
    lb-backendset = {
      name             = "lb-backendset"
      load_balancer_id = module.lb.load_balancer_id
      policy           = "ROUND_ROBIN"
      port                = "443"
      protocol            = "TCP"
      response_body_regex = ""
      url_path            = "/"
      return_code         = null
      certificate_ids     = null
      certificate_name    = null
      cipher_suite_name   = null
      protocols           = null
      trusted_certificate_authority_ids = null
      server_order_preference           = null
      verify_depth                      = null
      verify_peer_certificate           = false
   }
}

  lb-listener-https-params = { 
     "lb-listener" = {
      load_balancer_id         = module.lb.load_balancer_id
      name                     = "tcp"
      default_backend_set_name = module.lb-backendset.BackendsetNames[0]
      port                     = "443"
      protocol                 = "TCP"
      rule_set_names           = []
      idle_timeout_in_seconds = "10"
  }
}

    lb-backend-params = {
      "lb-backend" = {
        load_balancer_id = module.lb.load_balancer_id
        backendset_name  = module.lb-backendset.BackendsetNames[0]
        ip_address       = module.oac.private_endpoint_ip
        port             = "443"
        backup           = false
        drain            = false
        offline          = false
        weight           = "1"
    }
}

    SSL_headers-params = { 
      lb-SSLHeaders = {
        load_balancer_id = module.lb.load_balancer_id
        name             = "SSLHeaders"
        SSLitems = [{item={
          action = "ADD_HTTP_REQUEST_HEADER"
          header = "Proxy-SSL"
          value  = "true"
        }},
        {item={
          action = "ADD_HTTP_REQUEST_HEADER"
          header = "is_ssl"
          value  = "ssl"
      }}]
      countSSL = 2
    }
}

    demo_certificate-params = { 
      lb-certificate = {
        certificate_name   = "demo_cert"
        load_balancer_id   = module.lb.load_balancer_id
        public_certificate = module.keygen.CertPem.cert_pem
        private_key        = module.keygen.SSPrivateKey.private_key_pem
        ca_certificate     = module.keygen.CertPem.cert_pem
        passphrase         = null
    }
}


# Dynamic Groups and Policies 

  dynamic_groups = {
      "Lakehouse-FunctionsServiceDynamicGroup" = {
        description = "Functions Service Dynamic Group"
        compartment_id = var.tenancy_ocid
        matching_rule = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${var.compartment_id}'}"
      },
      "Lakehouse-DSDynamicGroup" =  {
        description    = "DS Dynamic Group"
        compartment_id = var.tenancy_ocid
        matching_rule  = "ALL {resource.type = 'datasciencenotebooksession', resource.compartment.id = '${var.compartment_id}'}"
      },
      "Lakehouse-Datacatalog" =  {
        description    = "Data Catalog dynamic group"
        compartment_id = var.tenancy_ocid
        matching_rule  = "Any {resource.id = 'datacatalog',resource.compartment.id = '${var.compartment_id}'}"
      },
  }

   policies = { 
    "Lakehouse-StreamingDataSciencePolicies" = { 
      compartment_id = var.tenancy_ocid,
      description    = "List of Policies Required for the Full Data Lake Solution",
      statements     =  [
    "allow group Administrators to manage streams in tenancy",
    "allow group Administrators to manage stream-push in tenancy",
    "allow group Administrators to manage streampools in tenancy",
    "allow group Administrators to manage buckets in tenancy",
    "allow group Administrators to manage objects in tenancy",
    "allow group Administrators TO read buckets in tenancy",
    "allow group Administrators to manage connect-harness in tenancy", 
    "allow group Administrators to manage stream-family in tenancy",
    "allow group Administrators to read objectstorage-namespaces in tenancy",
    "allow group Administrators to inspect compartments in tenancy",
    "allow group Administrators to use virtual-network-family in tenancy",
    "allow group Administrators to manage data-science-family in tenancy",
    "allow group Administrators to use cloud-shell in tenancy",
    "allow group Administrators to manage repos in tenancy",
    "allow group Administrators to read metrics in tenancy",
    "allow group Administrators to manage tag-namespaces in compartment id ${var.compartment_id}",
    "allow group Administrators to use virtual-network-family in compartment id ${var.compartment_id}",
    "allow group Administrators to use object-family in compartment id ${var.compartment_id}",
    "allow service dataintegration to use virtual-network-family in compartment id ${var.compartment_id}",
    "allow dynamic-group Lakehouse-DSDynamicGroup to manage data-science-family in tenancy", 
    "allow service datascience to use virtual-network-family in tenancy",
    "allow dynamic-group Lakehouse-DSDynamicGroup to manage object-family in tenancy", 
    "allow dynamic-group Lakehouse-DSDynamicGroup to manage objects in compartment id ${var.compartment_id}", 
    "allow group Administrators to manage objects in tenancy where all {target.bucket.name = '${var.dataflow_logs_bucket_name}', any {request.permission = 'OBJECT_CREATE', request.permission = 'OBJECT_INSPECT'}}",
    "allow group Administrators to manage functions-family in tenancy",
    "allow service FaaS to read repos in tenancy",
    "allow service FaaS to use virtual-network-family in tenancy",
    "allow dynamic-group Lakehouse-FunctionsServiceDynamicGroup to manage all-resources in tenancy",
    "Allow dynamic-group Lakehouse-Datacatalog to read object-family in compartment id ${var.compartment_id}",
    "Allow dynamic-group Lakehouse-Datacatalog to manage data-catalog-family in compartment id ${var.compartment_id}",
    "Allow dynamic-group Lakehouse-Datacatalog to use virtual-network-family in compartment id ${var.compartment_id}",
    "allow service dataintegration to manage virtual-network-family in compartment id ${var.compartment_id}",
    "allow service datacatalog to manage virtual-network-family in compartment id ${var.compartment_id}",
    "allow service datacatalog to {VNIC_READ, VNIC_ATTACH, VNIC_DETACH, VNIC_CREATE, VNIC_DELETE,VNIC_ATTACHMENT_READ, SUBNET_READ, VCN_READ, SUBNET_ATTACH, SUBNET_DETACH, INSTANCE_ATTACH_SECONDARY_VNIC, INSTANCE_DETACH_SECONDARY_VNIC} in compartment id ${var.compartment_id}",
    "allow service datacatalog to read object-family in compartment id ${var.compartment_id}",
    "allow group Administrators to read instances in compartment id ${var.compartment_id}",
    "allow group Administrators to manage database-family in compartment id ${var.compartment_id}",
    "allow group Administrators to manage data-catalog-family in compartment id ${var.compartment_id}",
    "allow group Administrators to manage dis-family in compartment id ${var.compartment_id}",
    "allow group Administrators to use functions-family in tenancy"]
    },
  }

  
# End of local block
# End

}


