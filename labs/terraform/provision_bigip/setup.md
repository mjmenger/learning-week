# Setup
In this section we will:
- deploy UDF blueprint
- Open VS Code 
- Install AWS CLI
- Configure AWS Credentials
- add EC2 Key Pair
- Install Terraform
- Download lab code from GitHub

## Deploy UDF blueprint 
For this lab we will leverage the [DevOps Base blueprint](https://udf.f5.com/b/54b4e41b-ba46-48a1-8274-51a970e7e66b#documentation).

If you are taking this lab as part of a course, please access the lab via the course information provided to you.  

Otherwise, please deploy a new instance of the [DevOps Base blueprint](https://udf.f5.com/b/54b4e41b-ba46-48a1-8274-51a970e7e66b#documentation). 

### Cloud Account
Once you've deployed the DevOps base blueprint you should now see a Cloud Accounts tab with information on your AWS ephermeral environment. 
| Variable | Description |
|----------|-------------|
| **Region** | typically us-west-2 |
| **Services** | AWS services available in your AWS account |
| **API Key** | AWS API Key used for programatic access |
| **API Secret** | AWS API Secret used for programmatic access |
| **Console URL** | URL to access the AWS console for your account |
| **Console Username** | Username for the AWS console |
| **Console Password** | Passsword for the AWS console |

## Open VS Code
This lab leverages a web based instance of [VS Code](https://code.visualstudio.com/) deployed within the DevOps Base Blueprint.  

To access VS Code:
1. Click the Components tab in the DevOps Base deployment
2. Click the *ACCESS* drop down for the *client* card
3. Click the *VS CODE* link

Open a base terminal in VS Code:
1. Click the hamburger menu (3 horizontal lines) in the top left
2. Click Terminal
3. Click New Terminal

## Install AWS CLI
Run the following commands in your VS Code terminal:
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Verify the install was successful:
```bash
aws --version
```

## Configure AWS Credentials 
The UDF environment has an internal metadata server which contains the AWS API Key and Secret.  We will use the commands below to save these values so the AWS CLI and Terraform can use them.

Run the following commands to store the AWS API Key, AWS API Secret and default region as environment variables:
```bash
export AWS_ACCESS_KEY_ID=`curl http://metadata.udf/cloudAccounts | jq  '.cloudAccounts[].apiKey' -r`
export AWS_SECRET_ACCESS_KEY=`curl http://metadata.udf/cloudAccounts | jq  '.cloudAccounts[].apiSecret' -r`
export AWS_DEFAULT_REGION=`curl http://metadata.udf/cloudAccounts | jq  '.cloudAccounts[].regions[0]' -r`
```

You should now be able to query the AWS API
```bash
aws ec2 describe-regions
```

## Add EC2 Key Pair
The BIG-IP can leverage [SSH Public Key authentication](https://www.ssh.com/ssh/public-key-authentication) which is a safer mechanism for publically accessible SSH servers.   To leverage this feature, we need to store an SSH key pair in our AWS EC2 configuration. 

Run the following commands from your terminal in VS Code to create and save a new SSH key pair:
```bash
aws ec2 create-key-pair --key-name my-key-pair --query "KeyMaterial" --output text > udf.pem
chmod 400 udf.pem
```

## Install Terraform
The DevOps base blueprint deploys an Ubuntu guest to host VS Code and run terraform commands from. While the blueprint already contains a version of Terraform it is helpful for you to understand how Terraform is installed. 

To install Terraform we will add the Hashicorp repository to our local Apt registry:
```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
```

Now we need to update our Apt metadata and then install Terraform:
```bash
sudo apt-get update && sudo apt-get install terraform
```

Check to ensure Terraform was installed:
```bash
terraform --version
```

## Download lab code from GitHub
To perform the remainder of this lab we need to clone the Terraform code from the lab's GitHub repository:
```bash
cd ~/projects
git clone https://github.com/f5devcentral/learning-week.git
cd learning-week/labs/terraform/provision_bigip/
```

[Next](./deploy_aws.md)