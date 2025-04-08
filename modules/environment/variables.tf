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