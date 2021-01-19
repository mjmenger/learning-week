# Deploy BIG-IP in AWS
This section will walk you through deploying a 3-nic BIG-IP VE appliance in AWS leveraging the [BIG-IP Terraform Provisioner for AWS](https://github.com/f5devcentral/terraform-aws-bigip-module). 

The code in this example will deploy a new VPC, subnets and a 3-nic BIG-IP.  The code is a modified version of the BIG-IP Terraform Provision for AWS [3-nic example](https://github.com/f5devcentral/terraform-aws-bigip-module/tree/master/examples/bigip_aws_3nic_deploy). 

## Accept Marketplace Subscription
To deploy the BIG-IP AWS Machine Image (AMI) we need to accept the marketplace subscription.  

To perform this step we will need to log into the AWS console for the ephermeral AWS account created with your UDF deployment.  
1. On the deployment page click on the *Cloud Accounts* tab
2. Collect the following information:
    - *Console Username*
    - *Console Password*
3. Click on the *Console URL* link
4. Enter the *Console Username* in the *IAM User Name* field
5. Enter the *Console Password* on the *Password* field
6. Click the *Sign In* button

To accept the AWS Marketplace Subscription for the BIG-IP AMI used in this lab:
1. Open the Marketplace Offer for the BIG-IP image: [https://aws.amazon.com/marketplace/pp?sku=8ogzl6mr9xeq1q9ajhtlauqjx](https://aws.amazon.com/marketplace/pp?sku=8ogzl6mr9xeq1q9ajhtlauqjx)
2. Click the orange *Continue to Subscribe* button in the top right corner 
3. Click the orange *Accept Terms* button in the middle of the page


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

You can now use this information to onboard and configure the BIG-IP.

## Test the deployment
To test our deployment we will leverage the [InSpec](inspec.io) tool by [Chef](https://www.chef.io/). Chef InSpec is an open-source framework for testing and auditing your applications and infrastructure. Chef InSpec works by comparing the actual state of your system with the desired state that you express in easy-to-read and easy-to-write Chef InSpec code. Chef InSpec detects violations and displays findings in the form of a report, but puts you in control of remediation.

The tests require the following environment variables:
| Variable | Description |
|----------|-------------|
| bigip_address | FQDN or ip address of the BIG-IP to test | 
| bigip_port | the port for the BIG-IP management service, commonly 443 |
| user|  the user account with which to authenticate to the BIG-IP |
| password | the password to use to authenticate to the BIG-IP |
| do_version | the expected version of declarative onboarding |
| as3_version | the expected version of application services |
| ts_version | the expected version of telemetry streaming |

Run the following commands to set the required environment variables:
```bash
export bigip_address=`terraform output -json | jq ".mgmtPublicIP.value[0][0]" -r`
export bigip_port=`terraform output -json | jq ".mgmtPort.value[0]" -r`
export user=admin
export password=`terraform output -json | jq ".bigip_password.value[0]" -r`
export do_version=1.16.0
export as3_version=3.23.0
```

Now run the BIG-IP InSpec tests:
```bash
inspec exec tests/big-ip --input=bigip_address=$bigip_address bigip_port=$bigip_port user=$user password=$password do_version=$do_version as3_version=$as3_version
```

The InSpec profile tests:
- the BIG-IP is reachabe
- DO is installed
- DO is running the requested version
- AS3 is installed
- AS3 is running the requested version
- BIG-IP is licensed

In the Inspec output you should notice that 8 tests were successful.  
```bash
Profile: InSpec Profile (big-ip)
Version: 0.1.0
Target:  local://

     No tests executed.

Profile: BIG-IP Automation Toolchain readiness (bigip-ready)
Version: 0.1.0
Target:  local://

  ✔  bigip-connectivity: BIG-IP is reachable
     ✔  Host 35.155.23.81 port 443 proto tcp is expected to be reachable
  ✔  bigip-declarative-onboarding: BIG-IP has Declarative Onboarding
     ✔  HTTP GET on https://35.155.23.81:443/mgmt/shared/declarative-onboarding/info status is expected to cmp == 200
     ✔  HTTP GET on https://35.155.23.81:443/mgmt/shared/declarative-onboarding/info headers.Content-Type is expected to match "application/json"
  ✔  bigip-declarative-onboarding-version: BIG-IP has specified version of Declarative Onboarding
     ✔  JSON content [0, "version"] is expected to eq "1.16.0"
  ✔  bigip-application-services: BIG-IP has Application Services
     ✔  HTTP GET on https://35.155.23.81:443/mgmt/shared/appsvcs/info status is expected to cmp == 200
     ✔  HTTP GET on https://35.155.23.81:443/mgmt/shared/appsvcs/info headers.Content-Type is expected to match "application/json"
  ✔  bigip-application-services-version: BIG-IP has specified version of Application Services
     ✔  JSON content version is expected to eq "3.23.0"
  ✔  bigip-licensed: BIG-IP has an active license
     ✔  HTTP GET on https://35.155.23.81:443/mgmt/tm/sys/license body is expected to match /registrationKey/


Profile Summary: 6 successful controls, 0 control failures, 0 controls skipped
Test Summary: 8 successful, 0 failures, 0 skipped
```

## Examine What Was Created
For this lab we leveraged the [BIG-IP Terraform Provisioner for AWS](https://github.com/f5devcentral/terraform-aws-bigip-module) to: 
- Create an [AWS Secrets Manager](https://us-west-2.console.aws.amazon.com/secretsmanager/home?region=us-west-2#/listSecrets) secret to store a randomly generated password for the BIG-IP
- deploy a 3-nic BIG-IP
- Declarative Onboarding declaration to onboard the new BIG-IP

In the next section we will configure the BIG-IP

[Previous](./setup.md) | [Next](./configure.md)