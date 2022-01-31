# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "ADW_Service_Console_URL" {
  value = module.adw.ADW_Service_Console_URL
}

output "Analytics_URL" {
  value = module.oac.Analytics_URL
}

output "ADW_LOGIN" {
  value = "Please use the ADW URL to login by using the user admin and the password that you have provided."
}

output "INSTRUCTIONS" {
  value = "Please scroll up for the GoldenGate Provisioning - there are all the informations how to connect to the OSA and Spark - save all the informations regarding connectivity, users, passwords, etc. in a safe place. Also you can use the generated private key from the current directory - to connect to the WebTierandBastion-init-web-tier Instance and in /home/opc is a file called Readme.txt that contains all the informations."
}

output "OSA_UI" {
  value = "You can access OSA UI using https://<Web-Tier-and-Bastion>/osa"
}

output "Spark_UI" {
  value = "Access Spark UI using https://<Web-Tier-and-Bastion>/spark"
}

output "Buckets" {
  value = module.os.buckets
}

output "DataCatalog" {
  value = module.datacatalog.datacatalog
}

output "Odi" {
  value = module.odi.odi
}

output "Datascience" {
  value = module.datascience.datascience
}

output "Notebook" {
  value = module.datascience.notebook
}

output "deployment_id" {
  value = module.golden_gate_deployment.deployment_id
}

output "private_ip" {
  value = module.golden_gate_deployment.deployment_ip
}

output "deployment_url" {
  value = module.golden_gate_deployment.deployment_url
}

output "golgen_gate_console" {
  value = "The GoldenGate console is only accessible through a private URL from a Compute instance using the same VCN as the GoldenGate deployment, or through a bastion host."
}

output "streaming_poolID" {
  value = module.streaming.streaming_poolID
}

output "streaming_ID" {
  value = module.streaming.streaming_ID
}

output "dataflow" {
  value = module.dataflowapp.dataflow
}

output "ai_anomaly_detection_project" {
    value = module.ai-anomaly-detection.ai_anomaly_detection_project
}

output "ai_anomaly_detection_data_asset" {
    value = module.ai-anomaly-detection.ai_anomaly_detection_data_asset
}

output "ai_anomaly_detection_model" {
    value = module.ai-anomaly-detection.ai_anomaly_detection_model
}

output "gateways" {
  value = module.api-gateway.gateways
}

output "deployments" {
  value = module.api-gateway.deployments
}

output "api_endpoints" {
  value = module.api-gateway.routes
}

output "big_data_service" {
  value = module.big-data-service.big_data_service
}

output "fss_filesystems" {
  value = module.fss.filesystems
}

output "fss_mount_targets" {
  value = module.fss.mount_targets
}

output "compute_linux_instances" {
  value = module.compute.linux_instances
}

output "all_instances" {
  value = module.compute.all_instances
}

output "all_private_ips" {
  value = module.compute.all_private_ips
}

output "fastconnect" {
    value = module.fastconnect.private_vc_with_provider_no_cross_connect_or_cross_connect_group_id
}

output "drgs_list" {
    value = module.drg.drgs_list
}

output "drgs_details" {
    value = module.drg.drgs_details
}
