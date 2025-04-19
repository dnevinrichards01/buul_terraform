variable "desired_counts_by_service" {
  type = map(number)
  default = {
    app = 1,
    celery = 1,
    beat = 1
  }
}

variable "domain" {
  type = string
  default = "buul-load-balancer.link"
}

variable "db_username" {
  type = string
  default = "db"
}

variable "analytics_db_master_username" {
  type = string
  default = "analyticsdb"
}

variable "analytics_db_user_username" {
  type = string
  default = "analyticsuser"
}

//

variable "db_password" {
  type = string
  sensitive = true
  default = "_BZV}^MliKL-8S)Q:u^_l:,M\u003c8aSp=,F"
}

variable "analytics_db_master_password" {
  type = string
  sensitive = true
  default = "_BZV}^MliKL-9T)R:v^_m:,Nv114d9bTq=,G"
}

variable "analytics_db_user_password" {
  type = string
  sensitive = true
  default = "_BZV}^abCDc-9T)R:v^_m:,Nv114d9bTq=,G"
}

variable "plaid_secret" {
  type = string
  sensitive = true
  default = "00874a8fdeea04e481523dbcb64eb1"
}

variable "plaid_host" {
  type = string
  sensitive = true
  default = "https://production.plaid.com"
}

variable "plaid_client_id" {
  type = string
  sensitive = true
  default = "671605190a8131001a389fcd"
}

variable "email_host_password" {
  type = string
  sensitive = true
  default = "izyaqueugqtaiiwh"
}

variable "email_host_user" {
  type = string
  sensitive = true
  default = "notifications@bu-ul.com"
}

variable "fmp_key" {
  type = string
  sensitive = true
  default = "I43MDWYS5CSPVrNprVkRitsfyA12q4Zc"
}

variable "regions" {
  type = list(string)
  default = ["us-west-1"]
}

variable "anonymize_user_hmac_key" {
  type = string
  sensitive = true
  default = "QcNqeUlvNTv3Q3xAWtFqZyduN5n6"
}

variable "notifications_email" {
  type = string
  sensitive = true
  default = "notifications@bu-ul.com"
}

variable "sendgrid_api_key" {
  type = string
  sensitive = true
  default = "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"
}