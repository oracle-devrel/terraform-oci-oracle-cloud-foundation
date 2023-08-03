# Copyright © 2023, Oracle and/or its affiliates.
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

resource "null_resource" "enable-monitoring" {
depends_on = [module.adw]
provisioner "local-exec" {
  when    = create
  command = "ansible-playbook db_monitoring_create.yaml -e managed_database_group_name=${var.managed_database_group_name} -e compartment_id=${var.compartment_id} -e autonomous_database_id=${local.autonomous_database_id}"
  } 
}


locals {
  ad_names                          = compact(data.template_file.ad_names.*.rendered)
  public_subnet_availability_domain = local.ad_names[0]
  service_name_prefix               = replace(var.service_name, "/[^a-zA-Z0-9]/", "")
  autonomous_database_id            = module.adw.adw[var.adw_db_name]


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
      subnet_id                   = lookup(module.network-subnets.subnets,"private-subnet").id
      nsg_ids                     = [lookup(module.network-security-groups.nsgs,"private-nsgs-list").id]
      data_safe_status            = var.adw_data_safe_status,
      defined_tags                = {}
  },
}

# Create Object Storage Buckets
  bucket_params = { 
    logging_logs = {
      compartment_id   = var.compartment_id,
      name             = var.logging_logs_bucket_name,
      access_type      = var.logging_logs_access_type,
      storage_tier     = var.logging_logs_storage_tier,
      events_enabled   = var.logging_logs_events_enabled,
      defined_tags     = {}
  },
    sch_logs = {
      compartment_id   = var.compartment_id,
      name             = var.sch_logs_bucket_name,
      access_type      = var.sch_logs_access_type,
      storage_tier     = var.sch_logs_storage_tier,
      events_enabled   = var.sch_logs_events_enabled,
      defined_tags     = {}
  }
}

# Create Notifications:
topic_params = {
  notification-topic = {
    compartment_id  = var.compartment_id
    topic_name  = "notification-topic"
    description = "Topic for related notifications."
  }
}

subscription_params = {
  subscription1 = {
    compartment_id  = var.compartment_id,
    endpoint   = "ionel.panaitescu@oracle.com"
    protocol   = "EMAIL"
    topic_name = "notification-topic"
  }
}


# Create Monitoring Alarms:
alarm_params = {
    alarm1 = {
        compartment_id                         = var.compartment_id
        destinations                           = [lookup(module.oci_notifications.topic_id,"notification-topic")]
        alarm_display_name                     = "autonomous_database_alam1"
        alarm_is_enabled                       = true
        alarm_metric_comp_name                 = var.compartment_id
        alarm_namespace                        = "oci_autonomous_database"
        alarm_query                            = "StorageUtilization[10m].max() > 95"
        alarm_severity                         = "Critical"
        alarm_body                             = "The Storage is reached the limit of 95% of it"
        message_format                         = "ONS_OPTIMIZED"
        alarm_metric_compartment_id_in_subtree = false
        alarm_pending_duration                 = null
        alarm_repeat_notification_duration     = null
        alarm_resolution                       = null
        alarm_resource_group                   = null
        suppression_params                      = []
    }
    alarm2 = {
        compartment_id                         = var.compartment_id
        destinations                           = [lookup(module.oci_notifications.topic_id,"notification-topic")]
        alarm_display_name                     = "autonomous_database_alam2"
        alarm_is_enabled                       = true
        alarm_metric_comp_name                 = var.compartment_id
        alarm_namespace                        = "oci_autonomous_database"
        alarm_query                            = "CpuUtilization[10m].max() > 90"
        alarm_severity                         = "Critical"
        alarm_body                             = "The CpuUtilization is high"
        message_format                         = "ONS_OPTIMIZED"
        alarm_metric_compartment_id_in_subtree = false
        alarm_pending_duration                 = null
        alarm_repeat_notification_duration     = null
        alarm_resolution                       = null
        alarm_resource_group                   = null
        suppression_params                      = []
    }
}


# Create Logging Groups and Log Groups:
log_group_params = {
  logging_logs_group = {
    compartment_id = var.compartment_id
    log_group_name = "logging_logs_group"
  }
}

