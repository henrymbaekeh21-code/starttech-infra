#!/bin/bash
# ============================================================================
# EC2 User Data - Backend Instance Bootstrap
# ============================================================================
set -euo pipefail
exec > >(tee /var/log/user-data.log) 2>&1

echo "=== Starting user data script at $(date) ==="

# Update system
yum update -y

# Install Docker
yum install -y docker
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# Install AWS CloudWatch Agent
yum install -y amazon-cloudwatch-agent

# Configure CloudWatch Agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'CWCONFIG'
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/muchtodo.log",
            "log_group_name": "${log_group}",
            "log_stream_name": "{instance_id}/app",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/user-data.log",
            "log_group_name": "${log_group}",
            "log_stream_name": "{instance_id}/bootstrap",
            "timezone": "UTC"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "StartTech/Backend",
    "metrics_collected": {
      "disk": {
        "measurement": ["used_percent"],
        "resources": ["*"],
        "drop_device": true
      },
      "mem": {
        "measurement": ["mem_used_percent"]
      },
      "cpu": {
        "measurement": ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"],
        "metrics_collection_interval": 60,
        "totalcpu": true
      }
    },
    "append_dimensions": {
      "AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
      "InstanceId": "$${aws:InstanceId}"
    }
  }
}
CWCONFIG

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Login to ECR (if image is from ECR)
if [[ "${backend_image}" == *"dkr.ecr"* ]]; then
  ACCOUNT_ID=$(curl -s http://169.254.169.254/latest/meta-data/identity-credentials/ec2/info | grep -o '"AccountId" : "[0-9]*"' | cut -d'"' -f4)
  REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
  aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
fi

# Create environment file
cat > /etc/muchtodo.env << ENVEOF
PORT=${container_port}
MONGO_URI=${mongo_uri}
REDIS_ADDR=${redis_addr}
JWT_SECRET_KEY=${jwt_secret_key}
ENABLE_CACHE=true
LOG_LEVEL=INFO
LOG_FORMAT=json
ENVEOF

chmod 600 /etc/muchtodo.env

# Pull and run backend container
docker pull ${backend_image}

docker run -d \
  --name muchtodo-backend \
  --restart unless-stopped \
  --env-file /etc/muchtodo.env \
  -p ${container_port}:${container_port} \
  --log-driver awslogs \
  --log-opt awslogs-group=${log_group} \
  --log-opt awslogs-region=${region} \
  --log-opt awslogs-create-group=true \
  ${backend_image}

# Health check loop
echo "=== Waiting for application to be healthy ==="
for i in {1..30}; do
  if curl -sf http://localhost:${container_port}${health_check_path} > /dev/null 2>&1; then
    echo "=== Application is healthy at $(date) ==="
    exit 0
  fi
  echo "Health check attempt $i failed, retrying in 5s..."
  sleep 5
done

echo "=== WARNING: Application did not become healthy ==="
exit 0
