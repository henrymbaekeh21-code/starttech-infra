output "alb_arn" { value = aws_lb.main.arn }
output "alb_dns_name" { value = aws_lb.main.dns_name }
output "alb_zone_id" { value = aws_lb.main.zone_id }
output "alb_target_group_arn" { value = aws_lb_target_group.backend.arn }
output "asg_name" { value = aws_autoscaling_group.backend.name }
output "launch_template_id" { value = aws_launch_template.backend.id }