log_params = {
  logging_logs_bucket-object-storage = {
    log_name            = "logging_logs_bucket-object-storage"
    log_group           = "logging_logs_group"
    log_type            = "SERVICE"
    source_log_category = "write"
    source_resource     = var.logging_logs_bucket_name
    source_service      = "objectstorage"
    source_type         = "OCISERVICE"
    compartment_id      = var.compartment_id
    is_enabled          = true
    retention_duration  = 30
  },
  logging_logs_public_subnet_flow_logs = {
    log_name            = "logging_logs_public_subnet_flow_logs"
    log_group           = "logging_logs_group"
    log_type            = "SERVICE"
    source_log_category = "all"
    source_resource     = "public-subnet"
    source_service      = "flowlogs"
    source_type         = "OCISERVICE"
    compartment_id      = var.compartment_id
    is_enabled          = true
    retention_duration  = 30
  },
  logging_logs_private_subnet_flow_logs = {
    log_name            = "logging_logs_private_subnet_flow_logs"
    log_group           = "logging_logs_group"
    log_type            = "SERVICE"
    source_log_category = "all"
    source_resource     = "private-subnet"
    source_service      = "flowlogs"
    source_type         = "OCISERVICE"
    compartment_id      = var.compartment_id
    is_enabled          = true
    retention_duration  = 30
  },
}


# Create Events:
events_params = {
  "notify-on-network-changes-rule" = {
    rule_display_name = "notify-on-network-changes-rule"
    description       = "Nofification on any event for networking"
    rule_is_enabled   = true
    compartment_id    = var.compartment_id
    freeform_tags     = {}
    action_params = [{
      action_type         = "ONS"
      actions_description = "Sends notification via ONS"
      function_name       = ""
      is_enabled          = true
      stream_name         = ""
      topic_name          = "notification-topic"
    }]
    condition = {
      "eventType" : ["com.oraclecloud.virtualnetwork.createvcn",
        "com.oraclecloud.virtualnetwork.deletevcn",
        "com.oraclecloud.virtualnetwork.updatevcn",
        "com.oraclecloud.virtualnetwork.createroutetable",
        "com.oraclecloud.virtualnetwork.deleteroutetable",
        "com.oraclecloud.virtualnetwork.updateroutetable",
        "com.oraclecloud.virtualnetwork.changeroutetablecompartment",
        "com.oraclecloud.virtualnetwork.createsecuritylist",
        "com.oraclecloud.virtualnetwork.deletesecuritylist",
        "com.oraclecloud.virtualnetwork.updatesecuritylist",
        "com.oraclecloud.virtualnetwork.changesecuritylistcompartment",
        "com.oraclecloud.virtualnetwork.createnetworksecuritygroup",
        "com.oraclecloud.virtualnetwork.deletenetworksecuritygroup",
        "com.oraclecloud.virtualnetwork.updatenetworksecuritygroup",
        "com.oraclecloud.virtualnetwork.updatenetworksecuritygroupsecurityrules",
        "com.oraclecloud.virtualnetwork.changenetworksecuritygroupcompartment",
        "com.oraclecloud.virtualnetwork.createdrg",
        "com.oraclecloud.virtualnetwork.deletedrg",
        "com.oraclecloud.virtualnetwork.updatedrg",
        "com.oraclecloud.virtualnetwork.createdrgattachment",
        "com.oraclecloud.virtualnetwork.deletedrgattachment",
        "com.oraclecloud.virtualnetwork.updatedrgattachment",
        "com.oraclecloud.virtualnetwork.createinternetgateway",
        "com.oraclecloud.virtualnetwork.deleteinternetgateway",
        "com.oraclecloud.virtualnetwork.updateinternetgateway",
        "com.oraclecloud.virtualnetwork.changeinternetgatewaycompartment",
        "com.oraclecloud.virtualnetwork.createlocalpeeringgateway",
        "com.oraclecloud.virtualnetwork.deletelocalpeeringgateway",
        "com.oraclecloud.virtualnetwork.updatelocalpeeringgateway",
        "com.oraclecloud.virtualnetwork.changelocalpeeringgatewaycompartment",
        "com.oraclecloud.natgateway.createnatgateway",
        "com.oraclecloud.natgateway.deletenatgateway",
        "com.oraclecloud.natgateway.updatenatgateway",
        "com.oraclecloud.natgateway.changenatgatewaycompartment",
        "com.oraclecloud.servicegateway.createservicegateway",
        "com.oraclecloud.servicegateway.deleteservicegateway.begin",
        "com.oraclecloud.servicegateway.deleteservicegateway.end",
        "com.oraclecloud.servicegateway.attachserviceid",
        "com.oraclecloud.servicegateway.detachserviceid",
        "com.oraclecloud.servicegateway.updateservicegateway",
        "com.oraclecloud.servicegateway.changeservicegatewaycompartment"
      ]
    }
  }

  "notify-on-autonomous-database-changes-rule" = {
    rule_display_name = "notify-on-autonomous-database-changes-rule"
    description       = "Nofification on any event for Autonomous Databases"
    rule_is_enabled   = true
    compartment_id    = var.compartment_id
    freeform_tags     = {}
    action_params = [{
      action_type         = "ONS"
      actions_description = "Sends notification via ONS"
      function_name       = ""
      is_enabled          = true
      stream_name         = ""
      topic_name          = "notification-topic"
    }]
    condition = {
      "eventType" : ["com.oraclecloud.databaseservice.autonomous.database.critical",
        "com.oraclecloud.databaseservice.restartautonomousdatabase.begin", 
        "com.oraclecloud.databaseservice.startautonomousdatabase.begin",
        "com.oraclecloud.databaseservice.stopautonomousdatabase.begin",
        "com.oraclecloud.databaseservice.deleteautonomousdatabase.begin",
        "com.oraclecloud.databaseservice.autonomous.database.warning"
      ]
    }
  }
}

