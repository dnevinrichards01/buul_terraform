variable "regions" {
  type = list(string)
}

variable "environment" {
  type = string
}

variable "desired_counts_by_service" {
  type = map(number)
}

variable "domain" {
  type        = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true
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

variable "analytics_db_user_username" {
  type = string
}

variable "analytics_db_user_password" {
  type = string
  sensitive = true
}

variable "analytics_db_master_username" {
  type = string
}

variable "analytics_db_master_password" {
  type = string
  sensitive = true
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


//

variable "proxy_master_key" {
  type = string
  sensitive = true
}

variable "proxy_db_user_username" {
  type = string
  sensitive = true
}

variable "proxy_db_user_password" {
  type = string
  sensitive = true
}