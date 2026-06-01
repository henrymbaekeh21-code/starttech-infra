# System Architecture Documentation

## Overview

The StartTech application uses a modern cloud-native architecture deployed on AWS with full CI/CD automation.

## High-Level Architecture

```
                              Users
                               |
            +------------------+------------------+
            |                                     |
     [CloudFront CDN]                    [Route 53]
            |                                     |
            v                                     v
     [S3 Frontend]                      [ALB HTTPS:443]
     (React SPA)                              |
                                              v
                                       [Target Group]
                                              |
                              +---------------+---------------+
                              |                               |
                    [EC2 - AZ1a]                  [EC2 - AZ1b]
                    (Backend API)                 (Backend API)
                    Docker Container              Docker Container
                              |                               |
                              +---------------+---------------+
                                              |
                              +---------------+---------------+
                              |                               |
                    [ElastiCache Redis]           [MongoDB Atlas]
                    (Session/Cache)                 (Database)
```

## Component Details

### Frontend (React)
- **Hosting**: S3 with static website configuration
- **CDN**: CloudFront for global edge caching
- **CI/CD**: GitHub Actions builds and deploys on push
- **Cache Strategy**: Immutable assets (long TTL), HTML (no-cache)

### Backend API (Golang)
- **Runtime**: Docker containers on EC2
- **Scaling**: Auto Scaling Group (2-5 instances)
- **Load Balancing**: Application Load Balancer
- **Health Checks**: `/health` endpoint with DB + cache validation
- **Deployment**: Rolling updates via instance refresh

### Cache (Redis)
- **Service**: AWS ElastiCache Redis 7
- **Config**: Multi-AZ with automatic failover
- **Encryption**: At-rest and in-transit
- **Use Cases**: Session storage, username cache, rate limiting

### Database (MongoDB)
- **Service**: MongoDB Atlas (managed)
- **Connection**: Via VPC peering or public IP with auth
- **Backup**: Atlas automated backups

## Network Architecture

```
VPC: 10.0.0.0/16
|
|-- Public Subnets (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24)
|   |-- ALB
|   |-- NAT Gateways
|
|-- Private Subnets (10.0.10.0/24, 10.0.11.0/24, 10.0.12.0/24)
    |-- EC2 instances (backend)
    |-- ElastiCache Redis
```

## CI/CD Flow

```
Developer Push
      |
      v
[GitHub Actions]
      |
      +-- Frontend Pipeline --> Build --> Test --> S3 Deploy --> CF Invalidate
      |
      +-- Backend Pipeline --> Test --> Build Image --> ECR Push --> Rolling Update
      |
      +-- Infra Pipeline --> Terraform Plan --> Terraform Apply
```

## Security Architecture

| Layer | Implementation |
|-------|---------------|
| Authentication | JWT tokens (backend) |
| Authorization | Role-based access |
| Network | Security groups, private subnets |
| Data | Encryption at rest and in transit |
| Secrets | GitHub Secrets + AWS Secrets Manager |
| CI/CD | OIDC (no long-lived credentials) |

## Scaling Strategy

| Component | Scaling Method |
|-----------|---------------|
| Frontend | CloudFront auto-scales globally |
| Backend | ASG with CPU-based scaling policies |
| Cache | ElastiCache cluster mode |
| Database | MongoDB Atlas auto-scaling |

## Disaster Recovery

| Component | RTO | RPO | Strategy |
|-----------|-----|-----|----------|
| Frontend | <5 min | N/A | S3 + CloudFront (multi-region) |
| Backend | <10 min | N/A | ASG replaces failed instances |
| Cache | <5 min | Minutes | Redis replication + failover |
| Database | <15 min | <1 hour | Atlas automated backups |