# Log Analytics

log_analytics_log_group_params = {
  log_analytics_log_group = {
    compartment_id  = var.compartment_id
    display_name    = "log_analytics_iopanait"
  }
}


# Service Connector Hub

srv_connector_params = {
  audit-logs-sch = {
    display_name              = "audit-logs-sch"
    compartment_id            = var.compartment_id
    srv_connector_source_kind = "logging"
    state                     = "ACTIVE"
    log_sources_params = [
      {
        compartment_id = var.compartment_id
        log_group_name = lookup(module.oci_logging.log_groups,"logging_logs_group")
        is_audit       = true
        log_name       = lookup(module.oci_logging.logs,"logging_logs_bucket-object-storage")
      },
    ]
    source_stream_name             = null
    srv_connector_target_kind      = "objectstorage"
    obj_batch_rollover_size_in_mbs = 100
    obj_batch_rollover_time_in_ms  = 420000
    obj_target_bucket              = var.sch_logs_bucket_name
    object_name_prefix             = "sch-AuditLogs"
    compartment_id                 = var.compartment_id
    function_name                  = null
    target_log_group               = null
    mon_target_metric              = null
    mon_target_metric_namespace    = null
    target_stream_name             = null
    target_topic_name              = null
    enable_formatted_messaging     = false
    tasks                          = []
  },
  audit-to-log-analytics = {
    display_name              = "audit-logging-to-loganalytics"
    compartment_id            = var.compartment_id
    srv_connector_source_kind = "logging"
    state                     = "ACTIVE"
    log_sources_params = [
      {
        compartment_id = var.compartment_id
        log_group_name = lookup(module.oci_logging.log_groups,"logging_logs_group")
        is_audit       = true
        log_name       = lookup(module.oci_logging.logs,"logging_logs_bucket-object-storage")
      },
    ]
    source_stream_name             = null
    srv_connector_target_kind      = "loggingAnalytics"
    obj_batch_rollover_size_in_mbs = null
    obj_batch_rollover_time_in_ms  = null
    obj_target_bucket              = null
    object_name_prefix             = null
    compartment_id                 = var.compartment_id
    function_name                  = null
    target_log_group               = lookup(module.oci_log_analytics.log_analytics_log_group,"log_analytics_iopanait"),
    mon_target_metric              = null
    mon_target_metric_namespace    = null
    target_stream_name             = null
    target_topic_name              = null
    enable_formatted_messaging     = false
    tasks                          = []
  },
}

