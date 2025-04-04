variable "environment" {
  type = string
  default = "prod"
}

variable "region" {
  type = string
  default = "us-west-1"
}

variable "domain_name" {
  type        = string
}

variable "alb_dns_name" {
  type        = string
}

variable "alb_zone_id" {
  type        = string
}
