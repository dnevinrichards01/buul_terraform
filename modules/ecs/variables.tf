variable "environment" {
  type    = string
  default = "prod"
}

variable "region" {
  type    = string
  default = "us-west-1"
}

variable "vpc_id" {
  type = string
}

variable "desired_counts_by_service" {
  type = map(number)
}

variable "alb_subnet_ids" {
  type = list(string)
}

variable "app_subnet_ids" {
  type = list(string)
}

variable "data_subnet_ids" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "app_security_group_id" {
  type = string
}

variable "data_security_group_id" {
  type = string
}

variable "ssm_env_arns" {
  type = map(string)
}

variable "secrets_arns" {
  type = map(string)
}

variable "ecr_repo_names" {
  type = map(string)
}

variable "ecs_task_role_arns" {
  type = map(string)
}

variable "acm_cert_arn" {
  type = string
}

variable "vpce_ids" {
  type = map(string)
}

variable "monitoring_logs_bucket_id" {
  type = string
}