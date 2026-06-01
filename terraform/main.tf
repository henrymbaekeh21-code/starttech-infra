# ============================================================================
# StartTech Infrastructure - Root Configuration
# ============================================================================
# Orchestrates all infrastructure modules for the MuchToDo application.
# ============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = var.owner
    }
  }
}

# ============================================================================
# Networking Module
# ============================================================================
module "networking" {
  source = "./modules/networking"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# ============================================================================
# Security Module
# ============================================================================
module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id
  my_ip        = var.my_ip
}

# ============================================================================
# Storage Module (S3 + CloudFront)
# ============================================================================
module "storage" {
  source = "./modules/storage"

  project_name    = var.project_name
  environment     = var.environment
  domain_name     = var.domain_name
  certificate_arn = var.certificate_arn
}

# ============================================================================
# Cache Module (ElastiCache Redis)
# ============================================================================
module "cache" {
  source = "./modules/cache"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  security_group_id  = module.security.redis_security_group_id
}

# ============================================================================
# Compute Module (EC2, ASG, ALB)
# ============================================================================
module "compute" {
  source = "./modules/compute"

  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.networking.vpc_id
  public_subnet_ids         = module.networking.public_subnet_ids
  private_subnet_ids        = module.networking.private_subnet_ids
  alb_security_group_id     = module.security.alb_security_group_id
  ec2_security_group_id     = module.security.ec2_security_group_id
  key_name                  = var.key_name
  instance_type             = var.instance_type
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  backend_image             = var.backend_image
  container_port            = var.container_port
  mongo_uri                 = var.mongo_uri
  redis_addr                = module.cache.redis_endpoint
  jwt_secret_key            = var.jwt_secret_key
  health_check_path         = var.health_check_path
  iam_instance_profile_name = module.monitoring.ec2_instance_profile_name
}

# ============================================================================
# Monitoring Module (CloudWatch + IAM)
# ============================================================================
module "monitoring" {
  source = "./modules/monitoring"

  project_name              = var.project_name
  environment               = var.environment
  alb_arn                   = module.compute.alb_arn
  alb_target_group_arn      = module.compute.alb_target_group_arn
  asg_name                  = module.compute.asg_name
  cloudwatch_log_group_name = var.cloudwatch_log_group_name
  sns_email                 = var.sns_email
}
