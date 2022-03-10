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
The compute module will create two VM's - one for a bastion that can be used to ssh or vnc to the ODI VM and the ODI VM itself. 
For the Bastion VM the shape and the linux images needs to be provided.
Here is the list of all the OCID images for each region.

``` 
linux_images = {
  ap-melbourne-1  = {
    centos6 = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaas4synyw646enlkqbgunmevfw3npohtccrpam6iqvtljesbtsqdoa"
    centos7 = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaa3wpbl3xl6jfgk3gat3gnesw7wvafzvbxl2zybh3zclr3lahllilq"
    oel6    = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaat52asmaafbfz6vdkgmopvbkwsucokrwqmxgdr5qjcwu6zutvic7a"
    oel7    = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaavpiybmiqoxcohpiih2gasjgqpsiyz4ggylyhhitmrmf3j2ycucrq"
  }
  ap-mumbai-1     = {
    centos6 = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaorpgj2wcaaawpi3sdisrsz7ahhx6k7yq27bzrcun6ohehvsp5kuq"
    centos7 = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaafr2lbi3vkymk2os3t3xqg2xp42xfqll7x73rv3j4msfuwwrbxmta"
    oel6    = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaahkxsdgr2piceahkowh7jmimywdvfe4wdc3ujizzrgmdpuansjlva"
    oel7    = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaarrsp6bazleeeghz6jcifatswozlqkoffzwxzbt2ilj2f65ngqi6a"
  }
  ap-osaka-1      = {
    centos6 = "ocid1.image.oc1.ap-osaka-1.aaaaaaaausl3ucj5slnzpjr6zc5hulnd7637eqakcscl45zc673fz3repgnq"
    centos7 = "ocid1.image.oc1.ap-osaka-1.aaaaaaaaws7jyd6nfsd6negf5ojd27m3v7xosspil7mkcnf3wfcbf3w3iq6a"
    oel6    = "ocid1.image.oc1.ap-osaka-1.aaaaaaaajoqvhi7dd776bch4uspb2xuzzhaoobrt6xh45rs3o4mv3ya4e5tq"
    oel7    = "ocid1.image.oc1.ap-osaka-1.aaaaaaaafa5rhs2n3dyuncddh5oynk6gisvotvcvch3e6xwplji7phwtbqqa"
  }
  ap-seoul-1     = {
    centos6 = "ocid1.image.oc1.ap-seoul-1.aaaaaaaajfn2tg23h6bspxhn3xlby6f6tsksagemmoaycoylxa5ivbf2prhq"
    centos7 = "ocid1.image.oc1.ap-seoul-1.aaaaaaaajsolmhhy7xjgfscxb4vpyet6k2sop6wdtwmn3dkc3fy7eyt3m24a"
    oel6    = "ocid1.image.oc1.ap-seoul-1.aaaaaaaa4rk36ectfyj2psdo3xcatz4z3x7ctber6l74vohqkbyfwoxdz3iq"
    oel7    = "ocid1.image.oc1.ap-seoul-1.aaaaaaaadrnhec6655uedkshgcklewzikoqcwr65sevbu27z7vzagniihfha"
  }
  ap-sydney-1    = {
    centos6 = "ocid1.image.oc1.ap-sydney-1.aaaaaaaaeevmpmgwugan2qljntoteqihc6ygfycwxui3nigeob7snaikuaiq"
    centos7 = "ocid1.image.oc1.ap-sydney-1.aaaaaaaayblorjjncrno3r5wh73lzmpu4ioro72oymd4eeu2hu4fsscumqha"
    oel6    = "ocid1.image.oc1.ap-sydney-1.aaaaaaaav4ooak5wysyydz4aezicqstgx3jxmjanjpdj7jonla3tk3npgzda"
    oel7    = "ocid1.image.oc1.ap-sydney-1.aaaaaaaaplq4fjdnoooudaqwgzaidh6r3lp3xdhqulx454jivy33t53hokga"
  }
  ap-tokyo-1     = {
    centos6 = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaai2umweqozk36atwr4cxaicukqjomfbueojr74fdbxe74fi75egca"
    centos7 = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaarkipypzhscxniq3uqr2jqc55maelnt7vgjikemck3k5vl5iabzrq"
    oel6    = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaadnxbyomirzk3rsp4ctmoi65n4dso3olkyf4pfdymslouoq5jcjha"
    oel7    = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaa5mpgmnwqwacey5gvczawugmo3ldgrjqnleckmnsokrqytcfkzspa"
  }
  ca-montreal-1  = {
    centos6 = "ocid1.image.oc1.ca-montreal-1.aaaaaaaafwemmq6tz6zwxfz7bvlwb6iyi7y2hzzu2mv54ngrldh6hhnyxama"
    centos7 = "ocid1.image.oc1.ca-montreal-1.aaaaaaaajxxgx4af4rcudk2avldhbebctl7e5v445ycs35wk6boneut423nq"
    oel6    = "ocid1.image.oc1.ca-montreal-1.aaaaaaaasm46wajq5kmztlbzqclqohpj3nevbi4ep2zi627xbr4uudnxxpma"
    oel7    = "ocid1.image.oc1.ca-montreal-1.aaaaaaaaevu23evecil3r23q5illjliinkpyvtkbdq5nsxmcfqypvlewytra"
  }
  ca-toronto-1   = {
    centos6 = "ocid1.image.oc1.ca-toronto-1.aaaaaaaan2fmhw2mcc7nidx6dimfzrkzdln4ckirpfyvcdp4xldnwkrlq43q"
    centos7 = "ocid1.image.oc1.ca-toronto-1.aaaaaaaabqsazpmiu5xq23pxxw3c4r6ko5rjfewk4mqkm7tgtsq4uc2exxoa"
    oel6    = "ocid1.image.oc1.ca-toronto-1.aaaaaaaayqaoapktxol6igmw26oi73pdypvwtvzxjc73i5ly4sqj3ghwaafa"
    oel7    = "ocid1.image.oc1.ca-toronto-1.aaaaaaaai25l5mqlzvhjzxvb5n4ullqu333bmalyyg3ki53vt24yn6ld7pra"
  }
  eu-amsterdam-1 = {
    centos6 = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaa4xufymkiho5dlscdbtvsru5b22knjoxcnnflgo6xloqqodfx2tda"
    centos7 = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaat32fvq5hsmbljrvy77gr2xel7i3l3oc6g3bcnnd6mimzz5jqa7ka"
    oel6    = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaacymg54gaxda5hwmf4tdaaxcmnmrfemiziweukau3c2gjqqzf77ga"
    oel7    = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaayd4knq4bdh23zqgatgjhoajiz3mx4fy3oy62e5f45ll7trwak5ga"
  }
  eu-frankfurt-1 = {
    centos6 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaf6ej4bn4wzvlocyybqn65x7osycxvobtjkcn7ya4urcsa6ql6rhq"
    centos7 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaahkaj2rzfdpruxajpy77gohgczstwhygsimohss2plkfslbbh4xfa"
    oel6    = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaawrdkszzb56yo4nb4k42txyp2yvwusgsbraztcua2b5ebsk5iz7lq"
    oel7    = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa4cmgko5la45jui5cuju7byv6dgnfnjbxhwqxaei3q4zjwlliptuq"
  }
  eu-zurich-1    = {
    centos6 = "ocid1.image.oc1.eu-zurich-1.aaaaaaaagmybtgdr33vlsaa245sulxmqvasf5pgoppbfkx2qtoonfd6pbwnq"
    centos7 = "ocid1.image.oc1.eu-zurich-1.aaaaaaaaedzqaa6w2b675og5go54nw2tmfoonqnk2kabhcdcuygbpy7habga"
    oel6    = "ocid1.image.oc1.eu-zurich-1.aaaaaaaafdub2llzurrq6ti2xff6po2x6ibm3aaabjhesgug6ceo73etquaq"
    oel7    = "ocid1.image.oc1.eu-zurich-1.aaaaaaaa4nwf5h6nl3u5cdauemg352itja6izecs7ol73z6jftsg4agpdsma"
  }
  me-jeddah-1    = {
    centos6 = "ocid1.image.oc1.me-jeddah-1.aaaaaaaac37rqyxwrl4lw2zcxkrplmkybkgykco2zzw4wbjjzbgzoj4emzxa"
    centos7 = "ocid1.image.oc1.me-jeddah-1.aaaaaaaa2hphaidibmfn6bomi756tjtb3ncakzroubrdrh4oteiexkgqzqxa"
    oel6    = "ocid1.image.oc1.me-jeddah-1.aaaaaaaa6ypmt4rwxpi2w3b5jvrzxsw6egopg3ckzhsddbbwjrdri4hyiara"
    oel7    = "ocid1.image.oc1.me-jeddah-1.aaaaaaaazrvioeng7va7w4qsuqny4jtxbvnxlf5hu7g2twn6rcwdu35u4riq"
  }
  sa-saopaulo-1   = {
    centos6 = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaat6zylwbmjc3nt3opxgr54vjuolezmxmdlkhumdkrnfzjmcalena"
    centos7 = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaa4jgkrkwd5d6ktzu43mjhri4el2p3gc7hzkkt26uhawjf6xe2s5ra"
    oel6    = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaw265lcnl4fottvdoid56arojwyxl57mihcl6g5p5dwwk457ufa6q"
    oel7    = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaalfracz4kuew4yxvgydpnbitip6qsreaz7kpxlkr4p67ravvi4jnq"
  }
  uk-gov-london-1 = {
    centos6 = "ocid1.image.oc4.uk-gov-london-1.aaaaaaaa3jm7g2knbd42qbmahxcitawva56svefikpjrlfqjdeiir4vhxdmq"
    centos7 = "ocid1.image.oc4.uk-gov-london-1.aaaaaaaavzplbvr4myylufwebu6556stwm44rhg5b7hzyljyghkzxkrpnntq"
    oel6    = "ocid1.image.oc4.uk-gov-london-1.aaaaaaaamcvr7kawh4i3sdrlok2kqkfetk573utdq5u4ighhe55r46ddmusq"
    oel7    = "ocid1.image.oc4.uk-gov-london-1.aaaaaaaaslh4pip7u6iopbpxujy2twi7diqrs6kfvqfhkl27esdadkqa76mq"
  }
  uk-london-1     = {
    centos6 = "ocid1.image.oc1.uk-london-1.aaaaaaaalaq6axfs4t4qibzlbo6mq2ejbij6rnhrdv43ic53yuu6nsziabdq"
    centos7 = "ocid1.image.oc1.uk-london-1.aaaaaaaalblgx62jnubrhfdt4kawbev4r3r2rord253r5h6b4vdsgvz7uhnq"
    oel6    = "ocid1.image.oc1.uk-london-1.aaaaaaaapir5bvtsdq6inbebytzb362kkd5tx2iz3qg7i2k4b2vbnejan6uq"
    oel7    = "ocid1.image.oc1.uk-london-1.aaaaaaaa2uwbd457cd2gtviihmxw7cqfmqcug4ahdg7ivgyzla25pgrn6soa"
  }
  us-ashburn-1    = {
    centos6 = "ocid1.image.oc1.iad.aaaaaaaa2czkuqalinjferx3iszp264xspwnd7xzlfhupxtzc4zdnuxi6bwa"
    centos7 = "ocid1.image.oc1.iad.aaaaaaaa3n6t4mwilogs7a7dvp64tptstjvivq52yasfjgw64lcbdqf4d3ca"
    oel6    = "ocid1.image.oc1.iad.aaaaaaaasxwd6pbz6py3shznyfxuxexiatoxse7zyd7tz4tmra27wle6ydwq"
    oel7    = "ocid1.image.oc1.iad.aaaaaaaavzjw65d6pngbghgrujb76r7zgh2s64bdl4afombrdocn4wdfrwdq"
  }
  us-langley-1    = {
    centos6 = "ocid1.image.oc2.us-langley-1.aaaaaaaa7bgboeixz75owe3fbdmg2pvmysk2rxob6bufkisyin3v27qsdz2q"
    centos7 = "ocid1.image.oc2.us-langley-1.aaaaaaaa3ryqvptloob45777kvfqsoymukhioddaj5yows526j4cn5enl6aa"
    oel6    = "ocid1.image.oc2.us-langley-1.aaaaaaaakzg6qr6hpm3jj7x3wyt2ya7bsh5xtvku3hmlysguuaasir6u673a"
    oel7    = "ocid1.image.oc2.us-langley-1.aaaaaaaauckkms7acrl6to3cuhmv6hfjqwlnoxzuzophaose7pi2sfk4dzna"
  }
  us-luke-1       = {
    centos6 = "ocid1.image.oc2.us-luke-1.aaaaaaaa6woblaikk4fmyciqfwmbvoeukgq2m3jt5rrqyclseehrsawwkpyq"
    centos7 = "ocid1.image.oc2.us-luke-1.aaaaaaaa4o74g2lmljky7fgx4o5zr3aw7rww7jjkliwbqoxq6yu5vjm23e3a"
    oel6    = "ocid1.image.oc2.us-luke-1.aaaaaaaajyelyu6k7kzyoxeneyye74ld3osxx53ufeh4a2thrnpub5zi47mq"
    oel7    = "ocid1.image.oc2.us-luke-1.aaaaaaaadxeycutztmvaeefvilc57lfqool2rlgl2r34juyu4jkbodx2xspq"
  }
  us-phoenix-1    = {
    centos6 = "ocid1.image.oc1.phx.aaaaaaaau6s3kqgtnuxtu2yc7czi2z4ylcn5mhx7igcmhb3ujjaiypcjhozq"
    centos7 = "ocid1.image.oc1.phx.aaaaaaaak3hatlw7tncpvvatc4t7ihocxfx243ii54m2kuxjlsln4vnspnea"
    oel6    = "ocid1.image.oc1.phx.aaaaaaaas3h3h5hr3uvfliydhvusoscpqzflewislg4m3ycj6y6y3exvbe3a"
    oel7    = "ocid1.image.oc1.phx.aaaaaaaacy7j7ce45uckgt7nbahtsatih4brlsa2epp5nzgheccamdsea2yq"
  }
}
```

