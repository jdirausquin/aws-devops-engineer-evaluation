# VPC 1
resource "aws_vpc" "vpc1" {
    cidr_block = "${var.vpc1_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "vpc_${var.sys}-${var.env}-01"
    }
}

# VPC 2
resource "aws_vpc" "vpc2" {
    cidr_block = "${var.vpc2_cidr}"
    enable_dns_hostnames = false
    tags {
        Name = "vpc_${var.sys}-${var.env}-02"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "igw1" {
    vpc_id = "${aws_vpc.vpc1.id}"
    tags {
        Name = "igw_${var.sys}-${var.env}-1"
    }
}

resource "aws_internet_gateway" "igw2" {
    vpc_id = "${aws_vpc.vpc2.id}"
    tags {
        Name = "igw_${var.sys}-${var.env}-2"
    }
}

# Public Subnet
resource "aws_subnet" "subnet-pub-1" {
    vpc_id = "${aws_vpc.vpc1.id}"
    cidr_block = "${var.subnet_pub_vpc1}"
    availability_zone = "${var.aws_az_1}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "sn_${var.sys}-${var.env}-pub-1"
    }
}

# Route Table - Public
resource "aws_route_table" "rtb-pub-1" {
    vpc_id = "${aws_vpc.vpc1.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.igw1.id}"
    }
    route {
        cidr_block = "${var.vpc2_cidr}"
        gateway_id = "${aws_vpc_peering_connection.vpc1-vpc2.id}"
    }
    tags {
        Name = "rtb_${var.sys}-${var.env}-pub-1"
    }
}

# Route Table Association - Public
resource "aws_route_table_association" "pub-1" {
    subnet_id = "${aws_subnet.subnet-pub-1.id}"
    route_table_id = "${aws_route_table.rtb-pub-1.id}"
}


# Elastic IP
resource "aws_eip" "nat_eip" {
    vpc = true
}

# Nat Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.subnet-pub-2.id}"
  depends_on = ["aws_internet_gateway.igw2"]
}

# Public Subnets
resource "aws_subnet" "subnet-pub-2" {
    vpc_id = "${aws_vpc.vpc2.id}"
    cidr_block = "${var.subnet_pub_vpc2}"
    availability_zone = "${var.aws_az_1}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "sn_${var.sys}-${var.env}-pub-2"
    }
}

# Route Table - Public
resource "aws_route_table" "rtb-pub-2" {
    vpc_id = "${aws_vpc.vpc2.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.igw2.id}"
    }
    tags {
        Name = "rtb_${var.sys}-${var.env}-pub-2"
    }
}

# Route Table Association - Public
resource "aws_route_table_association" "pub-2" {
    subnet_id = "${aws_subnet.subnet-pub-2.id}"
    route_table_id = "${aws_route_table.rtb-pub-2.id}"
}

#  Private Subnet
resource "aws_subnet" "subnet-pri-2" {
    vpc_id = "${aws_vpc.vpc2.id}"
    cidr_block = "${var.subnet_pri_vpc2}"
    availability_zone = "${var.aws_az_2}"
    tags {
        Name = "sn_${var.sys}-${var.env}-pri-2"
    }
}

# Route table private
resource "aws_route_table" "rtb-pri" {
    vpc_id = "${aws_vpc.vpc2.id}"
    route {
        cidr_block = "${var.vpc1_cidr}"
        gateway_id = "${aws_vpc_peering_connection.vpc1-vpc2.id}"
    }
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
    }
    tags {
        Name = "rtb_${var.sys}-${var.env}-pri"
    }
}

# Route table association - Private
resource "aws_route_table_association" "pri-2" {
    subnet_id = "${aws_subnet.subnet-pri-2.id}"
    route_table_id = "${aws_route_table.rtb-pri.id}"
}

#Peering between both VPC
resource "aws_vpc_peering_connection" "vpc1-vpc2" {
  peer_vpc_id   = "${aws_vpc.vpc1.id}"
  vpc_id        = "${aws_vpc.vpc2.id}"
  auto_accept   = true

  tags {
    Name = "Peering-${var.sys}-${var.env}"
  }
}

