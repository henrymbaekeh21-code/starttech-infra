# StartTech Infrastructure

> Month 3 Assessment - Infrastructure as Code with Terraform

## Overview

This repository contains Terraform configurations for deploying the StartTech application infrastructure on AWS. All resources are defined as code and managed through GitHub Actions CI/CD.

## Architecture

```
                    [CloudFront CDN]
                           |
                           v
                    [S3 - Frontend]
                           |
                    (User API Calls)
                           |
              +------------v------------+
              |   Application Load    |
              |      Balancer         |
              +------------+------------+
                           |
          +----------------+----------------+
          |                                 |
    [EC2 Instance]              [EC2 Instance]
    (AZ: us-east-1a)            (AZ: us-east-1b)
          |                                 |
          +----------------+----------------+
                           |
              +------------v------------+
              |   ElastiCache Redis     |
              +-------------------------+
                           |
              +------------v------------+
              |    MongoDB Atlas        |
              +-------------------------+
```

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── infrastructure-deploy.yml    # GitHub Actions pipeline
├── terraform/
│   ├── main.tf                          # Root orchestration
│   ├── variables.tf                     # Input variables
│   ├── outputs.tf                       # Output values
│   ├── terraform.tfvars.example         # Variable example
│   └── modules/
│       ├── networking/                  # VPC, subnets, NAT
│       ├── security/                    # Security groups
│       ├── compute/                     # ALB, ASG, EC2
│       ├── storage/                     # S3, CloudFront
│       ├── cache/                       # ElastiCache Redis
│       └── monitoring/                  # CloudWatch, IAM
├── scripts/
│   └── deploy-infrastructure.sh         # Deployment wrapper
├── monitoring/
│   ├── cloudwatch-dashboard.json        # Dashboard definition
│   ├── alarm-definitions.json           # Alarm configurations
│   └── log-insights-queries.txt         # Useful CW queries
└── README.md
```

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Terraform | >= 1.5.0 | Infrastructure provisioning |
| AWS CLI | >= 2.0 | AWS authentication |
| GitHub Actions | N/A | CI/CD pipeline |

## Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| `AWS_ROLE_ARN` | IAM role ARN for GitHub Actions OIDC |
| `MONGO_URI` | MongoDB Atlas connection string |
| `JWT_SECRET_KEY` | JWT signing secret |
| `MY_IP` | Your IP for SSH access (CIDR) |
| `BACKEND_IMAGE` | Docker image URI for backend |
| `SNS_EMAIL` | Email for alarm notifications |

## Quick Start

### 1. Configure AWS Credentials

Set up OIDC authentication between GitHub and AWS:

```bash
# Create an IAM role with trust policy for GitHub OIDC
# See: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
```

### 2. Set Up Terraform Backend

Create the S3 bucket and DynamoDB table for state management:

```bash
aws s3 mb s3://starttech-terraform-state --region us-east-1
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### 3. Configure Variables

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform.tfvars with your values
```

### 4. Deploy

```bash
# Option A: Via GitHub Actions (recommended)
git push origin main

# Option B: Manual deployment
./scripts/deploy-infrastructure.sh plan
./scripts/deploy-infrastructure.sh apply
```

## Terraform Modules

| Module | Resources | Description |
|--------|-----------|-------------|
| `networking` | VPC, subnets, NAT, IGW | Network foundation |
| `security` | Security groups | Firewall rules |
| `compute` | ALB, ASG, Launch Template | Backend compute |
| `storage` | S3, CloudFront | Frontend hosting |
| `cache` | ElastiCache Redis | Session/cache store |
| `monitoring` | CloudWatch, IAM, SNS | Observability |

## Outputs

| Output | Description |
|--------|-------------|
| `alb_dns_name` | Backend API endpoint |
| `cloudfront_domain_name` | Frontend CDN URL |
| `s3_bucket_name` | Frontend S3 bucket |
| `redis_endpoint` | Redis connection endpoint |
| `cloudwatch_log_group_name` | Log group for backend |

## Monitoring

- **CloudWatch Dashboard**: Visual overview of all metrics
- **Alarms**: CPU, latency, 5xx errors, healthy hosts
- **Logs**: Centralized via CloudWatch Logs Insights
- **SNS**: Email notifications for critical alarms

## Security

- OIDC authentication (no long-term AWS credentials)
- Security groups with least-privilege access
- Encrypted storage (S3, ElastiCache)
- IMDSv2 enforced on EC2 instances
- Private subnets for backend and cache

## Cleanup

```bash
./scripts/deploy-infrastructure.sh destroy
```

**Warning**: This will delete all AWS resources created by Terraform.
