resource "aws_s3_bucket" "stfile" {
  bucket = "backend-st"  # Must be globally unique
  }

# VPC
module "vpc" {
  source   = "./vpc-mod"
  vpc_cidr = "10.0.0.0/16"
}

# Public Subnets
module "subnet_public_1" {
  source     = "./subnets-mod"
  vpc_id     = module.vpc.vpc_id
  cidr_block = "10.0.0.0/24"
  az         = "us-east-1a"
  public     = true
  name       = "public-subnet-1"
}

module "subnet_public_2" {
  source     = "./subnets-mod"
  vpc_id     = module.vpc.vpc_id
  cidr_block = "10.0.2.0/24"
  az         = "us-east-1b"
  public     = true
  name       = "public-subnet-2"
}

# Private Subnets
module "subnet_private_1" {
  source     = "./subnets-mod"
  vpc_id     = module.vpc.vpc_id
  cidr_block = "10.0.1.0/24"
  az         = "us-east-1a"
  public     = false
  name       = "private-subnet-1"
}

module "subnet_private_2" {
  source     = "./subnets-mod"
  vpc_id     = module.vpc.vpc_id
  cidr_block = "10.0.3.0/24"
  az         = "us-east-1b"
  public     = false
  name       = "private-subnet-2"
}

# NAT & Internet Gateway
module "nat" {
  source           = "./Nat-mod"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.subnet_public_1.subnet_id
  name_prefix      = "app"
}

# Route Tables
module "route_tables" {
  source              = "./RT-mod"
  vpc_id              = module.vpc.vpc_id
  igw_id              = module.nat.igw_id
  nat_id              = module.nat.nat_id
  name_prefix         = "app"
  public_subnet_map   = {
    public1 = module.subnet_public_1.subnet_id
    public2 = module.subnet_public_2.subnet_id
  }
  private_subnet_map  = {
    private1 = module.subnet_private_1.subnet_id
    private2 = module.subnet_private_2.subnet_id
  }
}

# Security Groups
module "security_groups" {
  source      = "./securityG-mod"
  vpc_id      = module.vpc.vpc_id
  name_prefix = "pro-sg"
}

# Backend Apache EC2s (Private)
module "backend_1" {
  source        = "./backend _instances-mod"
  instance_type = "t2.micro"
  subnet_id     = module.subnet_private_1.subnet_id
  sg_ids        = [module.security_groups.secgr_id]
  name          = "backend-apache-1"
  bastion_host           = module.proxy_1.public_ip
  bastion_private_key_path = "./../prkey.pem"
}

module "backend_2" {
  source        = "./backend _instances-mod"
  instance_type = "t2.micro"
  subnet_id     = module.subnet_private_2.subnet_id
  sg_ids        = [module.security_groups.secgr_id]
  name          = "backend-apache-2"
  bastion_host           = module.proxy_2.public_ip
  bastion_private_key_path = "./../prkey.pem"
}

# Reverse Proxy EC2s (Public)
module "proxy_1" {
  source         = "./proxy-mod"
  instance_type  = "t2.micro"
  subnet_id      = module.subnet_public_1.subnet_id
  sg_ids         = [module.security_groups.secgr_id]
  backend_lb_dns = module.lb_backend.alb_dns_name
  name           = "proxy-1"
}

module "proxy_2" {
  source         = "./proxy-mod"
  instance_type  = "t2.micro"
  subnet_id      = module.subnet_public_2.subnet_id
  sg_ids         = [module.security_groups.secgr_id]
  backend_lb_dns = module.lb_backend.alb_dns_name
  name           = "proxy-2"
}

# Load Balancer for Reverse Proxies (Public-facing)
module "lb_reverse_proxy" {
  source       = "./loadbalancer-mod"
  name_prefix  = "gw-loadbalancer"
  internal     = false
  port         = 80
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = [
    module.subnet_public_1.subnet_id,
    module.subnet_public_2.subnet_id
  ]
  sg_id        = module.security_groups.secgr_id

  instance_map = {
    "proxy1" = module.proxy_1.instance_id
    "proxy2" = module.proxy_2.instance_id
  }
}

# Load Balancer for Apache Backend (Private/internal)
module "lb_backend" {
  source       = "./loadbalancer-mod"
  name_prefix  = "backend-lb"
  internal     = true
  port         = 80
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = [
    module.subnet_private_1.subnet_id,
    module.subnet_private_2.subnet_id
  ]
  sg_id        = module.security_groups.secgr_id

  instance_map = {
    "backend1" = module.backend_1.instance_id
    "backend2" = module.backend_2.instance_id
  }
}