More information regarding shapes can be found here:
https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm

* Parameters for the VM Bastion Compute Configuration
    * __bastion_shape__ - (Required) (Updatable) The shape of an instance. The shape determines the number of CPUs, amount of memory, and other resources allocated to the instance.
    * __bation_linux_image__ - the linux image OCID for your region.

Below is an example:
```
# VM Bastion Compute Configuration

variable "bastion_shape" {
  default = "VM.Standard2.4"
}

variable "bation_linux_image" {
  default = "ocid1.image.oc1.iad.aaaaaaaavzjw65d6pngbghgrujb76r7zgh2s64bdl4afombrdocn4wdfrwdq"
}
```

* Parameters for the ODI VM Configuration
    * __odi_instance_shape__ - (Required) (Updatable) The shape of an instance. The shape determines the number of CPUs, amount of memory, and other resources allocated to the instance.
    * __adw_username__ - the Autonomous Data Warehouse username
    * __adw_password__ - the Autonomous Data Warehouse password provided 
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
  default = "VM.Standard2.4"
}

variable "adw_username" {
  type = string
  default = "admin"
}

variable "adw_password" {
  type = string
  default = "<enter-password-here>"
}

variable "odi_vnc_password" {
  type = string
  default = "<enter-password-here>"
}

variable "odi_schema_prefix" {
  type = string
  default = "odi"
}

