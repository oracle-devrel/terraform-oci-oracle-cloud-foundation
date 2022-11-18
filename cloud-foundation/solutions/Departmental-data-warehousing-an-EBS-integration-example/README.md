# Oracle Cloud Foundation Terraform Solution - Departmental data warehousing - an EBS integration example




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
Analysts need an efficient way to consolidate data from multiple financial systems, spreadsheets and other data sources into a trusted, maintainable, and query-optimized source.

With Oracle Autonomous Data Warehouse and Oracle Analytics Cloud, you can load and optimize data from Oracle E-Business Suite and other sources into a centralized data warehouse location for analysis so departments can gain actionable insights.

Lines of business typically don't have timely or efficient access to data and information. Analysts gather the data manually, work with it on an individual basis, and then share copies of files through email or file servers. The data is not centralized, so ensuring the accuracy and the security of the data is difficult. Analysis can take a long time and the results are not easily repeatable.

A data mart is a simple form of a data warehouse that is focused on a single subject or functional area, such as sales, marketing, or finance and are often built and controlled by a single department within an organization. Given their single-subject focus, data marts usually draw data from only a few sources. The sources could include internal systems, a central data warehouse, or external data.

Governed data warehouses and data marts can provide rich information to business users and more effectively deliver the organization's key performance indicators without relying heavily on IT resources and availability.

For details of the architecture, see [_Departmental data warehousing - an EBS integration example_](https://docs.oracle.com/en/solutions/oci-ebs-analysis/).

## <a name="deliverables"></a>Deliverables
 This repository encloses one deliverable:

- A reference implementation written in Terraform HCL (Hashicorp Language) that provisions fully functional resources in an OCI tenancy.

## <a name="architecture"></a>Architecture-Diagram
The diagram below shows services that are deployed:

![](https://docs.oracle.com/en/solutions/oci-ebs-analysis/img/analysis-ebs.png)


## <a name="instructions"></a>Executing Instructions

## Prerequisites

- Permission to `manage` the following types of resources in your Oracle Cloud Infrastructure tenancy: `vcns`, `nat-gateways`, `route-tables`, `subnets`, `service-gateways`, `security-lists`, `autonomous database`, `Analytics Cloud`, `data catalog` and `compute instances`.
- Quota to create the following resources: 1 ADW database instance and 1 Oracle Analytics Cloud (OAC) instance, 1 Data Catalog and 2 instances one for a bastion and one for the ODI VM.
If you don't have the required permissions and quota, contact your tenancy administrator. See [Policy Reference](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm), [Service Limits](https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm), [Compartment Quotas](https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcequotas.htm).

# <a name="Deploy-Using-Oracle-Resource-Manager"></a>Deploy Using Oracle Resource Manager

1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation/releases/download/v1.0.0/Departmental-data-warehousing-an-EBS-integration-example-RM.zip)


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
    cd terraform-oci-oracle-cloud-foundation/cloud-foundation/solutions/Departmental-data-warehousing-an-EBS-integration-example
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

* **modules(folder)** - ( this folder will be pressent only for the Resource Manager zipped files) Contains folders with subsystems and modules for each section of the project: networking, autonomous database, analytics cloud, etc.
* **orm(folder)** - this folder contains one file - main.tf that calls the modules from the modules folder inside the root of the solution. This is neccesary for the Resource Manager zipped archives.
* **userdata(folder)** - this folder contains the necessary scripts that will run on the compute instances, for the bastion and also for the ODI VM -  installing Oracle Data Integrator, configure it, connect to Autonomous Data Warehouse etc.
* **CONTRIBUTING.md** - Contributing guidelines, also called Contribution guidelines, the CONTRIBUTING.md file, or software contribution guidelines, is a text file which project managers include in free and open-source software packages or other open media packages for the purpose of describing how others may contribute user-generated content to the project.The file explains how anyone can engage in activities such as formatting code for submission or submitting patches
* **LICENSE** - The Universal Permissive License (UPL), Version 1.0 
* **local.tf** - Local values can be helpful to avoid repeating the same values or expressions multiple times in a configuration, but if overused they can also make a configuration hard to read by future maintainers by hiding the actual values used.Here is the place where all the resources are defined.
* **main.tf** - Main Terraform script used for instantiating the Oracle Cloud Infrastructure provider and all subsystems modules
* **outputs.tf** - Defines project's outputs that you will see after the code runs successfuly
* **provider.tf** - The terraform provider that will be used (OCI)
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
    * __adw_whitelisted_ips__ - The client IP access control list (ACL). This feature is available for autonomous databases on shared Exadata infrastructure and on Exadata Cloud@Customer. Only clients connecting from an IP address included in the ACL may access the Autonomous Database instance.

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
  default = "<enter-password-here>" # Example password: Par0laMea123
}

