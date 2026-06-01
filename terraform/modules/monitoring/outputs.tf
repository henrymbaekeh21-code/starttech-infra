output "cloudwatch_log_group_name" { value = aws_cloudwatch_log_group.backend.name }
output "sns_topic_arn" { value = aws_sns_topic.alarms.arn }
output "ec2_instance_profile_name" { value = aws_iam_instance_profile.ec2_cloudwatch.name }
output "dashboard_name" { value = aws_cloudwatch_dashboard.main.dashboard_name }
