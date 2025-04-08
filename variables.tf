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

//

variable "db_password" {
  type = string
  sensitive = true
  default = "%BZV}^MliKL+8S)Q;u^_l:,M\u003c8aSp=,F"
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
//