variable "database_wallet_password" {
  type = string
  default = "<enter-password-here>" # Example password: Par0laMea123
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
    default = "AnalyicSDEBS"
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
    default = 2
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


# Compute ODI VM and Bastion
The compute module will create two VM's - one for a bastion that can be used to ssh or vnc to the ODI VM as a proxy server ( port forwarding ) and the ODI VM itself. You will need to install a VNC viewer on your local PC if you want to use port forwarding to the ODI Instance.
The Bastion it's deployed in the public subnet and the ODI Instance it's in the private subnet.
For the Bastion VM we are using the Oracle-Linux-Cloud-Developer-8.4-2021.08.27-0 image as it comes with all the neccesary software installed and for the ODI Instance we are using ODI Marketplace V12.2.1.4.221007. 

More information about this image and about the OCIDs required to be provided as a variable can be found here:

https://docs.oracle.com/en-us/iaas/images/image/2e439f8e-e98f-489b-82a3-338360b46b82/

More information regarding shapes can be found here:

https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm

* Parameters for the VM Bastion Compute Configuration
    * __bastion_shape__ - (Required) (Updatable) The shape of an instance. The shape determines the number of CPUs, amount of memory, and other resources allocated to the instance.
    * __bastion_instance_image_ocid__ - the linux image OCID for your region.

Below is an example:
```
# VM Bastion Compute Configuration

variable "bastion_shape" {
  default = "VM.Standard2.4"
}

variable "bastion_instance_image_ocid" {
  type = map(string)
  default = {
    ap-chuncheon-1	= "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaaihmt2keujm4pd3wswehk3ybcs4d4guuapvml7slexmwgjxwjaypq"
    ap-hyderabad-1	= "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaawcl3nadtbiijdrrrczdfh2bqbujtaswfviu5rf3dc2hldetikuzq"
    ap-melbourne-1	= "ocid1.image.oc1.ap-melbourne-1.aaaaaaaayrgmmffm34ikswpqlsc3rlu74vofqrypuo6srgvl6nhpccwkbdqq"
    ap-mumbai-1	    = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaayg64ftz6kq7y4zbvohti67pzn2yxioweb3yfscwqeq5urccnmcvq"
    ap-osaka-1	    = "ocid1.image.oc1.ap-osaka-1.aaaaaaaa4rzsgxccrowpua6nn6pujztlyrcmhdgd6gsgsgo4ikuvhgy3ihia"
    ap-seoul-1	    = "ocid1.image.oc1.ap-seoul-1.aaaaaaaayze2sndwv7uwwgltjvhjhy3n2rr5nr7wbrernzberaxzcm6iyepq"
    ap-sydney-1	    = "ocid1.image.oc1.ap-sydney-1.aaaaaaaahjlvew72o4dg5h5ok76tew7d5rw3s6hfng7xystxj6fxinxdixca"
    ap-tokyo-1	    = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaazou4xzdvfawk23xzeury3a33gvo4i3fmyzxlchpptsqnwpyrayrq"
    ca-montreal-1	  = "ocid1.image.oc1.ca-montreal-1.aaaaaaaazwrlosyjzkech4pokwrgi6mnzfvtjjeya6mj5rhimtf4i6ag3aoa"
    ca-toronto-1	  = "ocid1.image.oc1.ca-toronto-1.aaaaaaaarqogbrbjbgnpvio6im4yiz564kpgq6q35jk66q2h4a53cxnqgqeq"
    eu-amsterdam-1	= "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaa3wwms4s2asbn6isysx6qexsppsh725cbh5wuv6u466znhj64u64a"
    eu-frankfurt-1	= "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa7lzlvp6re2qyum4vmyryjk2okyfj7vp7lj2rd6qk2ovp7yfssoxa"
    eu-zurich-1	    = "ocid1.image.oc1.eu-zurich-1.aaaaaaaab6njbd32zxehpsvliwjujewg5jqow3vxmv5nr3wbvfomuc6lzv4a"
    me-dubai-1	    = "ocid1.image.oc1.me-dubai-1.aaaaaaaa7wybi5o7rye52jp5uj3bu5ccwofgxjjeo54gsers4j6lnfhrtuaq"
    me-jeddah-1	    = "ocid1.image.oc1.me-jeddah-1.aaaaaaaazk2fffaxgc5534lze5ojxai4vnxuxiz4k57s3joafi26hbby5w6a"
    sa-santiago-1	  = "ocid1.image.oc1.sa-santiago-1.aaaaaaaafchgyo6a4sa4h6edkvijohbcwnroafhb66sbe3come5d5qhj4noq"
    sa-saopaulo-1	  = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaawisuo2l655it3yw5oaq7lrf6wh7dyof22yk23ek47cnxfcpkgfia"
    sa-vinhedo-1	  = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaae2g4ystqi35snjnp2nn25cvmkh74ngpm45uqosmh7ukgurnalkuq"
    uk-cardiff-1	  = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaamijlpruvprwtaovx26yvun5tuijutfmmk6npcbawsfmgrv6fyc3a"
    uk-london-1	    = "ocid1.image.oc1.uk-london-1.aaaaaaaaqb6vgjln2bsdvlkdk2eqov5hhqbyffodkto2qimvab4mvh4q567q"
    us-ashburn-1	  = "ocid1.image.oc1.iad.aaaaaaaatw76yshzzwmu6l7rdpsv3kpfnanubwtdhjbrhelz4n7sz7ss5s6q"
    us-phoenix-1	  = "ocid1.image.oc1.phx.aaaaaaaavb7udllf45sc5whsgcsmzmbiqb73rpysi3t5nuy5jil3yocfsoka"
    us-sanjose-1	  = "ocid1.image.oc1.us-sanjose-1.aaaaaaaaicbcb5sfq6n5iisvx2hfr2vroifs4jmzgvuvizo7m32m2tlzzx6q"
  }
}
```

* Parameters for the ODI VM Configuration
    * __odi_instance_shape__ - (Required) (Updatable) The shape of an instance. The shape determines the number of CPUs, amount of memory, and other resources allocated to the instance.
    * __adw_username__ - the Autonomous Data Warehouse username
    * __adw_password__ - the Autonomous Data Warehouse password provided when deployed the Autonomous Database.
    * __odi_vnc_password__ - a VNC password that you can connect on the linux instance using VNC
    * __odi_schema_prefix__ - the schema prefix
    * __odi_schema_password__ - the schema password
    * __odi_password__ - the odi password
    * __adw_creation_mode__ - The Autonomous Data Warehouse creation mode
    * __embedded_db__ - value true or false for the embedded db, for this solution we are using the Autonomous Data Warehouse database.
    * __studio_mode__ - studio modeo fhe ODI. It can be "ADVANCED" or "Web" .
    * __db_tech__ - the tech for the DB.
    * __studio_name__ - The studio name of the ODI. It can be used the followings: "ADVANCED", "ODI Web Studio Administrator" or "ODI Studio" .

# ODI VM Configuration

```

variable "odi_instance_shape" {
  default = "VM.Standard2.4" # Example instance shape: VM.Standard2.4
}

variable "adw_username" {
  type = string
  default = "admin" # Example username: admin
}

variable "adw_password" {
  type = string
  default = "" # Example password: Par0laMea123
}

variable "odi_vnc_password" {
  type = string
  default = ""   # Example password: Par0laMea123
}

variable "odi_schema_prefix" {
  type = string
  default = "odi" # Example schema prefix: odi
}

variable "odi_schema_password" {
  type = string
  default = ""   # Example password: Par0laMea123
}

variable "odi_password" {
  type = string
  default = ""   # Example password: Par0laMea123
}

variable "adw_creation_mode" {
  type = bool
  default = true  # True - As we are using ADW not mysql
}

variable "embedded_db" {
  type = bool
  default = false  # False - As we are using ADW not mysql embeded 
}

variable "studio_mode" {
  type = string
  default = "ADVANCED"  # "ADVANCED" or "Web"
}

variable "db_tech" {
  type = string
  default = "ADB"  # DB Tech ADB not Mysql
}

variable "studio_name" {
  type = string
  default = "ADVANCED" #  "ADVANCED" ,  "ODI Web Studio Administrator" or "ODI Studio"
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

__Step #1:__ - After the terraform apply will be deployed you can login on the ODI VM instance using vnc on the public IP address with the ":1" session. Example: "ODI_INSTANCE_PUBLIC_IP:1". The linux instance has the GUI activated. On the desktop the ODI application is there. The instalation of ODI and configuration with ADW full process will take around 1 hour. To see the process you can have a look on the file: /u01/oracle/logs/odiConfigure.log .

__Step #2:__ - Open a terminal and use the command: "cat /u01/oracle/logs/odiConfigure.log"

When the installation and configuration it's done the output will look like the one below.

```
[opc@odi-instance logs]$ cat odiConfigure.log 

	RCU Logfile: /tmp/RCU2022-11-17_11-34_792509053/logs/rcu.log


RCU-6069:Warning : Database connect string specified is not in recommended format.  Refer to RCU help for supported connect string formats. Continuing execution.

Enter the database password(User:admin):
 

Processing command line ....
Repository Creation Utility - Checking Prerequisites
Checking Global Prerequisites
Enter the schema password. This password will be used for all schema users of following components:STB,WLS,IAU_APPEND,IAU_VIEWER,OPSS,IAU,ODI.
 

Enter the value of Custom Variable [Supervisor Password] for Component ODI [Min Length:6, Max Length:12]
 

Enter the value of Custom Variable [Work Repository Type: (D) Development (Default) or (E) Execution] for Component ODI [Min Length:0, Max Length:1]


RCUCommandLine Error - Value for Custom variable Work Repository Type: (D) Development (Default) or (E) Execution was not provided.
Enter the value of Custom Variable [Work Repository Type: (D) Development (Default) or (E) Execution] for Component ODI [Min Length:0, Max Length:1]


Enter the value of Custom Variable [Work Repository Name (WORKREP)] for Component ODI [Min Length:0, Max Length:128]


RCUCommandLine Error - Value for Custom variable Work Repository Name (WORKREP) was not provided.
Enter the value of Custom Variable [Work Repository Name (WORKREP)] for Component ODI [Min Length:0, Max Length:128]


Enter the value of Custom Variable [Work Repository Password] for Component ODI [Min Length:0, Max Length:10]
 

RCUCommandLine Error - Value for Custom variable Work Repository Password was not provided.
Enter the value of Custom Variable [Work Repository Password] for Component ODI [Min Length:0, Max Length:10]
 

Enter the value of Custom Variable [Encryption Algorithm: AES-128 (Default) or AES-256] for Component ODI [Min Length:0, Max Length:7]


RCUCommandLine Error - Value for Custom variable Encryption Algorithm: AES-128 (Default) or AES-256 was not provided.
Enter the value of Custom Variable [Encryption Algorithm: AES-128 (Default) or AES-256] for Component ODI [Min Length:0, Max Length:7]


Repository Creation Utility - Checking Prerequisites
Checking Component Prerequisites
Repository Creation Utility - Creating Tablespaces
Validating and Creating Tablespaces
Create tablespaces in the repository database
Repository Creation Utility - Create
Repository Create in progress.
        Percent Complete: 12
Executing pre create operations
        Percent Complete: 30
        Percent Complete: 30
        Percent Complete: 32
        Percent Complete: 34
        Percent Complete: 36
        Percent Complete: 36
        Percent Complete: 38
        Percent Complete: 38
Creating Common Infrastructure Services(STB)
        Percent Complete: 46
        Percent Complete: 46
        Percent Complete: 56
        Percent Complete: 56
        Percent Complete: 56
Creating Audit Services Append(IAU_APPEND)
        Percent Complete: 64
        Percent Complete: 64
        Percent Complete: 74
        Percent Complete: 74
        Percent Complete: 74
Creating Audit Services Viewer(IAU_VIEWER)
        Percent Complete: 82
        Percent Complete: 82
        Percent Complete: 82
        Percent Complete: 83
        Percent Complete: 83
        Percent Complete: 84
        Percent Complete: 84
        Percent Complete: 84
Creating Weblogic Services(WLS)
        Percent Complete: 89
        Percent Complete: 89
        Percent Complete: 93
        Percent Complete: 93
        Percent Complete: 100
Creating Audit Services(IAU)
Creating Oracle Platform Security Services(OPSS)
Creating Master and Work Repository(ODI)
Executing post create operations

Repository Creation Utility: Create - Completion Summary

Database details:
-----------------------------
Connect Descriptor                           : (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=rddainsuh6u1okc_adwipn_low.adb.oraclecloud.com))(security=(ssl_server_cert_dn=CN=adwc.uscom-east-1.oraclecloud.com, OU=Oracle BMCS US, O=Oracle Corporation, L=Redwood City, ST=California, C=US)))
Connected As                                 : admin
Prefix for (prefixable) Schema Owners        : ODI
RCU Logfile                                  : /tmp/RCU2022-11-17_11-34_792509053/logs/rcu.log

