# Oracle Cloud Foundation Terraform Solution - Deploy a secure production-ready Oracle Autonomous Database and Oracle APEX application

## Table of Contents
1. [Overview](#overview)
1. [Deliverables](#deliverables)
1. [Architecture](#Architecture-Diagram)
1. [Executing Instructions](#instructions)
    1. [Deploy Using the Terraform CLI](#Deploy-Using-the-Terraform-CLI)
    1. [What to do after the Deployment via Terraform CLI](#After-Deployment-via-Terraform-CLI)
1. [Documentation](#documentation)
1. [The Team](#team)
1. [Feedback](#feedback)
1. [Known Issues](#known-issues)
1. [Contribute](#CONTRIBUTING.md)


## <a name="overview"></a>Overview
----------------

Use Oracle APEX to build scalable, secure enterprise applications, with world-class features, that you can deploy anywhere. Oracle APEX is a low-code development platform. Once the application is up and running, you can use Terraform to automate deployment into an Oracle Cloud Infrastructure environment.


## <a name="deliverables"></a>Deliverables
----------------

 This repository encloses one deliverable:

- A reference implementation written in Terraform HCL (Hashicorp Language) that provisions fully functional resources in an OCI tenancy. 

## <a name="architecture"></a>Architecture-Diagram
----------------

This architecture leverages the load balancer to isolate an Oracle Autonomous Transaction Processing database in a separate private subnet. The Oracle Cloud Infrastructure (OCI) landing zone automated by Terraform provides a secure infrastructure for running the Oracle APEX application on top of the shared Oracle Autonomous Database exposed by the private endpoint.

The following diagram illustrates this reference architecture.


![](https://docs.oracle.com/en/solutions/deploy-autonomous-database-and-app/img/apex-app-adb.png)


## <a name="instructions"></a>Executing Instructions
----------------

## Prerequisites

- Permission to `manage` the following types of resources in your Oracle Cloud Infrastructure tenancy: `vcns`, `nat-gateways`, `route-tables`, `subnets`, `service-gateways`, `security-lists`, `autonomous database`, `Load Balancer` and `compute instances`.
- Quota to create the following resources: 1 ADW database instance inside OCI, 1 Load Balancer and 1 bastion server.
If you don't have the required permissions and quota, contact your tenancy administrator. See [Policy Reference](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm), [Service Limits](https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm), [Compartment Quotas](https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcequotas.htm).


# <a name="Deploy-Using-the-Terraform-CLI"></a>Deploy Using the Terraform CLI


## Clone the Module
Now, you'll want a local copy of this repo. You can make that with the commands:

    git clone https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation.git
    cd terraform-oci-oracle-cloud-foundation/cloud-foundation/solutions/ATP Deployment
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


* **modules(folder)** -  Contains folders with subsystems and modules for each section of the project: networking, autonomous database, load balancer etc ; Also in the modules folder there is a folder called provisioner - that will provision your full infrastructure with the data model.
* **CONTRIBUTING.md** - Contributing guidelines, also called Contribution guidelines, the CONTRIBUTING.md file, or software contribution guidelines, is a text file which project managers include in free and open-source software packages or other open media packages for the purpose of describing how others may contribute user-generated content to the project.The file explains how anyone can engage in activities such as formatting code for submission or submitting patches
* **LICENSE** - The Universal Permissive License (UPL), Version 1.0 
* **local.tf** - Local values can be helpful to avoid repeating the same values or expressions multiple times in a configuration, but if overused they can also make a configuration hard to read by future maintainers by hiding the actual values used.Here is the place where all the resources are defined.
* **main.tf** - Main Terraform script used for instantiating the Oracle Cloud Infrastructure provider and all subsystems modules
* **outputs.tf** - Defines project's outputs that you will see after the code runs successfuly
* **provider.tf** - The terraform provider that will be used (OCI)
* **README.md** - This file
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
  default = "deployAtp"
}

variable "db_password" {
  type = string
  default = "V2xzQXRwRGIxMjM0Iw=="
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
  default = "OLTP"
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
  # default = "NOT_ENABLED"
  # default = "ENABLED"
  default = "ENABLED"
}

```

# Compute VM

The compute module will create one VM bastion that will be populated with all the necessary scripts, configuration and data inside the Autonomous Database. 

This VM is using the Oracle-Linux-Cloud-Developer-8.5-2022.05.22-0 image - that commes with all the neccesarry packages to deploy the solution. 
After the solution it's deployed it will create a container using docker and run a the moviestream application on top of the VM that can be accessed via http.

For the Bastion VM the shape and the display name needs to be provided.

More information regarding shapes can be found here:
https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm

* Parameters for the VM Bastion Compute Configuration
    * __bastion_instance_image_ocid__ - (Required) It's a map of strings with each OCID for each region inside OCI of the image that will be deployed on the VM. 
    * __bastion_instance_display_name__ - The name of your bastion VM instance.
    * __bastion_instance_shape__ - (Required) (Updatable) The shape of an instance. The shape determines the number of CPUs, amount of memory, and other resources allocated to the instance.

Below is an example:
```
# Bastion Instance Variables:
# More information on what Image OCIDs you need to use based on the region can be found here:
# https://docs.oracle.com/en-us/iaas/images/image/2e439f8e-e98f-489b-82a3-338360b46b82/
# Oracle-Linux-Cloud-Developer-8.5-2022.05.22-0 image  

variable "bastion_instance_image_ocid" {
  type = map(string)
  default = {
    eu-amsterdam-1	  = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaabcomraotpw6apg7xvmc3xxu2avkkqpx4yj7cbdx7ebcm4d52halq"
    eu-stockholm-1    = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaa52kiqhwcoprmwfiuwureucv7nehqjfofoicwptpixdphzvon2mua"
    me-abudhabi-1     = "ocid1.image.oc1.me-abudhabi-1.aaaaaaaa7nqsxvp4vp25gvzcrvld6xaiyxaxmzepkb5gz6us5sfkgeeez2zq"
    ap-mumbai-1       = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaham2gnbrst3s46jrwchlnl3uqo7yxij7f3pqdzwx7zybu657347q"
    eu-paris-1        = "ocid1.image.oc1.eu-paris-1.aaaaaaaaab5yi4bbnabymexkvwcdjlcjiue26kf3vz6dvzm6dvpttqcpaj5q"
    uk-cardiff-1      = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaagvgnze6oq5il7b26onoq4daeaqrghp5hx4yp3q3rvtfpnbzq4zhq"
    me-dubai-1        = "ocid1.image.oc1.me-dubai-1.aaaaaaaaid5v36623wk7lyoivnqwygyaxppqfbzyo35wifxs7hkqo5caxhqa"
    eu-frankfurt-1    = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa3mdtxzi5rx2ids2tb74wmm77zvsqdaxbjlgvjpr4ytzc5njtksjq"
    sa-saopaulo-1     = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaa22wjczcl7udl7w7e347zkwig7mh5p3zfbcemzs46jiaeom5lznyq"
    ap-hyderabad-1    = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaaaq6ggb4u6p4fgsdcj7o2p4akt5t7gmyjnvootiytrqc5joe5pmfq"
    us-ashburn-1      = "ocid1.image.oc1.iad.aaaaaaaas4cu36z32iraul5otar4gl3uy4s5jkupcc4m5shfqlatjiwaoftq"
    ap-seoul-1        = "ocid1.image.oc1.ap-seoul-1.aaaaaaaakrtvc67c6thtmhrwphecd66omeytl7jmv3zd2bci74j56r4xodwq"
    me-jeddah-1       = "ocid1.image.oc1.me-jeddah-1.aaaaaaaaghsie5mvgzb6fbfzujidzrg7jnrraqkh6qkyh2vw7rl6cdnbpe6a"
    af-johannesburg-1 = "ocid1.image.oc1.af-johannesburg-1.aaaaaaaa2sj43nffpmyqlubrj4cikfgoij7qyqhymlnhw3bj7t26lh46euia"
    ap-osaka-1        = "ocid1.image.oc1.ap-osaka-1.aaaaaaaao3swjyengmcc5rz3ynp2euqskvcscqwgouzs3smaarxofxbwstcq"
    uk-london-1       = "ocid1.image.oc1.uk-london-1.aaaaaaaaetscnayepwj2lto7mpgiwtom4jwkqafr3axumt3pt32cgwczkexq"
    eu-milan-1        = "ocid1.image.oc1.eu-milan-1.aaaaaaaavht3nwv7qsue7ljexbqqgofogwvrlgybvtrxylm52eg6b6xrgniq"
    ap-melbourne-1    = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaafavk2azn6cizxnugwi7izvxsumhiuzthw6g7k2o4vuhg4l3phi3a"
    eu-marseille-1    = "ocid1.image.oc1.eu-marseille-1.aaaaaaaakpex24z6rmmyvdeop72nomfui5t54lztix7t5mblqii4l7v4iecq"
    il-jerusalem-1    = "ocid1.image.oc1.il-jerusalem-1.aaaaaaaafgok5gj36cnrsqo6a3p72wqpg45s3q32oxkt45fq573obioliiga"
    ap-tokyo-1        = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaappsxkscys22g5tha37tksf6rlec3tm776dnq7dcquaofeqqb6rna"
    us-phoenix-1      = "ocid1.image.oc1.phx.aaaaaaaawmvmgfvthguywgry23pugqqv2plprni37sdr2jrtzq6i6tmwdjwa"
    sa-santiago-1     = "ocid1.image.oc1.sa-santiago-1.aaaaaaaatqcxvjriek3gdndhk43fdss6hmmd47fw2vmuq7ldedr5f555vx5q"
    ap-singapore-1    = "ocid1.image.oc1.ap-singapore-1.aaaaaaaaouprplh2bubqudrghr46tofi3bukvtrdgiuvckylpk4kvmxyhzda"
    us-sanjose-1      = "ocid1.image.oc1.us-sanjose-1.aaaaaaaaqudryedi3l4danxy5kxbwqkz3nonewp3jwb5l3tdcikhftthmtga"
    ap-sydney-1       = "ocid1.image.oc1.ap-sydney-1.aaaaaaaaogu4pvw4zw2p7kjabyynczopoqipecr2gozdaolh5kem2mkdrloa"
    sa-vinhedo-1      = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaa57khlnd4ziajy6wwmud2d6k3wsqkm4yce3mlzbgxeggpbu3yqbpa"
    ap-chuncheon-1    = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaanod2kc3bw5l3myyd5okw4c46kapdpsu2fqgyswf4lka2hrordlla"
    ca-montreal-1     = "ocid1.image.oc1.ca-montreal-1.aaaaaaaaevwlof26wfzcoajtlmykpaev7q5ekqyvkpqo2sjo3gdwzygu7xta"
    ca-toronto-1      = "ocid1.image.oc1.ca-toronto-1.aaaaaaaanajb7uklrra5eq2ewx35xfi2aulyohweb2ugik7kc6bdfz6swyha"
    eu-zurich-1       = "ocid1.image.oc1.eu-zurich-1.aaaaaaaameaqzqjwp45epgv2zywkaw2cxutz6gdc6jxnrrbb4ciqpyrnkczq"
  }
}

variable "bastion_instance_display_name" {
  type    = string
  default = "ATP Web Server"
}

variable "bastion_instance_shape" {
    type    = string
    default  = "VM.Standard2.1"
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
  default = "lbatp"
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

Outputs:

ADW_Database_db_connection = tolist([
  {
    "all_connection_strings" = tomap({
      "HIGH" = "adb.us-ashburn-1.oraclecloud.com:1522/rddainsuh6u1okc_deployatp_high.adb.oraclecloud.com"
      "LOW" = "adb.us-ashburn-1.oraclecloud.com:1522/rddainsuh6u1okc_deployatp_low.adb.oraclecloud.com"
      "MEDIUM" = "adb.us-ashburn-1.oraclecloud.com:1522/rddainsuh6u1okc_deployatp_medium.adb.oraclecloud.com"
      "TP" = "adb.us-ashburn-1.oraclecloud.com:1522/rddainsuh6u1okc_deployatp_tp.adb.oraclecloud.com"
      "TPURGENT" = "adb.us-ashburn-1.oraclecloud.com:1522/rddainsuh6u1okc_deployatp_tpurgent.adb.oraclecloud.com"
    })
    "dedicated" = ""
    "high" = "adb.us-ashburn-1.oraclecloud.com:1522/rddainsuh6u1okc_deployatp_high.adb.oraclecloud.com"
    "low" = "adb.us-ashburn-1.oraclecloud.com:1522/rddainsuh6u1okc_deployatp_low.adb.oraclecloud.com"
    "medium" = "adb.us-ashburn-1.oraclecloud.com:1522/rddainsuh6u1okc_deployatp_medium.adb.oraclecloud.com"
    "profiles" = tolist([
      {
        "consumer_group" = "HIGH"
        "display_name" = "deployatp_high"
        "host_format" = "FQDN"
        "is_regional" = false
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "SERVER"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1521)(host=vezmsz1y.adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=rddainsuh6u1okc_deployatp_high.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))"
      },
      {
        "consumer_group" = "LOW"
        "display_name" = "deployatp_low"
        "host_format" = "FQDN"
        "is_regional" = false
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "SERVER"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1521)(host=vezmsz1y.adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=rddainsuh6u1okc_deployatp_low.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))"
      },
      {
        "consumer_group" = "MEDIUM"
        "display_name" = "deployatp_medium"
        "host_format" = "FQDN"
        "is_regional" = false
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "SERVER"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1521)(host=vezmsz1y.adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=rddainsuh6u1okc_deployatp_medium.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))"
      },
      {
        "consumer_group" = "TP"
        "display_name" = "deployatp_tp"
        "host_format" = "FQDN"
        "is_regional" = false
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "SERVER"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1521)(host=vezmsz1y.adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=rddainsuh6u1okc_deployatp_tp.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))"
      },
      {
        "consumer_group" = "TPURGENT"
        "display_name" = "deployatp_tpurgent"
        "host_format" = "FQDN"
        "is_regional" = false
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "SERVER"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1521)(host=vezmsz1y.adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=rddainsuh6u1okc_deployatp_tpurgent.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))"
      },
      {
        "consumer_group" = "HIGH"
        "display_name" = "deployatp_high"
        "host_format" = "FQDN"
        "is_regional" = false
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "MUTUAL"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=vezmsz1y.adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=rddainsuh6u1okc_deployatp_high.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))"
      },
      {
        "consumer_group" = "LOW"
        "display_name" = "deployatp_low"
        "host_format" = "FQDN"
        "is_regional" = false
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "MUTUAL"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=vezmsz1y.adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=rddainsuh6u1okc_deployatp_low.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))"
      },
      {
        "consumer_group" = "MEDIUM"
        "display_name" = "deployatp_medium"
        "host_format" = "FQDN"
        "is_regional" = false
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "MUTUAL"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=vezmsz1y.adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=rddainsuh6u1okc_deployatp_medium.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))"
      },
      {
        "consumer_group" = "TP"
        "display_name" = "deployatp_tp"
        "host_format" = "FQDN"
        "is_regional" = false
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "MUTUAL"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=vezmsz1y.adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=rddainsuh6u1okc_deployatp_tp.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))"
      },
      {
        "consumer_group" = "TPURGENT"
        "display_name" = "deployatp_tpurgent"
        "host_format" = "FQDN"
        "is_regional" = false
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "MUTUAL"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=vezmsz1y.adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=rddainsuh6u1okc_deployatp_tpurgent.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))"
      },
    ])
  },
])
ADW_Database_ip = "10.0.1.40"
Database_Actions = [
  "https://vezmsz1y.adb.us-ashburn-1.oraclecloudapps.com/ords/sql-developer",
]
adb_admin_password = <sensitive>
adb_user_name = "USER_WORKSHOP"
adb_user_password = "AaBbCcDdEe123!"
adb_workshop_base = "WORKSHOP"
database_fully_qualified_name = "vezmsz1y.adb.us-ashburn-1.oraclecloudapps.com"
graph_studio_url = [
  "https://vezmsz1y.adb.us-ashburn-1.oraclecloudapps.com/graphstudio/",
]
load_balancer_IP = [
  tolist([
    "157.151.255.207",
  ]),
]
load_balancer_url = "https://157.151.255.207"
machine_learning_user_management_url = [
  "https://vezmsz1y.adb.us-ashburn-1.oraclecloudapps.com/omlusers/",
]

```

## Connect to Autonomous Database
Please use the public IP address listed on the load_balancer_url output to connect to the autonomous database application via a web-browser.

A database user was created during the deployment. You can connect as that user using:

* User: `USER_WORKSHOP`, Password: `AaBbCcDdEe123!` , WorkShop: `WORKSHOP`
* User: `ADMIN`, Password: `V2xzQXRwRGIxMjM0Iw==`

Please change these passwords after deployment.


## <a name="documentation"></a>Documentation

[Autonomous Databases Overview](https://docs.oracle.com/en-us/iaas/Content/Database/Concepts/adboverview.htm)

[Terraform Autonomous Databases Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_autonomous_database)


## <a name="team"></a>The Team
- **Owners**: [Corina Todea](https://github.com/ctodearo) , [Panaitescu Ionel](https://github.com/ionelpanaitescu)

## <a name="feedback"></a>Feedback
We welcome your feedback. To post feedback, submit feature ideas or report bugs, please use the Issues section on this repository.	

## <a name="known-issues"></a>Known Issues
**At the moment, there are no known issues for this solution**


