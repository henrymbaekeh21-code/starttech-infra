# ============================================================================
# Outputs - Root Configuration
# ============================================================================

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.networking.private_subnet_ids
}

# ---------------------------------------------------------------------------
# Compute
# ---------------------------------------------------------------------------
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.compute.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB"
  value       = module.compute.alb_zone_id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.asg_name
}

# ---------------------------------------------------------------------------
# Storage
# ---------------------------------------------------------------------------
output "s3_bucket_name" {
  description = "Name of the S3 bucket for frontend hosting"
  value       = module.storage.s3_bucket_name
}

output "s3_website_url" {
  description = "S3 static website URL"
  value       = module.storage.s3_website_url
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.storage.cloudfront_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.storage.cloudfront_distribution_id
}

# ---------------------------------------------------------------------------
# Cache
# ---------------------------------------------------------------------------
output "redis_endpoint" {
  description = "ElastiCache Redis primary endpoint"
  value       = module.cache.redis_endpoint
}

output "redis_port" {
  description = "ElastiCache Redis port"
  value       = module.cache.redis_port
}

# ---------------------------------------------------------------------------
# Monitoring
# ---------------------------------------------------------------------------
output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.monitoring.cloudwatch_log_group_name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  value       = module.monitoring.sns_topic_arn
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
output "deployment_summary" {
  description = "Summary of deployed resources"
  value       = <<-EOT
    ============================================================
    StartTech Infrastructure Deployed Successfully!
    ============================================================

    Frontend (React):
      S3 Bucket:     ${module.storage.s3_bucket_name}
      CloudFront:    https://${module.storage.cloudfront_domain_name}
      S3 Website:    ${module.storage.s3_website_url}

    Backend (Golang):
      ALB DNS:       http://${module.compute.alb_dns_name}
      ASG Name:      ${module.compute.asg_name}

    Cache (Redis):
      Endpoint:      ${module.cache.redis_endpoint}:${module.cache.redis_port}

    Monitoring:
      Log Group:     ${module.monitoring.cloudwatch_log_group_name}
      SNS Topic:     ${module.monitoring.sns_topic_arn}

    VPC:
      VPC ID:        ${module.networking.vpc_id}
    ============================================================
  EOT
}
