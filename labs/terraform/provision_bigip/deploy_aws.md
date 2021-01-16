# Deploy BIG-IP in AWS
This section will walk you through deploying a 3-nic BIG-IP VE appliances in AWS leveraging the [BIG-IP Terraform Provisioner for AWS.](https://github.com/f5devcentral/terraform-aws-bigip-module). 

The code is a modified version of the BIG-IP Terraform PRovision for AWS [3-nic example](https://github.com/f5devcentral/terraform-aws-bigip-module/tree/master/examples/bigip_aws_3nic_deploy). 

## Initialize Terraform
We need to download the required Terraform providers and modules:
```bash
cd ~/projects/learning-week/labs/terraform/provision_bigip/aws
terraform init
```

Now we can build the BIG-IP in AWS:
```bash
terraform apply --auto-approve
```