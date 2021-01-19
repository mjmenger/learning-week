# Provision BIG-IP virtual appliances with Terraform
This lab leverages the [BIG-IP Terraform Provisioner for AWS](https://github.com/f5devcentral/terraform-aws-bigip-module) to deploy a BIG-IP in AWS.  

## Terraform Module Overview
The BIG-IP Terraform Provisioner for AWS was created to help customers easily deploy a BIG-IP in AWS.  It drastically reduces the steps required to deploy a BIG-IP based upon best practices for AWS. The module is currently accessible via the F5DevCentral GitHub organization.  However, in the near future the module will be transfered to the F5Networks GitHub organization where it will recieve full F5 Support as well as be published in the [Terraform Registry](https://registry.terraform.io/). 

### Advantages
- The module is very versatile as it supports any combination of network interfaces (n-nic) to match the customer's requirements 
- The module installs specified versions of AS3 and DO
- The module creates a DO declaration to help onboard the deployed BIG-IP
- Can set the BIG-IP password from a secrets manager 


## Requirements
 - Access to the Unified Demo Framework (UDF)

## Sections
1. [Setup](setup.md)
2. [Deploy BIG-IP in AWS](deploy_aws.md)
3. [Configure the BIG-IP](configure.md)

