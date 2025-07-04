variable "environment" {
  type = string
}

variable "app_subnet_id" {
  type = string
}

variable "data_subnet_ids" {
  type = list(string)
}

variable "analytics_db_master_password" {
  type      = string
  sensitive = true
}

variable "analytics_db_master_username" {
  type = string
}

variable "analytics_db_user_password" {
  type      = string
  sensitive = true
}

variable "analytics_db_user_username" {
  type = string
}

variable "sg_analytics_id" {
  type = string
}

variable "sg_analyticsdb_id" {
  type = string
}

variable "db_name_port_host" {
  type = map(string)
}

variable "ec2_analytics_role_name" {
  type = string
}
