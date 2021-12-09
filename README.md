# Cloud Foundation Library

[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_terraform-oci-oracle-cloud-foundation)](https://sonarcloud.io/dashboard?id=oracle-devrel_terraform-oci-oracle-cloud-foundation)

## Introduction
Oracle’s Cloud Foundation is a Terraform framework and module toolkit for building and deploying solutions on Oracle Cloud Infrastructure.
The framework is “composable” in that all the modules in the toolkit can be used individually or in any combination for a specific solution. The framework is also extendable - if the module you need isn’t already available, then it’s easy for you to add your own.

The modules are designed to be shared across multiple solution environments and deployments, with only the parameters differing between each environment. In this way, the module framework can be used as the Terraform core for a substantial cloud deployment in OCI.

The Library is designed as a starting point for your own module library. Our recommendation is that you take a point-in-time clone of the Library and then create your own internal library and use your own internal git. This way, you can have complete control over the modules and incur no external dependencies. You can enhance, extend or otherwise tailor the library to your organisation’s specific needs.
To get started, we suggest you take a look at the “Hello, World” example which uses the framework to deploy a simple webserver. In addition to this Terraform Library, the Cloud Foundation also includes a cloud architecture guide, and this will be published in December 2021.


## Getting started with the Cloud Foundation Library
Install Terraform for OCI using these [instructions] in your local environment, but instead of creating a new directory, clone the Cloud Foundation Library and try out the HelloWorld example. It will work on any Oracle always free or free tier account.

## Clone the repository 
You'll want a local copy of this repo - https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation 
1. Open Git Bash - If Git is not already installed, it is super simple. Just go to the [Git Download Folder](https://git-scm.com/downloads) and follow the instructions.
2. Go to the current directory where you want the cloned directory to be added.
To do this, input cd and add your folder location. You can add the folder location by dragging the folder to Git bash.
```
    cd '/home/user/Git_Project'
```
3. Go to the page https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation this is the repository that you want to clone
Click on “Clone or download” and copy the URL.
4. Use the git clone command along with the copied URL from earlier and press ENTER.
```
    $ git clone https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation.git
    Cloning into 'terraform-oci-oracle-cloud-foundation'...
    remote: Enumerating objects: 397, done.
    remote: Counting objects: 100% (397/397), done.
    remote: Compressing objects: 100% (288/288), done.
    remote: Total 397 (delta 130), reused 343 (delta 96), pack-reused 0
    Receiving objects: 100% (397/397), 631.10 KiB | 1.24 MiB/s, done.
    Resolving deltas: 100% (130/130), done.

    cd terraform-oci-oracle-cloud-foundation/
    ls
```
5. Congratulations!

### Prerequisites
- Install Terraform v0.13 or greater: https://www.terraform.io/downloads.html
- Install Python 3.6: https://www.digitalocean.com/community/tutorials/how-to-install-python-3-and-set-up-a-local-programming-environment-on-centos-7
- Generate an OCI API Key
- Create your config under \$home*directory/.oci/config (run \_oci setup config* and follow the steps)
- Gather Tenancy related variables (tenancy_id, user_id, local path to the oci_api_key private key, fingerprint of the oci_api_key_public key, and region)

### Installing Terraform

Go to [terraform.io](https://www.terraform.io/downloads.html) and download the proper package for your operating system and architecture. Terraform is distributed as a single binary.
Install Terraform by unzipping it and moving it to a directory included in your system's PATH. You will need the latest version available.

### Prepare Terraform Provider Values

In order to populate the provider file, you will need the following:

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

After uploading the public key, you can see its fingerprint into the console. You will need that fingerprint for your provider section or file.
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
Even though, you may know your region name, you will needs its identifier for the provider file (for example, US East Ashburn has us-ashburn-1 as its identifier).
In order to obtain your region identifier, you will need to Navigate in the OCI Console to Administration -> Region Management
Select the region you are interested in, and save the region identifier.


## Contributing
If you enhance a module or build a new module and you would like to share your work via the library, please contact us - we are always open to improving and extending the library.


## License
The Cloud Foundation Library is released under the Universal Permissive License (UPL), Version 1.0. and so there are very few limitations on what you can do - please check the [LICENSE](LICENSE) file for full details.

