variable "project_name" { type = string }
variable "environment" { type = string }
variable "alb_arn" { type = string }
variable "alb_target_group_arn" { type = string }
variable "asg_name" { type = string }
variable "cloudwatch_log_group_name" { type = string }
variable "sns_email" { type = string }

variable "desired_capacity" {
  type    = number
  default = 2
}