Component schemas created:
-----------------------------
Component                                    Status         Logfile		

Common Infrastructure Services               Success        /tmp/RCU2022-11-17_11-34_792509053/logs/stb.log 
Oracle Platform Security Services            Success        /tmp/RCU2022-11-17_11-34_792509053/logs/opss.log 
Master and Work Repository                   Success        /tmp/RCU2022-11-17_11-34_792509053/logs/odi.log 
Audit Services                               Success        /tmp/RCU2022-11-17_11-34_792509053/logs/iau.log 
Audit Services Append                        Success        /tmp/RCU2022-11-17_11-34_792509053/logs/iau_append.log 
Audit Services Viewer                        Success        /tmp/RCU2022-11-17_11-34_792509053/logs/iau_viewer.log 
WebLogic Services                            Success        /tmp/RCU2022-11-17_11-34_792509053/logs/wls.log 

Repository Creation Utility - Create : Operation Completed
Loading KM : LKM SQL to SQL (Built-In), Base KM : null
Loading KM : LKM SQL to Oracle (Built-In), Base KM : LKM SQL to SQL (Built-In)
Loading KM : LKM File to Oracle (Built-In), Base KM : LKM SQL to Oracle (Built-In)
Loading KM : LKM SQL to Hive (Built-In), Base KM : LKM SQL to SQL (Built-In)
Loading KM : LKM Oracle to Oracle (Built-In), Base KM : LKM SQL to Oracle (Built-In)
Loading KM : XKM SQL Extract, Base KM : null
Loading KM : IKM SQL Load, Base KM : null
Loading KM : IKM SQL Insert, Base KM : IKM SQL Load
Loading KM : IKM SQL Update, Base KM : IKM SQL Load
Loading KM : IKM SQL Merge, Base KM : IKM SQL Load
Loading KM : IKM SQL Multi-Connect Merge, Base KM : IKM SQL Merge
Loading KM : IKM No-op, Base KM : null
Loading KM : XKM SQL Join, Base KM : null
Loading KM : XKM SQL Filter, Base KM : null
Loading KM : LKM Oracle to Oracle (DB Link), Base KM : null
Loading KM : LKM Oracle to Oracle Pull (DB Link), Base KM : LKM Oracle to Oracle (DB Link)
Loading KM : LKM Oracle to Oracle Push (DB Link), Base KM : LKM Oracle to Oracle (DB Link)
Loading KM : XKM SQL Set, Base KM : null
Loading KM : XKM SQL Expression, Base KM : null
Loading KM : XKM Oracle Sequence, Base KM : null
Loading KM : XKM SQL Aggregate, Base KM : null
Loading KM : XKM SQL Aggregate (11g), Base KM : null
Loading KM : XKM Oracle Extract, Base KM : XKM SQL Extract
Loading KM : IKM Oracle Load, Base KM : IKM SQL Load
Loading KM : IKM Oracle Insert, Base KM : IKM Oracle Load
Loading KM : IKM Oracle Update, Base KM : IKM Oracle Load
Loading KM : IKM Oracle Merge, Base KM : IKM Oracle Load
Loading KM : IKM Oracle Multi-Insert, Base KM : IKM Oracle Load
Loading KM : XKM SQL File Extract, Base KM : null
Loading KM : XKM ERP SQL File Extract, Base KM : null
Loading KM : LKM SQL to File, Base KM : null
Loading KM : XKM SQL Lookup, Base KM : null
Loading KM : XKM SQL Sort, Base KM : null
Loading KM : XKM SQL Sub-Select, Base KM : null
Loading KM : XKM SQL Distinct, Base KM : null
Loading KM : XKM SQL Split, Base KM : null
Loading KM : XKM SQL Input Signature, Base KM : null
Loading KM : XKM SQL Output Signature, Base KM : null
Loading KM : XKM Oracle Output Signature, Base KM : XKM SQL Output Signature
Loading KM : XKM SQL Reusable Mapping, Base KM : null
Loading KM : LKM SQL Multi-Connect, Base KM : null
Loading KM : XKM SQL Subquery Filter, Base KM : null
Loading KM : XKM SQL Pivot, Base KM : null
Loading KM : XKM Oracle Pivot, Base KM : null
Loading KM : XKM Oracle Table Function, Base KM : null
Loading KM : IKM Oracle Table Function, Base KM : XKM Oracle Table Function
Loading KM : XKM Oracle Lookup, Base KM : XKM SQL Lookup
Loading KM : XKM SQL Unpivot, Base KM : null
Loading KM : XKM Oracle Unpivot, Base KM : null
Loading KM : XKM Oracle External Table, Base KM : XKM Oracle Extract
Loading KM : XKM Oracle Database Function (Decorator), Base KM : null
Loading KM : XKM Oracle Database Function (Projector), Base KM : null
Loading KM : XKM Jagged, Base KM : null
Loading KM : HiveBaseKM, Base KM : null
Loading KM : IKM Hive Append, Base KM : HiveBaseKM
Loading KM : IKM Hive Incremental Update, Base KM : IKM Hive Append
Loading KM : HiveBaseLKM, Base KM : HiveBaseKM
Loading KM : HiveHdfsLKM, Base KM : HiveBaseLKM
Loading KM : LKM File to Hive LOAD DATA, Base KM : HiveBaseLKM
Loading KM : LKM File to Hive LOAD DATA Direct, Base KM : LKM File to Hive LOAD DATA
Loading KM : LKM HBase to Hive HBASE-SERDE, Base KM : HiveBaseLKM
Loading KM : LKM Hive to HBase Incremental Update HBASE-SERDE Direct, Base KM : HiveBaseLKM
Loading KM : LKM Hive to File Direct, Base KM : HiveBaseKM
Loading KM : XKM Hive Sort, Base KM : HiveBaseKM
Loading KM : XKM Hive Flatten, Base KM : HiveBaseKM
Loading KM : LKM HDFS File to Hive LOAD DATA, Base KM : HiveHdfsLKM
Loading KM : LKM HDFS File to Hive LOAD DATA Direct, Base KM : HiveHdfsLKM
Loading KM : HiveSqoopBaseLKM, Base KM : HiveBaseLKM
Loading KM : HiveSqoopImportBaseLKM, Base KM : HiveSqoopBaseLKM
Loading KM : LKM SQL to Hive SQOOP, Base KM : HiveSqoopImportBaseLKM
Loading KM : LKM SQL to File SQOOP Direct, Base KM : LKM SQL to Hive SQOOP
Loading KM : LKM SQL to HBase SQOOP Direct, Base KM : LKM SQL to Hive SQOOP
Loading KM : HiveSqoopExportBaseLKM, Base KM : HiveSqoopBaseLKM
Loading KM : LKM File to SQL SQOOP, Base KM : HiveSqoopExportBaseLKM
Loading KM : LKM Hive to SQL SQOOP, Base KM : HiveSqoopExportBaseLKM
Loading KM : LKM HBase to SQL SQOOP, Base KM : LKM Hive to SQL SQOOP
Loading KM : HiveOlhBaseLKM, Base KM : HiveBaseLKM
Loading KM : LKM File to Oracle OLH-OSCH, Base KM : HiveOlhBaseLKM
Loading KM : LKM File to Oracle OLH-OSCH Direct, Base KM : LKM File to Oracle OLH-OSCH
Loading KM : LKM Hive to Oracle OLH-OSCH, Base KM : HiveOlhBaseLKM
Loading KM : LKM Hive to Oracle OLH-OSCH Direct, Base KM : LKM Hive to Oracle OLH-OSCH
Loading KM : XKM Oracle Flatten, Base KM : null
Loading KM : XKM Oracle Flatten XML, Base KM : null
Loading KM : LKM Oracle to File (datapump), Base KM : null
Loading KM : LKM File to Object Storage, Base KM : null
Loading KM : LKM File to Object Storage Direct, Base KM : LKM File to Object Storage
Loading KM : LKM SQL to Object Storage, Base KM : LKM File to Object Storage
Loading KM : LKM SQL to Object Storage Direct, Base KM : LKM SQL to Object Storage
Loading KM : ADWCBaseKM, Base KM : null
Loading KM : LKM Object Storage to ADWC External Table, Base KM : ADWCBaseKM
Loading KM : LKM File to ADWC External Table, Base KM : LKM Object Storage to ADWC External Table
Loading KM : LKM SQL to ADWC External Table, Base KM : LKM File to ADWC External Table
Loading KM : LKM Object Storage to ADWC Copy, Base KM : ADWCBaseKM
Loading KM : LKM File to ADWC Copy, Base KM : LKM Object Storage to ADWC Copy
Loading KM : LKM SQL to ADWC Copy, Base KM : LKM File to ADWC Copy
Loading KM : LKM Object Storage to ADWC Copy Direct, Base KM : ADWCBaseKM
Loading KM : LKM File to ADWC Copy Direct, Base KM : LKM Object Storage to ADWC Copy Direct
Loading KM : LKM SQL to ADWC Copy Direct, Base KM : LKM File to ADWC Copy Direct
Loading KM : LKM Oracle to ADWC Datapump, Base KM : null
Loading KM : BICCBaseKM, Base KM : null
Loading KM : LKM BICC to ADW External Table, Base KM : LKM Object Storage to ADWC External Table
Loading KM : LKM BICC to ADW Copy, Base KM : LKM Object Storage to ADWC Copy
Loading KM : LKM BICC to ADW Copy Direct, Base KM : LKM Object Storage to ADWC Copy Direct
Loading KM : OracleErpCloudExtractBaseKM, Base KM : null
Loading KM : LKM Oracle ERP Cloud to SQL, Base KM : OracleErpCloudExtractBaseKM
Loading KM : LKM Oracle ERP Cloud to File Direct, Base KM : OracleErpCloudExtractBaseKM
Loading KM : LKM NetSuite to Oracle, Base KM : null
Loading KM : PigKM, Base KM : null
Loading KM : LKMPig, Base KM : PigKM
Loading KM : LKMPigFile, Base KM : LKMPig
Loading KM : LKM File to Pig, Base KM : LKMPigFile
Loading KM : LKM Pig to File, Base KM : LKMPigFile
Loading KM : LKMPigHBase, Base KM : LKMPig
Loading KM : LKM HBase to Pig, Base KM : LKMPigHBase
Loading KM : LKM Pig to HBase, Base KM : LKMPigHBase
Loading KM : LKMPigHive, Base KM : LKMPig
Loading KM : LKM Hive to Pig, Base KM : LKMPigHive
Loading KM : LKM Pig to Hive, Base KM : LKMPigHive
Loading KM : LKM SQL to Pig SQOOP, Base KM : LKM File to Pig
Loading KM : XKM Pig Aggregate, Base KM : PigKM
Loading KM : XKM Pig Distinct, Base KM : PigKM
Loading KM : XKM Pig Expression, Base KM : PigKM
Loading KM : XKM Pig Filter, Base KM : PigKM
Loading KM : XKM Pig Flatten, Base KM : PigKM
Loading KM : XKM Pig Join, Base KM : PigKM
Loading KM : XKM Pig Lookup, Base KM : PigKM
Loading KM : XKM Pig Pivot, Base KM : PigKM
Loading KM : XKM Pig Set, Base KM : PigKM
Loading KM : XKM Pig Sort, Base KM : PigKM
Loading KM : XKM Pig Split, Base KM : PigKM
Loading KM : XKM Pig Subquery Filter, Base KM : PigKM
Loading KM : XKM Pig Table Function, Base KM : PigKM
Loading KM : XKM Pig Unpivot, Base KM : PigKM
Loading KM : XKM Jagged Pig, Base KM : null
Loading KM : SparkKM, Base KM : null
Loading KM : LKMSpark, Base KM : SparkKM
Loading KM : LKMSparkFile, Base KM : LKMSpark
Loading KM : LKM File to Spark, Base KM : LKMSparkFile
Loading KM : LKM Spark to File, Base KM : LKMSparkFile
Loading KM : LKMSparkHDFS, Base KM : LKMSpark
Loading KM : LKM HDFS to Spark, Base KM : LKMSparkHDFS
Loading KM : LKM Object Storage to Spark, Base KM : LKM HDFS to Spark
Loading KM : LKM Storage Cloud Service to Spark, Base KM : LKM HDFS to Spark
Loading KM : LKM Spark to HDFS, Base KM : LKMSparkHDFS
Loading KM : LKM Spark to Object Storage, Base KM : LKM Spark to HDFS
Loading KM : LKM Spark to Storage Cloud Service, Base KM : LKM Spark to HDFS
Loading KM : LKM Hive to Spark, Base KM : LKMSpark
Loading KM : LKM Spark to Hive, Base KM : LKMSpark
Loading KM : LKM Kafka to Spark, Base KM : LKMSpark
Loading KM : LKM Spark to Kafka, Base KM : LKMSpark
Loading KM : LKM SQL to Spark, Base KM : LKMSpark
Loading KM : LKM Spark to SQL, Base KM : LKMSpark
Loading KM : LKM Spark to Cassandra, Base KM : LKM Spark to SQL
Loading KM : XKM Spark Aggregate, Base KM : SparkKM
Loading KM : XKM Spark Distinct, Base KM : SparkKM
Loading KM : XKM Spark Expression, Base KM : SparkKM
Loading KM : XKM Spark Filter, Base KM : SparkKM
Loading KM : XKM Spark Flatten, Base KM : SparkKM
Loading KM : XKM Spark Join, Base KM : SparkKM
Loading KM : XKM Spark Lookup, Base KM : SparkKM
Loading KM : XKM Spark Pivot, Base KM : SparkKM
Loading KM : XKM Spark Unpivot, Base KM : SparkKM
Loading KM : XKM Spark Set, Base KM : SparkKM
Loading KM : XKM Spark Sort, Base KM : SparkKM
Loading KM : XKM Spark Split, Base KM : SparkKM
Loading KM : XKM Spark Table Function, Base KM : LKMSpark
Loading KM : IKM Spark Table Function, Base KM : XKM Spark Table Function
Loading KM : XKM Spark Input Signature, Base KM : SparkKM
Loading KM : XKM Spark Output Signature, Base KM : SparkKM
Physical Agent OracleDIAgent1 configuration does not exist in the repository. Hence creating...
physical Agent Configuration Completed Successfully
Logical Agent logicalAgent configuration does not exist in the repository. Hence creating...
Logical Agent Configuration Completed Successfully
Table SNP_ALLOC_AGENT entry for I_CONTEXT = 4 configuration does not exist in the repository. Hence creating...
Table SNP_ALLOC_AGENT Configuration Completed Successfully
  Closing down all connections.

