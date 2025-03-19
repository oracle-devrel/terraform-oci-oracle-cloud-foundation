# Oracle Cloud Foundation Terraform Solution - Deploy vectorRAG-IN-A-BOX

![](./images/vraginabox.png)

## Table of Contents
1. [Overview](#overview)
1. [Deliverables](#deliverables)
1. [Architecture](#Architecture-Diagram)
1. [Executing Instructions](#instructions)
    1. [Deploy Using Oracle Resource Manager](#Deploy-Using-Oracle-Resource-Manager)
    1. [What to do after the Deployment via Resource Manager](#After-Deployment-via-Resource-Manager)
    1. [Deploy Using the Terraform CLI](#Deploy-Using-the-Terraform-CLI)
    1. [What to do after the Deployment via Terraform CLI](#After-Deployment-via-Terraform-CLI)
1. [Documentation](#documentation)
1. [The Team](#team)
1. [Feedback](#feedback)
1. [Known Issues](#known-issues)
1. [Contribute](#CONTRIBUTING.md)


## <a name="overview"></a>Overview
----------------

The easy Retrieval Augmented Generation (RAG) in a box, essentially allows to create a fully functional RAG system that reads any number of files hosted on a bucket and allow natural language queries on that content.

The system uses Oracle's vector technology to allow full control of the chunking, embedding, and selection processes.

Even though the system comes with an APEX GUI, the code has been developed in such a way to be completely decoupled from any front-end allowing the embedding in any kind of application that can call Oracle pl/sql procedures.

The secondary goal of the vectorRAG-IN-A-BOX application is to allow hands-on experience on the consequences of parameter tweaking. All parameters used by the system are changeable (within reasonable limits) and all helps are populated. In order to do this you will need to enable the "expert mode" setting.

The "expert mode" even allows visibility on the chunking results from the proximitiy search passed on to the LLM to generate the answer.

Please refer to the "Show Documentation" button in the app or the field help info (press the '?' next to each field).

## Important  - please deploy the solution in any region but you need to use for the variable llm_region - one of the listed regions below as the GenAI it's only available in this regions. If you deploy it in other regions, the solution will not work. If you don't have any of the regions available in your tenancy, please subscribe to one of them.


Some regions don't offer all the models. See the region for each pretrained model to find out which models are available in a region near you.

| Region Name              | Location  | Region Identifier | Region Key |
|--------------------------|----------|-------------------|------------|
| Brazil East (Sao Paulo)  | Sao Paulo | sa-saopaulo-1     | GRU        |
| Germany Central (Frankfurt) | Frankfurt | eu-frankfurt-1 | FRA        |
| Japan Central (Osaka)    | Osaka    | ap-osaka-1       | KIX        |
| UK South (London)        | London   | uk-london-1      | LHR        |
| US Midwest (Chicago)     | Chicago  | us-chicago-1     | ORD        |

```
There is this variable called llm_region :
variable "llm_region" {
  type    = string
  default = "us-chicago-1"
}

It is set to default to us-chicago-1 ; you need to use any region available in your tenancy subscribed to one of the available LLMs regions listed above. 
```



## <a name="deliverables"></a>Deliverables
----------------

 This repository encloses one deliverable:

- A reference implementation written in Terraform HCL (Hashicorp Language) that provisions fully functional resources in an OCI tenancy.
    * __vectorRAG_IN_A_BOX_ADMIN.sql__ - creates the database user and grants it the needed permissions 
    * __vectorRAG_IN_A_BOX_APEX_ADMIN.sql__ - creates the APEX workspace and the administrative user that will own the application
    * __vectorRAG_IN_A_BOX_USER.sql__ - installs in the database user schema the software needed for the RAG implementation
    * __vectorRAG_IN_A_BOX_APEX_USER.sql__ - installs in the APEX admin user the application
    * __vectorRAG-IN-A-BOX_USER_CREDS.sql__ - install your personal credentials for your user.
    * __vectorRAG_IN_A_BOX_step_by_step_install.sql__ - if you are not using the terraform version and want to load everything manually please follow these instructions
    * __vectorRAG_IN_A_BOX_f100.sql__ - the application file

## <a name="architecture"></a>Architecture-Diagram
----------------

![](./images/diagram.png)


## <a name="instructions"></a>Executing Instructions
----------------

## Prerequisites

- Permission to `manage` the following types of resources in your Oracle Cloud Infrastructure tenancy: `autonomous database`
- Quota to create the following resources: 1 ADW database instance and a bucket inside OCI.
If you don't have the required permissions and quota, contact your tenancy administrator. See [Policy Reference](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm), [Service Limits](https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm), [Compartment Quotas](https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcequotas.htm).

# <a name="Deploy-Using-Oracle-Resource-Manager"></a>Deploy Using Oracle Resource Manager

1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation/releases/download/v1.0.0/RAG-in-a-Box-Vector-RM.zip)


    If you aren't already signed in, when prompted, enter the tenancy and user credentials.

2. Review and accept the terms and conditions.
3. Select the region where you want to deploy the stack.
4. Follow the on-screen prompts and instructions to create the stack.
  * __note__ - for the the private_key field -  If never done before, create API Key, download both PRIVATE and PUBLIC key files. Convert PRIVATE KEY into the needed format for the credentials and enter it as single line without breaks in the format: ```-----BEGIN PRIVATE KEY-----.......-----END PRIVATE KEY-----```.
  * Use this command to get the key correctly:  ```tr -d '\r\n' <mykeysep_privatepem.pem | pbcopy " ``` and paste the content of it in the field.
5. After creating the stack, click **Terraform Actions**, and select **Plan**.
6. Wait for the job to be completed, and review the plan.
    To make any changes, return to the Stack Details page, click **Edit Stack**, and make the required changes. Then, run the **Plan** action again.
7. If no further changes are necessary, return to the Stack Details page, click **Terraform Actions**, and select **Apply**. 

## <a name="After-Deployment-via-Resource-Manager"></a>What to do after the Deployment via Resource Manager
----------------

- After the solution was deployed successfully from Terraform CLI you will have some outputs on the screen. 

Example of output:

```
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

ADW_Database_db_connection = tolist([
  {
    "all_connection_strings" = tomap({
      "HIGH" = "adb.us-chicago-1.oraclecloud.com:1522/gef5c7ee9863259_vectorraginaboxx_high.adb.oraclecloud.com"
      "LOW" = "adb.us-chicago-1.oraclecloud.com:1522/gef5c7ee9863259_vectorraginaboxx_low.adb.oraclecloud.com"
      "MEDIUM" = "adb.us-chicago-1.oraclecloud.com:1522/gef5c7ee9863259_vectorraginaboxx_medium.adb.oraclecloud.com"
    })
    "dedicated" = ""
    "high" = "adb.us-chicago-1.oraclecloud.com:1522/gef5c7ee9863259_vectorraginaboxx_high.adb.oraclecloud.com"
    "low" = "adb.us-chicago-1.oraclecloud.com:1522/gef5c7ee9863259_vectorraginaboxx_low.adb.oraclecloud.com"
    "medium" = "adb.us-chicago-1.oraclecloud.com:1522/gef5c7ee9863259_vectorraginaboxx_medium.adb.oraclecloud.com"
    "profiles" = tolist([
      {
        "consumer_group" = "HIGH"
        "display_name" = "vectorraginaboxx_high"
        "host_format" = "FQDN"
        "is_regional" = false
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "MUTUAL"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-chicago-1.oraclecloud.com))(connect_data=(service_name=gef5c7ee9863259_vectorraginaboxx_high.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))"
      },
      {
        "consumer_group" = "LOW"
        "display_name" = "vectorraginaboxx_low"
        "host_format" = "FQDN"
        "is_regional" = false
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "MUTUAL"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-chicago-1.oraclecloud.com))(connect_data=(service_name=gef5c7ee9863259_vectorraginaboxx_low.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))"
      },
      {
        "consumer_group" = "MEDIUM"
        "display_name" = "vectorraginaboxx_medium"
        "host_format" = "FQDN"
        "is_regional" = false
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "MUTUAL"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-chicago-1.oraclecloud.com))(connect_data=(service_name=gef5c7ee9863259_vectorraginaboxx_medium.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))"
      },
    ])
  },
])
Buckets = [
  {
    "rag_bucket" = {
      "access_type" = "ObjectRead"
      "approximate_count" = "0"
      "approximate_size" = "0"
      "auto_tiering" = "Disabled"
      "bucket_id" = "ocid1.bucket.oc1.us-chicago-1.aaaaaaaal2hxtw6gok76txvkgnzdbxploiuknyykk7xv7nc4odiljkg6pz4a"
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaau2d3nt3v7klmdn35ux3ukiapgacd4c6l6inzk7ad7f4wwvjc7zoa"
      "created_by" = "ocid1.user.oc1..aaaaaaaasweswkwp5t25dqh4d64sq4ssjuzswy3ods6t5dsbdue4jj6btnnq"
      "defined_tags" = tomap({
        "Oracle-Tags.CreatedBy" = "oracle-sso/ionel.panaitescu@oracle.com"
        "Oracle-Tags.CreatedOn" = "2025-03-06T13:09:55.302Z"
      })
      "etag" = "7ff41c4d-9c84-41ff-9b95-59361a141928"
      "freeform_tags" = tomap({})
      "id" = "n/idukzrqavn8q/b/vectorRag_Buckett"
      "is_read_only" = false
      "kms_key_id" = tostring(null)
      "metadata" = tomap(null) /* of string */
      "name" = "vectorRag_Buckett"
      "namespace" = "idukzrqavn8q"
      "object_events_enabled" = false
      "object_lifecycle_policy_etag" = tostring(null)
      "replication_enabled" = false
      "retention_rules" = toset([])
      "storage_tier" = "Standard"
      "time_created" = "2025-03-06 13:09:55.31 +0000 UTC"
      "timeouts" = null /* object */
      "versioning" = "Disabled"
    }
  },
]
Database_Actions = [
  "https://GEF5C7EE9863259-VECTORRAGINABOXX.adb.us-chicago-1.oraclecloudapps.com/ords/sql-developer",
]
adb_admin_password = <sensitive>
adb_user_name = "RIAB"
adb_user_password = <sensitive>
apex_url = [
  "https://GEF5C7EE9863259-VECTORRAGINABOXX.adb.us-chicago-1.oraclecloudapps.com/ords/apex",
]
vectorRAG_IN_A_BOX_URL = "https://gef5c7ee9863259-vectorraginaboxx.adb.us-chicago-1.oraclecloudapps.com/ords/r/riab/vrag-in-a-box102"
```

## Oracle vectorRAG In a BOX demonstration deployment

This stack installs everything required to run the rag in a box solution. 

You can find details for connecting to these services in the Stack's Job Details Output. 


# <a name="Deploy-Using-the-Terraform-CLI"></a>Deploy Using the Terraform CLI


## Clone the Module
Now, you'll want a local copy of this repo. You can make that with the commands:

    git clone https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation.git
    cd terraform-oci-oracle-cloud-foundation/cloud-foundation/solutions/vectorRAG-IN-A-BOX
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

- Install Terraform v0.15 or greater: https://www.terraform.io/downloads.html
- Install sqlcl on your operating system: https://docs.oracle.com/en/database/oracle/apex/22.1/aeadm/downloading-and-installing-sqlcl.html
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

* **images(folder)** - Contains images to be used inside the README.md file
* **modules(folder)** - ( this folder will be pressent only for the Resource Manager zipped files) Contains folders with subsystems and modules for each section of the project: networking, autonomous database, analytics cloud, object storage, data catalog etc.
Also in the modules folder there is a folder called provisioner - that will provision your full infrastructure with the data model.
* **scripts(folder)** - this folder contains the necessary scripts that will run on the DB.
* **CONTRIBUTING.md** - Contributing guidelines, also called Contribution guidelines, the CONTRIBUTING.md file, or software contribution guidelines, is a text file which project managers include in free and open-source software packages or other open media packages for the purpose of describing how others may contribute user-generated content to the project.The file explains how anyone can engage in activities such as formatting code for submission or submitting patches
* **LICENSE** - The Universal Permissive License (UPL), Version 1.0 
* **local.tf** - Local values can be helpful to avoid repeating the same values or expressions multiple times in a configuration, but if overused they can also make a configuration hard to read by future maintainers by hiding the actual values used.Here is the place where all the resources are defined.
* **main.tf** - Main Terraform script used for instantiating the Oracle Cloud Infrastructure provider and all subsystems modules
* **outputs.tf** - Defines project's outputs that you will see after the code runs successfuly
* **provider.tf** - The terraform provider that will be used (OCI)
* **README.md** - This file
* **schema.yaml** - Schema documents are recommended for Terraform configurations when using Resource Manager. Including a schema document allows you to extend pages in the Oracle Cloud Infrastructure Console. Facilitate variable entry in the Create Stack page by surfacing SSH key controls and by naming, grouping, dynamically prepopulating values, and more. Define text in the Application Information tab of the stack detail page displayed for a created stack.
* **variables.tf** - Project's global variables

Secondly, populate the `terraform.tf` file with the disared configuration following the information:


# Autonomous Data Warehouse

The ADW subsystem / module is able to create ADW/ATP databases.

* Parameters:
    * __db_name__ - The database name. The name must begin with an alphabetic character and can contain a maximum of 14 alphanumeric characters. Special characters are not permitted. The database name must be unique in the tenancy.
    * __db_password__ - The password must be between 12 and 30 characters long, and must contain at least 1 uppercase, 1 lowercase, and 1 numeric character. It cannot contain the double quote symbol (") or the username "admin", regardless of casing. The password is mandatory if source value is "BACKUP_FROM_ID", "BACKUP_FROM_TIMESTAMP", "DATABASE" or "NONE".
    * __db_compute_model__ - The compute model of the Autonomous Database. This is required if using the computeCount parameter. If using cpuCoreCount then it is an error to specify computeModel to a non-null value.
    * __db_compute_count__ - The compute amount available to the database. Minimum and maximum values depend on the compute model and whether the database is on Shared or Dedicated infrastructure. For an Autonomous Database on Shared infrastructure, the 'ECPU' compute model requires values in multiples of two. Required when using the computeModel parameter. When using cpuCoreCount parameter, it is an error to specify computeCount to a non-null value.
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
    * __db_data_safe_status__ - (Updatable) Status of the Data Safe registration for this Autonomous Database. Could be REGISTERED or NOT_REGISTERED.
    * __db_operations_insights_status__ - (Updatable) Status of Operations Insights for this Autonomous Database. Values supported are ENABLED and NOT_ENABLED
    * __db_database_management_status__ - Status of Database Management for this Autonomous Database. Values supported are ENABLED and NOT_ENABLED

The RAG IN A BOX SETTINGS are:

* Parameters:
    * __llm_region__ - The region that you need to connect to your LLM. Some regions don't offer all the models. See the region for each pretrained model to find out which models are available in a region near you. It is set to default to us-chicago-1 ; you need to use any region available in your tenancy subscribed to one of the available LLMs regions listed : sa-saopaulo-1 , eu-frankfurt-1 , ap-osaka-1 , uk-london-1 , us-chicago-1    
    * __riab_user__ - The username inside the database where you will install the apex application
    * __riab_password__ - The password for the user inside the database - The password must be between 12 and 30 characters long, and must contain at least 1 uppercase, 1 lowercase, and 1 numeric character. It cannot contain the double quote symbol (") or the username "admin", regardless of casing. The password is mandatory if source value is "BACKUP_FROM_ID", "BACKUP_FROM_TIMESTAMP", "DATABASE" or "NONE"
    * __apex_workspace__ - The name of the apex workspace
    * __apex_user__ - The user in apex application
    * __apex_password__ - The password for the apex user application - The password must be between 12 and 30 characters long, and must contain at least 1 uppercase, 1 lowercase, and 1 numeric character. It cannot contain the double quote symbol (") or the username "admin", regardless of casing. The password is mandatory if source value is "BACKUP_FROM_ID", "BACKUP_FROM_TIMESTAMP", "DATABASE" or "NONE"
    * __bucket_url__ - This is the URL of the source buckt where the files will be ingested. Example: https://objectstorage.us-chicago-1.oraclecloud.com/n/Object_storage_namespace/b/bucket_name/o/". It is optional , if you don't have a bucket already, terraform will create a bucket for you and upload a sampledata file, as you log in the apex you can already put questions about data in industry.
    * __private_key__ - If never done before, create API Key, download both PRIVATE and PUBLIC key files. Convert PRIVATE KEY into the needed format for the credentials. Enter as single line without breaks in the format -----BEGIN PRIVATE KEY-----.......-----END PRIVATE KEY----- . Use this command to get the key correctly :   " tr -d '\r\n' <mykeysep_privatepem.pem | pbcopy "  - and copy the content of it in the below variable called : private_key


Below is an example:

```

variable "db_name" {
  type    = string
  default = "vectorRAGinaBOX"
}

variable "db_password" {
  type = string
  default = "<enter-password-here>"
}

variable "db_compute_model" {
  type    = string
  default = "ECPU"
}

variable "db_compute_count" {
  type = number
  default = 2
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
  default = "23ai"
}

variable "db_enable_auto_scaling" {
  type = bool
  default = false
}

variable "db_is_free_tier" {
  type = bool
  default = false
}

variable "db_license_model" {
  type = string
  default = "LICENSE_INCLUDED"
}

variable "db_data_safe_status" {
  type = string
  default = "NOT_REGISTERED"
  # default = "REGISTERED"
}

variable "db_operations_insights_status" {
  type = string
  default = "NOT_ENABLED"
  # default = "ENABLED"
}

variable "db_database_management_status" {
  type = string
  default = "NOT_ENABLED"
  # default = "ENABLED"
}



# The RAG IN A BOX SETTINGS are:


variable "llm_region" {
  type    = string
  default = "us-chicago-1"
}

# The username inside the database where you will install the apex application
variable "riab_user" {
  type = string
  default = "RIAB"
}

# The password for the user inside the database - The password must be between 12 and 30 characters long, and must contain at least 1 uppercase, 1 lowercase, and 1 numeric character. It cannot contain the double quote symbol (") or the username "admin", regardless of casing. The password is mandatory if source value is "BACKUP_FROM_ID", "BACKUP_FROM_TIMESTAMP", "DATABASE" or "NONE"
variable "riab_password" {
  type = string
  default = "<enter-password-here>"
}

# The name of the apex workspace
variable "apex_workspace" {
  type = string
  default = "RIAB"
}

# The user in apex application
variable "apex_user" {
  type = string
  default = "VRIAB"
}

# The password for the apex user application - The password must be between 12 and 30 characters long, and must contain at least 1 uppercase, 1 lowercase, and 1 numeric character. It cannot contain the double quote symbol (") or the username "admin", regardless of casing. The password is mandatory if source value is "BACKUP_FROM_ID", "BACKUP_FROM_TIMESTAMP", "DATABASE" or "NONE"
variable "apex_password" {
  type = string
  default = "<enter-password-here>"
}

# This is the URL of the source buckt where the files will be ingested.
# This is the URL of the source buckt where the files will be ingested. Example: https://objectstorage.us-chicago-1.oraclecloud.com/n/Object_storage_namespace/b/bucket_name/o". It is optional , if you don't have a bucket already, terraform will create a bucket for you and upload a sampledata file, as you log in the apex you can already put questions about data in industry.
variable "bucket_url" {
  type = string
  default = "https://objectstorage.us-chicago-1.oraclecloud.com/n/Object_storage_namespace/b/bucket_name/o"
}

# -- If never done before, create API Key, download both PRIVATE and PUBLIC key files
# -- Convert PRIVATE KEY into the needed format for the credentials
# -- DO NOT USE rtf, just plain text files
# -- Enter as single line without breaks in the format -----BEGIN PRIVATE KEY-----.......-----END PRIVATE KEY-----
# -- Use this command to get the key correctly :    tr -d '\r\n' <mykeysep_privatepem.pem | pbcopy   - and copy the content of it in the below variable called : private_key

variable "private_key" {
  type    = string
  default = "-----BEGIN PRIVATE KEY-----..... -----END PRIVATE KEY-----OCI_API_KEY"
}

```

## Running the code

```
# Run init to get terraform modules
$ terraform init

# Create the infrastructure
$ terraform apply --auto-approve

# If you are done with this infrastructure, take it down
$ terraform destroy --auto-approve
```

## <a name="After-Deployment-via-Terraform-CLI"></a>What to do after the Deployment via Terraform CLI
----------------

- After the solution was deployed successfully from Terraform CLI you will have some outputs on the screen. 

Example of output:

```
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

ADW_Database_db_connection = tolist([
  {
    "all_connection_strings" = tomap({
      "HIGH" = "adb.us-chicago-1.oraclecloud.com:1522/gef5c7ee9863259_vectorraginaboxx_high.adb.oraclecloud.com"
      "LOW" = "adb.us-chicago-1.oraclecloud.com:1522/gef5c7ee9863259_vectorraginaboxx_low.adb.oraclecloud.com"
      "MEDIUM" = "adb.us-chicago-1.oraclecloud.com:1522/gef5c7ee9863259_vectorraginaboxx_medium.adb.oraclecloud.com"
    })
    "dedicated" = ""
    "high" = "adb.us-chicago-1.oraclecloud.com:1522/gef5c7ee9863259_vectorraginaboxx_high.adb.oraclecloud.com"
    "low" = "adb.us-chicago-1.oraclecloud.com:1522/gef5c7ee9863259_vectorraginaboxx_low.adb.oraclecloud.com"
    "medium" = "adb.us-chicago-1.oraclecloud.com:1522/gef5c7ee9863259_vectorraginaboxx_medium.adb.oraclecloud.com"
    "profiles" = tolist([
      {
        "consumer_group" = "HIGH"
        "display_name" = "vectorraginaboxx_high"
        "host_format" = "FQDN"
        "is_regional" = false
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "MUTUAL"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-chicago-1.oraclecloud.com))(connect_data=(service_name=gef5c7ee9863259_vectorraginaboxx_high.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))"
      },
      {
        "consumer_group" = "LOW"
        "display_name" = "vectorraginaboxx_low"
        "host_format" = "FQDN"
        "is_regional" = false
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "MUTUAL"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-chicago-1.oraclecloud.com))(connect_data=(service_name=gef5c7ee9863259_vectorraginaboxx_low.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))"
      },
      {
        "consumer_group" = "MEDIUM"
        "display_name" = "vectorraginaboxx_medium"
        "host_format" = "FQDN"
        "is_regional" = false
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "MUTUAL"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-chicago-1.oraclecloud.com))(connect_data=(service_name=gef5c7ee9863259_vectorraginaboxx_medium.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))"
      },
    ])
  },
])
Buckets = [
  {
    "rag_bucket" = {
      "access_type" = "ObjectRead"
      "approximate_count" = "0"
      "approximate_size" = "0"
      "auto_tiering" = "Disabled"
      "bucket_id" = "ocid1.bucket.oc1.us-chicago-1.aaaaaaaal2hxtw6gok76txvkgnzdbxploiuknyykk7xv7nc4odiljkg6pz4a"
      "compartment_id" = "ocid1.compartment.oc1..aaaaaaaau2d3nt3v7klmdn35ux3ukiapgacd4c6l6inzk7ad7f4wwvjc7zoa"
      "created_by" = "ocid1.user.oc1..aaaaaaaasweswkwp5t25dqh4d64sq4ssjuzswy3ods6t5dsbdue4jj6btnnq"
      "defined_tags" = tomap({
        "Oracle-Tags.CreatedBy" = "oracle-sso/ionel.panaitescu@oracle.com"
        "Oracle-Tags.CreatedOn" = "2025-03-06T13:09:55.302Z"
      })
      "etag" = "7ff41c4d-9c84-41ff-9b95-59361a141928"
      "freeform_tags" = tomap({})
      "id" = "n/idukzrqavn8q/b/vectorRag_Buckett"
      "is_read_only" = false
      "kms_key_id" = tostring(null)
      "metadata" = tomap(null) /* of string */
      "name" = "vectorRag_Buckett"
      "namespace" = "idukzrqavn8q"
      "object_events_enabled" = false
      "object_lifecycle_policy_etag" = tostring(null)
      "replication_enabled" = false
      "retention_rules" = toset([])
      "storage_tier" = "Standard"
      "time_created" = "2025-03-06 13:09:55.31 +0000 UTC"
      "timeouts" = null /* object */
      "versioning" = "Disabled"
    }
  },
]
Database_Actions = [
  "https://GEF5C7EE9863259-VECTORRAGINABOXX.adb.us-chicago-1.oraclecloudapps.com/ords/sql-developer",
]
adb_admin_password = <sensitive>
adb_user_name = "RIAB"
adb_user_password = <sensitive>
apex_url = [
  "https://GEF5C7EE9863259-VECTORRAGINABOXX.adb.us-chicago-1.oraclecloudapps.com/ords/apex",
]
vectorRAG_IN_A_BOX_URL = "https://gef5c7ee9863259-vectorraginaboxx.adb.us-chicago-1.oraclecloudapps.com/ords/r/riab/vrag-in-a-box102"

```



## <a name="documentation"></a>Documentation

[Autonomous Databases Overview](https://docs.oracle.com/en-us/iaas/Content/Database/Concepts/adboverview.htm)

[Generative AI](https://docs.oracle.com/en-us/iaas/Content/generative-ai/home.htm)

[Terraform Autonomous Databases Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_autonomous_database)


## <a name="team"></a>The Team
- **Owners**: [Massimo Castelli](https://github.com/m-cas), [Panaitescu Ionel](https://github.com/ionelpanaitescu)

## <a name="feedback"></a>Feedback
We welcome your feedback. To post feedback, submit feature ideas or report bugs, please use the Issues section on this repository.	

## <a name="known-issues"></a>Known Issues
**At the moment, there are no known issues for this solution**

