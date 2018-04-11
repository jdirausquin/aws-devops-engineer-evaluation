provider "aws" {
    region = "${var.aws_region}"
}

variable "env" {
    default = "demo"
}

variable "sys" {
    default = "company"
}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "us-east-1"
}

variable "vpc1_cidr" {
    description = "CIDR for the VPC1"
    default = "172.10.0.0/16"
}

variable "vpc2_cidr" {
    description = "CIDR for the VPC1"
    default = "172.20.0.0/16"
}

variable "subnet_pub_vpc1" {
    description = "CIDR for the Public Subnet on VPC 1"
    default = "172.10.0.0/24"
}

variable "subnet_pub_vpc2" {
    description = "CIDR for the Private Subnet on VPC 2"
    default = "172.20.100.0/24"
}

variable "subnet_pri_vpc2" {
    description = "CIDR for the Private Subnet on VPC 2"
    default = "172.20.0.0/24"
}

variable "aws_az_1" {
    description = "EC2 AZ vor subnet 1"
    default = "us-east-1a"
}

variable "aws_az_2" {
    description = "EC2 AZ vor subnet 2"
    default = "us-east-1b"
}

variable "amis" {
    description = "AMIs by region"
    default = {
        us-east-1 = "ami-43a15f3e" #Ubuntu 16.04
    }
}

variable "aws_instance_type" {
    description = "EC2 instance type" 
    default = "t2.micro"
}

variable "aws_key_name" {
    default = "keyname"
}

variable "chef_connection" {
    type = "map"
    default = {
    	type = "ssh"
        agent = "false"
        private_key = "./keyname.pem"
        user = "ubuntu"
     }
}	
