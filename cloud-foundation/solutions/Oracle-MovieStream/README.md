# Oracle Cloud Foundation Terraform Solution - Oracle MovieStream - Integrate, Analyze and Act on All data using Autonomous Database
![](https://oracle-livelabs.github.io/adb/movie-stream-story-lite/introduction/images/moviestream.jpeg)

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


Introducing Action! MovieStream Analytics Produce the Best Picture with Oracle Cloud

[![Introducing Action! MovieStream Analytics Produce the Best Picture with Oracle Cloud](https://img.youtube.com/vi/fwkBA6A7isI/maxresdefault.jpg)](https://youtu.be/fwkBA6A7isI "Introducing Action! MovieStream Analytics Produce the Best Picture with Oracle Cloud")


Most workshops focus on teaching you about a cloud service or performing a series of tasks. This workshop is different. You will learn how to deliver high value solutions using Oracle Cloud data platform services. And, the workshop will do this in the context of a company that we all can relate to and understand.

Estimated Workshop Time: 1 hour

There are two versions of this workshop:

[Integrate, Analyze and Act on All data using Autonomous Database (Epic)](https://apexapps.oracle.com/pls/apex/r/dbpm/livelabs/view-workshop?wid=865&clear=180&session=109496871805585) - dives into details of setting up the solution and analyzing data. Will take several hours to complete.

[Integrate, Analyze and Act on All data using Autonomous Database](https://apexapps.oracle.com/pls/apex/r/dbpm/livelabs/view-workshop?wid=889) - this workshop! A one hour version that performs much of the setup for you.

If you would like to watch us do the workshop, [_click here_](https://www.youtube.com/watch?v=z2Er2yTP2BU).

There are also other workshops that focus on specific feature areas that also use the same business scenario.

Oracle MovieStream is a fictitious movie streaming service - similar to those that you currently subscribe to. They face challenges that are typical to many organizations across industries. MovieStream must:

Gain a better understanding of their customers to ensure that they love the service
Offer the right products to the right customers at the right price
Grow the business to become a dominant player in the streaming business
And much, much more
Oracle Cloud provides an amazing platform to productively deliver secure, insightful, scalable and performant solutions. MovieStream designed their solution leveraging the world class Oracle Autonomous Database and Oracle Cloud Infrastructure (OCI) Data Lake services. Their data architecture is following the Oracle Reference Architecture [_Enterprise Data Warehousing - an Integrated Data Lake_](https://docs.oracle.com/en/solutions/oci-curated-analysis/index.html) - which is used by Oracle customers around the world. It's worthwhile to review the architecture so you can understand the value of integrating the data lake and data warehouse - as it enables you to answer more complex questions using all your data.


## <a name="deliverables"></a>Deliverables
----------------

 This repository encloses one deliverable:

- A reference implementation written in Terraform HCL (Hashicorp Language) that provisions fully functional resources in an OCI tenancy. On top we will deploy a moviestream application.

You will learn how they built their solution and performed sophisticated analytics through a series of labs that highlight the following:

Objectives:
* Deploy an Autonomous Database instance
* Integrate Autonomous Database with the Data Lake
* Use advanced SQL to uncover issues and possibilities
* Predict customer churn using Machine Learning
* Use spatial analyses to help provide localized promotions
* Offer recommendations based on graph relationships

## <a name="architecture"></a>Architecture-Diagram
----------------

In this workshop, we'll start with two key components of MovieStream's architecture. MovieStream is storing their data across Oracle Object Storage and Autonomous Database. Data is captured from various sources into a landing zone in object storage. This data is then processed (cleansed, transformed and optimized) and stored in a gold zone on object storage. Once the data is curated, it is loaded into an Autonomous Database where it is analyzed by many (and varied) members of the user community.


![](https://oracle-livelabs.github.io/adb/movie-stream-story-lite/introduction/images/architecture.png)


## <a name="instructions"></a>Executing Instructions
----------------

## Prerequisites

- Permission to `manage` the following types of resources in your Oracle Cloud Infrastructure tenancy: `vcns`, `nat-gateways`, `route-tables`, `subnets`, `service-gateways`, `security-lists`, `autonomous database`, `data catalog` and `compute instances`.
- Quota to create the following resources: 1 ADW database instance and 1 VM that will serve as a bastion to deploy the elements of the solution and on top will play the role of a webserver with docker container to run the moviestream application; quota to deploy 1 Data Catalog inside OCI.
If you don't have the required permissions and quota, contact your tenancy administrator. See [Policy Reference](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm), [Service Limits](https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm), [Compartment Quotas](https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcequotas.htm).

# <a name="Deploy-Using-Oracle-Resource-Manager"></a>Deploy Using Oracle Resource Manager

1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation/releases/download/v1.0.0/Oracle-MovieStream-RM.zip)


    If you aren't already signed in, when prompted, enter the tenancy and user credentials.

2. Review and accept the terms and conditions.
3. Select the region where you want to deploy the stack.
4. Follow the on-screen prompts and instructions to create the stack.
5. After creating the stack, click **Terraform Actions**, and select **Plan**.
6. Wait for the job to be completed, and review the plan.
    To make any changes, return to the Stack Details page, click **Edit Stack**, and make the required changes. Then, run the **Plan** action again.
7. If no further changes are necessary, return to the Stack Details page, click **Terraform Actions**, and select **Apply**. 

## <a name="After-Deployment-via-Resource-Manager"></a>What to do after the Deployment via Resource Manager
----------------

## Oracle MovieStream demonstration deployment

This stack installs everything required to run the Oracle MovieStream application and learn how to use the analytics. After deploying the stack, the following services and infrastructure will be deployed:

* Virtual Cloud Network
* Autonomous Database
* Compute (bastion hosting the MovieStream application)
* Data Catalog

You can find details for connecting to these services in the Stack's Job Details Output.

## Connecting to the MovieStream application
The Oracle MovieStream application is deployed to the compute instance. It automatically connects to your Autonomous Database. You can access it using the `web-instance-all_public_ips` IP address:

https://<`web-instance-all_public_ips`>

## Connect to Autonomous Database
Go to Autonomous Database in the OCI console. The default name given to the database instance is: **OracleMovieStream**. You specified the ADMIN password when deploying the Oracle MovieStream stack. 

A database user was created during the deployment. You can connect as that user to look at the database schema, use analytic features, etc. 

* User: `MOVIESTREAM`, Password: `watchS0meMovies#`
* User: `ADMIN`, Password: `WlsAtpDb1234#`

Please change these passwords after deployment.

## Using database tools and applications

All of the Autonomous Database tools are available to you, including SQL worksheet, Data Studio, Machine Learning and Graph notebooks, etc. Go to Database Actions to access these tools. 

* **Database Actions:** Load, explore, transform, model, and catalog your data. Use an SQL worksheet, build REST interfaces and low-code apps, manage users and connections, build and apply machine learning models. 

Access Link is the graph_studio_url URL from the output. Example:
https://RDDAINSUH6U1OKC-ORACLEMOVIESTREAM.adb.us-ashburn-1.oraclecloudapps.com/ords/sql-developer


* **Graph Studio:** Oracle Graph Studio lets you create scalable property graph databases. Graph Studio automates the creation of graph models and in-memory graphs from database tables. It includes notebooks and developer APIs that allow you to execute graph queries using PGQL (an SQL-like graph query language) and over 50 built-in graph algorithms. Graph Studio also offers dozens of visualization, including native graph visualization. 

Access Link is the graph_studio_url URL from the output. Example:
https://RDDAINSUH6U1OKC-ORACLEMOVIESTREAM.adb.us-ashburn-1.oraclecloudapps.com/graphstudio/


* **Application Express:** Oracle Application Express (APEX) is a low-code development platform that enables you to build scalable, secure enterprise apps that can be deployed anywhere. 

Access Link is the graph_studio_url URL from the output. Example:
https://RDDAINSUH6U1OKC-ORACLEMOVIESTREAM.adb.us-ashburn-1.oraclecloudapps.com/ords/sql-developer


* **Oracle Machine Learning User Notebooks:** Oracle Machine Learning notebooks provide easy access to Oracle's parallelized, scalable in-database implementations of a library of Oracle Advanced Analytics' machine learning algorithms (classification, regression, anomaly detection, clustering, associations, attribute importance, feature extraction, times series, etc.), SQL, PL/SQL and Oracle's statistical and analytical SQL functions. 

The stack's job output also includes URLs that take you directly to the tools.

Access Link is the machine_learning_user_management_url URL from the output. Example:
https://RDDAINSUH6U1OKC-ORACLEMOVIESTREAM.adb.us-ashburn-1.oraclecloudapps.com/omlusers/

## Connecting to the bastion
The IP address to the bastion can be found in the stack's job output: `web-instance-all_public_ips`. Use the `generated_ssh_private_key_for_bastion` to make your connection via ssh.

- Go inside your terminal and connect to the  and create a file for your private key, paste the key copied inside the file and save the file.

An example is below:
```
$ touch private_key_bastion.pem
$ vi private_key_bastion.pem 
$ cat private_key_bastion.pem
-----BEGIN RSA PRIVATE KEY-----
MIIJJwIBAAKCAgEAomiZwto82D6e1+hzm5mjxAQ+LnzBGs40XkbRwJH2us/nQLOW
DX7eV91X8KQpWSwPSiYZsZ2j7ZknqLUA6k0VP/KNMop203temNunjUC6ZYgTtzcP
gMQqJ3G3IGb4eIgcvm/WziOheSgKsk7XYufGMdvAE8iDyS+15sSZEILLPtpKlCEc
..........
..........
zM15dhNSSj5sqJJHurrInBVf0J6U5D+glexxo/TA/qz7IhSJ+NY/iCANwg==
-----END RSA PRIVATE KEY-----

$ chmod 600 private_key_bastion.pem 

```

__SSH to the bastion:__

```
$ ssh -i private_key_bastion.pem  opc@PUBLIC_IP_OF_THE_BASTION -o IdentitiesOnly=yes
# sudo docker ps

```

# <a name="Deploy-Using-the-Terraform-CLI"></a>Deploy Using the Terraform CLI


## Clone the Module
Now, you'll want a local copy of this repo. You can make that with the commands:

    git clone https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation.git
    cd terraform-oci-oracle-cloud-foundation/cloud-foundation/solutions/some-folder
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


* **modules(folder)** - ( this folder will be pressent only for the Resource Manager zipped files) Contains folders with subsystems and modules for each section of the project: networking, autonomous database, analytics cloud, object storage, data catalog etc.
Also in the modules folder there is a folder called provisioner - that will provision your full infrastructure with the data model.
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
  default = "OracleMovieStream"
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
  default = "LICENSE_INCLUDED"
}

```

<!-- # Data Catalog
This resource provides the Catalog resource in Oracle Cloud Infrastructure Data Catalog service.
Creates a new data catalog instance that includes a console and an API URL for managing metadata operations. For more information, please see the documentation.

Note: if you are using Always free Autonomous database and Always free shape for the VM - VM.Standard.E2.1.Micro - the data catalog will not be deployed.

* Parameters:
    * __catalog_display_name__ - Data catalog identifier. 


Below is an example:
```
variable "catalog_display_name" {
    type    = string
    default = "OracleMovieStream"
}
``` -->

# Compute VM

The compute module will create one VM bastion that will be populated with all the necessary scripts, configuration and data inside the Autonomous Database. 

This VM is using the Oracle-Linux-Cloud-Developer-8.5-2022.05.22-0 image - that commes with all the neccesarry packages to deploy the solution. 
After the solution it's deployed it will create a container using docker and run a the moviestream application on top of the VM that can be accessed via http.

For the Bastion VM the shape and the display name needs to be provided.

More information regarding shapes can be found here:
https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm

* Parameters for the VM Bastion Compute Configuration
    * __bastion_source_image_id__ - (Required) It's a map of strings with each OCID for each region inside OCI of the image that will be deployed on the VM. 
    * __bastion_instance_display_name__ - The name of your bastion VM instance.
    * __bastion_instance_shape__ - (Required) (Updatable) The shape of an instance. The shape determines the number of CPUs, amount of memory, and other resources allocated to the instance.
    * __bastion_availability_domain__ - The availability domain of the instance. Note if you deploy the solution in a regions where there are more than one of availability domain you can specify where to place the VM. If you deploy the solution in a region with only one availability domain , leave the variable with the default of 1. 
    If you want to deploy a Always FREE VM, you need to check where the shape of VM.Standard.E2.1.Micro is available in wich availability domain.


Below is an example:
```
# Bastion Instance Variables: 
# Oracle-Linux-Cloud-Developer-8.5-2022.05.22-0 image

variable "bastion_source_image_id" {
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
  default = "Oracle-MovieStream"
}

variable "bastion_instance_shape" {
    type    = string
    default  = "VM.Standard2.4"
    # default = "VM.Standard.E2.1.Micro" # always free instance
}

variable "bastion_availability_domain" {
  type    = number
  default = 1
}
```


# Network
This resource provides the Vcn resource in Oracle Cloud Infrastructure Core service anso This resource provides the Subnet resource in Oracle Cloud Infrastructure Core service.
The solution will create 1 VCN in your compartment, 2 subnets ( one public and one private so the analytics cloud instance can be public or private ), 2 route tables for incomming and outoing traffic, 2 Network Security Groups for ingress and egress traffic, 1 internet gateway, 2 route tables for each subnet, dhcp service, NAT Gateway and a Service Gateway.

* Parameters
    * __service_name__ - The names of all compute and network resources will begin with this prefix. It can only contain letters or numbers and must begin with a letter.
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

variable "service_name" {
  type        = string
  default     = "OracleMovieStream"
  description = "A prefix for policies and dynamic groups names - scope: to be unique names not duplicates"
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
Apply complete! Resources: 2 added, 14 changed, 1 destroyed.

Outputs:

ADW_Database_db_connection = tolist([
  {
    "all_connection_strings" = tomap({
      "HIGH" = "adb.us-ashburn-1.oraclecloud.com:1522/rddainsuh6u1okc_oraclemoviestreamip_high.adb.oraclecloud.com"
      "LOW" = "adb.us-ashburn-1.oraclecloud.com:1522/rddainsuh6u1okc_oraclemoviestreamip_low.adb.oraclecloud.com"
      "MEDIUM" = "adb.us-ashburn-1.oraclecloud.com:1522/rddainsuh6u1okc_oraclemoviestreamip_medium.adb.oraclecloud.com"
    })
    "dedicated" = ""
    "high" = "adb.us-ashburn-1.oraclecloud.com:1522/rddainsuh6u1okc_oraclemoviestreamip_high.adb.oraclecloud.com"
    "low" = "adb.us-ashburn-1.oraclecloud.com:1522/rddainsuh6u1okc_oraclemoviestreamip_low.adb.oraclecloud.com"
    "medium" = "adb.us-ashburn-1.oraclecloud.com:1522/rddainsuh6u1okc_oraclemoviestreamip_medium.adb.oraclecloud.com"
    "profiles" = tolist([
      {
        "consumer_group" = "HIGH"
        "display_name" = "oraclemoviestreamip_high"
        "host_format" = "FQDN"
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "MUTUAL"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=rddainsuh6u1okc_oraclemoviestreamip_high.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))"
      },
      {
        "consumer_group" = "LOW"
        "display_name" = "oraclemoviestreamip_low"
        "host_format" = "FQDN"
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "MUTUAL"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=rddainsuh6u1okc_oraclemoviestreamip_low.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))"
      },
      {
        "consumer_group" = "MEDIUM"
        "display_name" = "oraclemoviestreamip_medium"
        "host_format" = "FQDN"
        "protocol" = "TCPS"
        "session_mode" = "DIRECT"
        "syntax_format" = "LONG"
        "tls_authentication" = "MUTUAL"
        "value" = "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=rddainsuh6u1okc_oraclemoviestreamip_medium.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))"
      },
    ])
  },
])
DataCatalog_Name = toset([
  {
    "OracleMovieStream" = "OracleMovieStream"
  },
])
Database_Actions = [
  "https://RDDAINSUH6U1OKC-ORACLEMOVIESTREAMIP.adb.us-ashburn-1.oraclecloudapps.com/ords/sql-developer",
]
Instructions = "Please use the public IP address listed below to connect to the moviestream application via a web-browser."
database_fully_qualified_name = "rddainsuh6u1okc-oraclemoviestreamip.adb.us-ashburn-1.oraclecloudapps.com"
datacatalog_connection = toset([
  {
    "OracleMovieStream" = "OracleMovieStream"
  },
])
datacatalog_data_asset = toset([
  {
    "OracleMovieStream" = "OracleMovieStream"
  },
])
generated_ssh_private_key_for_bastion = <<EOT
-----BEGIN RSA PRIVATE KEY-----
MIIJKAIBAAKCAgEA74zQdQUoEq6PcaDVfko3/ok0vo4dkfmSPR8onDoMyMqbfA4u
cYVCgj/0A6f+qh44YcPBMw9gEgmSlhqrC4mu/wNR6OqUe/NSMjkP7P7rQ1ZD6rd6
................................................................
................................................................
V7QEYmpqqpsO0Y1NV1O+kwD0b4etuFKriOBL9MbkijSZ3rDke4Az/8jCDaRpsC20
W0viKd7PHJL7Re2fsM2fd1WEcmZ4rS50eBK5GZ0+LFKDRXmLGUh90eyjUQAClrvg
c5rKfrumDwo+iR0GWRg9eB8Gby4tMpe2wNP3C7VvWeWXD+uftexOmNGgo58is9zx
PkZX9A26CvvAI0NbYyKvo2FXQFDAIzsBAoIBACdVelTMpkvuPL+/9FiVKd5Vi5Qp
h8mvoHICEBPe4QU//BzBlZghVKDGKUL3ouHkMzgt4zaFns9QOJdElSENS8yGibyU
J+kk3KCGksJ3UORwd5MPWQciU27myf/rc9KPoBQ5iSXEC3v8IO7pq3/Qe15rPuAm
9tm1WqTgvry8vr6iaUPh6wQiuWLZytnNKCnJHFHVMbS1XYJA1W39ZU7Y4CuroAb6
wnmUAYFoUdDIC7IyxAofmYml4rmCEwDB3N/U5GDvWShH9dpxDDBP1IKfBsRSzVof
TEduIIbKeBytX4p6Z8BxkbxBQGgqIvPi0QOJAlnEUjNKYukGCQ+7bL8s6tw=
-----END RSA PRIVATE KEY-----

EOT
graph_studio_url = [
  "https://RDDAINSUH6U1OKC-ORACLEMOVIESTREAMIP.adb.us-ashburn-1.oraclecloudapps.com/graphstudio/",
]
machine_learning_user_management_url = [
  "https://RDDAINSUH6U1OKC-ORACLEMOVIESTREAMIP.adb.us-ashburn-1.oraclecloudapps.com/omlusers/",
]
web-instance-all_instances = {
  "Oracle-MovieStream" = "ocid1.instance.oc1.iad.anuwcljtknuwtjicszf54clf7ato3mmomigkditqly6brkduby5xxmz6x7ia"
}
web-instance-all_private_ips = {
  "Oracle-MovieStream" = "10.0.0.192"
}
web-instance-all_public_ips = {
  "Oracle-MovieStream" = "143.47.121.145"
}

```

- Get the public IP address of the web-instance - example:

```
 web-instance-all_public_ips = {
  "Oracle-MovieStream" = "143.47.121.145"
}
```

## Oracle MovieStream demonstration deployment

This stack installs everything required to run the Oracle MovieStream application and learn how to use the analytics. After deploying the stack, the following services and infrastructure will be deployed:

* Virtual Cloud Network
* Autonomous Database
* Compute (bastion hosting the MovieStream application)
* Data Catalog

You can find details for connecting to these services in the Stack's Job Details Output.

## Connecting to the MovieStream application
The Oracle MovieStream application is deployed to the compute instance. It automatically connects to your Autonomous Database. You can access it using the `web-instance-all_public_ips` IP address:

https://<`web-instance-all_public_ips`>

## Connect to Autonomous Database
Go to Autonomous Database in the OCI console. The default name given to the database instance is: **OracleMovieStream**. You specified the ADMIN password when deploying the Oracle MovieStream stack. 

A database user was created during the deployment. You can connect as that user to look at the database schema, use analytic features, etc. 

* User: `MOVIESTREAM`, Password: `watchS0meMovies#`
* User: `ADMIN`, Password: `WlsAtpDb1234#`

Please change these passwords after deployment.

## Using database tools and applications

All of the Autonomous Database tools are available to you, including SQL worksheet, Data Studio, Machine Learning and Graph notebooks, etc. Go to Database Actions to access these tools. 

* **Database Actions:** Load, explore, transform, model, and catalog your data. Use an SQL worksheet, build REST interfaces and low-code apps, manage users and connections, build and apply machine learning models. 

Access Link is the graph_studio_url URL from the output. Example:
https://RDDAINSUH6U1OKC-ORACLEMOVIESTREAM.adb.us-ashburn-1.oraclecloudapps.com/ords/sql-developer


* **Graph Studio:** Oracle Graph Studio lets you create scalable property graph databases. Graph Studio automates the creation of graph models and in-memory graphs from database tables. It includes notebooks and developer APIs that allow you to execute graph queries using PGQL (an SQL-like graph query language) and over 50 built-in graph algorithms. Graph Studio also offers dozens of visualization, including native graph visualization. 

Access Link is the graph_studio_url URL from the output. Example:
https://RDDAINSUH6U1OKC-ORACLEMOVIESTREAM.adb.us-ashburn-1.oraclecloudapps.com/graphstudio/


* **Application Express:** Oracle Application Express (APEX) is a low-code development platform that enables you to build scalable, secure enterprise apps that can be deployed anywhere. 

Access Link is the graph_studio_url URL from the output. Example:
https://RDDAINSUH6U1OKC-ORACLEMOVIESTREAM.adb.us-ashburn-1.oraclecloudapps.com/ords/sql-developer


* **Oracle Machine Learning User Notebooks:** Oracle Machine Learning notebooks provide easy access to Oracle's parallelized, scalable in-database implementations of a library of Oracle Advanced Analytics' machine learning algorithms (classification, regression, anomaly detection, clustering, associations, attribute importance, feature extraction, times series, etc.), SQL, PL/SQL and Oracle's statistical and analytical SQL functions. 

The stack's job output also includes URLs that take you directly to the tools.

Access Link is the machine_learning_user_management_url URL from the output. Example:
https://RDDAINSUH6U1OKC-ORACLEMOVIESTREAM.adb.us-ashburn-1.oraclecloudapps.com/omlusers/

## Connecting to the bastion

- As the private key for the Bastion was created on the fly - we will use it to connect to the Bastion Host.

__SSH to the bastion with the Public IP Adress printed on the output from terraform:__

```
$ ssh -i private_key_bastion.pem  opc@PUBLIC_IP_OF_THE_BASTION -o IdentitiesOnly=yes
# sudo docker ps
```


## <a name="documentation"></a>Documentation

[Autonomous Databases Overview](https://docs.oracle.com/en-us/iaas/Content/Database/Concepts/adboverview.htm)

<!-- [Data Catalog Overview](https://docs.public.oneportal.content.oci.oraclecloud.com/en-us/iaas/data-catalog/using/overview.htm) -->

[Certificates](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm)

[Compute service](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm)

[Network Overview](https://docs.cloud.oracle.com/iaas/Content/Network/Concepts/overview.htm)

[Terraform Autonomous Databases Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_autonomous_database)

<!-- [Terraform Data Catalog Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/datacatalog_catalog) -->

[Terraform Certificates - TLS Provider](https://registry.terraform.io/providers/oracle/tls/latest/docs)

[Terraform Oracle Cloud Infrastructure Core Service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance)

[Terraform Vcn resource in Oracle Cloud Infrastructure Core service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_vcn)

[Terraform Subnet resource in Oracle Cloud Infrastructure Core service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet)


## <a name="team"></a>The Team
- **Owners**: [Panaitescu Ionel](https://github.com/ionelpanaitescu) , [Marty Gubar](https://github.com/martygubar)

## <a name="feedback"></a>Feedback
We welcome your feedback. To post feedback, submit feature ideas or report bugs, please use the Issues section on this repository.	

## <a name="known-issues"></a>Known Issues
**At the moment, there are no known issues for this solution**


