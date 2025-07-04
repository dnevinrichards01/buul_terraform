variable "environment" {
  type    = string
  default = "prod"
}

variable "region" {
  type = string
}

variable "domain" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "validation_record_fqdns" {
  type = list(string)
}