variable "odi_schema_password" {
  type = string
  default = "<enter-password-here>"
}

variable "odi_password" {
  type = string
  default = "<enter-password-here>"
}

variable "adw_creation_mode" {
  type = bool
  default = true
}

variable "embedded_db" {
  type = bool
  default = false
}

variable "studio_mode" {
  type = string
  default = "ADVANCED"     # "ADVANCED" or  "Web"
}

variable "db_tech" {
  type = string
  default = "ADB"
}

variable "studio_name" {
  type = string
  default = "ADVANCED"     # "ADVANCED" ,  "ODI Web Studio Administrator" or "ODI Studio"
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
Component schemas created:
-----------------------------
Component                                    Status         Logfile		

Common Infrastructure Services               Success        /tmp/RCU2022-03-03_09-53_432763643/logs/stb.log 
Oracle Platform Security Services            Success        /tmp/RCU2022-03-03_09-53_432763643/logs/opss.log 
Master and Work Repository                   Success        /tmp/RCU2022-03-03_09-53_432763643/logs/odi.log 
Audit Services                               Success        /tmp/RCU2022-03-03_09-53_432763643/logs/iau.log 
Audit Services Append                        Success        /tmp/RCU2022-03-03_09-53_432763643/logs/iau_append.log 
Audit Services Viewer                        Success        /tmp/RCU2022-03-03_09-53_432763643/logs/iau_viewer.log 
WebLogic Services                            Success        /tmp/RCU2022-03-03_09-53_432763643/logs/wls.log 

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

File saved!
Fetching all ADB instances...
Generating wallet for ADB Instance: ADWipn
Generating wallet for ADB Instance: ADWipan
ODI Marketplace configuration started.
Invoking ADB config
ODI configuration for ADB technology
Start wallet download
updating configuration
Starting repository creation for db tech
Running common configuration.
[INFO] Configuration is allowed.
Seeding ODI repository...
Running ODI MP common config...
Configuring ADB dataservers in ODI repo...
ODI configuration completed
[oracle@odi-instance logs]$

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