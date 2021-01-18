# Deploy BIG-IP in AWS
This section will walk you through deploying a 3-nic BIG-IP VE appliances in AWS leveraging the [BIG-IP Terraform Provisioner for AWS](https://github.com/f5devcentral/terraform-aws-bigip-module). 

The code in this example will deploy a new VPC, subnets and a 3-nic BIG-IP.  The code is a modified version of the BIG-IP Terraform Provision for AWS [3-nic example](https://github.com/f5devcentral/terraform-aws-bigip-module/tree/master/examples/bigip_aws_3nic_deploy). 

## Terraform Module Overview
The BIG-IP Terraform Provisioner for AWS was created to help customers easily deploy a BIG-IP in AWS.  It drastically reduces the steps required to deploy a BIG-IP based upon best practices for AWS. The module is currently accessible via the F5DevCentral GitHub organization.  However, in the near future the module will be transfered to the F5Networks GitHub organization where it will recieve full F5 Support as well as be published in the [Terraform Registry](https://registry.terraform.io/). 

### Advantages
- The module is very versital as it supports any combination of network interfaces (n-nic) to match the customer's requirements 
- The module installs specified versions of AS3 and DO
- The module creates a DO declaration to help onboard the deployed BIG-IP
- Can set the BIG-IP password from a secrets manager 

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

## Examine What Was Created
For this lab we leveraged the [BIG-IP Terraform Provisioner for AWS](https://github.com/f5devcentral/terraform-aws-bigip-module) to: 
- Create an [AWS Secrets Manager](https://us-west-2.console.aws.amazon.com/secretsmanager/home?region=us-west-2#/listSecrets) secret to store a randomly generated password for the BIG-IP
- deploy a 3-nic BIG-IP
- Declarative Onboarding declaration to onboard the new BIG-IP

## Test the deployment
To test our deployment we will leverage the [InSpec](inspec.io) tool by [Chef](https://www.chef.io/). 

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

Run the following commands to set these environment variables:
```bash
export bigip_address=`terraform output -json | jq ".mgmtPublicIP.value[0][0]" -r`
export bigip_port=`terraform output -json | jq ".mgmtPort.value[0]" -r`
export user=admin
export password=`terraform output -json | jq ".bigip_password.value[0]" -r`
export do_version=1.16.0
export as3_version=3.23.0
```

Now run our test:
```bash
inspec exec https://github.com/F5SolutionsEngineering/big-ip-atc-ready.git --input=bigip_address=$bigip_address bigip_port=$bigip_port user=$user password=$password do_version=$do_version as3_version=$as3_version ts_version=$ts_version
```

The InSpec exec commands tests:
- the BIG-IP is reachabe
- DO is installed
- DO is running the requested version
- AS3 is installed
- AS3 is running the requested version
- TS is installed
- TS is running the requested version
- FAST is installed
- FAST is running the requested version
- BIG-IP is licensed

In the Inspec output you should notice that 10 tests were successful and 4 test failed.  This is because the Telemetry Streaming and FAST extensions are not currently installed on the BIG-IP.  We will take care of that in our next step. 
```bash
Profile: BIG-IP Automation Toolchain readiness (bigip-ready)
Version: 0.1.0
Target:  local://

  ✔  bigip-connectivity: BIG-IP is reachable
     ✔  Host 44.241.96.34 port 443 proto tcp is expected to be reachable
  ✔  bigip-declarative-onboarding: BIG-IP has Declarative Onboarding
     ✔  HTTP GET on https://44.241.96.34:443/mgmt/shared/declarative-onboarding/info status is expected to cmp == 200
     ✔  HTTP GET on https://44.241.96.34:443/mgmt/shared/declarative-onboarding/info headers.Content-Type is expected to match "application/json"
  ✔  bigip-declarative-onboarding-version: BIG-IP has specified version of Declarative Onboarding
     ✔  JSON content [0, "version"] is expected to eq "1.16.0"
  ✔  bigip-application-services: BIG-IP has Application Services
     ✔  HTTP GET on https://44.241.96.34:443/mgmt/shared/appsvcs/info status is expected to cmp == 200
     ✔  HTTP GET on https://44.241.96.34:443/mgmt/shared/appsvcs/info headers.Content-Type is expected to match "application/json"
  ✔  bigip-application-services-version: BIG-IP has specified version of Application Services
     ✔  JSON content version is expected to eq "3.23.0"
  ×  bigip-telemetry-streaming: BIG-IP has Telemetry Streaming (1 failed)
     ×  HTTP GET on https://44.241.96.34:443/mgmt/shared/telemetry/info status is expected to cmp == 200
     
     expected: 200
          got: 404
     
     (compared using `cmp` matcher)

     ✔  HTTP GET on https://44.241.96.34:443/mgmt/shared/telemetry/info headers.Content-Type is expected to match "application/json"
  ×  bigip-telemetry-streaming-version: BIG-IP has specified version of Telemetry Streaming
     ×  JSON content version is expected to eq #<Inspec::Input::NO_VALUE_SET:0x00000000046639c0 @name="ts_version">
     
     expected: #<Inspec::Input::NO_VALUE_SET:0x00000000046639c0 @name="ts_version">
          got: nil
     
     (compared using ==)

  ×  bigip-fast: BIG-IP has F5 Application Service Templates (1 failed)
     ×  HTTP GET on https://44.241.96.34:443/mgmt/shared/fast/info status is expected to cmp == 200
     
     expected: 200
          got: 404
     
     (compared using `cmp` matcher)

     ✔  HTTP GET on https://44.241.96.34:443/mgmt/shared/fast/info headers.Content-Type is expected to match "application/json"
  ×  bigip-fast-version: BIG-IP has specified version of F5 Application Service Templates
     ×  JSON content version is expected to eq #<Inspec::Input::NO_VALUE_SET:0x00000000046624a8 @name="fast_version">
     
     expected: #<Inspec::Input::NO_VALUE_SET:0x00000000046624a8 @name="fast_version">
          got: nil
     
     (compared using ==)

  ✔  bigip-licensed: BIG-IP has an active license
     ✔  HTTP GET on https://44.241.96.34:443/mgmt/tm/sys/license body is expected to match /registrationKey/


Profile Summary: 6 successful controls, 4 control failures, 0 controls skipped
Test Summary: 10 successful, 4 failures, 0 skipped
```

In the next section we will configure the BIG-IP

[Previous](./setup.md) | [Next](./configure.md)