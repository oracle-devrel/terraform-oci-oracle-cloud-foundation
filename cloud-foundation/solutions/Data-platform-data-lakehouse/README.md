# Oracle Cloud Foundation Terraform Solution - Data platform - data lakehouse



## Table of Contents
1. [Overview](#overview)
1. [Deliverables](#deliverables)
1. [Architecture](#Architecture-Diagram)
1. [Executing Instructions](#instructions)
    1. [Deploy Using Oracle Resource Manager](#Deploy-Using-Oracle-Resource-Manager)
    1. [Deploy Using the Terraform CLI](#Deploy-Using-the-Terraform-CLI)
1. [Documentation](#documentation)
1. [The Team](#TheTeam)
1. [Feedback](#feedback)
1. [Known Issues](#known-issues)
1. [Contribute](./CONTRIBUTING.md)


## <a name="overview"></a>Overview
You can effectively collect and analyze event data and streaming data from internet of things (IoT) and social media sources, but how do you correlate it with the broad range of enterprise data resources to leverage your investment and gain the insights you want?

Leverage a cloud data lakehouse that combines the abilities of a data lake and a data warehouse to process a broad range of enterprise and streaming data for business analysis and machine learning.

A data lake enables an enterprise to store all of its data in a cost-effective, elastic environment while providing the necessary processing, persistence, and analytic services to discover new business insights. A data lake stores and curates structured and unstructured data and provides methods for organizing large volumes of highly diverse data from multiple sources.

With a data warehouse, you perform data transformation and cleansing before you commit the data to the warehouse. With a a data lake, you ingest data quickly and prepare it on the fly as people access it. A data lake supports operational reporting and business monitoring that require immediate access to data and flexible analysis to understand what is happening in the business while it is happening.

For details of the architecture, see [_Data platform - data lakehouse_](https://docs.oracle.com/en/solutions/data-platform-lakehouse/).

## <a name="deliverables"></a>Deliverables
 This repository encloses one deliverable:

- A reference implementation written in Terraform HCL (Hashicorp Language) that provisions fully functional resources in an OCI tenancy.

## <a name="architecture"></a>Architecture-Diagram

**Functional Architecture:**

This architecture combines the abilities of a data lake and a data warehouse to provide a modern data lakehouse platform that processes streaming data and other types of data from a broad range of enterprise data resources. Use this architecture to leverage the data for business analysis, machine learning, data services, and data products.

![](https://docs.oracle.com/en/solutions/data-platform-lakehouse/img/lakehouse-functional.png)


**Physical Architecture:**

The physical architecture for this data lakehouse supports the following:

- Data is ingested securely by using micro batch, streaming, APIs, and files from relational and non-relational data sources
- Data is processed leveraging a combination of Oracle Cloud Infrastructure Data Integration and Oracle Cloud Infrastructure Data Flow
- Data is stored in Oracle Autonomous Data Warehouse (ADW) and Oracle Cloud Infrastructure Object Storage and is organized according to its quality and value
- ADW serves warehouse and lake data services securely to consumers
- Oracle Analytics Cloud (OAC) surfaces data to business users by using visualizations
- OAC is exposed by using Oracle Cloud Infrastructure Load Balancing that is secured by Oracle Cloud Infrastructure Web Application Firewall (WAF) to provide access by using the internet
- Oracle Cloud Infrastructure Data Science is used to build, train, and deploy machine learning (ML) models
- Oracle Cloud Infrastructure API Gateway is leveraged to govern the Data Science ML model deployments
- Oracle Cloud Infrastructure Data Catalog harvests metadata from ADW and object storage
- Oracle Data Safe evaluates risks to data, implements and monitors security controls, assesses user security, monitors user activity, and addresses data security compliance requirements
- Oracle Cloud Infrastructure Bastion is used by administrators to manage private cloud resources

The following diagram illustrates this reference architecture.

![](https://docs.oracle.com/en/solutions/data-platform-lakehouse/img/lakehouse-architecture.png)


## <a name="instructions"></a>Executing Instructions

## Prerequisites

- Permission to `manage` the following types of resources in your Oracle Cloud Infrastructure tenancy: `vcns`, `nat-gateways`, `route-tables`, `subnets`, `service-gateways`, `security-lists`, `dynamic routing gateways`, `policies`, `dynamic groups`, `autonomous database`, `Analytics Cloud`, `object storage`, `data catalog`, `data integration`, `data science`, `functions`, `streaming`, `data flow`, `api gateway`, `bastion service`, `WAF`, and `Load Balancers`.
- Quota to create the following resources: 1 ADW database instance and 1 Oracle Analytics Cloud (OAC) instance, 4 object storage buckets, 1 Data Catalog, 1 Data Integration Service, 1 data science, 1 function, 1 stream pool with 1 Stream, 1 data flow, 1 api gateway, 1 load balancer, 3 dynamic groups and 1 policy, networking with 2 vnc and LPG between them, 1 waf. 
If you don't have the required permissions and quota, contact your tenancy administrator. See [Policy Reference](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm), [Service Limits](https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm), [Compartment Quotas](https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcequotas.htm).


# <a name="Deploy-Using-Oracle-Resource-Manager"></a>Deploy Using Oracle Resource Manager

1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation/releases/download/v1.0.0/Data-platform-data-lakehouse-RM.zip)


    If you aren't already signed in, when prompted, enter the tenancy and user credentials.

2. Review and accept the terms and conditions.
3. Select the region where you want to deploy the stack.
4. Follow the on-screen prompts and instructions to create the stack.
5. After creating the stack, click **Terraform Actions**, and select **Plan**.
6. Wait for the job to be completed, and review the plan.
    To make any changes, return to the Stack Details page, click **Edit Stack**, and make the required changes. Then, run the **Plan** action again.
7. If no further changes are necessary, return to the Stack Details page, click **Terraform Actions**, and select **Apply**. 


# <a name="Deploy-Using-the-Terraform-CLI"></a>Deploy Using the Terraform CLI

## Clone the Module
Now, you'll want a local copy of this repo. You can make that with the commands:

    git clone https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation.git
    cd terraform-oci-oracle-cloud-foundation/cloud-foundation/solutions/Data-platform-data-lakehouse
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
- Make sure you have docker installed or install it.
- Generate an Auth Token for the Container Registry

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

Additionally you'll need to do some pre-deploy setup for Docker and Fn Project inside your machine:

```
sudo su -
yum update
yum install yum-utils
yum-config-manager --enable *addons
yum install docker-engine
groupadd docker
service docker restart
usermod -a -G docker opc
chmod 666 /var/run/docker.sock
exit
curl -LSs https://raw.githubusercontent.com/fnproject/cli/master/install | sh
exit
```

For MacOS you can use colima as an option to have docker started.


### __Last additional prerequisites are:__
1. __Generate an Auth Token for the Container Registry__
  
  - In the top-right corner of the Console, open the User menu (User menu), and then click User Settings.
  - On the Auth Tokens page, click Generate Token.
  - Enter Tutorial auth token as a friendly description for the auth token and click Generate Token. The new auth token is displayed.
  - Copy the auth token immediately to a secure location from where you can retrieve it later, because you won't see the auth token again in the Console.
  - Close the Generate Token dialog. This token will be required for the ocir_user_password variable.
  - The code will create a repository for your artifacts inside the container registry service. Inside the repository the code will create a docker image that will be used as a function.

2. __Check your username format__ 
 - "tenancy-namespace>/username". For example, ansh81vru1zp/jdoe@acme.com. If your tenancy is federated with Oracle Identity Cloud Service, use the format tenancy-namespace/oracleidentitycloudservice/username. 
 - As the tenancy-namespace terraform will get it automatically, just verify if your tenancy it's federated or not. 
 - If it's federated remember the oracleidentitycloudservice/username format. For example: oracleidentitycloudservice/ionel_panaitescu . This will be required for the ocir_user_name variable.


## Repository files

* **functions(folder)** - In this folder all the neccesary files to create the Docker Image that will be pushed to the Container Registry. This Docker Image will decode all the messages from the StreamPool to the object storage.
* **modules(folder)** - ( this folder will be pressent only for the Resource Manager zipped files) Contains folders with subsystems and modules for each section of the project: networking, autonomous database, analytics cloud, etc.
* **CONTRIBUTING.md** - Contributing guidelines, also called Contribution guidelines, the CONTRIBUTING.md file, or software contribution guidelines, is a text file which project managers include in free and open-source software packages or other open media packages for the purpose of describing how others may contribute user-generated content to the project.The file explains how anyone can engage in activities such as formatting code for submission or submitting patches
* **LICENSE** - The Universal Permissive License (UPL), Version 1.0 
* **local.tf** - Local values can be helpful to avoid repeating the same values or expressions multiple times in a configuration, but if overused they can also make a configuration hard to read by future maintainers by hiding the actual values used.Here is the place where all the resources are defined.
* **main.tf** - Main Terraform script used for instantiating the Oracle Cloud Infrastructure provider and all subsystems modules
* **outputs.tf** - Defines project's outputs that you will see after the code runs successfuly
* **provider.tf** - The terraform provider that will be used (OCI)
* **README.md** - This file
* **schema.yaml** - Schema documents are recommended for Terraform configurations when using Resource Manager. Including a schema document allows you to extend pages in the Oracle Cloud Infrastructure Console. Facilitate variable entry in the Create Stack page by surfacing SSH key controls and by naming, grouping, dynamically prepopulating values, and more. Define text in the Application Information tab of the stack detail page displayed for a created stack.
* **tags.tf** - A file that will add tags for all the resouces as ArchitectureCenterTagNamespace convention.
* **variables.tf** - Project's global variables


Secondly, populate the `terraform.tf` file with the disared configuration following the information:


# Autonomous Data Warehouse

The ADW subsystem / module is able to create ADW/ATP databases.

* Parameters:
    * __db_name__ - The database name. The name must begin with an alphabetic character and can contain a maximum of 14 alphanumeric characters. Special characters are not permitted. The database name must be unique in the tenancy.
    * __db_password__ - The password must be between 12 and 30 characters long, and must contain at least 1 uppercase, 1 lowercase, and 1 numeric character. It cannot contain the double quote symbol (") or the username "admin", regardless of casing. The password is mandatory if source value is "BACKUP_FROM_ID", "BACKUP_FROM_TIMESTAMP", "DATABASE" or "NONE".
    * __db_cpu_core_count__ - The number of OCPU cores to be made available to the database. For Autonomous Databases on dedicated Exadata infrastructure, the maximum number of cores is determined by the infrastructure shape. See Characteristics of Infrastructure Shapes for shape details.
    * __db_size_in_tbs__ - The size, in gigabytes, of the data volume that will be created and attached to the database. This storage can later be scaled up if needed. The maximum storage value is determined by the infrastructure shape. See Characteristics of Infrastructure Shapes for shape details.
    * __db_workload__ - The Autonomous Database workload type. The following values are valid:
        - OLTP - indicates an Autonomous Transaction Processing database
        - DW - indicates an Autonomous Data Warehouse database
        - AJD - indicates an Autonomous JSON Database
        - APEX - indicates an Autonomous Database with the Oracle APEX Application Development workload type. *Note: db_workload can only be updated from AJD to OLTP or from a free OLTP to AJD.
    * __db_version__ - A valid Oracle Database version for Autonomous Database.db_workload AJD and APEX are only supported for db_version 19c and above.
    * __db_enable_auto_scaling__ - Indicates if auto scaling is enabled for the Autonomous Database OCPU core count. The default value is FALSE.
    * __db_is_free_tier__ - Indicates if this is an Always Free resource. The default value is false. Note that Always Free Autonomous Databases have 1 CPU and 20GB of memory. For Always Free databases, memory and CPU cannot be scaled. When db_workload is AJD or APEX it cannot be true.
    * __db_license_model__ - The Oracle license model that applies to the Oracle Autonomous Database. Bring your own license (BYOL) allows you to apply your current on-premises Oracle software licenses to equivalent, highly automated Oracle PaaS and IaaS services in the cloud. License Included allows you to subscribe to new Oracle Database software licenses and the Database service. Note that when provisioning an Autonomous Database on dedicated Exadata infrastructure, this attribute must be null because the attribute is already set at the Autonomous Exadata Infrastructure level. When using shared Exadata infrastructure, if a value is not specified, the system will supply the value of BRING_YOUR_OWN_LICENSE. It is a required field when db_workload is AJD and needs to be set to LICENSE_INCLUDED as AJD does not support default license_model value BRING_YOUR_OWN_LICENSE.

Below is an example:

```
variable "db_name" {
  type    = string
  default = "ADWDataLake"
}

variable "db_password" {
  type = string
  default = "<enter-password-here>"
}

variable "db_cpu_core_count" {
  type = number
  default = 1
}

variable "db_size_in_tbs" {
  type = number
  default = 1
}

variable "db_workload" {
  type = string
  default = "DW"
}

variable "db_version" {
  type = string
  default = "19c"
}

variable "db_enable_auto_scaling" {
  type = bool
  default = true
}

variable "db_is_free_tier" {
  type = bool
  default = false
}

variable "db_license_model" {
  type = string
  default = "BRING_YOUR_OWN_LICENSE"
}
```


# Object Storage

This resource provides the Bucket resource in Oracle Cloud Infrastructure Object Storage service.
Creates a bucket in the given namespace with a bucket name and optional user-defined metadata. Avoid entering confidential information in bucket names.

* Parameters:
    * __bronze_bucket_name__ - The name of the bucket. Valid characters are uppercase or lowercase letters, numbers, hyphens, underscores, and periods. Bucket names must be unique within an Object Storage namespace. Avoid entering confidential information. example: Example: my-new-bucket1
    * __bronze_bucket_access_type__ - The type of public access enabled on this bucket. A bucket is set to NoPublicAccess by default, which only allows an authenticated caller to access the bucket and its contents. When ObjectRead is enabled on the bucket, public access is allowed for the GetObject, HeadObject, and ListObjects operations. When ObjectReadWithoutList is enabled on the bucket, public access is allowed for the GetObject and HeadObject operations.
    * __bronze_bucket_storage_tier__ - The type of storage tier of this bucket. A bucket is set to 'Standard' tier by default, which means the bucket will be put in the standard storage tier. When 'Archive' tier type is set explicitly, the bucket is put in the Archive Storage tier. The 'storageTier' property is immutable after bucket is created.
    * __bronze_bucket_events_enabled__ - Whether or not events are emitted for object state changes in this bucket. By default, objectEventsEnabled is set to false. Set objectEventsEnabled to true to emit events for object state changes. For more information about events, see Overview of Events.
    * __silver_bucket_name__ - The name of the bucket. Valid characters are uppercase or lowercase letters, numbers, hyphens, underscores, and periods. Bucket names must be unique within an Object Storage namespace. Avoid entering confidential information. example: Example: my-new-bucket1
    * __silver_bucket_access_type__ - The type of public access enabled on this bucket. A bucket is set to NoPublicAccess by default, which only allows an authenticated caller to access the bucket and its contents. When ObjectRead is enabled on the bucket, public access is allowed for the GetObject, HeadObject, and ListObjects operations. When ObjectReadWithoutList is enabled on the bucket, public access is allowed for the GetObject and HeadObject operations.
    * __silver_bucket_storage_tier__ - The type of storage tier of this bucket. A bucket is set to 'Standard' tier by default, which means the bucket will be put in the standard storage tier. When 'Archive' tier type is set explicitly, the bucket is put in the Archive Storage tier. The 'storageTier' property is immutable after bucket is created.
    * __silver_bucket_events_enabled__ - Whether or not events are emitted for object state changes in this bucket. By default, objectEventsEnabled is set to false. Set objectEventsEnabled to true to emit events for object state changes. For more information about events, see Overview of Events.
    * __gold_bucket_name__ - The name of the bucket. Valid characters are uppercase or lowercase letters, numbers, hyphens, underscores, and periods. Bucket names must be unique within an Object Storage namespace. Avoid entering confidential information. example: Example: my-new-bucket1
    * __gold_bucket_access_type__ - The type of public access enabled on this bucket. A bucket is set to NoPublicAccess by default, which only allows an authenticated caller to access the bucket and its contents. When ObjectRead is enabled on the bucket, public access is allowed for the GetObject, HeadObject, and ListObjects operations. When ObjectReadWithoutList is enabled on the bucket, public access is allowed for the GetObject and HeadObject operations.
    * __gold_bucket_storage_tier__ - The type of storage tier of this bucket. A bucket is set to 'Standard' tier by default, which means the bucket will be put in the standard storage tier. When 'Archive' tier type is set explicitly, the bucket is put in the Archive Storage tier. The 'storageTier' property is immutable after bucket is created.
    * __gold_bucket_events_enabled__ - Whether or not events are emitted for object state changes in this bucket. By default, objectEventsEnabled is set to false. Set objectEventsEnabled to true to emit events for object state changes. For more information about events, see Overview of Events.
    * __dataflow_logs_bucket_name__ - The name of the bucket. Valid characters are uppercase or lowercase letters, numbers, hyphens, underscores, and periods. Bucket names must be unique within an Object Storage namespace. Avoid entering confidential information. example: Example: my-new-bucket1
    * __dataflow_logs_bucket_access_type__ - The type of public access enabled on this bucket. A bucket is set to NoPublicAccess by default, which only allows an authenticated caller to access the bucket and its contents. When ObjectRead is enabled on the bucket, public access is allowed for the GetObject, HeadObject, and ListObjects operations. When ObjectReadWithoutList is enabled on the bucket, public access is allowed for the GetObject and HeadObject operations.
    * __dataflow_logs_bucket_storage_tier__ - The type of storage tier of this bucket. A bucket is set to 'Standard' tier by default, which means the bucket will be put in the standard storage tier. When 'Archive' tier type is set explicitly, the bucket is put in the Archive Storage tier. The 'storageTier' property is immutable after bucket is created.
    * __dataflow_logs_bucket_events_enabled__ - Whether or not events are emitted for object state changes in this bucket. By default, objectEventsEnabled is set to false. Set objectEventsEnabled to true to emit events for object state changes. For more information about events, see Overview of Events.        


Below is an example:

```
variable "bronze_bucket_name" {
  type    = string
  default = "bronze_bucket"
}

variable "bronze_bucket_access_type" {
    type    = string
    default  = "NoPublicAccess"
}

variable "bronze_bucket_storage_tier" {
    type    = string
    default = "Standard"
}
  
variable "bronze_bucket_events_enabled" {
    type    = bool
    default = false
}

variable "silver_bucket_name" {
  type    = string
  default = "silver_bucket"
}

variable "silver_bucket_access_type" {
    type    = string
    default  = "NoPublicAccess"
}

variable "silver_bucket_storage_tier" {
    type    = string
    default = "Standard"
}
  
variable "silver_bucket_events_enabled" {
    type    = bool
    default = false
}

variable "gold_bucket_name" {
  type    = string
  default = "gold_bucket"
}

variable "gold_bucket_access_type" {
    type    = string
    default  = "NoPublicAccess"
}

variable "gold_bucket_storage_tier" {
    type    = string
    default = "Standard"
}
  
variable "gold_bucket_events_enabled" {
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


#  API Gateway service

This resource provides the Gateway resource and the Deployment resource in Oracle Cloud Infrastructure API Gateway service.Creates a new gateway and a new deployment.

* Parameters
    * __apigw_display_name__ -  (Optional) (Updatable) A user-friendly name. Does not have to be unique, and it's changeable. Avoid entering confidential information. Example: My new resource
    * __apigwdeploy_display_name__ - (Optional) (Updatable) A user-friendly name. Does not have to be unique, and it's changeable. Avoid entering confidential information. Example: My new resource


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

    function_routes = [
      {
        type          = "function"
        path          = "/func"
        methods       = ["GET", ]
        function_id   = function_id
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


# Streaming Service

This resource provides the Stream Pool resource in Oracle Cloud Infrastructure Streaming service.
Also this resource provides the Service Connector resource in Oracle Cloud Infrastructure Service Connector Hub service.

Creates a new service connector in the specified compartment. A service connector is a logically defined flow for moving data from a source service to a destination service in Oracle Cloud Infrastructure. For general information about service connectors, see Service Connector Hub Overview.

* Parameters:
    * __stream_name__ - The name of the stream. Avoid entering confidential information.
    * __stream_partitions__ - The number of partitions in the stream.
    * __stream_retention_in_hours__ -  The retention period of the stream, in hours. Accepted values are between 24 and 168 (7 days). If not specified, the stream will have a retention period of 24 hours.
    * __stream_pool_name__ - The name of the stream pool. Avoid entering confidential information

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
```

* Parameters:
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

```
variable "service_connector_display_name" {
  default = "Test_Service_Connector"
}

variable "service_connector_source_kind" {
  default = "streaming"
}

variable "service_connector_source_cursor_kind" {
  default = "TRIM_HORIZON"
}

variable "service_connector_target_kind" {
  default = "objectStorage"
}

variable "service_connector_target_bucket" {
  default = "bronze_bucket"
}

variable "service_connector_target_object_name_prefix" {
  default = "data"
}

variable "service_connector_target_batch_rollover_size_in_mbs" {
  default = 10
}

variable "service_connector_target_batch_rollover_time_in_ms" {
  default = 60000
}

variable "service_connector_description" {
  default = "Used to connect streaming to object storage"
}

variable "service_connector_tasks_kind" {
  default = "function"
}

variable "service_connector_tasks_batch_size_in_kbs" {
  default = 5120
}

variable "service_connector_tasks_batch_time_in_sec" {
  default = 60
}
```


# Functions Service

This data source provides the list of Functions in Oracle Cloud Infrastructure Functions service. 

* Parameters:
    * __app_display_name__ - The display name of the function. The display name must be unique within the application containing the function. Avoid entering confidential information.
    * __ocir_repo_name__ - The repo name where you will store the image in the Container Registry. The Repo name must be unique inside your tenancy.
    * __ocir_user_name__ - The username that will push the image in the Container Registry. The user should be in this format: "oracleidentitycloudservice/username"
    * __ocir_user_password__ - The auth token generated for your user.

Below is an example:

```
variable "app_display_name" {
  default = "DecoderApp"
}

# Example: decoder 
variable "ocir_repo_name" {
  default = "decoder_repo"
}

# Example: oracleidentitycloudservice/username
variable "ocir_user_name" {
  default = "oracleidentitycloudservice/ionel_panaitescu"
}

# Example: 5p2fVgX5xasda2
variable "ocir_user_password" {
  default = "<your-token>"
}
```


# Data Catalog

This resource provides the Catalog resource in Oracle Cloud Infrastructure Data Catalog service.
Creates a new data catalog instance that includes a console and an API URL for managing metadata operations. For more information, please see the documentation.

* Parameters:
    * __catalog_display_name__ - Data catalog identifier. 


Below is an example:

```
variable "catalog_display_name" {
    type    = string
    default = "DataLakeHouse"
}
```


# Bastion Service

This resource provides the Bastion resource in Oracle Cloud Infrastructure Bastion service.
Creates a new bastion. A bastion provides secured, public access to target resources in the cloud that you cannot otherwise reach from the internet. A bastion resides in a public subnet and establishes the network infrastructure needed to connect a user to a target resource in a private subnet.

* Parameters:
    * __private_bastion_service_name__ - The name of the bastion, which can't be changed after creation.


Below is an example:

```
variable "private_bastion_service_name" {
  default = "private-bastion-service"
}
```


# Oracle Analytics Cloud

This resource provides the Analytics Instance resource in Oracle Cloud Infrastructure Analytics service.
Create a new AnalyticsInstance in the specified compartment. The operation is long-running and creates a new WorkRequest.

* Parameters
    * __analytics_instance_feature_set__ - Analytics feature set: ENTERPRISE_ANALYTICS or SELF_SERVICE_ANALYTICS set
    * __analytics_instance_license_type__ - The license used for the service: LICENSE_INCLUDED or BRING_YOUR_OWN_LICENSE
    * __Oracle_Analytics_Instance_Name__ - The name of the Analytics instance. This name must be unique in the tenancy and cannot be changed.
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

Below is an example:

```
variable "Oracle_Analytics_Instance_Name" {
  default = "DataLakeHousev"
}

variable "analytics_instance_feature_set" {
  type = string
  default = "ENTERPRISE_ANALYTICS"
}

variable "analytics_instance_license_type" {
  type = string
  default = "LICENSE_INCLUDED"
}

variable "analytics_instance_idcs_access_token" {
  type = string
  default = "copy-paste your token instead"
}

variable "analytics_instance_capacity_capacity_type" {
  type = string
  default = "OLPU_COUNT"
}

variable "analytics_instance_capacity_value" {
  type = number
  default = 1
}
```


# Oracle Cloud Infrastructure Data Integration service
This resource provides the Workspace resource in Oracle Cloud Infrastructure Data Integration service.
Creates a new Data Integration workspace ready for performing data integration tasks.

* Parameters:
    * __ocidi_display_name__ - A user-friendly display name for the workspace. Does not have to be unique, and can be modified. Avoid entering confidential information.
    * __ocidi_description__ - A user defined description for the workspace.


Below is an example:

```
variable "ocidi_display_name" {
    type    = string
    default = "ocidi_workspace"
}

variable "ocidi_description" {
    type    = string
    default  = "ocidi_workspace"
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


# Data Flow Service

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


# WAF Service

This resource provides the Web App Firewall resource in Oracle Cloud Infrastructure Waf service. Creates a new WebAppFirewall.

* Parameters:
    * __waf_display_name__ - (Updatable) WebAppFirewall display name, can be renamed.


Below is an example:

```
variable "waf_display_name" {
  default = "waflb"
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
}
```


# Dynamic Routing Gateways (DRGs)

This resource provides the Drg resource in Oracle Cloud Infrastructure Core service. The DRG will be attached to the VCN-0 (Hub) VCN.

* Parameters
    * __drg_cidr_rt__ - Internal network -  cidr block: example - "192.0.0.0/16"


Below is an example:

```
variable "drg_cidr_rt" {
  default = "192.0.0.0/16"
}
```


# Network

This resource provides the Vcn resource in Oracle Cloud Infrastructure Core service anso This resource provides the Subnet resource in Oracle Cloud Infrastructure Core service.
The solution will create 2 VCN in your compartment, 4 subnets ( one public in the first VCN and three private subnets ) , 4 route tables for incomming and outoing traffic, 2 Network Security Groups for ingress and egress traffic, 1 internet gateway, 2 route tables for each subnet, dhcp service, NAT Gateway, Service Gateways and a local peering gateway between the 2 VCNs. 

* Parameters
    * __vcn_0_hub_cidr__ - The list of one or more IPv4 CIDR blocks for the VCN that meet the following criteria:
        The CIDR blocks must be valid.  
        They must not overlap with each other or with the on-premises network CIDR block.
        The number of CIDR blocks must not exceed the limit of CIDR blocks allowed per VCN. It is an error to set both cidrBlock and cidrBlocks. Note: cidr_blocks update must be restricted to one operation at a time (either add/remove or modify one single cidr_block) or the operation will be declined.
    * __public_subnet_cidr_vcn0__ - The CIDR IP address range of the subnet. The CIDR must maintain the following rules - a. The CIDR block is valid and correctly formatted. b. The new range is within one of the parent VCN ranges. This is the cidr for the public subnet.
    * __vcn_1_workload_cidr__ - The list of one or more IPv4 CIDR blocks for the VCN that meet the following criteria:
        The CIDR blocks must be valid.  
        They must not overlap with each other or with the on-premises network CIDR block.
        The number of CIDR blocks must not exceed the limit of CIDR blocks allowed per VCN. It is an error to set both cidrBlock and cidrBlocks. Note: cidr_blocks update must be restricted to one operation at a time (either add/remove or modify one single cidr_block) or the operation will be declined.
    * __private_subnet_cidr_application_vnc1__ - The CIDR IP address range of the subnet. The CIDR must maintain the following rules - a. The CIDR block is valid and correctly formatted. b. The new range is within one of the parent VCN ranges. This is the cidr for the private subnet.
    * __private_subnet_cidr_midtier_vnc1__ - The CIDR IP address range of the subnet. The CIDR must maintain the following rules - a. The CIDR block is valid and correctly formatted. b. The new range is within one of the parent VCN ranges. This is the cidr for the private subnet.
    * __private_subnet_cidr_data_vnc1__ - The CIDR IP address range of the subnet. The CIDR must maintain the following rules - a. The CIDR block is valid and correctly formatted. b. The new range is within one of the parent VCN ranges. This is the cidr for the private subnet.


Below is an example:

```
# VNC0
variable "vcn_0_hub_cidr" {
  default = "192.0.0.0/16"
}

variable "public_subnet_cidr_vcn0" {
  default = "192.0.2.0/28"
}

# VNC 1
variable "vcn_1_workload_cidr" {
  default = "10.0.0.0/16"
}

variable "private_subnet_cidr_application_vnc1" {
  default = "10.0.10.0/28"
}

variable "private_subnet_cidr_midtier_vnc1" {
  default = "10.0.20.0/28"
}

variable "private_subnet_cidr_data_vnc1" {
  default = "10.0.30.0/28"
}
```



# Load Balancer Configuration

* Parameters for Load Balancer Configuration
    * __load_balancer_shape__ - (Required) (Updatable) A template that determines the total pre-provisioned bandwidth (ingress plus egress). To get a list of available shapes, use the ListShapes operation. Example: flexible NOTE: Starting May 2023, Fixed shapes - 10Mbps, 100Mbps, 400Mbps, 8000Mbps would be deprecated and only shape allowed would be Flexible *Note: When updating shape for a load balancer, all existing connections to the load balancer will be reset during the update process. Also 10Mbps-Micro shape cannot be updated to any other shape nor can any other shape be updated to 10Mbps-Micro.
    * __load_balancer_maximum_bandwidth_in_mbps__ - (Required) (Updatable) Bandwidth in Mbps that determines the maximum bandwidth (ingress plus egress) that the load balancer can achieve. This bandwidth cannot be always guaranteed. For a guaranteed bandwidth use the minimumBandwidthInMbps parameter. The values must be between minimumBandwidthInMbps and 8000 (8Gbps). Example: 1500
    * __load_balancer_minimum_bandwidth_in_mbps__ - (Required) (Updatable) Bandwidth in Mbps that determines the total pre-provisioned bandwidth (ingress plus egress). The values must be between 10 and the maximumBandwidthInMbps. Example: 150
    * __load_balancer_display_name__ - (Required) (Updatable) A user-friendly name. It does not have to be unique, and it is changeable. Avoid entering confidential information. Example: example_load_balancer

Below is an example:

```
variable "load_balancer_shape" {
  default = "flexible"
}

variable "load_balancer_maximum_bandwidth_in_mbps" {
  type    = number 
  default = 400
}

variable "load_balancer_minimum_bandwidth_in_mbps" {
  type    = number 
  default = 10
}

variable "load_balancer_display_name" {
  default = "lboac"
}
```

Don't modify any other variables in the variable.tf file - it may cause that the solution will not work propertly. The release variable it's used in the tagging concept.

**Note**: A set of policies and three dynamic groups will be created allowing an administrator to deploy this solution. These are listed in "local.tf" file ( the last lines) and can be used as a reference when fitting this deployment to your specific IAM configuration.



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

[API Gateway Overview](https://docs.oracle.com/en-us/iaas/Content/APIGateway/Concepts/apigatewayoverview.htm)

[Streaming Overview](https://docs.oracle.com/en-us/iaas/Content/Streaming/Concepts/streamingoverview.htm)

[Functions Overview](https://docs.oracle.com/en-us/iaas/Content/Functions/Concepts/functionsoverview.htm)

[Pushing Images Using the Docker CLI](https://docs.oracle.com/en-us/iaas/Content/Registry/Tasks/registrypushingimagesusingthedockercli.htm)

[Data Catalog Overview](https://docs.oracle.com/en-us/iaas/data-catalog/using/overview.htm)

[Certificates Overview](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm)

[Bastion Service Overview](https://docs.oracle.com/en-us/iaas/Content/Bastion/Concepts/bastionoverview.htm)

[Analytics Cloud Overview](https://docs.oracle.com/en-us/iaas/analytics-cloud/index.html)

[Data Integration Overview](https://docs.oracle.com/en-us/iaas/data-integration/using/overview.htm)

[Data Science Overview](https://docs.oracle.com/en-us/iaas/data-science/using/overview.htm)

[Data Flow Overview](https://docs.oracle.com/en-us/iaas/data-flow/using/dfs_service_overview.htm)

[Web Application Firewall Overview](https://docs.oracle.com/en-us/iaas/Content/WAF/Concepts/overview.htm)

[Container Registry Overview](https://docs.oracle.com/en-us/iaas/Content/Registry/Concepts/registryoverview.htm)

[Compute service](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm)

[Dynamic Routing Gateways (DRGs) Overview](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingDRGs.htm)

[Network Overview](https://docs.cloud.oracle.com/iaas/Content/Network/Concepts/overview.htm)

[Tagging Overview](https://docs.oracle.com/en-us/iaas/Content/Tagging/Concepts/taggingoverview.htm)

[Load Balancer Overview](https://docs.oracle.com/en-us/iaas/Content/Balance/Concepts/balanceoverview.htm)

[Terraform Autonomous Databases Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_autonomous_database)

[Terraform Object Storage Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_bucket)

[Terraform API Gateway Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/apigateway_gateway)

[Terraform Deployment for API GatewayResource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/apigateway_deployment)

[Terraform Streaming Stream Pool Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/streaming_stream_pool)

[Terraform Streaming Stream Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/streaming_stream)

[Terraform Service Connector Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/sch_service_connector)

[Terraform Function Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/functions_function)

[Terraform Function Application Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/functions_application)

[Terraform Data Catalog Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/datacatalog_catalog)

[Terraform Certificates - TLS Provider](https://registry.terraform.io/providers/hashicorp/tls/latest/docs)

[Terraform Bastion Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/bastion_bastion)

[Terraform Analytics Cloud Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/analytics_analytics_instance)

[Terraform Data Integration Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/dataintegration_workspace)

[Terraform Data Science Project Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/datascience_project)

[Terraform Data Science Notebook Session Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/datascience_notebook_session)

[Terraform Data Flow Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/dataflow_application)

[Terraform Web App Firewall resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/waf_web_app_firewall)

[Terraform Container Repository resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/artifacts_container_repository)

[Terraform Oracle Cloud Infrastructure Core Service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance)

[Terraform Dynamic Routing Gateways (DRGs) resource in Oracle Cloud Infrastructure](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_drg)

[Terraform Vcn resource in Oracle Cloud Infrastructure Core service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_vcn)

[Terraform Subnet resource in Oracle Cloud Infrastructure Core service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet)

[Terraform Tag Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_tag_namespace)

[Terraform Load Balancer resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/load_balancer_load_balancer)


## <a name="theteam"></a>The Team
- **Owners**: [Panaitescu Ionel](https://github.com/ionelpanaitescu)

## <a name="feedback"></a>Feedback
We welcome your feedback. To post feedback, submit feature ideas or report bugs, please use the Issues section on this repository.	

## <a name="known-issues"></a>Known Issues
**At the moment, there are no known issues**