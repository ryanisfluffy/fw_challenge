terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.7"
        }
        cloudinit = {
            source = "hashicorp/cloudinit"
            version = "~> 2.2.0"
        }
        tls = {
            source = "hashicorp/tls"
            version = "~> 3.4.0"
        }
    }
    required_version = ">=1.2.0"
}

provider "aws" {
  region     = var.region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-west-3a"

  tags = {
      Name = "Public Subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "Public Subnet Route Table"
    }
}

resource "aws_route_table_association" "public_route_table_assoc" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public_route_table.id
}


resource "aws_instance" "app" {
    
    ami = var.ami_id
    instance_type = var.instance_type
    key_name = aws_key_pair.generated-key-pair.key_name
    user_data = data.cloudinit_config.server_conf.rendered
    vpc_security_group_ids = [ aws_security_group.app-security-group.id]
    subnet_id = aws_subnet.public.id
    associate_public_ip_address = true

    tags = {
        Name = var.app_name
    }
}

resource "aws_security_group" "app-security-group" {
  name = "app-security-group"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "ingress-app" {
    type = "ingress"
    from_port = 3030
    to_port = 3030
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = aws_security_group.app-security-group.id
    
}

resource "aws_security_group_rule" "ingress-ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = aws_security_group.app-security-group.id
    
}

resource "aws_security_group_rule" "egress-all" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = aws_security_group.app-security-group.id
    
}

data "cloudinit_config" "server_conf" {
    gzip = true
    base64_encode = true
    part {
        content_type = "text/cloud-config"
        content = file("${path.module}/cloudconfig.yaml")
    }
}

resource "tls_private_key" "pem" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated-key-pair" {
  key_name   = "generated-key-pair"
  public_key = tls_private_key.pem.public_key_openssh

# Creates the pem file on your computer
  provisioner "local-exec" {
    command = "echo '${tls_private_key.pem.private_key_pem}' > ./generated-key-pair.pem"
  }
}
