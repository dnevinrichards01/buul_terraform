variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "data_subnet_ids" {
  type = list(string)
}

variable "data_security_group_id" {
  type = string
} 

variable "db_username_final" {
  type = string
}

variable "db_password_final" {
  type      = string
  sensitive = true
}

///

variable "proxy_db_user_username" {
  type = string
}

variable "proxy_db_user_password" {
  type = string
  sensitive = true
}