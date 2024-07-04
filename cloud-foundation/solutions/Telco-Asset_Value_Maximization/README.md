# Oracle Cloud Foundation Terraform Solution - Deploy Telco Fixed Asset Value Maximization

## Table of Contents
1. [Overview](#overview)
1. [Deliverables](#deliverables)
1. [Architecture](#Architecture-Diagram)
1. [Executing Instructions](#instructions)
    1. [Deploy Using Oracle Resource Manager](#Deploy-Using-Oracle-Resource-Manager)
        1. [What to do after the Deployment via Resource Manager](#What-to-do-after-the-Deployment-via-Resource-Manager)
    2. [Deploy Using the Terraform CLI](#Deploy-Using-the-Terraform-CLI)
        1. [What to do after the Deployment via Terraform CLI](#What-to-do-after-the-Deployment-via-Terraform-CLI)
1. [Documentation](#documentation)
1. [The Team](#team)
1. [Feedback](#feedback)
1. [Known Issues](#known-issues)
1. [Contribute](#CONTRIBUTING.md)


## <a name="overview"></a>Overview

Lakehouse for Telcos Monetization and Asset Value Maximization Targets for Tower and Telecommunication Companies:
Telco Data environment complexity and multiple sources make it challenging to adapt quickly to a Data Driven Business Operating Model and rapidly both monetize Fixed Assets and improve their returns. 

Telco industry is going through a digital disruption and leveraging advanced technologies such as AI, ML, Big Data, Analytics etc. for digital transformation. Consistent with the Monetization and Asset Value Maximization Targets for Tower and Telecommunication Companies, most of our customers are evaluating strategies and tools to achieve greater Fixed Asset productivity and performance at reduced cost. 

Oracle Telco Lakehouse solution demonstrates “Data Platform” approach can with Speed connect to multiple data sources to make sense of the data and present it in a form that can be exploited to Manage the Business. 

The What:
Intent: Consistent with the Monetization and Asset Value Maximization Targets for Tower and Telecommunication Companies, most of our customers are evaluating strategies and tools to achieve greater Fixed Asset productivity and performance at reduced cost.

Oracle Intent: Show how a “Data Platform” approach can with Speed connect to multiple data sources to make sense of the data and present it in a form that can be exploited to Manage the Business

So What: Telco Data environment complexity and multiple sources make it challenging to adapt quickly to a Data Driven Business Operating Model and rapidly both monetize Fixed Assets and improve their returns. 



## <a name="deliverables"></a>Deliverables
 This repository encloses one deliverable:

- A reference implementation written in Terraform HCL (Hashicorp Language) that provisions fully functional resources in an OCI tenancy.

- On top we will use a script written in bash that will insert inside the Oracle Analytics Cloud a default bar with visuals for the data that's in the Autonomous Database.


## <a name="architecture"></a>Architecture-Diagram

The following diagram shows a mapping of the architecture above to services provided on Oracle Cloud Infrastructure using security best practices and at the end of the deployment you will have in your tenancy the related services.


![](./images/Telco-Asset_Value_Maximization.png)

![](./images/Telco-Asset_Value_Maximization_arch.png)

## <a name="instructions"></a>Executing Instructions

## Prerequisites

- Permission to `manage` the following types of resources in your Oracle Cloud Infrastructure tenancy: `vcns`, `nat-gateways`, `route-tables`, `subnets`, `service-gateways`, `security-lists`, `autonomous database`, `Analytics Cloud`, `object storage`, `compute instances`, `Data Catalog`, and `big data service - hive (optional)`.
- Quota to create the following resources: 1 ADW database instance, 1 Analytics Cloud, 1 object storge, 1 data catalog, and 1 VM instance. Additionaly the Big Data Cluster can be added if needed.
If you don't have the required permissions and quota, contact your tenancy administrator. See [Policy Reference](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm), [Service Limits](https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm), [Compartment Quotas](https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcequotas.htm).

# <a name="Deploy-Using-Oracle-Resource-Manager"></a>Deploy Using Oracle Resource Manager

1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation/releases/download/v1.0.0/Telco-Asset_Value_Maximization-RM.zip)


If you aren't already signed in, when prompted, enter the tenancy and user credentials.

2. Review and accept the terms and conditions.
3. Select the region where you want to deploy the stack.
4. Follow the on-screen prompts and instructions to create the stack.

* note - for the The OCI ociPrivateKeyWrapped -  The key that you have created or your own existing private key must be wrapped. You must pass this signing key in the payload for some snapshot APIs. Before you add it to the payload, you must Base64 encode the private key (ociPrivateKeyWrapped). For example, to generate a Base64 encoded string from your private key:
 - On Mac: cat myprivate-key.pem | base64 -o mywrapped-private-key.pem
 - On Linux: cat myprivate-key.pem | base64 -w 0 > mywrapped-private-key.pem
 - Note: Ensure that the private key file that you encode includes -----BEGIN and -----END tags.

5. After creating the stack, click **Terraform Actions**, and select **Plan**.
6. Wait for the job to be completed, and review the plan.
    To make any changes, return to the Stack Details page, click **Edit Stack**, and make the required changes. Then, run the **Plan** action again.
7. If no further changes are necessary, return to the Stack Details page, click **Terraform Actions**, and select **Apply**.

# <a name="What-to-do-after-the-Deployment-via-Resource-Manager"></a>What-to-do-after-the-Deployment-via-Resource-Manager

After the deployment finished you will need to: 
1. Download the Data-Lakehouse-Communications-Tower-Analytics-using-OML.json locally on your device from the link below: 
https://objectstorage.us-ashburn-1.oraclecloud.com/p/3DKrefhNXRXlUFuua9qooD6XtOMfvhaIv5Q-qBeEs3UAefvgDlP_oHV1Jsirhqk_/n/oradbclouducm/b/DataModelsTelco/o/Data-Lakehouse-Communications-Tower-Analytics-using-OML.json 

2. Login into the Oracle Machine Learning instance URL provided in the outputs (example :  OML_URL = "https://rddainsuh6u1okc-telcoasset.adb.us-ashburn-1.oraclecloudapps.com/oml"
) -  using the user "DMISHRA" and the Admin password provided for the database ( as the DMISHRA user has the same password as Admin). You can also change the DMISHRA or Admin passwords after.
3. In OML Home page Click on Hamburger icon and go to Notebooks
4. Import Data Lakehouse Communications-Tower Analytics using .json file downloaded before.
5. Once Imported successfully Click on Open.
6. To run any of the paragraphs, click on the Run button in the right hand side of the paragraph. The second and third buttons next to it can be used to Show/Hide Editor and Show/Hide Output.

* Visualizing Results in OML

1.	Click on the Settings icon right corner to avail the different options such as clearing the output, removing a paragraph, shifting the paragraph, changing the font appearance, hide title and to disable a running paragraph.
2. 	If required, a new paragraph can be added to the notebook by hovering between two paragraphs or between a paragraph and the Notebook Title section 
3.	If the results of a Python code paragraphs needs to be visualized, the paragraph should start with %python and ends with a dataframe. (SQL query needs to start with %sql).
4.	Once the query is rendered the following visualization Table, Bar Chart, Pie Chart, Area Chart, Line Chart, Scatter Chart can be selected to render it in particular visualization.
5.	The rendered Data can be downloaded as a CSV or TSV.
6.	Click the Settings icon to view the Available Fields, which are the tables, returned in the query result. Any of these fields can be selected in the Keys area (which are rendered on the X-axis) or Values area (which are rendered on the Y-axis). If the data needs to be grouped according to some field, that field can be added to the Groups area.

__Next part is the Data Visualization by OCI Analytics - can be monitored visually through Analytics Dashboard :__

After the soltution was deployed successfully from Resource Manager you will need to get the outputs especially the private key that was generated on the fly and also the public IP of the Bastion and to connect to it.

- Go to Outputs - click on "show" at the "generated_ssh_private_key_for_bastion" output and click copy.

- Go inside your terminal and create a file for your private key, paste the key copied inside the file and save the file.

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
$ ssh -i private_key_bastion.pem  opc@ui_data_server_public_ip -o IdentitiesOnly=yes

```
To interact with the Oracle Analytics API you will need to set up the credentials.
As the deployment it's getting automated all your credentials from the terraform like , ociUserId ,ociKeyFingerprint ,ociTenancyId and ociRegion  you will need to update also your private key. 
For this - edit the /home/opc/.oci/oci_api_key.pem file - and replace the content of the key with your own private key that you used to deploy the solution with terraform, the one that you use for authentificating on the OCI API located into your ~/.oci/config file.

Now you will need to do one manual step to grab the token of the Oracle Analytics Cloud and insert it in a shell script.

- Go inside your Tenancy, click on the Menu, click on Identity & Security and under Identity click on Federation.
Click on your identity provider and click on the link in the middle called : Oracle Identity Cloud Service Console: https://idcs-abcd.identity.oraclecloud.com/ui/v1/adminconsole

![](./images/step1.png)

- Now click on the Menu and Press Oracle Cloud Services.

![](./images/step2.png)

- Inside the Oracle Cloud Services search for your Analytics Cloud deployed and click on it. 

![](./images/step3.png)

- Now go to Configuration ; click Resources.
Here you need to modify:
- Access Token Expiration from 100 seconds to the maximum of 604800 seconds.
- Dezactivate the Is Refresh Token Allowed option
- Refresh Token Expiration from 86,400 seconds. to 604800 seconds.

- Click Save button in the right top.

![](./images/step4.png)

- Now, on the same page click Details and click on Generate Access Token ; and press: Download Token.
- Open the Token and copy the key - after the app_access_token from " to the end of ". 

![](./images/step5.png)


- Go back to your terminal that it's connected to the Bastion VM Instance and edit the __finalize.sh__ script located in /home/opc/ folder. Here is a line called __Authorization_Token=__ that needs to be filled with the Token that you have copied on the last step. 



![](./images/step6.png)

Now from the terminal run the script using the __./finalize.sh__ command.

The script will run and you will see this Output:

```
[opc@vnc-datamodelsmanufacturing ~]$ ./finalize.sh 
-- Getting Started
-- Retrive the original bar file from the shared object storage
-- Fixing the bar file
-- Modify the links for the picture using the current hostname and tenancy name
-- Create new bar file for OAC with the custom configuration
-- Upload the snapshot to the object storage in our tenancy
-- Get details of an Analytics instance
HTTP/1.1 200 OK
-- Create the Register Snapshot New Json File
-- Register an existing snapshot using the new json file created with all the variables based on your environment
HTTP/1.1 100 Continue
HTTP/1.1 202 Accepted
-- Get all snapshots available for your OAC already registered
HTTP/1.1 200 OK
-- Get the ID of your registered snapshoot and use it in the next step
-- Create the Restore Snapshot New Json File with your registered ID of the snapshot
-- Restore a snapshot in an Analytics instance
HTTP/1.1 202 Accepted


-- Restore Done!
```

Next we need to transfer the generated wallet from the Autonomous Database to your local PC. To do this you need to exit the bastion and from your local terminal use this command: 

* Note: the key is the the generated private key of the bastion ; the IP is the public ip of the bastion, the wallet it's located in /home/opc AND the name of the wallet it's wallet_DB_NAME.zip , where the DB_NAME is the name of your database.

```
$ scp -i private_key.pem  opc@129.213.104.154:/home/opc/wallet_TelcoAsset.zip .
wallet_TelcoAsset.zip                                                                                100%   21KB  68.7KB/s   00:00    
```

__Now everything it's done and ready ! You will want to connect to Oracle Analytics instance to see the data sets - open a web browser and connect copy paste the URL of the Analytic Cloud and hit enter.__

Here you will see already all the imported dashboards and reports. Last step it's to connect to your existing DB. For this go to : Menu - Data - Connections and connect each of the connections to the DB. (without the Comms_Hive_DB  - this connection is used only for the integration with a HIVE cluster. If you already have one you can connect to your data from here. If you don't have one and you have deployed the solution using the Big Data Service - that is optonal - you will find the details below).

Right Click on TowerDataset and select Inspect.
Use the password of the db for admin that you have provided in the provisioning phase and select your generated wallet that you have transfered from the bastion in the previous step to your local PC - file starting with "wallet_dbname.zip". Click Save.

![](./images/step7.png)

Right Click on TowerAnalytics and select Inspect.
Use the password of the db for admin that you have provided in the provisioning phase and select your generated wallet that you have transfered from the bastion in the previous step to your local PC - file starting with "wallet_dbname.zip". Click Save.

![](./images/step8.png)

Now you can go in your workbook called TowerCanvas and in inside there are 5 canvas. Click on each of them to get the info. Note - The 5th canvas it's only used for HIVE. So if the connection for the HIVE it's not done, no data will be displayed there.


__SELECT AI__

To use the select ai - you need to connect to the ADW with your credentials provided and wallet file using sql developer and run:

```
EXEC DBMS_CLOUD_AI.SET_PROFILE('DMISHRA');
```

After that you can run the select ai, here are some examples:

```
select ai tell me my estimated cost revenue;
select ai tell me my estimated cost revenue on The Chapters;
select ai tell me my nearest neighbor with a revenue more than 22227;
select ai tell me my nearest neighbor with a revenue more than 29227;
select ai tell me the site operation cost revenue;
select ai tell me the site operation cost revenue with the name Telstra Customer NILLIBUBICA ;
select ai tell me the revenue on CFA Site 118 Sawmill Rd MUCKLEFORD ;

You can use any of the followings attributes for select ai:
showsql
narrate
chat
runsql
```

__(OPTIONAL)Data Catalog - To harvest metadata from Autonomous Data Warehouse__
The solution will deploy also the Data Catalog Service with a Data Catalog and a Data Asset created inside. 

1.	For this created Data Asset, Add Connection by providing the details of the Communication Tower schemas.
2.	Provide the required database wallet downloaded from the bastion and, schema credentials for Admin and password provided.
3.	Test the connection to make sure it is successful.


__(OPTIONAL)BIG DATA SERVICE COMPONENTS:__
If you deployed the solution with the Big Data Service created you will want to do the followings:


1.	In the OCI Console after the deployed was got successfully created.  Click on BDS Cluster -> More Actions -> Add Cloud SQL and select compute shape and other required details
2.	By default, all the BDS cluster nodes will have private IP address so we can’t access the console directly via external network. Need to map private IP address to reserved public IP address to access it from external network or via to login to physical server
3.	On the Clusters page, click the name of BDS cluster and On the Cluster Information tab of the Cluster Details page, under Network Information, Copy the Subnet OCID to retrieve it later in this process.
4.	On the same page, under List of Cluster Nodes in the IP Address column, copy the private IP address of Master, Utility and Cloud SQL node to retrieve it later in this process.
5.	In the Cloud Console click on Cloud Shell and execute the below steps for each of Master, Utility and Cloud SQL node and note the Reserved Public IPs

```
export DISPLAY_NAME=<display-name>
export SUBNET_OCID=<subnet-ocid>
export PRIVATE_IP=<ip-address>
oci network public-ip create --display-name $DISPLAY_NAME --compartment-id `oci network private-ip list --subnet-id $SUBNET_OCID --ip-address $PRIVATE_IP | jq -r '.data[] | ."compartment-id"'` --lifetime "RESERVED" --private-ip-id `oci network private-ip list --subnet-id $SUBNET_OCID --ip-address $PRIVATE_IP | jq -r '.data[] | ."id"'`
```

__HDFS and HIVE Configuration__
1.	Login to utility node using Reserved Public IP, Create a new directory and download the csv files using wget:
```
mkdir comms_telecom_tower
cd comms_telecom_tower/
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/q1Fi0ijG2x5aLO3NoK5DeYR5ks3ZFm4GD2yQ3G0BJNkfPPp3AcukIX-5Ljh73g8u/n/oradbclouducm/b/DataModelsTelco/o/Blackspots.csv/Blackspots.csv
```

2.	Create Hadoop distributed file system directory Ex :
```
hdfs dfs –mkdir /warehouse/tablespace/external/hive/View1
```
3.	Put the csv files to HDFS using below commands Ex :
```
hdfs dfs -put BLACKSPOTS.csv /warehouse/tablespace/external/hive/View1
```
4.	Login to hive via beeline using credentials hive/hive from Utility node and Create Database
```
create database COMMS_LAKEHOUSE_TELECOM_TOWER_HIVE;
```
5.	Use Created Database and create external table for backspots.csv file using sql file ( Please find the below  Reference ) 
```
use COMMS_LAKEHOUSE_TELECOM_TOWER_HIVE;

CREATE external TABLE IF NOT EXISTS COMMS_LAKEHOUSE_TELECOM_TOWER_HIVE.BLACKSPOTS_HIVE (
LOCATIONNAME STRING,
IDENTIFIER STRING,
ROAD_SECTION STRING,
PUBLIC_INTEREST_PREMISES STRING,
STATE STRING,
LATITUDE STRING,
LONGITUDE STRING,
ELECTORATE STRING,
LOCAL_GOVERNMENT_AREA STRING,
POST_CODE STRING,
REMOTENESS_AREA STRING,
UPDATED STRING,
REGIONAL_DEVELOPMENT_AUTHORITY STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
location '/warehouse/tablespace/external/hive/View1';
```

In Oracle Analytics Cloud - to have the 5th Canvas working you will need to do the followings:

1.	Navigate to actions menu (over right side ) of the Comms_Hive_DB connection and click on Inspect and update the below details
Host : Cloud SQL Public IP address
Port : 10000 
User name : hive
Password : hive

2. Synchronizing Hive Databases from Ambari
-	Login to Ambari using https://<Utility Node Public IP>:7183
-	Select Cloud SQL under Services and Navigate to CONFIGS and make sure you have updated (*) in Synchronized Hive Databases under Advanced metadata-sync option
-	Navigate to Summary, click on “BIG DATA SQL QUERY SERVER“ and click on host
-	Under Summary -> ”BIG DATA SQL QUERY SERVER / Cloud SQL“ -> More Actions , Click on Synchronize Hive Databases
-	Make sure it synchronization is 100% completed
 
-	At this point you can run the select queries on both hive and cloud sql to validate the synchronization
Ex : In Cloud SQL
```
select * from COMMS_LAKEHOUSE_TELECOM_TOWER_HIVE.BLACKSPOTS_HIVE  where rownum < 2;
```
Ex : In Hive
```
select * from COMMS_LAKEHOUSE_TELECOM_TOWER_HIVE.BLACKSPOTS_HIVE  limit 2;
```


# <a name="Deploy-Using-the-Terraform-CLI"></a>Deploy Using the Terraform CLI

## Clone the Module
Now, you'll want a local copy of this repo. You can make that with the commands:

    git clone https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation.git
    cd terraform-oci-oracle-cloud-foundation/cloud-foundation/solutions/Telco-Asset_Value_Maximization
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

On top of this default variables, for this solution you will need to get also:

- ociPrivateKeyWrapped

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

#### **Getting the private key wrapped.** 

The key that you have created or your own existing private key must be wrapped. 
 - You must pass this signing key in the payload for some snapshot APIs. Before you add it to the payload, you must Base64 encode the private key (ociPrivateKeyWrapped). For example, to generate a Base64 encoded string from your private key:

 - On Mac: cat myprivate-key.pem | base64 -o mywrapped-private-key.pem
 - On Linux: cat myprivate-key.pem | base64 -w 0 > mywrapped-private-key.pem
 - Note: Ensure that the private key file that you encode includes -----BEGIN and -----END tags.

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

variable "ociPrivateKeyWrapped" {
  default = "LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBeXBjNmsxWjAwNHhyWGF1ZjlXMGV6OTV6cUk2SU91dnN5aTRrOFUyTDQ1ZlY0QkExCm02N0FUbEtJTy9vYlBTZGp1Z3dHQzkrTzM2Rjk0cWdZV2xLZDNuRmFHYW8kM0Y0U0Mm9lTFcKbVU2Y2c3ei80bzNWZlZ2Kzl6di8yU2kvL0LSGFpeDN1RHMzWUh5QnJURVAveUQzSeFBjMmh0Y1A3eFBoTGdGTmhobXpaaDEKcYOW0rS3I5Y0Z5b0JxaHMxbnJBVXlWalFwNlRyei9UT1ZuCm9UREthbjlmMEVieVFwSGtRVnJ5MC9nYWtUb0hIajA0MjczeU9ROGZCQlRyRnNMRGFlTml1ajlyQW9HQkFONW0KU2xXL095QWVjNE50K2lRM0hCSDU5L2w3U01SU3hnL0tEMVgzamZJL1d5aGl6a1daaFBIa3dvd2dZVzdFUjVEUQpJU0xtZXZGOVdkYVNhWmlHR1RpV1Y5R2dnVTBlaW9RVXQ2OTVyZ2hBN1o3bitaNVpoN0k5dGM2MGkwUHRFVWJsCm1JckFzbU4wdWpnWDVQZDRobTdoaWVKZE1EQlFUVGFQaEZudWVxQnRBb0dCQU53ZkxJo= EXAMPLE"
}

# This variable needs to be blank for now. 
# It's used to create a couple of files on the bastion that will be run later on after the deployment it's done. 
# This Authorization Token you will get it from the Identity Cloud Service portal on the Oracle Analytics under Oracle Cloud Services.

variable "Authorization_Token" {
  default = ""
} 
```

## Repository files
* **images(folder)** - Contains images to be used inside the README.md file
* **modules(folder)** - ( this folder will be present only for the Resource Manager zipped files) Contains folders with subsystems and modules for each section of the project: networking, autonomous database, analytics cloud, etc.
For this solution there is inside the modules folder; another folder called provisioner that contains the configuration files.
* **CONTRIBUTING.md** - Contributing guidelines, also called Contribution guidelines, the CONTRIBUTING.md file, or software contribution guidelines, is a text file which project managers include in free and open-source software packages or other open media packages for the purpose of describing how others may contribute user-generated content to the project.The file explains how anyone can engage in activities such as formatting code for submission or submitting patches
* **Data-Lakehouse-Communications-Tower-Analytics-using-OML.json** - It's the notebook json - the file that you will need to use in the Autonomous Database Machine Learning 
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
    * __llmpw__ - Provide the LLM token provided by your openai account

Below is an example:

```
variable "db_name" {
  type    = string
  default = "TelcoAsset"
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
  # default = "NOT_ENABLED"
  # default = "ENABLED"
  default = "ENABLED"
}

# LLM token provided by your openai account

variable "llmpw" {
  default = ""
}

```

# Oracle Analytics Cloud
This resource provides the Analytics Instance resource in Oracle Cloud Infrastructure Analytics service.
Create a new AnalyticsInstance in the specified compartment. The operation is long-running and creates a new WorkRequest.

* Parameters
    * __Oracle_Analytics_Instance_Name__ - The name of the Analytics instance. This name must be unique in the tenancy and cannot be changed.
    * __analytics_instance_feature_set__ - Analytics feature set: ENTERPRISE_ANALYTICS or SELF_SERVICE_ANALYTICS set
    * __analytics_instance_license_type__ - The license used for the service: LICENSE_INCLUDED or BRING_YOUR_OWN_LICENSE
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
  default = "TelcoAsset"
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
  default = ""
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
  default = "TelcoAsset"
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

# (OPTIONAL) Big Data Service service
This resource provides the Bds Instance resource in Oracle Cloud Infrastructure Big Data Service service. Creates a Big Data Service cluster.

* Parameters
    * __create_big_data_cluster__ - (Required) Please provide if you want to create the cluster or no. (variables: yes/no) ; By default it's no.
    * __big_data_cluster_admin_password__ - (Required) Base-64 encoded password for the cluster (and Cloudera Manager) admin user. e.g.: echo Init01$$ | base64
    * __big_data_cluster_public_key__ -  (Required) The SSH public key used to authenticate the cluster connection.
    * __big_data_cluster_version__ - (Required) Version of the Hadoop distribution. ODH1 is the new version with Ambari Server - no autoscalling working at the moment. "CDH6" // old version - Cloudera Manager version with autoscalling working.
    * __big_data_display_name__ - (Required) (Updatable) Name of the Big Data Service cluster.
    * __big_data_is_high_availability__ - (Required) Boolean flag specifying whether or not the cluster is highly available (HA).
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

variable "create_big_data_cluster" {
  default = "no"
}

variable "big_data_cluster_admin_password" {
  default = "QWR3RGJPUkNMMTIzNCM="   # Password has to be Base64 encoded, e.g.: echo AdwDbORCL1234# | base64
}

variable "big_data_cluster_public_key" {
  default = "/users/user/.ssh/id_rsa.pub" # example : "/root/.ssh/id_rsa.pub"
}

variable "big_data_cluster_version" {
  default = "ODH1"
}

variable "big_data_display_name" {
  default = "lakehouse"
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
  default = "VM.Standard2.1"
}

variable "big_data_worker_node_block_volume_size_in_gbs" {
  default = 150 // minimum size is 150
}

variable "big_data_worker_node_number_of_nodes" {
  default = 3 // worker_node.0.number_of_nodes to be at least (3)
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
    default = "TelcoAsset"
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


# Compute DataModelsTelco Server VM Configuration
The compute module will create one VM, acting like a Bastion to provision the solution.
For the UI Data Server VM we are using the Oracle-Linux-Cloud-Developer-8.5-2022.05.22-0 image as it comes with all the neccesary software installed.

More information about this image and about the OCIDs required to be provided as a variable can be found here:

https://docs.oracle.com/en-us/iaas/images/image/2e439f8e-e98f-489b-82a3-338360b46b82/

Here is the list of all the OCID images for each region.

``` 
Image OCIDs
    Region	               OCID

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
```

More information regarding shapes can be found here:

https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm

* Parameters for the UI Data Server VM Configuration
    * __bastion_instance_display_name__ - (Required) (Updatable) - Required. The hostname/dns name for the UI Data Server VM.
    * __bastion_instance_shape__ - (Required) (Updatable) The shape of an instance. The shape determines the number of CPUs, amount of memory, and other resources allocated to the instance.

```
variable "bastion_instance_display_name" {
  type    = string
  default = "DataModelsTelco"
}

variable "bastion_instance_shape" {
    type    = string
    default  = "VM.Standard2.4"
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
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
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

# <a name="What-to-do-after-the-Deployment-via-Terraform-CLI"></a>What-to-do-after-the-Deployment-via-Terraform-CLI

After the deployment finished you will have to:
1. Login into the Oracle Machine Learning instance URL provided in the outputs (example :  OML_URL = "https://rddainsuh6u1okc-telcoasset.adb.us-ashburn-1.oraclecloudapps.com/oml"
) -  using the user "DMISHRA" and the Admin password provided for the database ( as the DMISHRA user has the same password as Admin). You can also change the DMISHRA or Admin passwords after.
2. In OML Home page Click on Hamburger icon and go to Notebooks
3. Import Data Lakehouse Communications-Tower Analytics using .json file called Data-Lakehouse-Communications-Tower-Analytics-using-OML.json that stores in the root of the solution.
4. Once Imported successfully Click on Open.
5. To run any of the paragraphs, click on the Run button in the right hand side of the paragraph. The second and third buttons next to it can be used to Show/Hide Editor and Show/Hide Output.

* Visualizing Results in OML

1.	Click on the Settings icon right corner to avail the different options such as clearing the output, removing a paragraph, shifting the paragraph, changing the font appearance, hide title and to disable a running paragraph.
2. 	If required, a new paragraph can be added to the notebook by hovering between two paragraphs or between a paragraph and the Notebook Title section 
3.	If the results of a Python code paragraphs needs to be visualized, the paragraph should start with %python and ends with a dataframe. (SQL query needs to start with %sql).
4.	Once the query is rendered the following visualization Table, Bar Chart, Pie Chart, Area Chart, Line Chart, Scatter Chart can be selected to render it in particular visualization.
5.	The rendered Data can be downloaded as a CSV or TSV.
6.	Click the Settings icon to view the Available Fields, which are the tables, returned in the query result. Any of these fields can be selected in the Keys area (which are rendered on the X-axis) or Values area (which are rendered on the Y-axis). If the data needs to be grouped according to some field, that field can be added to the Groups area.

__Next part is the Data Visualization by OCI Analytics - can be monitored visually through Analytics Dashboard :__

- After the soltution was deployed successfully from Terraform CLI you will have some outputs on the screen.
- As the private key for the Bastion was created on the fly - we will use it to connect to the Bastion Host.

__SSH to the bastion with the Public IP Adress printed on the output from terraform:__

```
$ ssh -i private_key_bastion.pem  opc@ui_data_server_public_ip -o IdentitiesOnly=yes

```
To interact with the Oracle Analytics API you will need to set up the credentials.
As the deployment it's getting automated all your credentials from the terraform like , ociUserId ,ociKeyFingerprint ,ociTenancyId and ociRegion you will need to update also your private key. 
For this - edit the /home/opc/.oci/oci_api_key.pem file - and replace the content of the key with your own private key that you used to deploy the solution with terraform.

Now you will need to do one manual step to grab the token of the Oracle Analytics Cloud and insert it in a shell script.

- Go inside your Tenancy, click on the Menu, click on Identity & Security and under Identity click on Federation.
Click on your identity provider and click on the link in the middle called : Oracle Identity Cloud Service Console: https://idcs-abcd.identity.oraclecloud.com/ui/v1/adminconsole

![](./images/step1.png)

- Now click on the Menu and Press Oracle Cloud Services.

![](./images/step2.png)

- Inside the Oracle Cloud Services search for your Analytics Cloud deployed and click on it. 

![](./images/step3.png)

- Now go to Configuration ; click Resources.
Here you need to modify:
- Access Token Expiration from 100 seconds to the maximum of 604800 seconds.
- Dezactivate the Is Refresh Token Allowed option
- Refresh Token Expiration from 86,400 seconds. to 604800 seconds.

- Click Save button in the right top.

![](./images/step4.png)

- Now, on the same page click Details and click on Generate Access Token ; and press: Download Token.
- Open the Token and copy the key - after the app_access_token from " to the end of ". 

![](./images/step5.png)


- Go back to your terminal that it's connected to the Bastion VM Instance and edit the __finalize.sh__ script located in /home/opc/ folder. Here is a line called __Authorization_Token=__ that needs to be filled with the Token that you have copied on the last step. 



![](./images/step6.png)

Now from the terminal run the script using the __./finalize.sh__ command.

The script will run and you will see this Output:

```
[opc@vnc-datamodelsmanufacturing ~]$ ./finalize.sh 
-- Getting Started
-- Retrive the original bar file from the shared object storage
-- Fixing the bar file
-- Modify the links for the picture using the current hostname and tenancy name
-- Create new bar file for OAC with the custom configuration
-- Upload the snapshot to the object storage in our tenancy
-- Get details of an Analytics instance
HTTP/1.1 200 OK
-- Create the Register Snapshot New Json File
-- Register an existing snapshot using the new json file created with all the variables based on your environment
HTTP/1.1 100 Continue
HTTP/1.1 202 Accepted
-- Get all snapshots available for your OAC already registered
HTTP/1.1 200 OK
-- Get the ID of your registered snapshoot and use it in the next step
-- Create the Restore Snapshot New Json File with your registered ID of the snapshot
-- Restore a snapshot in an Analytics instance
HTTP/1.1 202 Accepted


-- Restore Done!
```

__Now everything it's done and ready ! You will want to connect to Oracle Analytics instance to see the data sets - open a web browser and connect copy paste the URL of the Analytic Cloud and hit enter.__

Here you will see already all the imported dashboards and reports. Last step it's to connect to your existing DB. For this go to : Menu - Data - Connections and connect each of the connections to the DB. (without the Comms_Hive_DB  - this connection is used only for the integration with a HIVE cluster. If you already have one you can connect to your data from here. If you don't have one and you have deployed the solution using the Big Data Service - that is optonal - you will find the details below).

Right Click on TowerDataset and select Inspect.
Use the password of the db for admin that you have provided in the provisioning phase and select your generated wallet that you have transfered from the bastion in the previous step to your local PC - file starting with "wallet_dbname.zip". Click Save.

![](./images/step7.png)

Right Click on TowerAnalytics and select Inspect.
Use the password of the db for admin that you have provided in the provisioning phase and select your generated wallet that you have transfered from the bastion in the previous step to your local PC - file starting with "wallet_dbname.zip". Click Save.

![](./images/step8.png)

Now you can go in your workbook called TowerCanvas and in inside there are 5 canvas. Click on each of them to get the info. Note - The 5th canvas it's only used for HIVE. So if the connection for the HIVE it's not done, no data will be displayed there.


__SELECT AI__

To use the select ai - you need to connect to the ADW with your credentials provided and wallet file using sql developer and run:

```
EXEC DBMS_CLOUD_AI.SET_PROFILE('DMISHRA');
```

After that you can run the select ai, here are some examples:

```
select ai tell me my estimated cost revenue;
select ai tell me my estimated cost revenue on The Chapters;
select ai tell me my nearest neighbor with a revenue more than 22227;
select ai tell me my nearest neighbor with a revenue more than 29227;
select ai tell me the site operation cost revenue;
select ai tell me the site operation cost revenue with the name Telstra Customer NILLIBUBICA ;
select ai tell me the revenue on CFA Site 118 Sawmill Rd MUCKLEFORD ;

You can use any of the followings attributes for select ai:
showsql
narrate
chat
runsql
```

__(OPTIONAL)Data Catalog - To harvest metadata from Autonomous Data Warehouse__
The solution will deploy also the Data Catalog Service with a Data Catalog and a Data Asset created inside. 

1.	For this created Data Asset, Add Connection by providing the details of the Communication Tower schemas.
2.	Provide the required database wallet downloaded from the bastion and, schema credentials for Admin and password provided.
3.	Test the connection to make sure it is successful.


__(OPTIONAL)BIG DATA SERVICE COMPONENTS:__
If you deployed the solution with the Big Data Service created you will want to do the followings:


1.	In the OCI Console after the deployed was got successfully created.  Click on BDS Cluster -> More Actions -> Add Cloud SQL and select compute shape and other required details
2.	By default, all the BDS cluster nodes will have private IP address so we can’t access the console directly via external network. Need to map private IP address to reserved public IP address to access it from external network or via to login to physical server
3.	On the Clusters page, click the name of BDS cluster and On the Cluster Information tab of the Cluster Details page, under Network Information, Copy the Subnet OCID to retrieve it later in this process.
4.	On the same page, under List of Cluster Nodes in the IP Address column, copy the private IP address of Master, Utility and Cloud SQL node to retrieve it later in this process.
5.	In the Cloud Console click on Cloud Shell and execute the below steps for each of Master, Utility and Cloud SQL node and note the Reserved Public IPs

```
export DISPLAY_NAME=<display-name>
export SUBNET_OCID=<subnet-ocid>
export PRIVATE_IP=<ip-address>
oci network public-ip create --display-name $DISPLAY_NAME --compartment-id `oci network private-ip list --subnet-id $SUBNET_OCID --ip-address $PRIVATE_IP | jq -r '.data[] | ."compartment-id"'` --lifetime "RESERVED" --private-ip-id `oci network private-ip list --subnet-id $SUBNET_OCID --ip-address $PRIVATE_IP | jq -r '.data[] | ."id"'`
```

__HDFS and HIVE Configuration__
1.	Login to utility node using Reserved Public IP, Create a new directory and use the file called the csv files using wget:
```
mkdir comms_telecom_tower
cd comms_telecom_tower/
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/q1Fi0ijG2x5aLO3NoK5DeYR5ks3ZFm4GD2yQ3G0BJNkfPPp3AcukIX-5Ljh73g8u/n/oradbclouducm/b/DataModelsTelco/o/Blackspots.csv/Blackspots.csv
```

2.	Create Hadoop distributed file system directory Ex :
```
hdfs dfs –mkdir /warehouse/tablespace/external/hive/View1
```
3.	Put the csv files to HDFS using below commands Ex :
```
hdfs dfs -put BLACKSPOTS.csv /warehouse/tablespace/external/hive/View1
```
4.	Login to hive via beeline using credentials hive/hive from Utility node and Create Database
```
create database COMMS_LAKEHOUSE_TELECOM_TOWER_HIVE;
```
5.	Use Created Database and create external table for backspots.csv file using sql file ( Please find the below  Reference ) 
```
use COMMS_LAKEHOUSE_TELECOM_TOWER_HIVE;

CREATE external TABLE IF NOT EXISTS COMMS_LAKEHOUSE_TELECOM_TOWER_HIVE.BLACKSPOTS_HIVE (
LOCATIONNAME STRING,
IDENTIFIER STRING,
ROAD_SECTION STRING,
PUBLIC_INTEREST_PREMISES STRING,
STATE STRING,
LATITUDE STRING,
LONGITUDE STRING,
ELECTORATE STRING,
LOCAL_GOVERNMENT_AREA STRING,
POST_CODE STRING,
REMOTENESS_AREA STRING,
UPDATED STRING,
REGIONAL_DEVELOPMENT_AUTHORITY STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
location '/warehouse/tablespace/external/hive/View1';
```

In Oracle Analytics Cloud - to have the 5th Canvas working you will need to do the followings:

1.	Navigate to actions menu (over right side ) of the Comms_Hive_DB connection and click on Inspect and update the below details
Host : Cloud SQL Public IP address
Port : 10000 
User name : hive
Password : hive

2. Synchronizing Hive Databases from Ambari
-	Login to Ambari using https://<Utility Node Public IP>:7183
-	Select Cloud SQL under Services and Navigate to CONFIGS and make sure you have updated (*) in Synchronized Hive Databases under Advanced metadata-sync option
-	Navigate to Summary, click on “BIG DATA SQL QUERY SERVER“ and click on host
-	Under Summary -> ”BIG DATA SQL QUERY SERVER / Cloud SQL“ -> More Actions , Click on Synchronize Hive Databases
-	Make sure it synchronization is 100% completed
 
-	At this point you can run the select queries on both hive and cloud sql to validate the synchronization
Ex : In Cloud SQL
```
select * from COMMS_LAKEHOUSE_TELECOM_TOWER_HIVE.BLACKSPOTS_HIVE  where rownum < 2;
```
Ex : In Hive
```
select * from COMMS_LAKEHOUSE_TELECOM_TOWER_HIVE.BLACKSPOTS_HIVE  limit 2;
```


## <a name="documentation"></a>Documentation

[Autonomous Databases Overview](https://docs.oracle.com/en-us/iaas/Content/Database/Concepts/adboverview.htm)

[Analytics Cloud Overview](https://docs.oracle.com/en-us/iaas/analytics-cloud/index.html)

[Object Storage Overview](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm)

[Big Data Service Overview](https://docs.oracle.com/en-us/iaas/Content/bigdata/home.htm)

[Data Catalog Overview](https://docs.oracle.com/en-us/iaas/data-catalog/using/overview.htm)

[Certificates](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm)

[Compute service](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm)

[Network Overview](https://docs.cloud.oracle.com/iaas/Content/Network/Concepts/overview.htm)

[Select AI Overview](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/sql-generation-ai-autonomous.html)

[Select AI presentation](https://www.oracle.com/autonomous-database/select-ai/)

[Terraform Autonomous Databases Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_autonomous_database)

[Terraform Analytics Cloud Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/analytics_analytics_instance)

[Terraform Certificates - TLS Provider](https://registry.terraform.io/providers/hashicorp/tls/latest/docs)

[Terraform Oracle Cloud Infrastructure Core Service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance)

[Terraform Object Storage Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_bucket)

[Terraform Big Data Service Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/bds_bds_instance)

[Terraform Data Catalog Resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/datacatalog_catalog)

[Terraform Vcn resource in Oracle Cloud Infrastructure Core service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_vcn)

[Terraform Subnet resource in Oracle Cloud Infrastructure Core service](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet)


## <a name="team"></a>The Team
- **Owners**: [Panaitescu Ionel](https://github.com/ionelpanaitescu) , [Deepak Mishra](https://github.com/DeepakMishra1108)


## <a name="feedback"></a>Feedback
We welcome your feedback. To post feedback, submit feature ideas or report bugs, please use the Issues section on this repository.	

## <a name="known-issues"></a>Known Issues
**At the moment, there are no known issues**