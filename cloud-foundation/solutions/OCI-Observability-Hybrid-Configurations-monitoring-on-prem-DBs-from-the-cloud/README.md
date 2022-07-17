# Oracle Cloud Foundation Terraform Solution - External Database Service with the possibility of Enabling Database Management for: External Container Database and External Pluggable Database and also Enabling Operation Insights for: External Pluggable Database


## Table of Contents
1. [Overview](#overview)
1. [Deliverables](#deliverables)
1. [Executing Instructions](#instructions)
    1. [Deploy Using the Terraform CLI](#Deploy-Using-the-Terraform-CLI)
1. [Documentation](#documentation)
1. [The Team](#team)
1. [Feedback](#feedback)
1. [Known Issues](#known-issues)
1. [Contribute](#CONTRIBUTING.md)


## <a name="overview"></a>Overview

**External Database Service**

You can manage and monitor Oracle Databases that are located outside of Oracle Cloud Infrastructure (OCI) using OCI's External Database service. External Database allows you use cloud-based tools such as Database Management with your external databases. External Database can be used with both single-instance Oracle Databases and Oracle RAC instances.

Associated Services Available for External Databases:
External databases can utilize services including Database Management, Operations Insights, and Application Performance Monitoring for analysis, management, and application monitoring.

See Managing Associated Services for External Databases for instructions on enabling and disabling these services for an external database.

**Database Management Service**
As a database administrator, you can use the Oracle Cloud Infrastructure Database Management service to monitor and manage your Oracle Databases. Database Management supports Oracle Database versions 11.2.0.4 and later. Using Database Management you can:

* Monitor the key performance and configuration metrics of your fleet of Oracle Databases. You can also compare and analyze database metrics over a selected period of time.
* Group your critical Oracle Databases, which reside across compartments into a Database Group, and monitor them.
* Create SQL jobs to perform administrative operations on a single Oracle Database or a Database Group.
* Use Performance Hub to monitor database performance and diagnose performance issues such as determining the causes of wait time, performance degradation, and changes in database performance. For detailed information, see Using Performance Hub to Analyze Database Performance.
For complete documentation on the Database Management service, see Database Management.
 
**Operations Insights Service**
Operations Insights provides 360-degree insight into the resource utilization and capacity of databases and hosts. You can easily analyze CPU and storage resources, forecast capacity issues, and proactively identify SQL performance issues across your database fleet. See the Operations Insights documentation for complete details. Operations Insights can be enabled for external pluggable database and non-container database resources.

For details, see [_External Database Service Documentation_](https://docs.oracle.com/en-us/iaas/Content/Database/Concepts/externaloverview.htm).

## <a name="deliverables"></a>Deliverables
 This repository encloses one deliverable:

- A reference implementation written in Terraform HCL (Hashicorp Language) that provisions fully functional resources in an OCI tenancy.

## <a name="instructions"></a>Executing Instructions

## Prerequisites

- Required IAM Policy for Management Agent Communication

The Oracle Cloud Infrastructure (OCI) Management Agent is required to create a connection with an External Database. It is also required to enable the communication and data collection between an External Database and other OCI services such as Database Management, Operations Insights, and the Monitoring service.

A Management Agent permission is required to allow a user in a particular user group to manage the management-agents resource-type in a specific compartment:

```
ALLOW GROUP <group_name> TO MANAGE management-agents IN COMPARTMENT <compartment_name>

```

You must create a dynamic group for all the management agents to be used by the External Database. This is required to allow the External Database to interact with the OCI service endpoints. A dynamic group is created using the IAM service from the OCI Console. See the following topics for information about dynamic groups and how to create them.

- Example: Create a dynamic group named Management_Agent_Dynamic_Group with the following under Rule 1:

```
ALL {resource.type='managementagent', resource.compartment.id='ocid1.compartment.oc1.examplecompartmentid'}

```
Once the dynamic group is created, you must create policies to allow the management agents to interact with the Management Agent service and to allow the management agents to upload data to OCI Monitoring service.

For example, the following commands allow Management_Agent_Dynamic_Group dynamic group to interact with the Management Agent service in Agents_Compartment compartment, and upload data to the Monitoring service.

```
ALLOW DYNAMIC-GROUP Management_Agent_Dynamic_Group TO MANAGE management-agents IN COMPARTMENT Agents_Compartment
ALLOW DYNAMIC-GROUP Management_Agent_Dynamic_Group TO USE METRICS IN COMPARTMENT Agents_Compartment
```

Note that you may need to add similar policies if your service expects the management agent to deposit data to different services. For more information on service-specific requirements, see service-specific documentation.

- Install Management Agents

After completing the prerequistes as described, follow these steps to install the management agents.
* [_Download the Agent Software_](https://docs.oracle.com/en-us/iaas/management-agents/doc/install-management-agent-chapter.html#GUID-536CA5A4-7FF9-4CA1-996D-37B1A9F499BF)
* [_Create Install Key_](https://docs.oracle.com/en-us/iaas/management-agents/doc/management-agents-administration-tasks.html#GUID-C841426A-2C32-4630-97B6-DF11F05D5712)
* [_Configure a Response File_](https://docs.oracle.com/en-us/iaas/management-agents/doc/install-management-agent-chapter.html#GUID-5D20D4A7-616C-49EC-A994-DA383D172486)
* [_Install Management Agent_](https://docs.oracle.com/en-us/iaas/management-agents/doc/install-management-agent-chapter.html#GUID-8C7C4C54-016A-497F-AEB8-F5ABA139D223)
* [_Verify the Management Agent Installation_](https://docs.oracle.com/en-us/iaas/management-agents/doc/install-management-agent-chapter.html#GUID-46BE5661-012E-4557-B679-6456DBBEAA4A)
* [_Troubleshoot Management Agent Installation Issues_](https://docs.oracle.com/en-us/iaas/management-agents/doc/install-management-agent-chapter.html#GUID-48E6657B-B74B-414C-947E-ADD75503589B)


# <a name="Deploy-Using-the-Terraform-CLI"></a>Deploy Using the Terraform CLI

## Clone the Module
Now, you'll want a local copy of this repo. You can make that with the commands:

    git clone https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation.git
    cd terraform-oci-oracle-cloud-foundation/cloud-foundation/solutions/oci_external_databases_example
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

* **modules(folder)** -  Contains folders contains the module for creating and using external databases inside OCI and has also the ability for: Enabling Database Management External Container Database and for External Pluggable Database Details and also Enabling Operation Insights for External Pluggable Database
* **CONTRIBUTING.md** - Contributing guidelines, also called Contribution guidelines, the CONTRIBUTING.md file, or software contribution guidelines, is a text file which project managers include in free and open-source software packages or other open media packages for the purpose of describing how others may contribute user-generated content to the project.The file explains how anyone can engage in activities such as formatting code for submission or submitting patches
* **LICENSE** - The Universal Permissive License (UPL), Version 1.0 
* **local.tf** - Local values can be helpful to avoid repeating the same values or expressions multiple times in a configuration, but if overused they can also make a configuration hard to read by future maintainers by hiding the actual values used.Here is the place where all the resources are defined and here is the place where you need to populate all the neccesary informations.
* **main.tf** - Main Terraform script used for instantiating the Oracle Cloud Infrastructure provider and all subsystems modules
* **outputs.tf** - Defines project's outputs that you will see after the code runs successfuly
* **provider.tf** - The terraform provider that will be used (OCI)
* **README.md** - This file
* **variables.tf** - Project's global variables


Secondly, populate the `local.tf` file with the disared configuration following the information:


# External Database Service example code for one external container with 10 external pluggable dbs.

* Parameters for __register_external_container_db__:
    * __container1__ - the key-value of the container. This will be the first index.
      * __compartment_id__ - the ocid of your compartment.
      * __external_container_display_name__ - the display name of the container

* Parameters for __register_external_pluggable_db__:
    * __pdb1__ - the key-value of the external pluggable databases. This will be the first index.
      * __compartment_id__ - the ocid of your compartment.
      * __external_container_name__ - In what container this external database will be example: container 1 - the one that we have already created in the register_external_container_db resource.
      * __external_pluggable_database_display_name__ - the display name of the first pluggable database.

* Parameters for __connector_external_container_db__:
    * __container1__ - the key-value of the first connector that will register your first external container db.
      * __external_container_name__ - The name of the already created container. Example: "container1"
      * __oci_database_connector_agent_id__ - (Required) The ID of the agent used for the external database connector. Example: "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      * __external_database_connector_display_name__ = (Required) (Updatable) The user-friendly name for the external database connector. The name does not have to be unique. Example: "container1"
      * __external_database_connector_connection_credentials_credential_type__ - The type of credential used to connect to the database. Example: "DETAILS"
      * __external_database_connector_connection_credentials_credential_name__ - (Required) (Updatable) The name of the credential information that used to connect to the database. The name should be in "x.y" format, where the length of "x" has a maximum of 64 characters, and length of "y" has a maximum of 199 characters. The name strings can contain letters, numbers and the underscore character only. Other characters are not valid, except for the "." character that separates the "x" and "y" portions of the name. IMPORTANT - The name must be unique within the Oracle Cloud Infrastructure region the credential is being created in. If you specify a name that duplicates the name of another credential within the same Oracle Cloud Infrastructure region, you may overwrite or corrupt the credential that is already using the name. Example: "dbname1212.123456789"
      * __external_database_connector_connection_credentials_password__ - (Required) The password that will be used to connect to the database. Example: "your_password_here"
      * __external_database_connector_connection_credentials_role__ - (Required) The role of the user that will be connecting to the database. Example: "NORMAL"
      * __external_database_connector_connection_credentials_username__ - (Required) The username that will be used to connect to the database. Example: "username"
      * __external_database_connector_connection_string_hostname__ - (Required) (Updatable) The host name of the database. Example: "10.1.1.1"
      * __external_database_connector_connection_string_port__ - (Required) (Updatable) The port used to connect to the database. Example: "1521"
      * __external_database_connector_connection_string_protocol__ - (Required) (Updatable) The protocol used to connect to the database. Example: "TCP"
      * __external_database_connector_connection_string_service__ - Required) (Updatable) The name of the service alias used to connect to the database. Example: "service"
      * __external_database_connector_connector_type__ - The type of connector used by the external database resources. Currently only the MACS type is supported. Example: "MACS"
      * __enable_database_management_for_external_containers_database__ - (Required) (Updatable) Enabling Database Management on External Container Databases . Requires boolean value "true" or "false". Example: true
      * __license_model__ - The Oracle license model that applies to the external database. Required only for enabling database management. Example: "BRING_YOUR_OWN_LICENSE"

* Parameters for __connector_external_pluggable_db__:
    * __pdb1__ - the key-value of the first connector that will register your first external pluggable db.
      * __external_pluggable_name__ - The name of the already created external pluggable db. Example: "pdb1"
      * __external_container_name__ - The name of the already created container. Example: "container1"
      * __oci_database_connector_agent_id__ - (Required) The ID of the agent used for the external database connector. Example: "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      * __external_database_connector_display_name__ = (Required) (Updatable) The user-friendly name for the external database connector. The name does not have to be unique. Example: "connection1_pluggable_db"
      * __external_database_connector_connection_credentials_credential_type__ - The type of credential used to connect to the database. Example: "DETAILS"
      * __external_database_connector_connection_credentials_credential_name__ - (Required) (Updatable) The name of the credential information that used to connect to the database. The name should be in "x.y" format, where the length of "x" has a maximum of 64 characters, and length of "y" has a maximum of 199 characters. The name strings can contain letters, numbers and the underscore character only. Other characters are not valid, except for the "." character that separates the "x" and "y" portions of the name. IMPORTANT - The name must be unique within the Oracle Cloud Infrastructure region the credential is being created in. If you specify a name that duplicates the name of another credential within the same Oracle Cloud Infrastructure region, you may overwrite or corrupt the credential that is already using the name. Example: "dbname1212.123456789"
      * __external_database_connector_connection_credentials_password__ - (Required) The password that will be used to connect to the database. Example: "your_password_here"
      * __external_database_connector_connection_credentials_role__ - (Required) The role of the user that will be connecting to the database. Example: "NORMAL"
      * __external_database_connector_connection_credentials_username__ - (Required) The username that will be used to connect to the database. Example: "username"
      * __external_database_connector_connection_string_hostname__ - (Required) (Updatable) The host name of the database. Example: "10.1.1.1"
      * __external_database_connector_connection_string_port__ - (Required) (Updatable) The port used to connect to the database. Example: "1521"
      * __external_database_connector_connection_string_protocol__ - (Required) (Updatable) The protocol used to connect to the database. Example: "TCP"
      * __external_database_connector_connection_string_service__ - Required) (Updatable) The name of the service alias used to connect to the database. Example: "service"
      * __external_database_connector_connector_type__ - The type of connector used by the external database resources. Currently only the MACS type is supported. Example: "MACS"
      * __enable_database_management_for_external_pluggable_database__ - (Required) (Updatable) Enabling Database Management on External Pluggable Databases . Requires boolean value "true" or "false". Example: true
      * __enable_operations_insights_management_for_external_pluggable_database__ - (Required) (Updatable) Enabling OPSI on External Pluggable Databases . Requires boolean value "true" or "false". Example: true


Below is an example:
```
  register_external_container_db = {
    container1 = {
      compartment_id                           = var.compartment_id,
      external_container_display_name          = "container1"
    },
  }

  register_external_pluggable_db = {
    pdb1 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb1"
    },
    pdb2 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb2"
    },
    pdb3 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb3"
    },
    pdb4 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb4"
    },
    pdb5 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb5"
    },
    pdb6 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb6"
    },
    pdb7 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb7"
    },
    pdb8 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb8"
    },
    pdb9 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb9"
    },
    pdb10 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb10"
    },
  }


# Container Databases:

  connector_external_container_db = {
    container1 = {
      external_container_name = "container1"
      oci_database_connector_agent_id = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name = "container1"
      external_database_connector_connection_credentials_credential_type = "DETAILS"
      external_database_connector_connection_credentials_credential_name = "dbname1212.123456789"
      external_database_connector_connection_credentials_password = "password_here"
      external_database_connector_connection_credentials_role = "NORMAL"
      external_database_connector_connection_credentials_username = "username"
      external_database_connector_connection_string_hostname = "ip_address"
      external_database_connector_connection_string_port = 1521
      external_database_connector_connection_string_protocol = "TCP"
      external_database_connector_connection_string_service = "service"
      external_database_connector_connector_type = "MACS"
      enable_database_management_for_external_containers_database = true
      license_model = "BRING_YOUR_OWN_LICENSE"
   }
  }


# Pluggable Databases

connector_external_pluggable_db = {
    pdb1 = {
      external_pluggable_name                                               = "pdb1"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection1_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname1212.12345678912"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }
    pdb2 = {
      external_pluggable_name                                               = "pdb2"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection2_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname2121.123456789113"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }

    pdb3 = {
      external_pluggable_name                                               = "pdb3"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection3_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname2212.123456789114"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }

    pdb4 = {
      external_pluggable_name                                               = "pdb4"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection4_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname2213.123456789115"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }

    pdb5 = {
      external_pluggable_name                                               = "pdb5"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection5_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname2214.123456789116"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }

    pdb6 = {
      external_pluggable_name                                               = "pdb6"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection6_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname2215.123456789117"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }


    pdb7 = {
      external_pluggable_name                                               = "pdb7"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection7_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname2216.123456789118"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }

    pdb8 = {
      external_pluggable_name                                               = "pdb8"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection8_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname2217.123456789119"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }


    pdb9 = {
      external_pluggable_name                                               = "pdb9"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection9_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname2218.1234567891110"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }


    pdb10 = {
      external_pluggable_name                                               = "pdb10"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection10_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname2219.1234567891111"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }

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

## <a name="documentation"></a>Documentation

[External Database Service Overview](https://docs.oracle.com/en-us/iaas/Content/Database/Concepts/externaloverview.htm)

[Database Management Overview](https://docs.oracle.com/en-us/iaas/database-management/index.html)

[Operations Insights Overview](https://docs.oracle.com/en-us/iaas/operations-insights/index.html)

[Management Agent Overview](https://docs.oracle.com/en-us/iaas/management-agents/doc/you-begin.html)

[Terraform oci_database_external_container_database Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_external_container_database)

[Terraform oci_database_external_pluggable_database Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_external_pluggable_database)

[Terraform oci_database_external_database_connector Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_external_database_connector)

[Terraform oci_database_external_container_database_management Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_external_container_database_management)

[Terraform oci_database_external_pluggable_database_management Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_external_pluggable_database_management)

[Terraform oci_database_external_pluggable_database_operations_insights_management Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_external_pluggable_database_operations_insights_management)


## <a name="team"></a>The Team
- **Owners**: [Panaitescu Ionel](https://github.com/ionelpanaitescu)

## <a name="feedback"></a>Feedback
We welcome your feedback. To post feedback, submit feature ideas or report bugs, please use the Issues section on this repository.	

## <a name="known-issues"></a>Known Issues
**At the moment, there are no known issues**