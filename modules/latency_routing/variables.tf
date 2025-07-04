variable "regions" {
  type = list(string)
}

variable "environment" {
  type = string
}

variable "domain" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "alb_dns_names" {
  type = map(string)
}

variable "alb_zone_ids" {
  type = map(string)
}
