variable "ec2_key_name" {
  description = "AWS EC2 Key name for SSH access"
  type        = string
  default     = "tf-demo-key"
}

variable "prefix" {
  description = "Prefix for resources created by this module"
  type        = string
  default     = "tf-aws-bigip"
}

variable "region" {
  description = "AWS region to deploy in"
  type        = string
  default     = "us-west-2"
}

variable "cidr" {
  description = "aws VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availabilityZones" {
  description = "If you want the VM placed in an AWS Availability Zone, and the AWS region you are deploying to supports it, specify the numbers of the existing Availability Zone you want to use."
  type        = list(any)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "AllowedIPs" {
  description = "IP CIDR to allow traffic from"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_count" {
  description = "Number of Bigip instances to create( From terraform 0.13, module supports count feature to spin mutliple instances )"
  type        = number
  default     = 1
}

variable "f5_ami_search_name" {
  description = "BIG-IP AMI name to search for"
  type        = string
  default     = "F5 BIGIP-16.*Best*1Gb*"
}

variable "aws_secretmanager_auth" {
  description = "Whether to use key vault to pass authentication"
  type        = bool
  default     = true
}
