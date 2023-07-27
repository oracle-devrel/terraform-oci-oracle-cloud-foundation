# Oracle Cloud Foundation Terraform Solution - Deploy Exadata Database Service with in region Data Guard

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
n the event of a disaster, your Oracle Exadata Database Service on Dedicated Infrastructure primary database could become unavailable. A standby database is a copy of the production database that becomes available in the event of a production database outage. Configuring Oracle Data Guard for your primary database automatically creates a standby database. For the highest availability, we recommend configuring primary and standby databases in different OCI regions. Configuring the primary and standby databases in the same OCI region is also supported.

Oracle Data Guard ensures high availability, data protection, and disaster recovery for enterprise data in an Oracle Database. Oracle Data Guard provides a comprehensive set of services that create, maintain, manage, and monitor one or more standby databases to enable production Oracle databases to survive disasters and data corruptions. Oracle Data Guard maintains these standby databases as copies of the primary production database. If the primary database becomes unavailable because of a planned or an unplanned outage, Oracle Data Guard can switch any standby database to primary, minimizing the downtime associated with the outage.


## <a name="deliverables"></a>Deliverables
 This repository encloses one deliverable:

- A reference implementation written in Terraform HCL (oracle Language) that provisions fully functional resources in an OCI tenancy.


## <a name="architecture"></a>Architecture-Diagram

**Physical Architecture:**

Your Oracle Exadata Database Service on Dedicated Infrastructure databases can be located within the same region.

The following diagram illustrates this architecture.

