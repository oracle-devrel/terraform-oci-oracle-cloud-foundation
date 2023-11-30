# Oracle Cloud Foundation Terraform Solution - Informatica Secure Agent – create a ready to go development data platform on OCI

## Table of Contents
1. [Overview](#overview)
1. [Deliverables](#deliverables)
1. [Architecture](#Architecture-Diagram)
1. [Executing Instructions](#instructions)
    1. [Deploy Using Oracle Resource Manager](#Deploy-Using-Oracle-Resource-Manager)
    1. [Deploy Using the Terraform CLI](#Deploy-Using-the-Terraform-CLI)
1. [Documentation](#documentation)
1. [The Team](#team)
1. [Feedback](#feedback)
1. [Known Issues](#known-issues)
1. [Contribute](#CONTRIBUTING.md)


## <a name="overview"></a>Overview
The partnership between Oracle and Informatica brings together two industry-leaders in database and data management to deliver a comprehensive enterprise data warehouse and lakehouse ecosystem.

This reference architecture shows how the Informatica IDMC Secure Agent operates in Oracle Cloud Infrastructure (OCI). Data is exported from Oracle E-Business Suite and imported data into an Oracle Autonomous Database to be consumed by either analytics or data science processes.

Without this integration, we can access actionable information from our application data (in this instance Oracle E-Business Suite) but we cannot enrich this with other sources of data to unlock valuable insight. It is also not good practice to run analytical workloads on operational systems.

The integration provides an analytical platform where application data containing a record of interactions is combined with other sets of curated data in the management layer and is refined into actionable information and insight in the exploitation layer.


## <a name="deliverables"></a>Deliverables
 This repository encloses one deliverable:

- A reference implementation written in Terraform HCL (Hashicorp Language) that provisions fully functional resources in an OCI tenancy.


## <a name="architecture"></a>Architecture-Diagram
This reference architecture shows how the Informatica IDMC Secure Agent operates in Oracle Cloud Infrastructure (OCI). Data is exported from Oracle E-Business Suite and imported data into an Oracle Autonomous Database to be consumed by either analytics or data science processes.

The following diagram shows a mapping of the architecture above to services provided on Oracle Cloud Infrastructure using security best practices and at the end of the deployment you will have in your tenancy the related services.

![](./images/infa-no-bastion-adb.png)


For more options of deployment the Informatica IDMC please check the link: see [_Deploy an analytics platform for Informatica IDMC on Oracle Cloud_](https://docs.oracle.com/en/solutions/informatica-on-oci/).


## <a name="instructions"></a>Executing Instructions

## Prerequisites

- Permission to `manage` the following types of resources in your Oracle Cloud Infrastructure tenancy: `vcns`, `nat-gateways`, `route-tables`, `subnets`, `service-gateways`, `security-lists`, `autonomous database`, `Object Storage` and `compute instance`.
- Quota to create the following resources: 1 ADW database instance and 2 VM instance, 1 Object Storage
If you don't have the required permissions and quota, contact your tenancy administrator. See [Policy Reference](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm), [Service Limits](https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm), [Compartment Quotas](https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcequotas.htm).

# <a name="Deploy-Using-Oracle-Resource-Manager"></a>Deploy Using Oracle Resource Manager

1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation/releases/download/v1.0.0/Informatica-Secure-AgentCreate-a-ready-to-go-development-data-platform-on-OCI-RM.zip)


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
    cd terraform-oci-oracle-cloud-foundation/cloud-foundation/solutions/Informatica-Secure-AgentCreate-a-ready-to-go-development-data-platform-on-OCI
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
* **images(folder)** - Contains images to be used inside the README.md file
* **modules(folder)** - ( this folder will be pressent only for the Resource Manager zipped files) Contains folders with subsystems and modules for each section of the project: networking, autonomous database, analytics cloud, etc.
* **scripts(folder)** - this folder contains the necessary scripts that will run on the compute instance for the Secure Agent VM.
* **CONTRIBUTING.md** - Contributing guidelines, also called Contribution guidelines, the CONTRIBUTING.md file, or software contribution guidelines, is a text file which project managers include in free and open-source software packages or other open media packages for the purpose of describing how others may contribute user-generated content to the project.The file explains how anyone can engage in activities such as formatting code for submission or submitting patches
* **LICENSE** - The Universal Permissive License (UPL), Version 1.0 
* **local.tf** - Local values can be helpful to avoid repeating the same values or expressions multiple times in a configuration, but if overused they can also make a configuration hard to read by future maintainers by hiding the actual values used.Here is the place where all the resources are defined.
* **main.tf** - Main Terraform script used for instantiating the Oracle Cloud Infrastructure provider and all subsystems modules
* **outputs.tf** - Defines project's outputs that you will see after the code runs successfuly
* **provider.tf** - The terraform provider that will be used (OCI)
* **README.md** - This file
* **subscription.tf** - Get Image Agreement, Accept Terms and Subscribe to the image, placing the image in a particular compartment, Gets the partner image subscription
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

Below is an example:

```
variable "db_name" {
  type    = string
  default = "ADWSecureAgentOCI"
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
  default = 4
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
```

# Object Storage
This resource provides the Bucket resource in Oracle Cloud Infrastructure Object Storage service.
Creates a bucket in the given namespace with a bucket name and optional user-defined metadata. Avoid entering confidential information in bucket names.

* Parameters:
    * __bucket_name__ - The name of the bucket. Valid characters are uppercase or lowercase letters, numbers, hyphens, underscores, and periods. Bucket names must be unique within an Object Storage namespace. Avoid entering confidential information. example: Example: my-new-bucket1
    * __bucket_access_type__ - The type of public access enabled on this bucket. A bucket is set to NoPublicAccess by default, which only allows an authenticated caller to access the bucket and its contents. When ObjectRead is enabled on the bucket, public access is allowed for the GetObject, HeadObject, and ListObjects operations. When ObjectReadWithoutList is enabled on the bucket, public access is allowed for the GetObject and HeadObject operations.
    * __bucket_storage_tier__ - The type of storage tier of this bucket. A bucket is set to 'Standard' tier by default, which means the bucket will be put in the standard storage tier. When 'Archive' tier type is set explicitly, the bucket is put in the Archive Storage tier. The 'storageTier' property is immutable after bucket is created.
    * __bucket_events_enabled__ - Whether or not events are emitted for object state changes in this bucket. By default, objectEventsEnabled is set to false. Set objectEventsEnabled to true to emit events for object state changes. For more information about events, see Overview of Events.
     

Below is an example:
```
variable "bucket_name" {
  type    = string
  default = "InformaticaSecureAgentOCI"
}

variable "bucket_access_type" {
    type    = string
    default  = "NoPublicAccess"
}

variable "bucket_storage_tier" {
    type    = string
    default = "Standard"
}
  
variable "bucket_events_enabled" {
    type    = bool
    default = false
}
```

# KeyGen
Generates a secure private key and encodes it as PEM. This resource is primarily intended for easily bootstrapping throwaway development environments.

In the main.tf file we are calling the keygen module that will create one public and one private key. 
This keys are neccesary, as the public key will be generated and injected in all the instances, and the private key will be generated.
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


# Compute Informatica Secure Agent VM 
The compute module will create the informatica VM's one VM.

* Parameters for the Infromatica Secure Agent VM Configuration
    * __informatica_instance_shape__ - (Required) (Updatable) The shape of an instance. The shape determines the number of CPUs, amount of memory, and other resources allocated to the instance.
    * __informatica_secure_agent_display_name__ - A user-friendly name. Does not have to be unique, and it's changeable. Avoid entering confidential information.
    * __iics_user__ - Required. The user name to access IDMC.
    * __iics_token__ - Required. Paste the Secure Agent install token that you get from the IDMC Administrator service. To get the install token, perform the following steps: 1. Log in to IDMC. 2. Select Administrator, and then click Runtime Environments. 3. Click Generate Install Token. 4. Click Copy to copy the install token string.
    * __iics_gn__ - Optional. Name of the Secure Agent group.If your account does not contain the group specified or if you do not specify a group name, the Secure Agent is assigned to an unnamed group.
    * __iics_provider__ - Required. The Cloud Provider where you have your IDMC account. Choose the cloud provider based on the user details registered in IDMC.
    * __iics_provider_enum__ - the available cloud providers for Informatica.
    * __mp_subscription_enabled__ - As the Informatica VM image it's a narketplace image you need to subscribe to it - as the default it's true.


# Infromatica Secure Agent VM Configuration

```
variable "informatica_instance_shape" {
  default = "VM.Standard2.4" # Example instance shape: VM.Standard2.4
}

variable "informatica_secure_agent_display_name" {
  default = "InformaticaVMOCI"
}

variable "iics_user" {
  description = "The user name to access Informatica Intelligent Data Management Cloud"
  default     = "" <enter your username here>
}

variable "iics_token" {
  description = "Paste the Secure Agent install token that you get from the IDMC Administrator service"
  default     = "" <enter your token here>
}

variable "iics_gn" {
  description = "Name of the Secure Agent group. If your account does not contain the group specified or if you do not specify a group name, the Secure Agent is assigned to an unnamed group"
  default     = "" <enter your group (optional)>
}

variable "iics_provider" {
  description = "The data center location for the deployment. Choose the data center location based on the user details registered in Informatica Intelligent Data Management Cloud"
  default = "Oracle Cloud Infrastructure"
    # default = "Amazon Web Services"
    # default = "Microsoft Azure"
    # default = "Google Cloud"
}

variable "iics_provider_enum" {
  type = map
  default = {
    OCI    = "Oracle Cloud Infrastructure"
    AWS    = "Amazon Web Services"
    Azure  = "Microsoft Azure"
    GCP    = "Google Cloud"
  }
}

variable "mp_subscription_enabled" {
  description = "Subscribe to Marketplace listing?"
  type        = bool
  //default     = false
  default     = true
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
## Validate Topology 

__Step #1:__ - After the terraform apply will be deployed you can login on on the Informatica Secure Agent VM instance using ssh and after that do a sudo su -

Example: 

```
Informatica-Secure-Agent–create-a-ready-to-go-development-data-platform-on-OCI iopanait$ ssh -i private_key.pem opc@193.122.156.212
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Mon May  1 11:25:37 2023 from 217.123.20.97
[opc@securenl ~]$ 
[opc@securenl ~]$ sudo su - 
Last login: Mon May  1 11:25:41 GMT 2023 on pts/0
[root@securenl ~]# 

```

__Step #2:__ - You can access the log files at the following locations:
    - /opt/infaagent/apps/agentcore/agentcore.log
    - /opt/infaagent/apps/agentcore/infaagent.log
    - /opt/agent_setup.log
    - /opt/DO_NOT_DELETE_INFA_IICS_SA.txt

When the installation and configuration it's done the output will look like the one below.

```
[infa@informaticagcp agentcore]$ cat /opt/infaagent/apps/agentcore/agentcore.log
2023-11-16 11:27:10,385 GMT  tid="1" tn="main" INFO [com.informatica.runtime.common.util.NetworkUtil] - Determining network interface used for device based encryption
2023-11-16 11:27:10,782 GMT  tid="1" tn="main" INFO [com.informatica.runtime.common.util.AgentIdUtil] - Successfully created agent_nwid.dat
2023-11-16 11:27:12,070 GMT  tid="1" tn="main" INFO [com.informatica.saas.infaagent.agentcore.admin.Administrator] - Ignore agentcore packages package-agentcoreupgrade.6713, package-agentcoreupgradefips.6713
2023-11-16 11:27:12,080 GMT  tid="1" tn="main" INFO [com.informatica.saas.infaagent.agentcore.impls.MainApp] - Regular agent configuration with token
2023-11-16 11:27:12,095 GMT  tid="1" tn="main" INFO [com.informatica.saas.infaagentv3.agentcore.AgentCorePublisher] - Starting RMI server...
2023-11-16 11:27:12,129 GMT  tid="1" tn="main" INFO [com.informatica.saas.infaagent.agentcore.impls.MainApp] - Agent Core's RMI started up.
2023-11-16 11:29:09,985 GMT  tid="25" tn="RMI TCP Connection(2)-127.0.0.1" INFO [com.informatica.saas.infaagent.agentcore.impls.AgentConfiguratorTokenImpl] - Register agent to org 8ee6nPfuGAakd7TjaRFXEh with name informaticagcp
2023-11-16 11:29:11,743 GMT  tid="25" tn="RMI TCP Connection(2)-127.0.0.1" INFO [com.informatica.runtime.common.security.DeviceEncryption] - Key file required for device based encryption doesn't exists
2023-11-16 11:29:11,744 GMT  tid="25" tn="RMI TCP Connection(2)-127.0.0.1" INFO [com.informatica.runtime.common.security.DeviceEncryption] - Generating a new key for device based encryption
2023-11-16 11:29:14,708 GMT  tid="27" tn="LifecycleManagerFactoryDefault-akka.actor.default-dispatcher-2" INFO [com.informatica.saas.lcm.lcmnative.LCMComponents] - \tlcm.app.path = /opt/infaagent/apps
2023-11-16 11:29:14,708 GMT  tid="27" tn="LifecycleManagerFactoryDefault-akka.actor.default-dispatcher-2" INFO [com.informatica.saas.lcm.lcmnative.LCMComponents] - \tlcm.port.low = 14000
2023-11-16 11:29:14,708 GMT  tid="27" tn="LifecycleManagerFactoryDefault-akka.actor.default-dispatcher-2" INFO [com.informatica.saas.lcm.lcmnative.LCMComponents] - \tlcm.port.high = 14999
2023-11-16 11:29:14,709 GMT  tid="27" tn="LifecycleManagerFactoryDefault-akka.actor.default-dispatcher-2" INFO [com.informatica.saas.lcm.lcmnative.LCMComponents] - \tlcm.cache.charset.name = UTF-8
2023-11-16 11:29:14,709 GMT  tid="27" tn="LifecycleManagerFactoryDefault-akka.actor.default-dispatcher-2" INFO [com.informatica.saas.lcm.lcmnative.LCMComponents] - \tlcm.manifest.threads = 1
2023-11-16 11:29:14,709 GMT  tid="27" tn="LifecycleManagerFactoryDefault-akka.actor.default-dispatcher-2" INFO [com.informatica.saas.lcm.lcmnative.LCMComponents] - \twait_for_apps_to_stop = false
2023-11-16 11:29:14,709 GMT  tid="27" tn="LifecycleManagerFactoryDefault-akka.actor.default-dispatcher-2" INFO [com.informatica.saas.lcm.lcmnative.LCMComponents] - \tlcm.temp.dir = /opt/infaagent/apps/agentcore/logs/temp

[infa@informaticagcp agentcore]$ cat /opt/infaagent/apps/agentcore/infaagent.log
Successfully started up InfaAgent.
InfaAgent is starting up... Please ensure InfaAgent has come up successfully on the web page.
[2023-11-16T11:27:08+0000]: Starting agent core
67.13
/opt/infaagent/apps/agentcore
ConfigProperties: Loading properties from /opt/infaagent/apps/agentcore/../../apps/agentcore/conf/infaagent.ini
ConfigProperties: Done loading properties from /opt/infaagent/apps/agentcore/../../apps/agentcore/conf/infaagent.ini
ConfigProperties: Loading properties from /opt/infaagent/apps/agentcore/../../apps/agentcore/conf/proxy.ini
ConfigProperties: Done loading properties from /opt/infaagent/apps/agentcore/../../apps/agentcore/conf/proxy.ini
[infa@informaticagcp agentcore]$ 


[infa@informaticagcp agentcore]$ cat /opt/agent_setup.log
Starting IICS secure agent installation...
Starting agent registration...
Setting Data Center location...
Adding secure agent to group 
Starting IICS Agent
Registering IICS Agent
Execution complete

[root@securenl ~]# cat /opt/DO_NOT_DELETE_INFA_IICS_SA.txt
Secure agent installation script completed.
[root@securenl ~]# 
```

## <a name="documentation"></a>Documentation

[Autonomous Databases Overview](https://docs.oracle.com/en-us/iaas/Content/Database/Concepts/adboverview.htm)

[Object Storage Overview](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm)

[Certificates](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm)

[Compute service](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm)

[Network Overview](https://docs.cloud.oracle.com/iaas/Content/Network/Concepts/overview.htm)

[Terraform Autonomous Databases Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_autonomous_database)

[Terraform Object Storage Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_bucket)

[Terraform Certificates - TLS Provider](https://registry.terraform.io/providers/oracle/tls/latest/docs)

[Terraform Oracle Cloud Infrastructure Core Service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance)

[Terraform Vcn resource in Oracle Cloud Infrastructure Core service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_vcn)

[Terraform Subnet resource in Oracle Cloud Infrastructure Core service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet)


## <a name="team"></a>The Team
- **Owners**: [Panaitescu Ionel](https://github.com/ionelpanaitescu) 

## <a name="feedback"></a>Feedback
We welcome your feedback. To post feedback, submit feature ideas or report bugs, please use the Issues section on this repository.	

## <a name="known-issues"></a>Known Issues
**At the moment, there are no known issues**