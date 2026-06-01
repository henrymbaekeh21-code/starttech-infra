variable "project_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "alb_security_group_id" { type = string }
variable "ec2_security_group_id" { type = string }
variable "key_name" { type = string }
variable "instance_type" { type = string }
variable "desired_capacity" { type = number }
variable "min_size" { type = number }
variable "max_size" { type = number }
variable "backend_image" { type = string }
variable "container_port" { type = number }

variable "mongo_uri" {
  type      = string
  sensitive = true
}

variable "redis_addr" { type = string }

variable "jwt_secret_key" {
  type      = string
  sensitive = true
}

variable "health_check_path" { type = string }
variable "iam_instance_profile_name" { type = string }
