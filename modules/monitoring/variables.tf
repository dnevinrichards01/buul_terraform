variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "flow_logs_role_arn" {
  type = string
}

variable "app_alb_arn" {
  type = string
}

variable "firehose_delivery_role_arn" {
  type = string
}