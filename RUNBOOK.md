# Operations Runbook

## Quick Reference

| Component | Health Check | Logs |
|-----------|-------------|------|
| Backend API | `curl http://ALB_DNS/health` | `/starttech/production/backend` |
| Frontend | `curl https://CLOUDFRONT_DOMAIN` | S3 access logs |
| Redis | `redis-cli -h ENDPOINT ping` | ElastiCache console |
| MongoDB | Atlas dashboard | Atlas logs |

## Common Procedures

### Check Application Health

```bash
# Backend health
curl http://$(terraform output -raw alb_dns_name)/health

# Check all pods/targets
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw alb_target_group_arn)
```

### View Logs

```bash
# Recent backend logs
aws logs tail /starttech/production/backend --follow

# Search for errors
aws logs filter-log-events \
  --log-group-name /starttech/production/backend \
  --filter-pattern "ERROR" \
  --limit 50
```

### Scale Backend Manually

```bash
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name $(terraform output -raw asg_name) \
  --desired-capacity 4
```

### Restart Backend (Rolling Update)

```bash
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name $(terraform output -raw asg_name) \
  --strategy Rolling \
  --preferences MinHealthyPercentage=50
```

### Rollback Backend

```bash
cd scripts
./rollback.sh
# Or specify a version:
# ./rollback.sh v1.2.3
```

## Troubleshooting

### Backend Returning 5xx Errors

1. Check application logs for errors
2. Verify MongoDB connection: `curl /health` should show `"database": "ok"`
3. Check target health in ALB console
4. Review CloudWatch 5xx alarm

### High CPU / Slow Response

1. Check CloudWatch CPU metric
2. ASG should auto-scale, verify instance count
3. Check Redis cache hit rate
4. Review slow query logs in MongoDB Atlas

### Frontend Not Loading

1. Check S3 bucket has `index.html`
2. Verify CloudFront distribution is deployed
3. Check CloudFront invalidation status
4. Test S3 website endpoint directly

### Redis Connection Failures

1. Check ElastiCache status in console
2. Verify security group allows port 6379 from EC2
3. Test: `redis-cli -h <endpoint> -p 6379 ping`
4. Check for memory exhaustion

## Emergency Contacts

| Alert Level | Response Time | Action |
|-------------|---------------|--------|
| Critical (5xx, down) | 15 minutes | Page on-call engineer |
| Warning (high CPU) | 1 hour | Review during business hours |
| Info (deployment) | N/A | Log only |

## Maintenance Windows

- **Terraform updates**: Wednesday 10:00-12:00 UTC
- **Database patches**: MongoDB Atlas handles automatically
- **Security updates**: AWS Systems Manager Patch Manager
