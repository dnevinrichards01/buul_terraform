variable "environment" {
  type = string
}

variable "secret_policy_doc_json" {
  type = string
}

variable "desired_counts_by_service" {
  type = map(number)
}

variable "ecs_task_role_arns" {
  type = map(string)
}

variable "sqs_access_policy_doc_json" { 
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

