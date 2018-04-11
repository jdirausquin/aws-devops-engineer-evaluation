# AWS DevOps engineer evaluation

## Objective

Evaluate your knowledge/experience in three key areas: AWS, Chef and Terraform.

## Asumptions

We assume that you have a working AWS account where you can test the infrastructure you're developing. If you don't have a personal account, you can create one and make use of the [AWS free tier](https://aws.amazon.com/free/).

## Topics

- AWS.
- Chef.
- Infrastructure as code (terraform).

## Details

### The Challenge

NGINX can act as regular web server or as a reverse proxy (load balancer). The challenge consists of creating two VPCs (VPC1 and VPC2)
each VPC has only one subnet, VPC 1 has a public subnet, and VPC2 has a private subnet. On VPC2 there is an EC2 instance, running
NGINX (let's call this the backend server); on VPC1 there's another EC2 instance running NGINX and acting as a reverse proxy
(or load balancer).

When an user hits the public IP address of the NGINX load balancer, it sends the traffic to the backend server, the backend server
responds and the website is delivered to the user and rendered in a web browser.

To do that, you have to create a (wrapper) Chef cookbook, and then use it from Terraform.

### Chef

Create a chef (wrapper) cookbook to install and configure NGINX and its requirements (you can use any comunity cookbooks - only from the Chef supermarket, or create your own cookbook from scratch). You must also include tests for your cookbook (using test kitchen +
serverspec). Additionally, your cookbook must pass food critic and rubocop.

### Terraform

#### AWS Resources

You'll need to create (at least) the following resources:
- Two VPCs.
- One subnet for each VPC.
- At least 2 security groups.
- Two ec2 instances.

The following diagram can give you a better idea of what you should code in terraform:

```
   +--|++++++++++|-----------------------------------------------------------------------------------+
   |  |  AWS     |                                                                                   |
   |  +----------+                                                                                   |
   |                                                                                                 |
   |   +--|+++++|-------------------------------+       +--|+++++|-------------------------------+   |
   |   |  |VPC1 |                               |       |  |VPC2 |                               |   |
   |   |  +-----+                               |       |  +-----+                               |   |
   |   |                                        |       |                                        |   |
   |   |                                        |       |                                        |   |
   |   |   +|+++++++++++++++++++++++++++++++|+  |       |   +|+++++++++++++++++++++++++++++++|+  |   |
   |   |   || public subnet                 ||  |       |   || private subnet                ||  |   |
   |   |   |+-------------------------------+|  |       |   |+-------------------------------+|  |   |
   |   |   |  +---------------------------+  |  |       |   |  +---------------------------+  |  |   |
   |   |   |  |                           |  |  |       |   |  |                           |  |  |   |
   |   |   |  |  ec2 instance acting as   |<-+--+-------+---+->|  ec2 instance running a   |  |  |   |
   |   |   |  |  a load balancer (nginx)  |  |  |       |   |  |  web server(nginx)        |  |  |   |
   |   |   |  |                           |  |  |       |   |  |                           |  |  |   |
   |   |   |  +---------------------------+  |  |       |   |  +---------------------------+  |  |   |
   |   |   +---------------------------------+  |       |   +---------------------------------+  |   |
   |   |                                        |       |                                        |   |
   |   +----------------------------------------+       +----------------------------------------+   |
   +-------------------------------------------------------------------------------------------------+

```

## Deliverables

### Instructions

**You must provide instructions to reproduce your infrastructure, it can be a regular README file. You have to provide instructions to test your cookbook.**

### Code

You have to ship your code to us, please create a pull request against the upstream repo.

# Solution

## Instructions
1. Clon the gitihub project
2. Download and unzip terraform https://www.terraform.io/downloads.html
3. Go to you AWS console and create a Key pair with any name.
4. Edit the file vars.tf and change all the ocurrences of "keyname" for the name given to the AWS ssh-key generated before
4. Copy the ssh key "keyname.pem" inside the directory of the repository cloned before. _It has to be: ../repository/keyname.pem_
3. Execute *terraform init*
4. Execute *terraform apply*
5. Wait for the process execution. 
6. Copy the IP address of the loadbalancer instance shown as an output and paste it on your browser using http (port 80): _http://ip-address_
7. That's it

### Notes:
- The infrastructure will have a 3rd EC2 instance. This instance is the one used as bastion-server to access the instance that belong to the private network.
- The scripts were made for the use on OS Ubuntu16.04 only.
- Some variables can be changed as needed on file vars.tf. However, as mentioned before for the sake of this demo please do not change the AMI used.
