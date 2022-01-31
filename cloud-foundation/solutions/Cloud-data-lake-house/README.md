# Oracle Cloud Foundation Terraform Solution - Cloud data lake house - process enterprise and streaming data for analysis and machine learning



## Table of Contents
1. [Overview](#overview)
1. [Deliverables](#deliverables)
1. [Architecture](#Architecture-Diagram)
1. [Executing Instructions](#instructions)
    1. [Deploy Using the Terraform CLI](#Deploy-Using-the-Terraform-CLI)
1. [Documentation](#documentation)
1. [The Team](#team)
1. [Feedback](#feedback)
1. [Known Issues](#known-issues)
1. [Contribute](#CONTRIBUTING.md)


## <a name="overview"></a>Overview
You can effectively collect and analyze event data and streaming data from internet of things (IoT) and social media sources, but how do you correlate it with the broad range of enterprise data resources to leverage your investment and gain the insights you want?

Leverage a cloud data lake house that combines the abilities of a data lake and a data warehouse to process a broad range of enterprise and streaming data for business analysis and machine learning.

A data lake enables an enterprise to store all of its data in a cost effective, elastic environment while providing the necessary processing, persistence, and analytic services to discover new business insights. A data lake stores and curates structured and unstructured data and provides methods for organizing large volumes of highly diverse data from multiple sources.

With a data warehouse, you perform data transformation and cleansing before you commit the data to the warehouse. With a a data lake, you ingest data quickly and prepare it on the fly as people access it. A data lake supports operational reporting and business monitoring that require immediate access to data and flexible analysis to understand what is happening in the business while it it happening.

For details of the architecture, see [_Cloud data lake house - process enterprise and streaming data for analysis and machine learning_](https://docs.oracle.com/en/solutions/oci-curated-analysis/).

## <a name="deliverables"></a>Deliverables
 This repository encloses one deliverable:

- A reference implementation written in Terraform HCL (Hashicorp Language) that provisions fully functional resources in an OCI tenancy.

## <a name="architecture"></a>Architecture-Diagram
The diagram below shows services that are deployed:

![](https://docs.oracle.com/en/solutions/oci-curated-analysis/img/cloud-data-lake-house-architecture.png)


## <a name="instructions"></a>Executing Instructions

## Prerequisites

- Permission to `manage` the following types of resources in your Oracle Cloud Infrastructure tenancy: `vcns`, `nat-gateways`, `route-tables`, `subnets`, `service-gateways`, `security-lists`, `dynamic routing gateways`, `fast connect`,  `autonomous database`, `Analytics Cloud`, `object storage`, `data catalog`, `data integration`, `data science`, `golden gate`, `streaming`, `data flow`, `api gateway`, `ai-anomaly-detection`, `big-data-service`, `File Strorage Service` and `compute instances`.
- Quota to create the following resources: 1 ADW database instance and 1 Oracle Analytics Cloud (OAC) instance, 1 fast connect, 2 object storage buckets, 1 Data Catalog, 1 Data Integration Service, 1 data science, 1 golden gate deployment, 1 stream pool with 1 Stream, 1 data flow, 1 api gateway, 1 ai anomaly detection service, 1 big data cluster, 4 file systems with 1 mount target and 6 instances for GOLDEN GATE STREAM ANALYTICS cluster.
If you don't have the required permissions and quota, contact your tenancy administrator. See [Policy Reference](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm), [Service Limits](https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm), [Compartment Quotas](https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcequotas.htm).

# <a name="Deploy-Using-the-Terraform-CLI"></a>Deploy Using the Terraform CLI

## Clone the Module
Now, you'll want a local copy of this repo. You can make that with the commands:

    git clone https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation.git
    cd terraform-oci-oracle-cloud-foundation/cloud-foundation/solutions/Cloud-data-lake-house
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

## Repository files

* **CONTRIBUTING.md** - Contributing guidelines, also called Contribution guidelines, the CONTRIBUTING.md file, or software contribution guidelines, is a text file which project managers include in free and open-source software packages or other open media packages for the purpose of describing how others may contribute user-generated content to the project.The file explains how anyone can engage in activities such as formatting code for submission or submitting patches
* **LICENSE** - The Universal Permissive License (UPL), Version 1.0 
* **local.tf** - Local values can be helpful to avoid repeating the same values or expressions multiple times in a configuration, but if overused they can also make a configuration hard to read by future maintainers by hiding the actual values used.Here is the place where all the resources are defined.
* **main.tf** - Main Terraform script used for instantiating the Oracle Cloud Infrastructure provider and all subsystems modules
* **outputs.tf** - Defines project's outputs that you will see after the code runs successfuly
* **provider.tf** - The terraform provider that will be used (OCI)
* **provisioner.tf** - Provisioners can be used to model specific actions on the local machine or on a remote machine in order to prepare servers or other infrastructure objects for service.
Terraform includes the concept of provisioners as a measure of pragmatism, knowing that there will always be certain behaviors that can't be directly represented in Terraform's declarative model.However, they also add a considerable amount of complexity and uncertainty to Terraform usage. Firstly, Terraform cannot model the actions of provisioners as part of a plan because they can in principle take any action. Secondly, successful use of provisioners requires coordinating many more details than Terraform usage usually requires: direct network access to your servers, issuing Terraform credentials to log in, making sure that all of the necessary external software is installed, etc.
* **README.md** - This file
* **subscription.tf** - Get Image Agreement, Accept Terms and Subscribe to the image, placing the image in a particular compartment, Gets the partner image subscription
* **tags.tf** - A file that will add tags for all the resouces as ArchitectureCenterTagNamespace convention.
* **variables.tf** - Project's global variables


Secondly, populate the `terraform.tf` file with the disared configuration following the information:


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
    default = "ADWipan"
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

```

# Oracle Analytics Cloud
This resource provides the Analytics Instance resource in Oracle Cloud Infrastructure Analytics service.
Create a new AnalyticsInstance in the specified compartment. The operation is long-running and creates a new WorkRequest.

* Parameters
    * __analytics_instance_feature_set__ - Analytics feature set: ENTERPRISE_ANALYTICS or SELF_SERVICE_ANALYTICS set
    * __analytics_instance_license_type__ - The license used for the service: LICENSE_INCLUDED or BRING_YOUR_OWN_LICENSE
    * __analytics_instance_hostname__ - The name of the Analytics instance. This name must be unique in the tenancy and cannot be changed.
    * __analytics_instance_idcs_access_token__ - IDCS access token identifying a stripe and service administrator user. THe IDCS access token can be obtained from OCI console - Menu -> Identity & Security -> Federation -> OracleIdentityCloudService -  and now click on the Oracle Identity Cloud Service Console)
    Access Oracle Identity Cloud Service console, click the avatar icon on the top-right corner, and then click My Access Tokens. 
    You can download an access token in the following ways:
    Select Invokes Identity Cloud Service APIs to specify the available administrator roles that are assigned to you. The APIs from the specified administrator roles will be included in the token.
    Select Invokes other APIs to select confidential applications that are assigned to the user account.
    Click Select an Application to add a configured confidential resource application. On the Select an Application window, the list of assigned confidential applications displays.
    Click applications to select them, and then click Add. The My Access Tokens page lists the added applications.
    In the Token Expires in (Mins) field, select or enter how long (in minutes) the access token you're generating can be used before it expires. You can choose to keep the default number or specify between 1 and 527,040.
    Click Download Token. The access token is generated and downloaded to your local machine as a tokens.tok file.
    * __analytics_instance_capacity_capacity_type__ - The capacity model to use. Accepted values are: OLPU_COUNT, USER_COUNT . Values are case-insensitive.
    * __analytics_instance_capacity_value__ - The capacity value selected (OLPU count, number of users, …etc…). This parameter affects the number of CPUs, amount of memory or other resources allocated to the instance.
    * __analytics_instance_network_endpoint_details_network_endpoint_type__ - The type of network endpoint public or private
    * __whitelisted_ips__ and __analytics_instance_network_endpoint_details_whitelisted_ips__ - If the network_endpoint_type is public you need to put the Source IP addresses or IP address ranges igress rules.


Below is an example:
```
variable "analytics_instance_feature_set" {
    type    = string
    default = "ENTERPRISE_ANALYTICS"
}

variable "analytics_instance_license_type" {
    type    = string
    default = "LICENSE_INCLUDED"
}

variable "analytics_instance_hostname" {
    type    = string
    default = "AnalyicSD"
}

variable "analytics_instance_idcs_access_token" {
    type    = string
    default = "copy-paste your token instead"
}

variable "analytics_instance_capacity_capacity_type" {
    type    = string
    default = "OLPU_COUNT"
}

variable "analytics_instance_capacity_value" {
    type    = number
    default = 1
}

variable "analytics_instance_network_endpoint_details_network_endpoint_type" {
    type    = string
    default = "public"
}

variable "whitelisted_ips" {
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "analytics_instance_network_endpoint_details_whitelisted_ips" {
  type = list(string)
  default = ["0.0.0.0/0"]
} 
```

# Object Storage
This resource provides the Bucket resource in Oracle Cloud Infrastructure Object Storage service.
Creates a bucket in the given namespace with a bucket name and optional user-defined metadata. Avoid entering confidential information in bucket names.

* Parameters:
    * __data_bucket_name__ - The name of the bucket. Valid characters are uppercase or lowercase letters, numbers, hyphens, underscores, and periods. Bucket names must be unique within an Object Storage namespace. Avoid entering confidential information. example: Example: my-new-bucket1
    * __data_bucket_access_type__ - The type of public access enabled on this bucket. A bucket is set to NoPublicAccess by default, which only allows an authenticated caller to access the bucket and its contents. When ObjectRead is enabled on the bucket, public access is allowed for the GetObject, HeadObject, and ListObjects operations. When ObjectReadWithoutList is enabled on the bucket, public access is allowed for the GetObject and HeadObject operations.
    * __data_bucket_storage_tier__ - The type of storage tier of this bucket. A bucket is set to 'Standard' tier by default, which means the bucket will be put in the standard storage tier. When 'Archive' tier type is set explicitly, the bucket is put in the Archive Storage tier. The 'storageTier' property is immutable after bucket is created.
    * __data_bucket_events_enabled__ - Whether or not events are emitted for object state changes in this bucket. By default, objectEventsEnabled is set to false. Set objectEventsEnabled to true to emit events for object state changes. For more information about events, see Overview of Events.
    * __dataflow_logs_bucket_name__ - The name of the bucket Data Flow Logs bucket that will be used by the Data Flow Service inside OCI. Valid characters are uppercase or lowercase letters, numbers, hyphens, underscores, and periods. Bucket names must be unique within an Object Storage namespace. Avoid entering confidential information. example: Example: dataflow-logs
    * __dataflow_logs_bucket_access_type__ - The type of public access enabled on this bucket. A bucket is set to NoPublicAccess by default, which only allows an authenticated caller to access the bucket and its contents. When ObjectRead is enabled on the bucket, public access is allowed for the GetObject, HeadObject, and ListObjects operations. When ObjectReadWithoutList is enabled on the bucket, public access is allowed for the GetObject and HeadObject operations.
    * __dataflow_logs_bucket_storage_tier__ - The type of storage tier of this bucket. A bucket is set to 'Standard' tier by default, which means the bucket will be put in the standard storage tier. When 'Archive' tier type is set explicitly, the bucket is put in the Archive Storage tier. The 'storageTier' property is immutable after bucket is created.
    * __dataflow_logs_bucket_events_enabled__ - Whether or not events are emitted for object state changes in this bucket. By default, objectEventsEnabled is set to false. Set objectEventsEnabled to true to emit events for object state changes. For more information about events, see Overview of Events.
     

Below is an example:
```
variable "data_bucket_name" {
    type    = string
    default = "Lakehouse_data_bucket"
}

variable "data_bucket_access_type" {
    type    = string
    default  = "NoPublicAccess"
}

variable "data_bucket_storage_tier" {
    type    = string
    default = "Standard"
}
  
variable "data_bucket_events_enabled" {
    type    = bool
    default = false
}

variable "dataflow_logs_bucket_name" {
    type    = string
    default = "dataflow-logs"
}

variable "dataflow_logs_bucket_access_type" {
    type    = string
    default  = "NoPublicAccess"
}

variable "dataflow_logs_bucket_storage_tier" {
    type    = string
    default = "Standard"
}
  
variable "dataflow_logs_bucket_events_enabled" {
    type    = bool
    default = false
}
```

# Data Catalog
This resource provides the Catalog resource in Oracle Cloud Infrastructure Data Catalog service.
Creates a new data catalog instance that includes a console and an API URL for managing metadata operations. For more information, please see the documentation.

* Parameters:
    * __datacatalog_display_name__ - Data catalog identifier. 


Below is an example:
```
variable "datacatalog_display_name" {
    type    = string
    default = "DataCatalogIP"
}
```

# Oracle Cloud Infrastructure Data Integration service
This resource provides the Workspace resource in Oracle Cloud Infrastructure Data Integration service.
Creates a new Data Integration workspace ready for performing data integration tasks.

* Parameters:
    * __odi_display_name__ - A user-friendly display name for the workspace. Does not have to be unique, and can be modified. Avoid entering confidential information.
    * __odi_description__ - A user defined description for the workspace.


Below is an example:
```
variable "odi_display_name" {
    type    = string
    default = "odi_workspace"
}

variable "odi_description" {
    type    = string
    default  = "odi_workspace"
}
```

# Data Science with notebook 

This resource provides the Notebook Session resource in Oracle Cloud Infrastructure Data Science service.

* Parameters:
    * __project_description__ - A short description of the project.
    * __project_display_name__ - A user-friendly display name for the resource. It does not have to be unique and can be modified. Avoid entering confidential information.
    * __notebook_session_display_name__ -  A user-friendly display name for the resource. It does not have to be unique and can be modified. Avoid entering confidential information.
    * __notebook_session_notebook_session_configuration_details_shape__ - The shape used to launch the notebook session compute instance. The list of available shapes in a given compartment can be retrieved using the ListNotebookSessionShapes endpoint.
    * __notebook_session_notebook_session_configuration_details_block_storage_size_in_gbs__ - A notebook session instance is provided with a block storage volume. This specifies the size of the volume in GBs.

Below is an example:

```
variable "project_description" {
  default = "Machine_learning_platform"
}

variable "project_display_name" {
  default = "Machine_learning_platform"
}

variable "notebook_session_display_name" {
  default = "Machine_learning_notebook_session"
}

variable "notebook_session_notebook_session_configuration_details_shape" {
  default = "VM.Standard2.1"
}

variable "notebook_session_notebook_session_configuration_details_block_storage_size_in_gbs" {
  default = 50
}
```

# Golden Gate Deployment

This resource provides the Deployment resource in Oracle Cloud Infrastructure Golden Gate service.

* Parameters:
    * __goden_gate_cpu_core_count__ - The Minimum number of OCPUs to be made available for this Deployment.
    * __goden_gate_deployment_type__ - The type of deployment, the value determines the exact 'type' of service executed in the Deployment. NOTE: Use of the value OGG is maintained for backward compatibility purposes. Its use is discouraged in favor of the equivalent DATABASE_ORACLE value.
    * __golden_gate_license_model__ - The Oracle license model that applies to a Deployment.
    * __goden_gate_display_name__ - An object's Display Name.
    * __goden_gate_is_auto_scaling_enabled__ - Indicates if auto scaling is enabled for the Deployment's CPU core count.
    * __goden_gate_admin_password__ - The password associated with the GoldenGate deployment console username. The password must be 8 to 30 characters long and must contain at least 1 uppercase, 1 lowercase, 1 numeric, and 1 special character. Special characters such as ‘$’, ‘^’, or ‘?’ are not allowed.
    * __goden_gate_admin_username__ - The GoldenGate deployment console username.
    * __goden_gate_deployment_name__ - The name given to the GoldenGate service deployment. The name must be 1 to 32 characters long, must contain only alphanumeric characters and must start with a letter.

Below is an example:

```
variable "goden_gate_cpu_core_count" {
  default = 2
}

variable "goden_gate_deployment_type" {
  default = "OGG"
}

variable "golden_gate_license_model" {
  default = "LICENSE_INCLUDED"
}

variable "goden_gate_display_name" {
  default = "ogg_deployment"
}

variable "goden_gate_is_auto_scaling_enabled" {
  default = false
}

variable "goden_gate_admin_password" {
  default = "Oracle-1234567"
}

variable "goden_gate_admin_username" {
  default = "ogg"
}

variable "goden_gate_deployment_name" {
  default = "ogg_deployment"
}
```


# Streaming

This resource provides the Stream Pool resource in Oracle Cloud Infrastructure Streaming service.
Also this resource provides the Service Connector resource in Oracle Cloud Infrastructure Service Connector Hub service.

Creates a new service connector in the specified compartment. A service connector is a logically defined flow for moving data from a source service to a destination service in Oracle Cloud Infrastructure. For general information about service connectors, see Service Connector Hub Overview.

* Parameters:
    * __stream_name__ - The name of the stream. Avoid entering confidential information.
    * __stream_partitions__ - The number of partitions in the stream.
    * __stream_retention_in_hours__ -  The retention period of the stream, in hours. Accepted values are between 24 and 168 (7 days). If not specified, the stream will have a retention period of 24 hours.
    * __stream_pool_name__ - The name of the stream pool. Avoid entering confidential information


* Service Connector Hub (optional):
    * __service_connector_display_name__ - A user-friendly name. It does not have to be unique, and it is changeable. Avoid entering confidential information.
    * __service_connector_source_kind__ - The type descriminator.
    * __service_connector_source_cursor_kind__ - The type descriminator.
    * __service_connector_target_kind__ - An object that represents the target of the flow defined by the service connector. An example target is a stream. For more information about flows defined by service connectors, see Service Connector Hub Overview.
    * __service_connector_target_bucket__ - The name of the bucket. Avoid entering confidential information.
    * __service_connector_target_object_name_prefix__ - The prefix of the objects. Avoid entering confidential information.
    * __service_connector_target_batch_rollover_size_in_mbs__ -  The batch rollover size in megabytes.
    * __service_connector_target_batch_rollover_time_in_ms__ - The batch rollover time in milliseconds.
    * __service_connector_description__ - The description of the resource. Avoid entering confidential information.
    * __service_connector_tasks_kind__ - The type descriminator.
    * __service_connector_tasks_batch_size_in_kbs__ - Size limit (kilobytes) for batch sent to invoke the function.
    * __service_connector_tasks_batch_time_in_sec__ - Time limit (seconds) for batch sent to invoke the function.    
    * __function_id__ - Your function name or function ocid from your tenancy. 

Below is an example:

```

# Streaming

variable "stream_name" {
    type    = string
    default = "Test_Stream"
}

variable "stream_partitions" {
    type    = string
    default = "1"
}

variable "stream_retention_in_hours" {
    type    = string
    default = "24"
}
  
variable "stream_pool_name" {
    type    = string
    default = "Test_Stream_Pool"
}
```
The streaming module also has the service connector hub integrated and you can use it if you have a function already in your tenancy available. For this solution only the stream pool and 1 stream will be provisioned.

For this you need to go into the local.tf file and for the service_connector object to be replaced with the code below and also to set in the variables.tf file the rest of the variables detailed upper.
Also you need to replace the : function_id with your function name or function ocid from your tenancy. 

```
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
      function_id                                         = lookup(module.functions.functions,"Lakehouse_Function").ocid
  }
}
```

# Data Flow

This resource provides the Application resource in Oracle Cloud Infrastructure Data Flow service. Creates an application.

* Parameters:
    * __application_display_name__ - A user-friendly name. It does not have to be unique. Avoid entering confidential information.
    * __application_driver_shape__ - The VM shape for the driver. Sets the driver cores and memory.
    * __application_executor_shape__ - The VM shape for the executors. Sets the executor cores and memory.
    * __application_file_uri__ - n Oracle Cloud Infrastructure URI of the file containing the application to execute. See https://docs.cloud.oracle.com/iaas/Content/API/SDKDocs/hdfsconnector.htm#uriformat. 
    * __application_language__ - The Spark language.
    * __application_num_executors__ - The number of executor VMs requested.
    * __application_spark_version__ -  The Spark version utilized to run the application.
    * __application_class_name__ - The class for the application.
    * __application_description__ - A user-friendly description.


Below is an example:

```
variable "application_display_name" {
  default = "dataflowapp"
}

variable "application_driver_shape" {
  default = "VM.Standard2.1"
}

variable "application_executor_shape" {
  default = "VM.Standard2.1"
}

variable "application_file_uri" {
  default = "oci://oow_2019_dataflow_lab@bigdatadatasciencelarge/usercontent/oow-lab-2019-java-etl-1.0-SNAPSHOT.jar"
}

variable "application_language" {
  default = "Java"
}

variable "application_num_executors" {
  default = 1
}

variable "application_spark_version" {
  default = "2.4.4"
}

variable "application_class_name" {
  default = "convert.Convert"
}

variable "application_description" {
  default = "Test Java Application"
}
```

#  API Gateway service
This resource provides the Gateway resource and the Deployment resource in Oracle Cloud Infrastructure API Gateway service.Creates a new gateway and a new deployment.

* Parameters
    * __apigw_display_name__ -  (Optional) (Updatable) A user-friendly name. Does not have to be unique, and it's changeable. Avoid entering confidential information. Example: My new resource
    * __apigwdeploy_display_name__ - Optional) (Updatable) A user-friendly name. Does not have to be unique, and it's changeable. Avoid entering confidential information. Example: My new resource


Below is an example in the variables.tf File.
```
variable "apigw_display_name" {
  default = "Lakehouse_ApiGW"
}

variable "apigwdeploy_display_name" {
  default = "Lakehouse_deployment"
}
```

The Api Gateway provides many features - you can also add function deployment type. Below it's an example that can be used if you already have a function deployed inside your tenancy. Go inside the local.tf file at the API Gateway section and you can use this code where function_id is your function name or function ocid.
Below is an example:
```

apigw_params = {
  apigw = {
    compartment_id = var.compartment_id,
    endpoint_type  = "PUBLIC"
    subnet_id      = lookup(module.network-subnets.subnets,"public-subnet").id,
    display_name   = "Lakehouse_ApiGW"
    defined_tags   =  {}
  }
}

gwdeploy_params = {
  api_deploy1 = {
    compartment_id = var.compartment_id,
    gateway_name     = "apigw"
    display_name     = "Lakehouse_deployment"
    path_prefix      = "/tf"
    access_log       = true
    exec_log_lvl     = "WARN"
    defined_tags   =  {}

    function_routes = [
      {
        type          = "function"
        path          = "/func"
        methods       = ["GET", ]
        function_id   = lookup(module.functions.functions,"Lakehouse_Function").ocid
      },
    ]
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
```

#  Ai Anomaly Detection service
This resource provides the Project resource in Oracle Cloud Infrastructure Ai Anomaly Detection service. Creates a new Project and creates a new DataAsset. 

* Parameters
    * __ai_anomaly_detection_project_display_name__ - (Optional) (Updatable) A user-friendly display name for the resource. It does not have to be unique and can be modified. Avoid entering confidential information.
    * __ai_anomaly_detection_project_description__ - (Optional) (Updatable) A short description of the project.
    * __ai_anomaly_detection_data_asset_project_name__ - (Optional) (Updatable) A user-friendly display name for the resource. It does not have to be unique and can be modified. Avoid entering confidential information.
    * __ai_anomaly_detection_data_asset_data_source_type__ - (Applicable when data_source_type=ORACLE_OBJECT_STORAGE) Object storage bucket name
    * __ai_anomaly_detection_data_asset_bucket__ - The name of the bucket where is the data. Example: Lakehouse_data_bucket
    * __ai_anomaly_detection_data_asset_measurement_name__ - (Required when data_source_type=INFLUX) Measurement name for influx
    * __ai_anomaly_detection_data_asset_object__ - (Applicable when data_source_type=ORACLE_OBJECT_STORAGE) File name. Example: demo-testing-data.json
    * __ai_anomaly_detection_data_asset_influx_version__ - (Required) Data source type where actually data asset is being stored
    * __ai_anomaly_detection_data_asset_description__ - (Optional) (Updatable) A short description of the Ai data asset
    * __ai_anomaly_detection_data_asset_display_name__ - (Optional) (Updatable) A user-friendly display name for the resource. It does not have to be unique and can be modified. Avoid entering confidential information.


Below is an example:
```
variable "ai_anomaly_detection_project_display_name" {
  default = "Lakehouse_anomaly_detection_project"
}

variable "ai_anomaly_detection_project_description" {
  default = "Lakehouse_anomaly_detection_project"
}

variable "ai_anomaly_detection_data_asset_project_name" {
  default = "Lakehouse_project"
}

variable "ai_anomaly_detection_data_asset_data_source_type" {
  default = "ORACLE_OBJECT_STORAGE"
}

variable "ai_anomaly_detection_data_asset_bucket" {
  default = "Lakehouse_data_bucket"
}

variable "ai_anomaly_detection_data_asset_measurement_name" {
  default = "influx_lakehouse"
}

variable "ai_anomaly_detection_data_asset_object" {
  default = "demo-testing-data.json"
}

variable "ai_anomaly_detection_data_asset_influx_version" {
  default = "V_2_0"
}

variable "ai_anomaly_detection_data_asset_description" {
  default = "Lakehouse_anomaly_detection_data_asset"
}

variable "ai_anomaly_detection_data_asset_display_name" {
  default = "Lakehouse_anomaly_detection_data_asset"
}

```

The module also has the option to train the model. In the local.tf file there is the object ai_anomaly_detection_model_params that can be used to accomplish this. In this solution we are not train the model. For more information regarding Ai Anomaly Detection service please visit the documentation section at the bottom.

Below is an example:
```
ai_anomaly_detection_model_params = {
  Lakehouse_project_model = {
     compartment_id    = var.compartment_id,
     project_name      = "Lakehouse_project"
     target_fap        = "0.05"
     training_fraction = "0.7"
     description       = "Lakehouse_train_model"
     display_name      = "Lakehouse_project"
     defined_tags      =  {}
   }
}
```

# Big Data Service service
This resource provides the Bds Instance resource in Oracle Cloud Infrastructure Big Data Service service. Creates a Big Data Service cluster.

* Parameters
    * __big_data_cluster_admin_password__ - (Required) Base-64 encoded password for the cluster (and Cloudera Manager) admin user. e.g.: echo Init01$$ | base64
    * __big_data_cluster_public_key__ -  (Required) The SSH public key used to authenticate the cluster connection.
    * __big_data_cluster_version__ - (Required) Version of the Hadoop distribution. ODH1 is the new version with Ambari Server - no autoscalling working at the moment. "CDH6" // old version - Cloudera Manager version with autoscalling working.
    * __big_data_display_name__ - (Required) (Updatable) Name of the Big Data Service cluster.
    * __big_data_is_high_availability__ - Required) Boolean flag specifying whether or not the cluster is highly available (HA).
    * __big_data_is_secure__ - (Required) Boolean flag specifying whether or not the cluster should be set up as secure.
    * __big_data_master_node_spape__ - (Required) The list of nodes in the Big Data Service cluster. The (Required) (Updatable) Shape of the node MASTER.
    * __big_data_master_node_block_volume_size_in_gbs__ - (Required) The size of block volume in GB to be attached to a given node. All the details needed for attaching the block volume are managed by service itself. Minimum size is 150 GB
    * __big_data_master_node_number_of_nodes__ - Number of Master Nodes. Minimum 1 it's needed.
    * __big_data_util_node_shape__ - (Required) The list of nodes in the Big Data Service cluster. The (Required) (Updatable) Shape of the node UTIL Server.
    * __big_data_util_node_block_volume_size_in_gbs__ - (Required) The size of block volume in GB to be attached to a given node. All the details needed for attaching the block volume are managed by service itself. Minimum size is 150 GB
    * __big_data_util_node_number_of_nodes__ - Number of Util Nodes. Minimum 1 it's needed.
    * __big_data_worker_node_shape__ - (Required) The list of nodes in the Big Data Service cluster. The (Required) (Updatable) Shape of the node WORKERs Servers.
    * __big_data_worker_node_block_volume_size_in_gbs__ - (Required) The size of block volume in GB to be attached to a given node. All the details needed for attaching the block volume are managed by service itself. Minimum size is 150 GB
    * __bbig_data_worker_node_number_of_nodes__ - Number of Workers Nodes. Minimum 3 it's needed!


Below is an example:
```

variable "big_data_cluster_admin_password" {
  default = "SW5pdDAxQA=="     # Password has to be Base64 encoded, e.g.: echo Init01$$ | base64
}

variable "big_data_cluster_public_key" {
  default = "/root/.ssh/id_rsa.pub"
}

variable "big_data_cluster_version" {
  default = "ODH1" // new version with Ambari Server - no autoscalling working at the moment
    # cluster_version = "CDH6" // old version - Cloudera Manager version with autoscalling working 
}

variable "big_data_display_name" {
  default = "Lakehouse Cluster"
}

variable "big_data_is_high_availability" {
  default = false
}

variable "big_data_is_secure" {
  default = false
}

variable "big_data_master_node_spape" {
  default = "VM.Standard2.4"
}

variable "big_data_master_node_block_volume_size_in_gbs" {
  default = 150 // minimum size is 150
}

variable "big_data_master_node_number_of_nodes" {
  default = 1
}

variable "big_data_util_node_shape" {
  default = "VM.Standard2.4"
}

variable "big_data_util_node_block_volume_size_in_gbs" {
  default = 150 // minimum size is 150
}

variable "big_data_util_node_number_of_nodes" {
  default = 1
}

variable "big_data_worker_node_shape" {
  default = "VM.Standard2.4"
}

variable "big_data_worker_node_block_volume_size_in_gbs" {
  default = 150 // minimum size is 150
}

variable "big_data_worker_node_number_of_nodes" {
  default = 3 // worker_node.0.number_of_nodes to be at least (3)
}
```

# Oracle Cloud Infrastructure File Storage service
This resource provides the File System resource in Oracle Cloud Infrastructure File Storage service.
Creates a new file system in the specified compartment and availability domain. Instances can mount file systems in another availability domain, but doing so might increase latency when compared to mounting instances in the same availability domain.
After you create a file system, you can associate it with a mount target. Instances can then mount the file system by connecting to the mount target's IP address. You can associate a file system with more than one mount target at a time.

In the main.tf file we are calling the FSS module and all the configuration for this solution it's done in the locals.tf file. For this solution we recommand that no parameter should be changed as it will break the solution.
It will create 4 file systems named MYSQL, KAFKA, SPARL and GGBD and one mount target called GGSMT. All the file systems there own export path for each type of service.

Below is an example:

```
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
```


# KeyGen
Generates a secure private key and encodes it as PEM. This resource is primarily intended for easily bootstrapping throwaway development environments.

In the main.tf file we are calling the keygen module that will create one public and one private key. 
This keys are neccesary, as the public key will be generated and injected in all the instances, and the private key will be generated and will be used to connect to the bastion server that will provision all the masters and slaves instances.
Both can be found in the solution folder if you want to use them after the deployment it's done.
For Resource Manager, the keys can be found in the dashboard under the resource section.

Below is an example:
```
module "keygen" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/keygen"
  display_name = "keygen"
  subnet_domain_name = "keygen"
}
```


# Compute
The compute module will create a production cluster for GGSA in OCI.
A production cluster should have 1 web-tier compute instance, 2 spark master compute instances, and a variable number of worker instances for Spark slaves and Kafka. Minimum worker instances for running spark slaves and Kafka are 2. The current solution will provision an production cluster with six compute instances configured as follows.
1. Single compute instance running GGSA Web-tier. Minimal shape is VM 2.4. This web-tier instance will also act as a Bastion Host for the cluster and should be created in a public regional subnet.
2. Two spark master compute instances running spark master processes. Minimal shape is VM 2.2. Both instances could be of same shape and should be created in a private regional subnet.
3. Three worker instances running Spark slave, Kafka broker, and Zookeeper processes. Minimal shape is VM 2.2. All three instances could be of same shape and should be created in a private regional subnet.

All instances will use the GGSA image that comes pre-packaged with GGSA, GGBD, Spark, Kafka, MySQL, and Nginx.

To provision a GGSA production cluster you will need to first provision GGSA compute instances using the custom GGSA VM image. The GGSA VM image contains binaries for GGSA, GGBD, Spark, Kafka, MySQL, OSA, Nginx, etc. There is no need for any other software beyond the GGSA image. 

The image packages the following scripts
* init-kafka-zk.sh – Bash script to initialize Zookeeper and Kafka on worker VMs.
* init-spark-master.sh – Bash script to initialize Spark master on Spark master VMs.
* init-spark-slave.sh - Bash script to initialize Spark slave on worker VMs.
* init-web-tier.sh – Bash script to initialize GGSA web-tier on the Web-tier VM.

Infrastructure resources must be created and scripts must be run in an specific order that can be found in the provisioner.tf file.

We recommand to not modify and paramater  from the local.tf (#create the VM's for the solution section) and provisioner.tf file - it will break the solution and the configuration of the production cluster.

For the moment the variables that can be modified are in the variables.tf file for the instances shapes.
More information regarding shapes can be found here:
https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm

Below is an example:
```
# Compute Configuration
# "Web-Tier-and-Bastion" variables

variable "bastion_shape" {
  default = "VM.Standard2.4"
}

# "Workers" variables

variable "worker1_shape" {
  default = "VM.Standard2.4"
}

variable "worker2_shape" {
  default = "VM.Standard2.4"
}

variable "worker3_shape" {
  default = "VM.Standard2.4"
}


# "Masters" variables

variable "master1_shape" {
  default = "VM.Standard2.4"
}

variable "master2_shape" {
  default = "VM.Standard2.4"
}
```

# Dynamic Routing Gateways (DRGs)
This resource provides the Drg resource in Oracle Cloud Infrastructure Core service. The DRG will be attached to the VCN so that a fastconnect can be provisioned and be used.
Creates a new dynamic routing gateway (DRG) in the specified compartment. 
For the purposes of access control, you must provide the OCID of the compartment where you want the DRG to reside. Notice that the DRG doesn't have to be in the same compartment as the VCN, the DRG attachment, or other Networking Service components. If you're not sure which compartment to use, put the DRG in the same compartment as the VCN. 
You may optionally specify a display name for the DRG, otherwise a default is provided. It does not have to be unique, and you can change it. Avoid entering confidential information.

* Parameters
    * __drg_name__ - (Optional) (Updatable) A user-friendly name. Does not have to be unique, and it's changeable. Avoid entering confidential information.
    * __drg_cidr_rt__ - Internal network -  cidr block: example - "192.0.0.0/16"


Below is an example:
```
variable "drg_name" {
  default = "mgmt_drg"
}

variable "drg_cidr_rt" {
  default = "192.0.0.0/16"
}
```

# FastConnect - Virtual Circuit 
This resource provides the Virtual Circuit resource in Oracle Cloud Infrastructure Core service.
Creates a new virtual circuit to use with Oracle Cloud Infrastructure FastConnect. 
For the purposes of access control, you must provide the OCID of the compartment where you want the virtual circuit to reside. If you're not sure which compartment to use, put the virtual circuit in the same compartment with the DRG it's using. For more information about compartments and access control, see Overview of the IAM Service. 
You may optionally specify a display name for the virtual circuit. It does not have to be unique, and you can change it. Avoid entering confidential information.
Important: When creating a virtual circuit, you specify a DRG for the traffic to flow through. Make sure you attach the DRG to your VCN and confirm the VCN's routing sends traffic to the DRG. Otherwise traffic will not flow.

* Parameters
    * __private_fastconnect_name__ -  (Optional) (Updatable) A user-friendly name. Does not have to be unique, and it's changeable. Avoid entering confidential information.
    * __private_fastconnect_type__ - Whether the virtual circuit supports private or public peering. For more information, see FastConnect Overview in the documentation section below.
    * __private_fastconnect_bw_shape__ -  (Optional) (Updatable) The provisioned data rate of the connection. To get a list of the available bandwidth levels (that is, shapes), see ListFastConnectProviderServiceVirtualCircuitBandwidthShapes. Example: 10 Gbps
    * __private_fastconnect_cust_bgp_peering_ip__ - (Optional) (Updatable) The BGP IPv4 address for the router on the other end of the BGP session from Oracle. Specified by the owner of that router. If the session goes from Oracle to a customer, this is the BGP IPv4 address of the customer's edge router. If the session goes from Oracle to a provider, this is the BGP IPv4 address of the provider's edge router. Must use a /30 or /31 subnet mask. There's one exception: for a public virtual circuit, Oracle specifies the BGP IPv4 addresses. Example: 10.0.0.18/31
    * __private_fastconnect_oracle_bgp_peering_ip__ - (Optional) (Updatable) The IPv4 address for Oracle's end of the BGP session. Must use a /30 or /31 subnet mask. If the session goes from Oracle to a customer's edge router, the customer specifies this information. If the session goes from Oracle to a provider's edge router, the provider specifies this. There's one exception: for a public virtual circuit, Oracle specifies the BGP IPv4 addresses. Example: 10.0.0.19/31
    * __private_fastconnect_drg__ - Optional) (Updatable) For private virtual circuits only. The OCID of the dynamic routing gateway (DRG) that this virtual circuit uses.


Below is an example:
```
variable "private_fastconnect_name" {
  default = "private_vc_with_provider_no_cross_connect_or_cross_connect_group_id"
}

variable "private_fastconnect_type" {
  default = "PRIVATE"
}

variable "private_fastconnect_bw_shape" {
  default = "10 Gbps"
}

variable "private_fastconnect_cust_bgp_peering_ip" {
  default = "10.0.0.22/30"
}

variable "private_fastconnect_oracle_bgp_peering_ip" {
  default = "10.0.0.21/30"
}

variable "private_fastconnect_drg" {
  default = "mgmt_drg"
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
  default     = "ServiceName"
  description = "A prefix for policies and dynamic groups names - scope: to be unique names not duplicates"
}
```

Don't modify any other variables in the variable.tf file - it may cause that the solution will not work propertly. The use_regional_subnet variable is for the subnets to be regional, not AD specific. Also the release variable it's used in the tagging concept.

**Note**: A set of policies and two dynamic groups will be created allowing an administrator to deploy this solution. These are listed in "local.tf" file ( the last lines) and can be used as a reference when fitting this deployment to your specific IAM configuration.


## Validate Topology for the GoldenGate Stream Analytics for production workloads - GGSA cluster with Spark and Kafka

__Step #1:__ - From browser or via curl, open https://Web-Tier-and-Bastion/osa, to see the login page.

__Step #2:__ - Retrieve the password for osaadmin user from the output of the terraform deployment

__Step #3:__ - Login to OSA UI and import one of the samples

__Step #4:__ - Ensure LocalKafka connection artifact points to zookeepers in system settings

__Step #5:__ - Publish pipeline and view dashboard

__Step #6:__ - Topology is good if dashboard is animated.


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

[Analytics Cloud Overview](https://docs.oracle.com/en-us/iaas/analytics-cloud/index.html)

[Object Storage Overview](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm)

[Data Catalog Overview](https://docs.public.oneportal.content.oci.oraclecloud.com/en-us/iaas/data-catalog/using/overview.htm)

[Data Integration Overview](https://docs.oracle.com/en-us/iaas/data-integration/using/overview.htm)

[Data Science Overview](https://docs.oracle.com/en-us/iaas/data-science/using/overview.htm)

[Golden Gate Overview](https://docs.oracle.com/en-us/iaas/goldengate/index.html)

[Streaming Overview](https://docs.oracle.com/en-us/iaas/Content/Streaming/Concepts/streamingoverview.htm)

[Data Flow Overview](https://docs.oracle.com/en-us/iaas/data-flow/using/dfs_service_overview.htm)

[API Gateway Overview](https://docs.oracle.com/en-us/iaas/Content/APIGateway/Concepts/apigatewayoverview.htm)

[AI Anomaly Detection Overview](https://docs.oracle.com/en-us/iaas/Content/anomaly/using/home.htm)

[Big Data Service Overview](https://docs.oracle.com/en-us/iaas/Content/bigdata/home.htm)

[File Storage service](https://docs.oracle.com/en-us/iaas/Content/File/Concepts/filestorageoverview.htm)

[Certificates](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm)

[Compute service](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm)

[Dynamic Routing Gateways (DRGs) Overview](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingDRGs.htm)

[FastConnect Overview](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/fastconnect.htm)

[Network Overview](https://docs.cloud.oracle.com/iaas/Content/Network/Concepts/overview.htm)

[Tagging Overview](https://docs.oracle.com/en-us/iaas/Content/Tagging/Concepts/taggingoverview.htm)

[Terraform Autonomous Databases Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/database_autonomous_database)

[Terraform Analytics Cloud Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/analytics_analytics_instance)

[Terraform Object Storage Service Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/objectstorage_bucket)

[Terraform Data Catalog Service Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/datacatalog_catalog)

[Terraform Data Integration Service Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/dataintegration_workspace)

[Terraform Data Science Project Service Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/datascience_project)

[Terraform Data Science Notebook Session Service Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/datascience_notebook_session)

[Terraform Deployment Golden Gate Service Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/golden_gate_deployment)

[Terraform Streaming Stream Pool Service Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/streaming_stream_pool)

[Terraform Streaming Stream Service Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/streaming_stream)

[Terraform Service Connector Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/sch_service_connector)

[Terraform Data Flow Service Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/dataflow_application)

[Terraform API Gateway Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/apigateway_gateway)

[Terraform Deployment for API GatewayResource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/apigateway_deployment)

[Terraform Ai Anomaly Detection service Project Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/ai_anomaly_detection_project)

[Terraform Ai Anomaly Detection service Data Asset Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/ai_anomaly_detection_data_asset)

[Terraform Ai Anomaly Detection service Model resource Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/ai_anomaly_detection_model)

[Terraform Big Data Service Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/bds_bds_instance)

[Terraform Oracle Cloud Infrastructure File Storage Service](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/file_storage_file_system)

[Terraform Certificates - TLS Provider](https://registry.terraform.io/providers/hashicorp/tls/latest/docs)

[Terraform Oracle Cloud Infrastructure Core Service](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_instance)

[Terraform Dynamic Routing Gateways (DRGs) resource in Oracle Cloud Infrastructure](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_drg)

[Terraform FastConnect Virtual Circuit resource in Oracle Cloud Infrastructure Core service](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_virtual_circuit)

[Terraform Vcn resource in Oracle Cloud Infrastructure Core service](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_vcn)

[Terraform Subnet resource in Oracle Cloud Infrastructure Core service](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_subnet)

[Terraform Tag Service Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_tag_namespace)


## <a name="team"></a>The Team
- **Owners**: [Panaitescu Ionel](https://github.com/ionelpanaitescu), [Corina Todea](https://github.com/ctodearo)

## <a name="feedback"></a>Feedback
We welcome your feedback. To post feedback, submit feature ideas or report bugs, please use the Issues section on this repository.	

## <a name="known-issues"></a>Known Issues
**At the moment, there are no known issues**