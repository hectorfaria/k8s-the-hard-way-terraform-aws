provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  region = "us-east-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Name = "kubernetes"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "kubernetes-the-hard-way"
  cidr = local.vpc_cidr


  azs             = local.azs
  public_subnets  = ["10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24"]


  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway      = true
  single_nat_gateway      = true
  map_public_ip_on_launch = true


  tags = {
    Name = "kubernetes-the-hard-way"
  }
}

resource "aws_security_group" "kubernetes" {
  name        = "kubernetes"
  description = "Kubernetes security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16", "10.200.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.tags
}