# Security group public instance
resource "aws_security_group" "sg_load-balancer" {
    name = "sg_ec2-load-balancer"
    description = "sg_load-balancer"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1" # all protocols
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.vpc1.id}"
    tags {
        Name = "sg_${var.sys}-${var.env}-load-balancer"
    }
}

resource "aws_security_group" "sg_bastion" {
    name = "sg_ec2-bastion"
    description = "sg_bastion"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1" # all protocols
        cidr_blocks = ["0.0.0.0/0"]
    }
    vpc_id = "${aws_vpc.vpc2.id}"
    tags {
        Name = "sg_${var.sys}-${var.env}-bastion"
    }
}

# Security group private instance
resource "aws_security_group" "sg_backend" {
    name = "sg_ec2-backend"
    description = "sg_backend"
    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        security_groups = ["${aws_security_group.sg_load-balancer.id}"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = ["${aws_security_group.sg_bastion.id}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1" # all protocols
        cidr_blocks = ["0.0.0.0/0"]
    }
    vpc_id = "${aws_vpc.vpc2.id}"
    tags {
        Name = "sg_${var.sys}-${var.env}-backend"
    }
}

# Instances
resource "aws_instance" "bastion" {
    ami = "${lookup(var.amis, var.aws_region)}"
    instance_type = "${var.aws_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.sg_bastion.id}"]
    subnet_id = "${aws_subnet.subnet-pub-2.id}"
    tags {
        Name = "${var.sys}-${var.env}-bastion"
    }
}

resource "aws_instance" "backend" {
    ami = "${lookup(var.amis, var.aws_region)}"
    instance_type = "${var.aws_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.sg_backend.id}"]
    subnet_id = "${aws_subnet.subnet-pri-2.id}"
    tags {
        Name = "${var.sys}-${var.env}-backend"
    }
    connection {
        type        = "${var.chef_connection.["type"]}"
        agent       = "${var.chef_connection.["agent"]}"
        private_key = "${file("${var.chef_connection.["private_key"]}")}"
        user        = "${var.chef_connection.["user"]}"    

        bastion_host        = "${aws_instance.bastion.public_ip}"
        bastion_port        = 22
        bastion_user        = "${var.chef_connection.["user"]}"
        bastion_private_key = "${file("${var.chef_connection.["private_key"]}")}"
    }
    provisioner "file" {
        source      = "chef/chef-backend.sh"
        destination = "/tmp/chef-backend.sh"
    }
    provisioner "file" {
        source      = "nginx/backend"
        destination = "/tmp"
    }
    provisioner "remote-exec" {
        inline = [
          "sudo apt update",  
          "sudo chmod +x /tmp/chef-backend.sh",
          "sudo /tmp/chef-backend.sh", 
        ]
    }  
}

resource "aws_instance" "load_balancer" {
    ami = "${lookup(var.amis, var.aws_region)}"
    instance_type = "${var.aws_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.sg_load-balancer.id}"]
    subnet_id = "${aws_subnet.subnet-pub-1.id}"
    tags {
        Name = "${var.sys}-${var.env}-load-balancer"
    }
    connection {
        type        = "${var.chef_connection.["type"]}"
        agent       = "${var.chef_connection.["agent"]}"
        private_key = "${file("${var.chef_connection.["private_key"]}")}"
        user        = "${var.chef_connection.["user"]}"
    }
    provisioner "file" {
        source      = "chef/chef-loadbalancer.sh"
        destination = "/tmp/chef-loadbalancer.sh"  
    }
    provisioner "local-exec" {
        command = "cp nginx/loadbalancer/default.conf.orig nginx/loadbalancer/default.conf && sed -i 's/backend/${aws_instance.backend.private_ip}/' nginx/loadbalancer/default.conf"
    }
    provisioner "file" {
        source      = "nginx/loadbalancer"
        destination = "/tmp"
    }
    provisioner "remote-exec" {
        inline = [
          "sudo apt update",  
          "sudo chmod +x /tmp/chef-loadbalancer.sh",
          "sudo /tmp/chef-loadbalancer.sh", 
        ]
    }
}

output "load_balancer_ip" {
  value = ["${aws_instance.load_balancer.public_ip}"]
}