# Data Safe Monitoring DB ADW
oci_data_safe_private_endpoint_params = {
  data_safe_endpoint = {
    compartment_id  = var.compartment_id
    display_name    = "data_safe_endpoint"
    description     = "data_safe_endpoint"
    vcn_id          = lookup(module.network-vcn.vcns,"vcn").id
    subnet_id       = lookup(module.network-subnets.subnets,"private-subnet").id
    nsg_ids         = [lookup(module.network-security-groups.nsgs,"private-nsgs-list").id]
    defined_tags    = {}
  }
}

## Creates the VCN "vcn with the CIDR BLOCK 10.0.0.0/16"
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
            defined_tags = {}
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
            defined_tags = {}
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
            defined_tags = {}
    }
  }

#create security list - opening port 22 ssh and port 80 - http
  security_lists = {
    public_security_list = {
        vcn_id = lookup(module.network-vcn.vcns,"vcn").id,
        compartment_id = var.compartment_id,
            defined_tags = {}
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
        vcn_id = lookup(module.network-vcn.vcns,"vcn").id,
        compartment_id = var.compartment_id,
            defined_tags = {}
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
            defined_tags = {}
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
            defined_tags = {}
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
      "${local.service_name_prefix}-DynamicGroup" = {
        description = "odi_dynamic_group"
        compartment_id = var.tenancy_ocid
        matching_rule = "ALL {instance.compartment.id = '${var.compartment_id}'}"
      },
      "${local.service_name_prefix}-loganalytics_dynamic_group_name" = {
        compartment_id = var.tenancy_ocid
        description    = "Logging Analytics Management Agent Dynamic group"
        matching_rule = "All {resource.type = 'managementagent', resource.compartment.id = '${var.compartment_id}'}"
      }
  }

  policies = { 
    "${local.service_name_prefix}-monitoring" = { 
      compartment_id = var.compartment_id,
      description    = "monitoring",
      statements     =  [
    "allow dynamic-group ${local.service_name_prefix}-DynamicGroup to inspect autonomous-database-family in compartment id ${var.compartment_id}",
    "allow dynamic-group ${local.service_name_prefix}-DynamicGroup to read autonomous-database-family in compartment id ${var.compartment_id}",
    "allow any-user to manage objects in compartment id ${var.compartment_id} where all {request.principal.type='serviceconnector',target.bucket.name= 'Logging_Logs_bucket',request.principal.compartment.id= '${var.compartment_id}'}",
    "allow dynamic-group ${local.service_name_prefix}-DynamicGroup to inspect compartments in compartment id ${var.compartment_id}",
    "allow service loganalytics to READ loganalytics-features-family in compartment id ${var.compartment_id}",
    "allow group Administrators to READ compartments in compartment id ${var.compartment_id}",
    "allow group Administrators to MANAGE loganalytics-features-family in compartment id ${var.compartment_id}",
    "allow group Administrators to MANAGE loganalytics-resources-family in compartment id ${var.compartment_id}",
    "allow group Administrators to MANAGE management-dashboard-family in compartment id ${var.compartment_id}",
    "allow group Administrators to READ metrics IN compartment id ${var.compartment_id}",
    "allow group Administrators TO MANAGE management-agents IN compartment id ${var.compartment_id}",
    "allow group Administrators to MANAGE management-agent-install-keys IN compartment id ${var.compartment_id}",
    "allow group Administrators to READ users IN compartment id ${var.compartment_id}",
    "allow any-user to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id ${var.compartment_id} where all {request.principal.type='serviceconnector', target.loganalytics-log-group.id='log_analytics_iopanait)', request.principal.compartment.id='${var.compartment_id}'}",
    "allow dynamic-group ${local.service_name_prefix}-loganalytics_dynamic_group_name to MANAGE management-agents IN compartment id ${var.compartment_id}",
    "allow dynamic-group ${local.service_name_prefix}-loganalytics_dynamic_group_name to USE METRICS IN compartment id ${var.compartment_id}",
    "allow dynamic-group ${local.service_name_prefix}-loganalytics_dynamic_group_name to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id ${var.compartment_id}",
    "allow dynamic-group ${local.service_name_prefix}-loganalytics_dynamic_group_name to USE loganalytics-collection-warning in compartment id ${var.compartment_id}"]  
    },
  }

# End

}