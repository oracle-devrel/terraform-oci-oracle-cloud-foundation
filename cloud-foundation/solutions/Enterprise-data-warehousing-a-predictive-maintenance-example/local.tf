# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
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

data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_regions" "oci_regions" {
  filter {
    name = "name" 
    values = [var.region]
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
  public_subnet_availability_domain = local.ad_names[0]
  ad_names = compact(data.template_file.ad_names.*.rendered)
  service_name_prefix = replace(var.service_name, "/[^a-zA-Z0-9]/", "")

  function_image = "${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/decoder:0.0.50"
  ocir_docker_repository = join("", [lower(lookup(data.oci_identity_regions.oci_regions.regions[0], "key")), ".ocir.io"])
  ocir_namespace         = lookup(data.oci_identity_tenancy.tenancy, "name")

# Object Storage
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

service_connector = {
    Test_Stream = {
      compartment_id          = var.compartment_id
      service_connector_display_name = var.service_connector_display_name
      service_connector_source_kind  = var.service_connector_source_kind
      service_connector_source_cursor_kind = var.service_connector_source_cursor_kind
      service_connector_target_kind = var.service_connector_target_kind
      service_connector_target_batch_rollover_size_in_mbs = var.service_connector_target_batch_rollover_size_in_mbs
      service_connector_target_batch_rollover_time_in_ms  = var.service_connector_target_batch_rollover_time_in_ms
      service_connector_target_bucket                     = var.service_connector_target_bucket
      service_connector_target_object_name_prefix         = var.service_connector_target_object_name_prefix
      service_connector_description                       = var.service_connector_description
      defined_tags =  { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
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
      subnet_ids        = [lookup(module.network-subnets.subnets,"public-subnet").id]
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

# OCI DataScience
datascience_params = {
    data_science_project = {
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
      project_name               = "data_science_project"
      notebook_session_notebook_session_configuration_details_block_storage_size_in_gbs = var.notebook_session_notebook_session_configuration_details_block_storage_size_in_gbs
      notebook_session_display_name = var.notebook_session_display_name
      defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  }
}

#creates the VCN "vcn with the CIDR BLOCK 10.0.0.0/16"
  vcns-lists = {
    vcn = { 
     compartment_id = var.compartment_id
     cidr           = var.vcn_cidr
     dns_label      = "vcn"
     is_create_igw  = true
     is_attach_drg  = false
     block_nat_traffic = false
     subnets  = {}  
     defined_tags   = {}
     freeform_tags = {}
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
      "${local.service_name_prefix}-FunctionsServiceDynamicGroup" = {
        description = "Functions Service Dynamic Group"
        compartment_id = var.tenancy_ocid
        matching_rule = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${var.compartment_id}'}"
      },
      "${local.service_name_prefix}-DSDynamicGroup" =  {
        description    = "DS Dynamic Group"
        compartment_id = var.tenancy_ocid
        matching_rule  = "ALL {resource.type = 'datasciencenotebooksession', resource.compartment.id = '${var.compartment_id}'}"
      },
  }



   policies = { 
    "${local.service_name_prefix}-StreamingDataSciencePolicies" = { 
      compartment_id = var.tenancy_ocid,
      description    = "List of Policies Required for this solution",
      statements     =  [
    "allow group Administrators to manage streams in tenancy",
    "allow group Administrators to manage stream-push in tenancy",
    "allow group Administrators to manage buckets in tenancy",
    "allow group Administrators to manage objects in tenancy",
    "allow group Administrators TO read buckets in tenancy",
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
    "allow dynamic-group ${local.service_name_prefix}-DSDynamicGroup to manage data-science-family in tenancy", 
    "allow service datascience to use virtual-network-family in tenancy",
    "allow dynamic-group ${local.service_name_prefix}-DSDynamicGroup to manage object-family in tenancy", 
    "allow dynamic-group ${local.service_name_prefix}-DSDynamicGroup to manage objects in compartment id ${var.compartment_id}", 
    "allow group Administrators to manage objects in tenancy where all {target.bucket.name = '${var.dataflow_logs_bucket_name}', any {request.permission = 'OBJECT_CREATE', request.permission = 'OBJECT_INSPECT'}}",
    "allow group Administrators to manage functions-family in tenancy",
    "allow group Administrators to use functions-family in tenancy",
    "allow service FaaS to read repos in tenancy",
    "allow service FaaS to use virtual-network-family in tenancy",
    "allow dynamic-group ${local.service_name_prefix}-FunctionsServiceDynamicGroup to manage all-resources in tenancy",
    "allow group Administrators to use functions-family in tenancy"]
    },
  }
# End of local block
}

resource "null_resource" "Login2OCIR" {
  provisioner "local-exec" {
    command = "echo '${var.ocir_user_password}' |  docker login ${local.ocir_docker_repository} --username ${local.ocir_namespace}/${var.ocir_user_name} --password-stdin"
  }
}

resource "null_resource" "DecoderPush2OCIR" {
  depends_on = [null_resource.Login2OCIR]
  provisioner "local-exec" {
    command     = "image=$(docker images | grep decoder | awk -F ' ' '{print $3}') ; docker rmi -f $image &> /dev/null ; echo $image"
    working_dir = "functions/decoder"
  }
  provisioner "local-exec" {
    command     = "fn build --verbose"
    working_dir = "functions/decoder"
  }
  provisioner "local-exec" {
    command     = "image=$(docker images | grep decoder | awk -F ' ' '{print $3}') ; docker tag $image ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/decoder:0.0.50"
    working_dir = "functions/decoder"
  }
  provisioner "local-exec" {
    command     = "docker push ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/decoder:0.0.50"
    working_dir = "functions/decoder"
  }
}