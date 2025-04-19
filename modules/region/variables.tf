variable "environment" {
  type = string
}

variable "desired_counts_by_service" {
  type = map(number)
}

variable "ecs_task_role_arns" {
  type = map(string)
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true
}

variable "domain" {
  type = string
}


variable "plaid_secret" {
  type = string
  sensitive = true
}

variable "plaid_host" {
  type = string
  sensitive = true
}

variable "plaid_client_id" {
  type = string
  sensitive = true
}

variable "email_host_password" {
  type = string
  sensitive = true
}

variable "email_host_user" {
  type = string
  sensitive = true
}

variable "fmp_key" {
  type = string
  sensitive = true
}

variable "hosted_zone_id" {
  type = string
}

variable "validation_record_fqdns" {
  type = list(string)
}

variable "analytics_db_name_port_host" {
  type = map(string)
}

variable "analytics_ec2_role_arn" {
  type = string
}

variable "analytics_db_user_password" {
  type = string
  sensitive = true
}

variable "analytics_db_user_username" {
  type = string
}

variable "anonymize_user_hmac_key" {
  type = string
  sensitive = true
}

variable "notifications_email" {
  type = string
  sensitive = true
}

variable "sendgrid_api_key" {
  type = string
  sensitive = true
}