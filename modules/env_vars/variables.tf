variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "sqs_urls" {
  type = map(string)
}

variable "redis_no_cluster_host_port_url" {
  type = map(string)
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "plaid_client_id" {
  type      = string
  sensitive = true
}

variable "db_name_port_host" {
  type = map(string)
}

variable "plaid_secret" {
  type      = string
  sensitive = true
}

variable "plaid_host" {
  type      = string
  sensitive = true
}

variable "email_host_password" {
  type      = string
  sensitive = true
}

variable "email_host_user" {
  type      = string
  sensitive = true
}

variable "fmp_key" {
  type      = string
  sensitive = true
}

variable "vpce_ids" {
  type = map(string)
}

variable "ecs_task_role_arns" {
  type = map(string)
}

variable "kms_aliases" {
  type = map(string)
}

//variable "analytics_db_user_username" {
//  type = string
//}

//variable "analytics_db_user_password" {
//  type = string
//  sensitive = true
//}

//variable "analytics_db_name_port_host" {
//  type = map(string)
//}

//variable "analytics_ec2_role_arn" {
//  type = string
//}

variable "anonymize_user_hmac_key" {
  type      = string
  sensitive = true
}

variable "notifications_email" {
  type      = string
  sensitive = true
}

variable "sendgrid_api_key" {
  type      = string
  sensitive = true
}

variable "domain" {
  type = string
}


variable "docker_username" {
  sensitive = true
  type = string
}

variable "docker_password" {
  sensitive = true
  type = string
}

variable "codebuild_role_arn" {
  type = string
}