Generating wallet for ADB Instance: ADWipn
Generating wallet for ADB Instance: ADWipnEBSa
Wallet download failed for: ADWipnEBSa Reason: (409, IncorrectState, false) The operation cannot be performed because the Autonomous Database with ID ocid1.autonomousdatabase.oc1.iad.anuwcljrknuwtjiaduyk7kcycx2herbmq5ma4qfxlzk27znotyucf46s4evq is in the TERMINATED state. (opc-request-id: A438A148576649A0B9AF772C0839C72A/0466E8FDE7BB9CA960FE60568EDEE12F/E9D06B02F35DB5D78DBA950217317142)
Generating wallet for ADB Instance: ADWipanEBS
Generating wallet for ADB Instance: DataModelsManufacturing
Wallet download failed for: DataModelsManufacturing Reason: (409, IncorrectState, false) The operation cannot be performed because the Autonomous Database with ID ocid1.autonomousdatabase.oc1.iad.anuwcljrknuwtjiay5bssljdgfmdtcfri7jtx3nmgcuutwhki3q462ukchya is in the TERMINATED state. (opc-request-id: F30BAE62364A47D6BBBF917E393E61D0/FD053F18F73A34CECAAFA7BD499BBDF5/B0F82948BEB88BC44A689A74174A8038)
ODI Marketplace configuration started.
Invoking ADB config
ODI configuration for ADB technology
Start wallet download
updating configuration
[INFO] Feature Flag JSON file updated

