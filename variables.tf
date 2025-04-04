variable "desired_counts_by_service" {
  type = map(number)
  default = {
    app = 1,
    celery = 1,
    beat = 1
  }
}

variable "domain_name" {
  type = string
  default = "buul-load-balancer.link"
}

variable "db_username" {
  type = string
  default = "db"
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

variable "fmp_key" {
  type = string
  sensitive = true
}


