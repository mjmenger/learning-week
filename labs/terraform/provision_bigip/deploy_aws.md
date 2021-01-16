# Deploy BIG-IP in AWS
This section will walk you through deploying a 3-nic BIG-IP VE appliances in AWS leveraging the [BIG-IP Terraform Provisioner for AWS](https://github.com/f5devcentral/terraform-aws-bigip-module). 

The code in this example will deploy a new VPC, subnets and a 3-nic BIG-IP.  The code is a modified version of the BIG-IP Terraform PRovision for AWS [3-nic example](https://github.com/f5devcentral/terraform-aws-bigip-module/tree/master/examples/bigip_aws_3nic_deploy). 

## Terraform Module Overview
The BIG-IP Terraform Provisioner for AWS was created to help customers easily deploy a BIG-IP in AWS.  It drastically reduces the steps required and deploys the BIG-IP based upon best practices for AWS. The module is currently accessible via the F5DevCentral GitHub organization.  However, in the near future the module will be transfered to the F5Networks GitHub organization where it will recieve full F5 Support as well as be published in the [Terraform Registry](https://registry.terraform.io/). 

### Advantages
- The module is very versital as it supports any combination of network interfaces (n-nic) to match the customer's requirements 
- The module installs the latest versions of the F5 BIG-IP Automation Toolchain
- The module creates a DO declaration to help onboard the deployed BIG-IP
- Can set the BIG-IP password from a secrets manager 

## Deploy the BIG-IP
We need to download the required Terraform providers and modules:
```bash
cd ~/projects/learning-week/labs/terraform/provision_bigip/aws
terraform init
```

Now we can build the BIG-IP in AWS:
```bash
terraform apply --auto-approve
```

**Note**: if you receive an error regarding *IncorrectInstanceState* run the terraform apply command again.

Once the *terraform apply* command completes, it will output information related to the new BIG-IP deployment:

| Variable | Description |
|----------|-------------|
| bigip_password | Password to access the BIG-IP API and UI|
| f5_username | Username to access the BIG-IP API and UI |
| mgmtPort | Port to access the BIG-IP API and UI | 
| mgmtPublicDNS | FQDN to access the BIG-IP API or UI | 
| mgmtPublicIP | Public IP address of the BIG-IP management interface |
| mgmtPublicURL | Public URL to access the BIG-IP management interface |
| private_addresses | IP addresses for the private subnets |
| public_addresses | Elastic IP address for the public Self-IP |
| vpc_id | ID for the VPC created in this demo |

You an now use this information to onboard and configure the BIG-IP.