![](https://docs.oracle.com/en/solutions/dataguard-exadata-dedicated-infrastructure/img/exadata-dedicated-region-dataguard.png)

When configuring Oracle Data Guard, we recommend configuring your Oracle Exadata Database Service on Dedicated Infrastructure primary and standby databases accordingly to ensure maximum availability:

- Maximum availability: Primary and standby databases in different OCI regions.
- Higher availability: Primary and standby databases in the same region, but different availability domains.
- High availability: Primary and standby databases in the same region and availability domain.

For details of the architecture, see [_Configure Data Guard for Oracle Exadata Database Service on Dedicated Infrastructure_](https://docs.oracle.com/en/solutions/dataguard-exadata-dedicated-infrastructure/)


## <a name="instructions"></a>Executing Instructions

## Prerequisites

- Permission to `manage` the following types of resources in your Oracle Cloud Infrastructure tenancy: `vcns`, `nat-gateways`, `route-tables`, `subnets`, `service-gateways`, `security-lists`, `remote peering`, `exadata infrastructure`, `cloud vm cluster`, `database db homes`, `data guard association` and `compute instances`.
- Quota to create the following resources in region: 1 exadata infrastructure, 1 vm cluster in the exadata infrastructure, database db home and the db in region and at the end the data guard association between ADs.
If you don't have the required permissions and quota, contact your tenancy administrator. See [Policy Reference](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm), [Service Limits](https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm), [Compartment Quotas](https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcequotas.htm).


# <a name="Deploy-Using-the-Terraform-CLI"></a>Deploy Using the Terraform CLI

## Clone the Module
Now, you'll want a local copy of this repo. You can make that with the commands:

    git clone https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation.git
    cd terraform-oci-oracle-cloud-foundation/cloud-foundation/solutions/Deploy-Exadata-Database-Service-with-in-region-Data-Guard
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
- Compartment ID

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
    default = "" (the region used for deploying the infrastructure - ex: us-sanjose-1)
}

variable "compartment_id" {
  type = string
  default = "" (the compartment OCID used for deploying the solution - ex: ocid1.compartment.oc1..aaaaaa...)
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
* **local.tf** - Local values can be helpful to avoid repeating the same values or expressions multiple times in a configuration, but if overused they can also make a configuration hard to read by future maintainers by hiding the actual values used. Here is the place where all the resources are defined.
* **main.tf** - Main Terraform script used for instantiating the Oracle Cloud Infrastructure provider and all subsystems modules
* **outputs.tf** - Defines project's outputs that you will see after the code runs successfuly
* **provider.tf** - The terraform provider that will be used (OCI)
* **README.md** - This file
* **variables.tf** - Project's global variables


Secondly, populate the `terraform.tf` file with the disared configuration following the information:


# KeyGen
Generates a secure private key and encodes it as PEM. This resource is primarily intended for easily bootstrapping throwaway development environments.

In the main.tf file we are calling the keygen module that will create one public and one private key. 
This keys are neccesary, as the public key will be generated and injected in the instance, and the private key will be generated. In our case we are creating 1 VM as Bastion Server.
Both can be found in the solution folder if you want to use them after the deployment it's done.

Below is an example:
```
module "keygen" {
  source = "./modules/cloud-foundation-library/keygen"
  display_name = "keygen"
  subnet_domain_name = "keygen"
}
```


# Networking
This resource provides the Vcn resource in Oracle Cloud Infrastructure Core service anso This resource provides the Subnet resource in Oracle Cloud Infrastructure Core service.
The solution will create in the Region: 1 VCN in your compartment, 3 subnets ( public-subnet, private-subnet and backup-subnet ), route tables for incomming and outoing traffic, 1 internet gateway, dhcp service, NAT Gateway, Service Gateway, security lists.

* Parameters:
    * __vcn_cidr__ - The list of one or more IPv4 CIDR blocks for the VCN that meet the following criteria:
        The CIDR blocks must be valid.  
        They must not overlap with each other or with the on-premises network CIDR block.
        The number of CIDR blocks must not exceed the limit of CIDR blocks allowed per VCN. It is an error to set both cidrBlock and cidrBlocks. Note: cidr_blocks update must be restricted to one operation at a time (either add/remove or modify one single cidr_block) or the operation will be declined.
    * __public_subnet_cidr__ - The CIDR IP address range of the subnet. The CIDR must maintain the following rules - a. The CIDR block is valid and correctly formatted. b. The new range is within one of the parent VCN ranges. This is the cidr for the public subnet.
    * __private_subnet_cidr__ - The CIDR IP address range of the subnet. The CIDR must maintain the following rules - a. The CIDR block is valid and correctly formatted. b. The new range is within one of the parent VCN ranges. This is the cidr for the private subnet.
    * __backup_subnet_cidr__ - The CIDR IP address range of the subnet. The CIDR must maintain the following rules - a. The CIDR block is valid and correctly formatted. b. The new range is within one of the parent VCN ranges. This is the cidr for the private subnet.


Below is an example:
```
# VCN and subnet Variables

variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "backup_subnet_cidr" {
  default = "10.0.2.0/24"
}
```


# Compute VM - Bastion
The compute module will create one VM with the purpose of a Bastion. The Bastion it's deployed in the public subnet.
For the Bastion VM we are using the Oracle-Linux-Cloud-Developer-8.5-2022.05.22-0 image as it comes with all the neccesary software installed.
More information about this image and about the OCIDs required to be provided as a variable can be found here:
https://docs.oracle.com/en-us/iaas/images/image/2e439f8e-e98f-489b-82a3-338360b46b82/

More information regarding shapes can be found here:
https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm


* Parameters for the VM Bastion Compute Configuration
    * __bastion_instance_display_name__ - (Required) (Updatable) - Required. The hostname/dns name for the Bastion VM.
    * __bastion_instance_shape__ - (Required) (Updatable) The shape of an instance. The shape determines the number of CPUs, amount of memory, and other resources allocated to the instance.


Below is an example:
```
variable "bastion_instance_display_name" {
  type    = string
  default = "VNC-Bastion"
}

variable "bastion_instance_shape" {
    type    = string
    default  = "VM.Standard2.4"
}
```


# First AD Variables for Exadata Infrastructure, Cloud VM Cluster and DB Home


* __Exadata Infrastructure__

This resource provides the Cloud Exadata Infrastructure resource in Oracle Cloud Infrastructure Database service.
Creates a cloud Exadata infrastructure resource. This resource is used to create either an Exadata Cloud Service instance or an Autonomous Database on dedicated Exadata infrastructure.

* Parameters:
    * __exadata_infrastructure_first_availability_domain__ - (Required) The availability domain where the cloud Exadata infrastructure is located.
    * __exadata_infrastructure_firstAD_display_name__ - (Required) (Updatable) The user-friendly name for the cloud Exadata infrastructure resource. The name does not need to be unique.
    * __exadata_infrastructure_firstAD_shape__ - (Required) The shape of the cloud Exadata infrastructure resource.
    * __exadata_infrastructure_firstAD_email__ - (Updatable) The email address used by Oracle to send notifications regarding databases and infrastructure.
    * __exadata_infrastructure_firstAD_preference__ - The maintenance window scheduling preference.


Below is an example:
```
# #############  First AD
# # Create Exadata Infrastrucutre in First AD

variable "exadata_infrastructure_first_availability_domain" {
  type    = number
  default = 1
}

variable "exadata_infrastructure_firstAD_display_name" {
  type    = string
  default = "exacs-firstAD"
}

variable "exadata_infrastructure_firstAD_shape" {
  type    = string
  default = "Exadata.Quarter3.100"
}

variable "exadata_infrastructure_firstAD_email" {
  type    = string
  default = "name@provider.us"
}

variable "exadata_infrastructure_firstAD_preference" {
  type    = string
  default = "NO_PREFERENCE"
}
```

* __Cloud VM Cluster in First AD__

This resource provides the Cloud Vm Cluster resource in Oracle Cloud Infrastructure Database service.
Creates a cloud VM cluster.

* Parameters:
    * __cloud_vm_cluster_firstAD_cpu_core_count__ - (Required) (Updatable) The number of CPU cores to enable for a cloud VM cluster. Valid values depend on the specified shape:
      - Exadata.Base.48 - Specify a multiple of 2, from 0 to 48.
      - Exadata.Quarter1.84 - Specify a multiple of 2, from 22 to 84.
      - Exadata.Half1.168 - Specify a multiple of 4, from 44 to 168.
      - Exadata.Full1.336 - Specify a multiple of 8, from 88 to 336.
      - Exadata.Quarter2.92 - Specify a multiple of 2, from 0 to 92.
      - Exadata.Half2.184 - Specify a multiple of 4, from 0 to 184.
      - Exadata.Full2.368 - Specify a multiple of 8, from 0 to 368.
    * __cloud_vm_cluster_firstAD_display_name__ - (Required) (Updatable) The user-friendly name for the cloud VM cluster. The name does not need to be unique.
    * __cloud_vm_cluster_firstAD_gi_version__ - (Required) A valid Oracle Grid Infrastructure (GI) software version.
    * __cloud_vm_cluster_firstAD_hostname__ - (Required) The hostname for the cloud VM cluster. The hostname must begin with an alphabetic character, and can contain alphanumeric characters and hyphens (-). The maximum length of the hostname is 16 characters for bare metal and virtual machine DB systems, and 12 characters for Exadata systems. The maximum length of the combined hostname and domain is 63 characters. Note: The hostname must be unique within the subnet. If it is not unique, the cloud VM Cluster will fail to provision.
    * __cloud_vm_cluster_firstAD_cluster_name__ - The cluster name for cloud VM cluster. The cluster name must begin with an alphabetic character, and may contain hyphens (-). Underscores (_) are not permitted. The cluster name can be no longer than 11 characters and is not case sensitive.
    * __cloud_vm_cluster_firstAD_data_storage_percentage__ - The percentage assigned to DATA storage (user data and database files). The remaining percentage is assigned to RECO storage (database redo logs, archive logs, and recovery manager backups). Accepted values are 35, 40, 60 and 80. The default is 80 percent assigned to DATA storage. See Storage Configuration in the Exadata documentation for details on the impact of the configuration settings on storage.
    * __cloud_vm_cluster_firstAD_is_local_backup_enabled__ - If true, database backup on local Exadata storage is configured for the cloud VM cluster. If false, database backup on local Exadata storage is not available in the cloud VM cluster.
    * __cloud_vm_cluster_firstAD_is_sparse_diskgroup_enabled__ -  If true, the sparse disk group is configured for the cloud VM cluster. If false, the sparse disk group is not created.
    * __cloud_vm_cluster_firstAD_license_model__ -  (Updatable) The Oracle license model that applies to the cloud VM cluster. The default is BRING_YOUR_OWN_LICENSE.
    * __cloud_vm_cluster_firstAD_scan_listener_port_tcp__ - The TCP Single Client Access Name (SCAN) port. The default port is 1521.
    * __cloud_vm_cluster_firstAD_scan_listener_port_tcp_ssl__ - The TCPS Single Client Access Name (SCAN) port. The default port is 2484.
    * __cloud_vm_cluster_firstAD_time_zone__ - The time zone to use for the cloud VM cluster. For details, see [Time Zones](https://docs.cloud.oracle.com/iaas/Content/Database/References/timezones.htm).


Below is an example:
```
# # Create Cloud VM Cluster in First AD

variable "cloud_vm_cluster_firstAD_cpu_core_count" {
  type    = number
  default = 4
}

variable "cloud_vm_cluster_firstAD_display_name" {
  type    = string
  default = "exacs-firstad-vm"
}

variable "cloud_vm_cluster_firstAD_gi_version" {
  type    = string
  default = "19.0.0.0"
}

variable "cloud_vm_cluster_firstAD_hostname" {
  type    = string
  default = "exacs-firstad-vm"
}

variable "cloud_vm_cluster_firstAD_cluster_name" {
  type    = string
  default = "cl-exa1"
}

variable "cloud_vm_cluster_firstAD_data_storage_percentage" {
  type    = number
  default = 60
}

variable "cloud_vm_cluster_firstAD_is_local_backup_enabled" {
  type    = string
  default = "false"
}

variable "cloud_vm_cluster_firstAD_is_sparse_diskgroup_enabled" {
  type    = string
  default = "true"
}

variable "cloud_vm_cluster_firstAD_license_model" {
  type    = string
  default = "BRING_YOUR_OWN_LICENSE"
}

variable "cloud_vm_cluster_firstAD_scan_listener_port_tcp" {
  type    = number
  default = 1521
}

variable "cloud_vm_cluster_firstAD_scan_listener_port_tcp_ssl" {
  type    = number
  default = 2484
}

variable "cloud_vm_cluster_firstAD_time_zone" {
  type    = string
  default = "UTC"
}
```

* __DB Home and Database in First AD__

This resource provides the Db Home resource in Oracle Cloud Infrastructure Database service.
Creates a new Database Home in the specified database system based on the request parameters you provide. Applies only to bare metal and Exadata systems.

* Parameters:
    * __database_db_home_firstAD_admin_password__ - (Required) A strong password for SYS, SYSTEM, PDB Admin and TDE Wallet. The password must be at least nine characters and contain at least two uppercase, two lowercase, two numbers, and two special characters. The special characters must be _, #, or -.
    * __database_db_home_firstAD_db_version__ -  A valid Oracle Database version. To get a list of supported versions, use the [ListDbVersions](https://docs.cloud.oracle.com/iaas/api/#/en/database/latest/DbVersionSummary/ListDbVersions) operation. This cannot be updated in parallel with any of the following: licenseModel, dbEdition, cpuCoreCount, computeCount, computeModel, adminPassword, whitelistedIps, isMTLSConnectionRequired, openMode, permissionLevel, dbWorkload, privateEndpointLabel, nsgIds, isRefreshable, dbName, scheduledOperations, dbToolsDetails, isLocalDataGuardEnabled, or isFreeTier.
    * __database_db_home_firstAD_display_name__ - The user-provided name of the Database Home.
    * __database_db_home_firstAD_db_name__ - The display name of the database to be created from the backup. It must begin with an alphabetic character and can contain a maximum of eight alphanumeric characters. Special characters are not permitted.
    * __database_db_home_firstAD_source__ - The source of database: NONE for creating a new database. DB_BACKUP for creating a new database by restoring from a database backup. VM_CLUSTER_NEW for creating a database for VM Cluster.


Below is an example:
```
# # Create the DB Home and database in First AD

variable "database_db_home_firstAD_admin_password" {
  type    = string
  default = "PAr0lamea-#1"
}

variable "database_db_home_firstAD_db_version" {
  type    = string
  default = "19.0.0.0"
}

variable "database_db_home_firstAD_display_name" {
  type    = string
  default = "dbhome-dbsj"
}

variable "database_db_home_firstAD_db_name" {
  type    = string
  default = "dbsj"
}

variable "database_db_home_firstAD_source" {
  type    = string
  default = "VM_CLUSTER_NEW"
}
```


# Second AD Variables for Exadata Infrastructure and Cloud VM Cluster. No DB Home and Database will be deployed in the second AD, as the data guard association will create them after.


* __Exadata Infrastructure__

This resource provides the Cloud Exadata Infrastructure resource in Oracle Cloud Infrastructure Database service.
Creates a cloud Exadata infrastructure resource. This resource is used to create either an Exadata Cloud Service instance or an Autonomous Database on dedicated Exadata infrastructure.

* Parameters:
    * __exadata_infrastructure_second_availability_domain__ - (Required) The availability domain where the cloud Exadata infrastructure is located.
    * __exadata_infrastructure_secondAD_display_name__ - (Required) (Updatable) The user-friendly name for the cloud Exadata infrastructure resource. The name does not need to be unique.
    * __exadata_infrastructure_secondAD_shape__ - (Required) The shape of the cloud Exadata infrastructure resource.
    * __exadata_infrastructure_secondAD_email__ - (Updatable) The email address used by Oracle to send notifications regarding databases and infrastructure.
    * __exadata_infrastructure_secondAD_preference__ - The maintenance window scheduling preference.


Below is an example:
```
# Create Exadata Infrastrucutre in Second AD

variable "exadata_infrastructure_second_availability_domain" {
  type    = number
  default = 2
}

variable "exadata_infrastructure_secondAD_display_name" {
  type    = string
  default = "exacs-secondAD"
}

variable "exadata_infrastructure_secondAD_shape" {
  type    = string
  default = "Exadata.Quarter3.100"
}

variable "exadata_infrastructure_secondAD_email" {
  type    = string
  default = "name@provider.us"
}

variable "exadata_infrastructure_secondAD_preference" {
  type    = string
  default = "NO_PREFERENCE"
}
```

* __Cloud VM Cluster in Second AD__

This resource provides the Cloud Vm Cluster resource in Oracle Cloud Infrastructure Database service.
Creates a cloud VM cluster.

* Parameters:
    * __cloud_vm_cluster_secondAD_cpu_core_count__ - (Required) (Updatable) The number of CPU cores to enable for a cloud VM cluster. Valid values depend on the specified shape:
      - Exadata.Base.48 - Specify a multiple of 2, from 0 to 48.
      - Exadata.Quarter1.84 - Specify a multiple of 2, from 22 to 84.
      - Exadata.Half1.168 - Specify a multiple of 4, from 44 to 168.
      - Exadata.Full1.336 - Specify a multiple of 8, from 88 to 336.
      - Exadata.Quarter2.92 - Specify a multiple of 2, from 0 to 92.
      - Exadata.Half2.184 - Specify a multiple of 4, from 0 to 184.
      - Exadata.Full2.368 - Specify a multiple of 8, from 0 to 368.
    * __cloud_vm_cluster_secondAD_display_name__ - (Required) (Updatable) The user-friendly name for the cloud VM cluster. The name does not need to be unique.
    * __cloud_vm_cluster_secondAD_gi_version__ - (Required) A valid Oracle Grid Infrastructure (GI) software version.
    * __cloud_vm_cluster_secondAD_hostname__ - (Required) The hostname for the cloud VM cluster. The hostname must begin with an alphabetic character, and can contain alphanumeric characters and hyphens (-). The maximum length of the hostname is 16 characters for bare metal and virtual machine DB systems, and 12 characters for Exadata systems. The maximum length of the combined hostname and domain is 63 characters. Note: The hostname must be unique within the subnet. If it is not unique, the cloud VM Cluster will fail to provision.
    * __cloud_vm_cluster_secondAD_cluster_name__ - The cluster name for cloud VM cluster. The cluster name must begin with an alphabetic character, and may contain hyphens (-). Underscores (_) are not permitted. The cluster name can be no longer than 11 characters and is not case sensitive.
    * __cloud_vm_cluster_secondAD_data_storage_percentage__ - The percentage assigned to DATA storage (user data and database files). The remaining percentage is assigned to RECO storage (database redo logs, archive logs, and recovery manager backups). Accepted values are 35, 40, 60 and 80. The default is 80 percent assigned to DATA storage. See Storage Configuration in the Exadata documentation for details on the impact of the configuration settings on storage.
    * __cloud_vm_cluster_secondAD_is_local_backup_enabled__ - If true, database backup on local Exadata storage is configured for the cloud VM cluster. If false, database backup on local Exadata storage is not available in the cloud VM cluster.
    * __cloud_vm_cluster_secondAD_is_sparse_diskgroup_enabled__ -  If true, the sparse disk group is configured for the cloud VM cluster. If false, the sparse disk group is not created.
    * __cloud_vm_cluster_secondAD_license_model__ -  (Updatable) The Oracle license model that applies to the cloud VM cluster. The default is BRING_YOUR_OWN_LICENSE.
    * __cloud_vm_cluster_secondAD_scan_listener_port_tcp__ - The TCP Single Client Access Name (SCAN) port. The default port is 1521.
    * __cloud_vm_cluster_secondAD_scan_listener_port_tcp_ssl__ - The TCPS Single Client Access Name (SCAN) port. The default port is 2484.
    * __cloud_vm_cluster_secondAD_time_zone__ - The time zone to use for the cloud VM cluster. For details, see [Time Zones](https://docs.cloud.oracle.com/iaas/Content/Database/References/timezones.htm).


Below is an example:
```
# # Create Cloud VM Cluster in Second AD

variable "cloud_vm_cluster_secondAD_cpu_core_count" {
  type    = number
  default = 4
}

variable "cloud_vm_cluster_secondAD_display_name" {
  type    = string
  default = "exacs-secondad-vm"
}

variable "cloud_vm_cluster_secondAD_gi_version" {
  type    = string
  default = "19.0.0.0"
}

variable "cloud_vm_cluster_secondAD_hostname" {
  type    = string
  default = "exacs-secondad-vm"
}

variable "cloud_vm_cluster_secondAD_cluster_name" {
  type    = string
  default = "cl-exa2"
}

variable "cloud_vm_cluster_secondAD_data_storage_percentage" {
  type    = number
  default = 60
}

variable "cloud_vm_cluster_secondAD_is_local_backup_enabled" {
  type    = string
  default = "false"
}

variable "cloud_vm_cluster_secondAD_is_sparse_diskgroup_enabled" {
  type    = string
  default = "true"
}

variable "cloud_vm_cluster_secondAD_license_model" {
  type    = string
  default = "BRING_YOUR_OWN_LICENSE"
}

variable "cloud_vm_cluster_secondAD_scan_listener_port_tcp" {
  type    = number
  default = 1521
}

variable "cloud_vm_cluster_secondAD_scan_listener_port_tcp_ssl" {
  type    = number
  default = 2484
}

variable "cloud_vm_cluster_secondAD_time_zone" {
  type    = string
  default = "UTC"
}
```


# Data Guard Association

This resource provides the Data Guard Association resource in Oracle Cloud Infrastructure Database service.

Creates a new Data Guard association. A Data Guard association represents the replication relationship between the specified database and a peer database. For more information, see [Using Oracle Data Guard](https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/usingdataguard.htm).

All Oracle Cloud Infrastructure resources, including Data Guard associations, get an Oracle-assigned, unique ID called an Oracle Cloud Identifier (OCID). When you create a resource, you can find its OCID in the response. You can also retrieve a resource's OCID by using a List API operation on that resource type, or by viewing the resource in the Console. For more information, see [Resource Identifiers](https://docs.cloud.oracle.com/iaas/Content/General/Concepts/identifiers.htm).

* Parameters:
    * __database_data_guard_association_creation_type__ - (Required) Specifies whether to create the peer database in an existing DB system or in a new DB system.
    * __database_data_guard_association_protection_mode__ - (Required) (Updatable) The protection mode to set up between the primary and standby databases. For more information, see [Oracle Data Guard Protection Modes](http://docs.oracle.com/database/122/SBYDB/oracle-data-guard-protection-modes.htm#SBYDB02000) in the Oracle Data Guard documentation.
    IMPORTANT - The only protection mode currently supported by the Database service is MAXIMUM_PERFORMANCE.
    * __database_data_guard_association_transport_type__ - (Required) (Updatable) The redo transport type to use for this Data Guard association. Valid values depend on the specified protectionMode:
      MAXIMUM_AVAILABILITY - SYNC or FASTSYNC
      MAXIMUM_PERFORMANCE - ASYNC
      MAXIMUM_PROTECTION - SYNC
    For more information, see [Redo Transport Services](http://docs.oracle.com/database/122/SBYDB/oracle-data-guard-redo-transport-services.htm#SBYDB00400) in the Oracle Data Guard documentation.
    IMPORTANT - The only transport type currently supported by the Database service is ASYNC.


Below is an example:
```
# Data Guard Association variables:

variable "database_data_guard_association_creation_type" {
  type    = string
  default = "ExistingVmCluster"
}

variable "database_data_guard_association_protection_mode" {
  type    = string
  default = "MAXIMUM_PERFORMANCE"
}

variable "database_data_guard_association_transport_type" {
  type    = string
  default = "ASYNC"
}
```


## Running the code

```
# Run init to get terraform modules
$ terraform init

# Create the infrastructure
$ terraform apply --auto-approve

# If you are done with this infrastructure, take it down.
$ terraform destroy --auto-approve
```


## <a name="documentation"></a>Documentation

[Certificates](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm)

[Network Overview](https://docs.cloud.oracle.com/iaas/Content/Network/Concepts/overview.htm)

[Compute service](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm)

[Oracle Exadata Database Service on Dedicated Infrastructure Overview](https://docs.oracle.com/en-us/iaas/exadatacloud/exacs/exadata-cloud-infrastructure-overview.html)

[Use Oracle Data Guard with Exadata Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/exadatacloud/exacs/using-data-guard-with-exacc.html)

[Terraform Certificates - TLS Provider](https://registry.terraform.io/providers/hashicorp/tls/latest/docs)

[Terraform Vcn resource in Oracle Cloud Infrastructure Core service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_vcn)

[Terraform Subnet resource in Oracle Cloud Infrastructure Core service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet)

[Terraform Oracle Cloud Infrastructure Core Service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance)

[Cloud Exadata Infrastructure resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_cloud_exadata_infrastructure)

[Cloud Vm Cluster resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_cloud_vm_cluster)

[Db Home resource in Oracle Cloud Infrastructure Database service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_db_home.html)

[Data Guard Association resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_data_guard_association)


## <a name="team"></a>The Team
- **Owners**: [Panaitescu Ionel](https://github.com/ionelpanaitescu) 

## <a name="feedback"></a>Feedback
We welcome your feedback. To post feedback, submit feature ideas or report bugs, please use the Issues section on this repository.	

## <a name="known-issues"></a>Known Issues
**At the moment, there are no known issues**