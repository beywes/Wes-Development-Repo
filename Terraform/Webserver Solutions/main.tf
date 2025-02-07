terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

# VPC and Network Configuration
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# Security Groups
module "security_groups" {
  source = "./modules/security"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}

# Application Load Balancer
module "alb" {
  source = "./modules/alb"

  vpc_id            = module.vpc.vpc_id
  environment       = var.environment
  public_subnets    = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_security_group_id
  certificate_arn   = var.certificate_arn
}

# WAF Configuration
module "waf" {
  source = "./modules/waf"

  alb_arn     = module.alb.alb_arn
  environment = var.environment
}

# EC2 Instances
module "webservers" {
  source = "./modules/ec2"

  environment          = var.environment
  instance_type       = var.webserver_instance_type
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  security_group_ids  = [module.security_groups.webserver_security_group_id]
  db_security_group_id = module.security_groups.db_security_group_id
  key_name           = var.key_name
  target_group_arns  = [module.alb.target_group_arn]
}

# Route 53 Configuration
module "route53" {
  source = "./modules/route53"

  domain_name     = var.domain_name
  environment     = var.environment
  alb_dns_name    = module.alb.alb_dns_name
  alb_zone_id     = module.alb.alb_zone_id
}
