variable "region" {
    type = string
}

variable "environment" {
    type = string
}

variable "secret_policy_doc_json" {
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

variable "plaid_client_id" {
  type = string
  sensitive = true
}

variable "db_name_port_host" {
  type = map(string)
}

variable "plaid_secret" {
  type = string
  sensitive = true
}

variable "plaid_host" {
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