Starting repository creation for db tech
Running ODI Post-RCU MP common config ...
ODI configuration completed
Finished MP configuration
Going to start Apps
Allowing : 127.0.0.1,10.0.0.86,127.0.0.1
2022-11-17 12:04:10.775 NOTIFICATION Ignoring JIT  connection to master repository, being 18c or above driver and connections are cached
2022-11-17 12:04:12.473 NOTIFICATION Ignoring JIT  connection to master repository, being 18c or above driver and connections are cached
2022-11-17 12:04:12.740 NOTIFICATION New data source: [ODI_ODI_REPO/*******@jdbc:oracle:thin:@(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=rddainsuh6u1okc_adwipn_low.adb.oraclecloud.com))(security=(ssl_server_cert_dn=CN=adwc.uscom-east-1.oraclecloud.com, OU=Oracle BMCS US, O=Oracle Corporation, L=Redwood City, ST=California, C=US)))]
2022-11-17 12:04:12.741 NOTIFICATION Ignoring JIT  connection to work repository, being SSL enabled DB and connections are cached
2022-11-17 12:04:12.741 NOTIFICATION Ignoring JIT  connection to work repository, being SSL enabled DB and connections are cached
2022-11-17 12:04:14.274 NOTIFICATION Ignoring JIT  connection to master repository, being 18c or above driver and connections are cached
2022-11-17 12:04:14.821 NOTIFICATION ODI-1111 Agent OracleDIAgent1 started. Agent version: 12.2.1. Port: 20910. JMX Port: 20810.
2022-11-17 12:04:14.823 NOTIFICATION ODI-1136 Starting Schedulers on Agent OracleDIAgent1.
2022-11-17 12:04:16.281 NOTIFICATION ODI-1137 Scheduler started for work repository WORKREP on Agent OracleDIAgent1.
2022-11-17 12:04:25.973 NOTIFICATION Inside cleanStaleSessions ::::::::::::::::::::::::::::::::::::
2022-11-17 12:04:26.209 NOTIFICATION Not an InternatlAgent ::::::::::::::::startContinueLoadPlansThread:::::::::::::::
[opc@odi-instance logs]$ 

```

## <a name="documentation"></a>Documentation

[Autonomous Databases Overview](https://docs.oracle.com/en-us/iaas/Content/Database/Concepts/adboverview.htm)

[Analytics Cloud Overview](https://docs.oracle.com/en-us/iaas/analytics-cloud/index.html)

[Data Catalog Overview](https://docs.public.oneportal.content.oci.oraclecloud.com/en-us/iaas/data-catalog/using/overview.htm)

[Data Integration Overview](https://www.oracle.com/middleware/technologies/data-integration.html)

[Certificates](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm)

[Compute service](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm)

[Network Overview](https://docs.cloud.oracle.com/iaas/Content/Network/Concepts/overview.htm)

[Tagging Overview](https://docs.oracle.com/en-us/iaas/Content/Tagging/Concepts/taggingoverview.htm)

[Terraform Autonomous Databases Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/database_autonomous_database)

[Terraform Analytics Cloud Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/analytics_analytics_instance)

[Terraform Data Catalog Service Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/datacatalog_catalog)

[Terraform Certificates - TLS Provider](https://registry.terraform.io/providers/hashicorp/tls/latest/docs)

[Terraform Oracle Cloud Infrastructure Core Service](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_instance)

[Terraform Vcn resource in Oracle Cloud Infrastructure Core service](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_vcn)

[Terraform Subnet resource in Oracle Cloud Infrastructure Core service](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_subnet)

[Terraform Tag Service Resource](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_tag_namespace)


## <a name="team"></a>The Team
- **Owners**: [Panaitescu Ionel](https://github.com/ionelpanaitescu), [Corina Todea](https://github.com/ctodearo)

## <a name="feedback"></a>Feedback
We welcome your feedback. To post feedback, submit feature ideas or report bugs, please use the Issues section on this repository.	

## <a name="known-issues"></a>Known Issues
**At the moment, there are no known issues**