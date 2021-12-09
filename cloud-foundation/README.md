# Oracle Cloud Foundation Terraform Structure


## <a name="Cloud-foundation Structure"></a>Overview
We have implemented the following stucture:

- Modules folder are the libraries - module toolkit for building and deploying solutions on Oracle Cloud Infrastructure. The modules are designed to be shared across multiple solution environments and deployments, with only the parameters differing between each environment. In this way, the module framework can be used as the Terraform core for a substantial cloud deployment in OCI.

- Solutions folder is the code as servers as examples for our solutions. The framework is “composable” in that all the modules in the toolkit can be used individually or in any combination for a specific solution.

- Solutions-for-oracle-res-mgr - are the zipped solutions that are compatible with Resource Manager in Oracle Cloud Infrastructure.



