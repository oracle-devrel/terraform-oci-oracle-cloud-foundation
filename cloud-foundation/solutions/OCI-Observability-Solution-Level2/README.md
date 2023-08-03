# Oracle Cloud Foundation Terraform Solution - OCI Observability Solution Level 2



## Table of Contents
1. [Overview](#overview)
1. [Deliverables](#deliverables)
1. [Executing Instructions](#instructions)
    1. [Deploy Using the Terraform CLI](#Deploy-Using-the-Terraform-CLI)
1. [Documentation](#documentation)
1. [Help](#help)
1. [The Team](#team)
1. [Feedback](#feedback)
1. [Known Issues](#known-issues)
1. [Contribute](#CONTRIBUTING.md)
1. [License](#LICENSE.md)

## <a name="overview"></a>Overview
One of the most important things to consider when building a service is how you will monitor it and gain insights as to how it’s performing. This is a critical aspect of running any service at scale. 

When you are building your service in OCI, there are many options you can use for monitoring your applications, services and infrastructure. This tutorial will help you monitor your services inside OCI. In addition, we will also use Terraform to describe all the configuration through code.

This concept (Level 2) it's based on Level 1 and will bring more insides. 
Main services that we will cover here are:
-	OCI Monitoring
-	OCI Notification
-	OCI Events
-	Database Management Service
-	OCI Logging
-	OCI Operations Insight
-	OCI Data Safe
-	OCI Service Connector Hub
-	OCI Logging Analytics

To enable the Database Management Service and Operations Insight on a Autonomous Data Warehouse databases we use ansible.


For this we are using the ansible oci collections:

__oracle.oci.oci_database_autonomous_database_actions__ – Perform actions on an AutonomousDatabase resource in Oracle Cloud Infrastructure 
    - For action=enable_autonomous_database_management, enables Database Management for Autonomous Database.
    - For action=enable_autonomous_database_operations_insights, enables the specified Autonomous Database with Operations Insights.

__oracle.oci.oci_database_management_managed_database_group__ – Manage a ManagedDatabaseGroup resource in Oracle Cloud Infrastructure
    - For state=present, creates a Managed Database Group. The group does not contain any Managed Databases when it is created, and they must be added later.

__oracle.oci.oci_database_management_managed_database_group_actions__ – Perform actions on a ManagedDatabaseGroup resource in Oracle Cloud Infrastructure
    - For action=add_managed_database, adds a Managed Database to a specific Managed Database Group. After the database is added, it will be included in the management activities performed on the Managed Database Group.


## <a name="deliverables"></a>Deliverables
 This repository encloses one deliverable:

- A reference implementation written in Terraform HCL (Hashicorp Language) that provisions fully functional resources in an OCI tenancy.

- Oracle Cloud Infrastructure Ansible Collection provide an easy way to create and provision resources in Oracle Cloud Infrastructure (OCI) through Ansible. These modules allow you to author Ansible playbooks that help you automate the provisioning and configuring of Oracle Cloud Infrastructure services and resources, such as Compute, Load Balancing, Database, and other Oracle Cloud Infrastructure services.


## <a name="instructions"></a>Executing Instructions

## Prerequisites

- Permission to `manage` the following types of resources in your Oracle Cloud Infrastructure tenancy: `vcns`, `nat-gateways`, `route-tables`, `subnets`, `service-gateways`, `security-lists`, `dynamic groups`, `policies`, `network security groups`, `autonomous database`, `object storage`, `oci notifications`, `monitoring alarms`, `oci logging `, `oci events` , `database management`, `oci data safe `, `oci service connector hub `, ` Operations Insights ` and `oci logging analytics `.
- Quota to create the following resources: 1 ADW database instance , 1 object storage buckets, 1 notification topic with 1 subscription inside it, 2 monitoring alarms, 1 log groups with 3 logging flows, 2 events using OCI events service and enable database management for the autonomous database with Ansible.Also will create 1 log analytics log group, 1 data safe private endpoint for the autonomous database, enable the Opeartions Insights service on the autonomous database, creates 2 service connector hubs, one for the object storage logs and one for the logging service connecting with the Log Analytics Service.
If you don't have the required permissions and quota, contact your tenancy administrator. See [Policy Reference](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm), [Service Limits](https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm), [Compartment Quotas](https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcequotas.htm).

# <a name="Deploy-Using-the-Terraform-CLI"></a>Deploy Using the Terraform CLI

## Clone the Module
Now, you'll want a local copy of this repo. You can make that with the commands:

    git clone https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation.git
    cd terraform-oci-oracle-cloud-foundation/cloud-foundation/solutions/OCI-Observability-Solution-Level2
    ls

## Deployment

- Follow the instructions from Prerequisites links in order to install terraform.
- Download the terraform version suitable for your operating system.
- Unzip the archive.
- Add the executable to the PATH.
- You will have to generate an API signing key (public/private keys) and the public key should be uploaded in the OCI console, for the iam user that will be used to create the resources. Also, you should make sure that this user has enough permissions to create resources in OCI. In order to generate the API Signing key, follow the steps from: https://docs.us-phoenix-1.oraclecloud.com/Content/API/Concepts/apisigningkey.htm#How
  The API signing key will generate a fingerprint in the OCI console, and that fingerprint will be used in a terraform file described below.
- You will also need to generate an OpenSSH public key pair. Please store those keys in a place accessible like your user home .ssh directory.

## Prerequisites

- Install Terraform v0.13 or greater: https://www.terraform.io/downloads.html
- Install Python 3.6: https://www.digitalocean.com/community/tutorials/how-to-install-python-3-and-set-up-a-local-programming-environment-on-centos-7
- Ansible>=2.9 
- oci>=2.57.0
- OCI Ansible Collection 
- Generate an OCI API Key
- Create your config under \$home*directory/.oci/config (run \_oci setup config* and follow the steps)
- Gather Tenancy related variables (tenancy_id, user_id, local path to the oci_api_key private key, fingerprint of the oci_api_key_public key, and region)

### Installing Terraform

Go to [terraform.io](https://www.terraform.io/downloads.html) and download the proper package for your operating system and architecture. Terraform is distributed as a single binary.
Install Terraform by unzipping it and moving it to a directory included in your system's PATH. You will need the latest version available.

### Prepare Terraform Provider Values

**variables.tf** is located in the root directory. This file is used in order to be able to make API calls in OCI, hence it will be needed by all terraform automations.

In order to populate the **variables.tf** file, you will need the following:

- Tenancy OCID
- User OCID
- Local Path to your private oci api key
- Fingerprint of your public oci api key
- Region

#### **Getting the Tenancy and User OCIDs**

You will have to login to the [console](https://console.us-ashburn-1.oraclecloud.com) using your credentials (tenancy name, user name and password). If you do not know those, you will have to contact a tenancy administrator.

In order to obtain the tenancy ocid, after logging in, from the menu, select Administration -> Tenancy Details. The tenancy OCID, will be found under Tenancy information and it will be similar to **ocid1.tenancy.oc1..aaa…**

In order to get the user ocid, after logging in, from the menu, select Identity -> Users. Find your user and click on it (you will need to have this page open for uploading the oci_api_public_key). From this page, you can get the user OCID which will be similar to **ocid1.user.oc1..aaaa…**

#### **Creating the OCI API Key Pair and Upload it to your user page**

Create an oci_api_key pair in order to authenticate to oci as specified in the [documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#How):

Create the .oci directory in the home of the current user

`$ mkdir ~/.oci`

Generate the oci api private key

`$ openssl genrsa -out ~/.oci/oci_api_key.pem 2048`

Make sure only the current user can access this key

`$ chmod go-rwx ~/.oci/oci_api_key.pem`

Generate the oci api public key from the private key

`$ openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem`

You will have to upload the public key to the oci console for your user (go to your user page -> API Keys -> Add Public Key and paste the contents in there) in order to be able to do make API calls.

After uploading the public key, you can see its fingerprint into the console. You will need that fingerprint for your variables.tf file.
You can also get the fingerprint from running the following command on your local workstation by using your newly generated oci api private key.

`$ openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c`

#### **Generating an SSH Key Pair on UNIX or UNIX-Like Systems Using ssh-keygen**

- Run the ssh-keygen command.

`ssh-keygen -b 2048 -t rsa`

- The command prompts you to enter the path to the file in which you want to save the key. A default path and file name are suggested in parentheses. For example: /home/user_name/.ssh/id_rsa. To accept the default path and file name, press Enter. Otherwise, enter the required path and file name, and then press Enter.
- The command prompts you for a passphrase. Enter a passphrase, or press ENTER if you don't want to havea passphrase.
  Note that the passphrase isn't displayed when you type it in. Remember the passphrase. If you forget the passphrase, you can't recover it. When prompted, enter the passphrase again to confirm it.
- The command generates an SSH key pair consisting of a public key and a private key, and saves them in the specified path. The file name of the public key is created automatically by appending .pub to the name of the private key file. For example, if the file name of the SSH private key is id_rsa, then the file name of the public key would be id_rsa.pub.
  Make a note of the path where you've saved the SSH key pair.
  When you create instances, you must provide the SSH public key. When you log in to an instance, you must specify the corresponding SSH private key and enter the passphrase when prompted.

#### **Getting the Region**

Even though, you may know your region name, you will needs its identifier for the variables.tf file (for example, US East Ashburn has us-ashburn-1 as its identifier).
In order to obtain your region identifier, you will need to Navigate in the OCI Console to Administration -> Region Management
Select the region you are interested in, and save the region identifier.

#### **Prepare the variables.tf file**

You will have to modify the **variables.tf** file to reflect the values that you’ve captured.

```
variable "tenancy_ocid" {
  type = string
  default = "" (tenancy ocid, obtained from OCI console - Profile -> Tenancy)
}

variable "region" {
    type = string
    default = "" (the region used for deploying the infrastructure - ex: eu-frankfurt-1)
}

variable "compartment_id" {
  type = string
  default = "" (the compartment used for deploying the solution - ex: compartment1)
}

variable "user_ocid" {
    type = string
    default = "" (user ocid, obtained from OCI console - Profile -> User Settings)
}

variable "fingerprint" {
    type = string
    default = "" (fingerprint obtained after setting up the API public key in OCI console - Profile -> User Settings -> API Keys -> Add Public Key)
}

variable "private_key_path" {
    type = string
    default = ""  (the path of your local oci api key - ex: /root/.ssh/oci_api_key.pem)
}
```
### Ansible collection installation

#### Oracle Linux 7

```
sudo yum-config-manager --enable ol7_developer
sudo yum-config-manager --enable ol7_developer_EPEL
sudo yum install oci-ansible-collection
```
#### Oracle Linux 8

```
sudo yum-config-manager --enable ol8_developer
sudo yum-config-manager --enable ol8_developer_EPEL
sudo yum install oci-ansible-collection
```

#### Linux/macOS

```
curl -L https://raw.githubusercontent.com/oracle/oci-ansible-collection/master/scripts/install.sh | bash -s -- --verbose
```
#### For more info about installation and troubleshooting check the [Installation Guide](InstallationGuide).


## Repository files

* **COMMON_ISSUES.md** - OCI Ansible Collections common issues
* **CONTRIBUTING.md** - Contributing guidelines, also called Contribution guidelines, the CONTRIBUTING.md file, or software contribution guidelines, is a text file which project managers include in free and open-source software packages or other open media packages for the purpose of describing how others may contribute user-generated content to the project.The file explains how anyone can engage in activities such as formatting code for submission or submitting patches
* **db_monitoring_create.yaml** - The Ansible File that will deploy/create/enable the Monitoring solution for Database Management Service
* **FAQ.md** - Frequently Asked Questions Page
* **InstallationGuide.md** - Info about installation and troubleshooting guide the Ansible Installation
* **KNOWN_ISSUES.md** - OCI Ansible Modules Knows Issues
* **LICENSE** - The Universal Permissive License (UPL), Version 1.0 
* **local.tf** - Local values can be helpful to avoid repeating the same values or expressions multiple times in a configuration, but if overused they can also make a configuration hard to read by future maintainers by hiding the actual values used.Here is the place where all the resources are defined.
* **main.tf** - Main Terraform script used for instantiating the Oracle Cloud Infrastructure provider and all subsystems modules
* **outputs.tf** - Defines project's outputs that you will see after the code runs successfuly
* **provider.tf** - The terraform provider that will be used (OCI)
* **README.md** - This file
* **variables.tf** - Project's global variables
* **variables.ini** - Project's global variables for ansible that will store the database group ID.


Now, populate the `variable.tf` file with the disared configuration following the information:


# Autonomous Data Warehouse

The ADW subsystem / module is able to create ADW/ATP databases.

* Parameters:
    * __adw_cpu_core_count__ - The number of OCPU cores to be made available to the database. For Autonomous Databases on dedicated Exadata infrastructure, the maximum number of cores is determined by the infrastructure shape. See Characteristics of Infrastructure Shapes for shape details.
    * __adw_size_in_tbss__ - The size, in gigabytes, of the data volume that will be created and attached to the database. This storage can later be scaled up if needed. The maximum storage value is determined by the infrastructure shape. See Characteristics of Infrastructure Shapes for shape details.
    * __adw_db_name__ - The database name. The name must begin with an alphabetic character and can contain a maximum of 14 alphanumeric characters. Special characters are not permitted. The database name must be unique in the tenancy.
    * __adw_db_workload__ - The Autonomous Database workload type. The following values are valid:
        - OLTP - indicates an Autonomous Transaction Processing database
        - DW - indicates an Autonomous Data Warehouse database
        - AJD - indicates an Autonomous JSON Database
        - APEX - indicates an Autonomous Database with the Oracle APEX Application Development workload type. *Note: db_workload can only be updated from AJD to OLTP or from a free OLTP to AJD.
    * __adw_db_version__ - A valid Oracle Database version for Autonomous Database.db_workload AJD and APEX are only supported for db_version 19c and above.
    * __adw_enable_auto_scaling__ - Indicates if auto scaling is enabled for the Autonomous Database OCPU core count. The default value is FALSE.
    * __adw_is_free_tier__ - Indicates if this is an Always Free resource. The default value is false. Note that Always Free Autonomous Databases have 1 CPU and 20GB of memory. For Always Free databases, memory and CPU cannot be scaled. When db_workload is AJD or APEX it cannot be true.
    * __adw_license_model__ - The Oracle license model that applies to the Oracle Autonomous Database. Bring your own license (BYOL) allows you to apply your current on-premises Oracle software licenses to equivalent, highly automated Oracle PaaS and IaaS services in the cloud. License Included allows you to subscribe to new Oracle Database software licenses and the Database service. Note that when provisioning an Autonomous Database on dedicated Exadata infrastructure, this attribute must be null because the attribute is already set at the Autonomous Exadata Infrastructure level. When using shared Exadata infrastructure, if a value is not specified, the system will supply the value of BRING_YOUR_OWN_LICENSE. It is a required field when db_workload is AJD and needs to be set to LICENSE_INCLUDED as AJD does not support default license_model value BRING_YOUR_OWN_LICENSE.
    * __database_admin_password__ - The password must be between 12 and 30 characters long, and must contain at least 1 uppercase, 1 lowercase, and 1 numeric character. It cannot contain the double quote symbol (") or the username "admin", regardless of casing. The password is mandatory if source value is "BACKUP_FROM_ID", "BACKUP_FROM_TIMESTAMP", "DATABASE" or "NONE".
    * __database_wallet_password__ - (Required) The password to encrypt the keys inside the wallet. The password must be at least 8 characters long and must include at least 1 letter and either 1 numeric character or 1 special character.
    * __adw_data_safe_status__ - (Optional) (Updatable) Status of the Data Safe registration for this Autonomous Database. Could be REGISTERED or NOT_REGISTERED.


Below is an example:

```
variable "adw_cpu_core_count" {
    type = number
    default = 1
}

variable "adw_size_in_tbs" {
    type = number
    default = 1
}

variable "adw_db_name" {
    type = string
    default = "ADWoipna"
}

variable "adw_db_workload" {
    type = string
    default = "DW"
}

variable "adw_db_version" {
    type = string
    default = "19c"
}

variable "adw_enable_auto_scaling" {
    type = bool
    default = true
}

variable "adw_is_free_tier" {
    type = bool
    default = false
}

variable "adw_license_model" {
    type = string
    default = "BRING_YOUR_OWN_LICENSE"
}

variable "adw_license_model" {
    type = string
    default = "LICENSE_INCLUDED"
}

variable "database_admin_password" {
  type = string
  default = "<enter-password-here>"
}

variable "database_wallet_password" {
  type = string
  default = "<enter-password-here>"
}

variable "adw_data_safe_status" {
  type = string
  default = "REGISTERED"
}

```

# Object Storage
This resource provides the Bucket resource in Oracle Cloud Infrastructure Object Storage service.
Creates a bucket in the given namespace with a bucket name and optional user-defined metadata. Avoid entering confidential information in bucket names.

* Parameters:
    * __logging_logs_bucket_name__ - The name of the bucket. Valid characters are uppercase or lowercase letters, numbers, hyphens, underscores, and periods. Bucket names must be unique within an Object Storage namespace. Avoid entering confidential information. example: Example: my-new-bucket1
    * __logging_logs_access_type__ - The type of public access enabled on this bucket. A bucket is set to NoPublicAccess by default, which only allows an authenticated caller to access the bucket and its contents. When ObjectRead is enabled on the bucket, public access is allowed for the GetObject, HeadObject, and ListObjects operations. When ObjectReadWithoutList is enabled on the bucket, public access is allowed for the GetObject and HeadObject operations.
    * __logging_logs_storage_tier__ - The type of storage tier of this bucket. A bucket is set to 'Standard' tier by default, which means the bucket will be put in the standard storage tier. When 'Archive' tier type is set explicitly, the bucket is put in the Archive Storage tier. The 'storageTier' property is immutable after bucket is created.
    * __logging_logs_events_enabled__ - Whether or not events are emitted for object state changes in this bucket. By default, objectEventsEnabled is set to false. Set objectEventsEnabled to true to emit events for object state changes. For more information about events, see Overview of Events.
    * __sch_logs_bucket_name__ - The name of the bucket. Valid characters are uppercase or lowercase letters, numbers, hyphens, underscores, and periods. Bucket names must be unique within an Object Storage namespace. Avoid entering confidential information. example: Example: my-new-bucket1
    * __sch_logs_access_type__ - The type of public access enabled on this bucket. A bucket is set to NoPublicAccess by default, which only allows an authenticated caller to access the bucket and its contents. When ObjectRead is enabled on the bucket, public access is allowed for the GetObject, HeadObject, and ListObjects operations. When ObjectReadWithoutList is enabled on the bucket, public access is allowed for the GetObject and HeadObject operations.
    * __sch_logs_storage_tier__ - The type of storage tier of this bucket. A bucket is set to 'Standard' tier by default, which means the bucket will be put in the standard storage tier. When 'Archive' tier type is set explicitly, the bucket is put in the Archive Storage tier. The 'storageTier' property is immutable after bucket is created.
    * __sch_logs_events_enabled__ - Whether or not events are emitted for object state changes in this bucket. By default, objectEventsEnabled is set to false. Set objectEventsEnabled to true to emit events for object state changes. For more information about events, see Overview of Events.

Below is an example:
```
variable "logging_logs_bucket_name" {
    type    = string
    default = "Logging_Logs_bucket"
}

variable "logging_logs_access_type" {
    type    = string
    default  = "NoPublicAccess"
}

variable "logging_logs_storage_tier" {
    type    = string
    default = "Standard"
}
  
variable "logging_logs_events_enabled" {
    type    = bool
    default = false
}

variable "sch_logs_bucket_name" {
    type    = string
    default = "Sch_Logs_bucket"
}

variable "sch_logs_access_type" {
    type    = string
    default  = "NoPublicAccess"
}

variable "sch_logs_storage_tier" {
    type    = string
    default = "Standard"
}
  
variable "sch_logs_events_enabled" {
    type    = bool
    default = false
}
```
# Database management service - managed group - required for the ansible module

Here you need to put what name you want to use for the Database Group Name inside the Database Management Service.

```
variable "managed_database_group_name" {
  type    = string
  default = "My_manage_Group"
}
```

# Network
This resource provides the Vcn resource in Oracle Cloud Infrastructure Core service anso This resource provides the Subnet resource in Oracle Cloud Infrastructure Core service.
The solution will create 1 VCN in your compartment, 2 subnets ( one public and one private so the analytics cloud instance can be public or private ), 2 route tables for incomming and outoing traffic, 2 Network Security Groups for ingress and egress traffic, 1 internet gateway, 2 route tables for each subnet, dhcp service, NAT Gateway and a Service Gateway. 

* Parameters
    * __vcn_cidr__ - The list of one or more IPv4 CIDR blocks for the VCN that meet the following criteria:
        The CIDR blocks must be valid.  
        They must not overlap with each other or with the on-premises network CIDR block.
        The number of CIDR blocks must not exceed the limit of CIDR blocks allowed per VCN. It is an error to set both cidrBlock and cidrBlocks. Note: cidr_blocks update must be restricted to one operation at a time (either add/remove or modify one single cidr_block) or the operation will be declined.
    * __public_subnet_cidr__ - The CIDR IP address range of the subnet. The CIDR must maintain the following rules - a. The CIDR block is valid and correctly formatted. b. The new range is within one of the parent VCN ranges. This is the cidr for the public subnet.
    * __private_subnet_cidr__ - The CIDR IP address range of the subnet. The CIDR must maintain the following rules - a. The CIDR block is valid and correctly formatted. b. The new range is within one of the parent VCN ranges. This is the cidr for the private subnet.
    * __service_name__ - A prefix for policies and dynamic groups names - scope: to be unique names not duplicates.


Below is an example:
```
variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "service_name" {
  type        = string
  default     = "monitoringlevel2"
  description = "A prefix for policies and dynamic groups names - scope: to be unique names not duplicates"
}
```
Don't modify any other variables in the variable.tf file - it may cause that the solution will not work propertly. The use_regional_subnet variable is for the subnets to be regional, not AD specific. Also the release variable it's used in the tagging concept.

Secondly, populate the `local.tf` file with the disared configuration following the information:


# Create Notifications:
This resource provides the Notification Topic resource in Oracle Cloud Infrastructure Notifications service.

This resource provides the Subscription resource in Oracle Cloud Infrastructure Notifications service.
Creates a subscription for the specified topic and sends a subscription confirmation URL to the endpoint. The subscription remains in "Pending" status until it has been confirmed. For information about confirming subscriptions.
Transactions Per Minute (TPM) per-tenancy limit for this operation: 60

Below is an example:
```
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
```

# Create Monitoring Alarms:
This resource provides the Alarm resource in Oracle Cloud Infrastructure Monitoring service.
Creates a new alarm in the specified compartment. For important limits information, see Limits on Monitoring.
This call is subject to a Monitoring limit that applies to the total number of requests across all alarm operations. Monitoring might throttle this call to reject an otherwise valid request when the total rate of alarm operations exceeds 10 requests, or transactions, per second (TPS) for a given tenancy.

We will create 2 examples of alarms that will monitor the autonomous datase for Storage Utilization and Cpu Utilization.

Below is an example:
```
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
```

# Create Logging Groups and Log Groups:
This resource provides the Log Group resource in Oracle Cloud Infrastructure Logging service.
Create a new log group with a unique display name. This call fails if the log group is already created with the same displayName in the compartment.

This resource provides the Log resource in Oracle Cloud Infrastructure Logging service.
Creates a log within the specified log group. This call fails if a log group has already been created with the same displayName or (service, resource, category) triplet.


We will create one log group and inside it 3 logging flows for object storage, and 2 for the subnets ( public and private ).


Below is an example:
```
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
```

# Create Events:
This resource provides the Rule resource in Oracle Cloud Infrastructure Events service.

We will creat 2 example event, one for that will monitor your network modifications and the second one will monitor the autonomous database for specific state changes.

Below is an example:
```
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
```

# Enable Database Management Service and Operations Insights Service
After the Autonomous Database it's deployed, it will run the ansible script that will enable the Database Management Service on it and also the Operations Insights Service.

```
resource "null_resource" "enable-monitoring" {
depends_on = [module.adw]
provisioner "local-exec" {
  when    = create
  command = "ansible-playbook db_monitoring_create.yaml -e managed_database_group_name=${var.managed_database_group_name} -e compartment_id=${var.compartment_id} -e autonomous_database_id=${local.autonomous_database_id}"
  } 
}
```

# Log Analytics Service
This resource provides the Log Analytics Log Group resource in Oracle Cloud Infrastructure Log Analytics service.

```
log_analytics_log_group_params = {
  log_analytics_log_group = {
    compartment_id  = var.compartment_id
    display_name    = "log_analytics_iopanait"
  }
}
```

# Data Safe Monitoring for Autonomous Database
This resource provides the Data Safe Private Endpoint resource in Oracle Cloud Infrastructure Data Safe service.
Creates a new Data Safe private endpoint for the Autonomous Database.

```
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
```

# Service Connector Hub
This resource provides the Service Connector resource in Oracle Cloud Infrastructure Service Connector Hub service.
Creates a new service connector in the specified compartment. A service connector is a logically defined flow for moving data from a source service to a destination service in Oracle Cloud Infrastructure. For instructions, see To create a service connector. For general information about service connectors, see Service Connector Hub Overview.
For purposes of access control, you must provide the OCID of the compartment where you want the service connector to reside. Notice that the service connector doesn't have to be in the same compartment as the source or target services. For information about access control and compartments, see Overview of the IAM Service.
After you send your request, the new service connector's state is temporarily CREATING. When the state changes to ACTIVE, data begins transferring from the source service to the target service. For instructions on deactivating and activating service connectors, see To activate or deactivate a service connector.

In the current solution, we will deploy 2 service connector hubs. 
The first one will be take the log_name from the Logging Service and will move the Logs to Object Storage.
The second service connector hub, will take the logs from the logging service and will be moved and analyzed in the Log Analytics Service.

```
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
```

**Note**: A set of policies and two dynamic groups will be created allowing an administrator to deploy this solution. These are listed in "local.tf" file ( the last lines) and can be used as a reference when fitting this deployment to your specific IAM configuration.


## Running the code

```
# Run init to get terraform modules
$ terraform init

# Create the infrastructure
$ terraform apply --auto-approve

# If you are done with this infrastructure, take it down
$ terraform destroy --auto-approve
```


## <a name="documentation"></a>Documentation

[Autonomous Databases Overview](https://docs.oracle.com/en-us/iaas/Content/Database/Concepts/adboverview.htm)

[Object Storage Overview](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm)

[Notifications Overview](https://docs.oracle.com/en-us/iaas/Content/Notification/Concepts/notificationoverview.htm)

[Monitoring Overview](https://docs.oracle.com/en-us/iaas/Content/Monitoring/Concepts/monitoringoverview.htm)

[Logging Overview](https://docs.oracle.com/en-us/iaas/Content/Logging/Concepts/loggingoverview.htm)

[Events Overview](https://docs.oracle.com/en-us/iaas/Content/Events/Concepts/eventsoverview.htm)

[Database Management Overview](https://docs.oracle.com/en-us/iaas/database-management/doc/database-management.html)

[Operations Insights Overview](https://docs.oracle.com/en-us/iaas/operations-insights/doc/operations-insights.html)

[Logging Analytics Overview](https://docs.oracle.com/en-us/iaas/logging-analytics/index.html)

[Data Safe Overview](https://docs.oracle.com/en-us/iaas/data-safe/index.html)

[Service Connector Hub Overview](https://docs.oracle.com/en-us/iaas/Content/service-connector-hub/home.htm)

[Network Overview](https://docs.cloud.oracle.com/iaas/Content/Network/Concepts/overview.htm)

[Terraform Autonomous Databases Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_autonomous_database)

[Terraform Object Storage Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_bucket)

[Terraform Vcn resource in Oracle Cloud Infrastructure Core service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_vcn)

[Terraform Subnet resource in Oracle Cloud Infrastructure Core service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet)

[Terraform Notifications Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/ons_notification_topic)

[Terraform Monitoring Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/monitoring_alarm)

[Terraform Logging Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/logging_log)

[Terraform Events Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/events_rule)

[Logging Analytics Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/log_analytics_log_analytics_log_group)

[Data Safe Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/data_safe_data_safe_private_endpoint)

[Service Connector Hub Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/sch_service_connector)

Module HTML documentation is available on [readthedocs.io](https://oci-ansible-collection.readthedocs.io/en/latest/collections/oracle/oci/index.html).

To view the module documentation, use this command:
  ``` bash
ansible-doc oracle.oci.[module_name]
  ```
General documentation can be found [here](https://docs.cloud.oracle.com/iaas/Content/API/SDKDocs/ansible.htm).

Related documentation for the Ansible modules:

[oracle.oci.oci_database_autonomous_database_actions](https://oci-ansible-collection.readthedocs.io/en/latest/collections/oracle/oci/oci_database_autonomous_database_actions_module.html#examples)

[oracle.oci.oci_database_management_managed_database_group](https://oci-ansible-collection.readthedocs.io/en/latest/collections/oracle/oci/oci_database_management_managed_database_group_module.html#ansible-collections-oracle-oci-oci-database-management-managed-database-group-module)

[oracle.oci.oci_database_management_managed_database_group_actions](https://oci-ansible-collection.readthedocs.io/en/latest/collections/oracle/oci/oci_database_management_managed_database_group_actions_module.html#ansible-collections-oracle-oci-oci-database-management-managed-database-group-actions-module)

## <a name="Help"></a>Help
- For FAQs, check the [Frequently Asked Questions](FAQ) page.
- For commmon issues, check the [Common Issues](COMMON_ISSUES) page.
- To file bugs or feature requests, use [GitHub issues](https://github.com/oracle/oci-ansible-collections/issues).
- For other channels, check the ["Questions or Feedback"](https://docs.cloud.oracle.com/en-us/iaas/Content/API/SDKDocs/ansible.htm#questions) section.

## <a name="team"></a>The Team
- **Owners**: [Panaitescu Ionel](https://github.com/ionelpanaitescu)

## <a name="feedback"></a>Feedback
We welcome your feedback. To post feedback, submit feature ideas or report bugs, please use the Issues section on this repository.	

## <a name="known-issues"></a>Known Issues
**At the moment, there are no known issues for this solution**
You can find information on any known issues about Ansible in general on [Known Issues](KNOWN_ISSUES) or [GitHub issues](https://github.com/oracle/oci-ansible-collections/issues) page.

## Contributing
If you enhance a module or build a new module and you would like to share your work via the library, please contact us - we are always open to improving and extending the library.

## License
The Cloud Foundation Library is released under the Universal Permissive License (UPL), Version 1.0. and so there are very few limitations on what you can do - please check the [LICENSE](LICENSE) file for full details.