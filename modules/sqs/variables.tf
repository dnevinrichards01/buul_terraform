variable "environment" {
  type    = string
  default = "prod"
}

variable "region" {
  type    = string
  default = "us-west-1"
}

variable "ecs_task_role_arns" {
  type = map(string)
}

variable "vpce_ids" {
  type = map(string)
}