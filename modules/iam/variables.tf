variable "regions" {
  type = list(string)
}

variable "environment" {
  type = string
}

variable "codeconnection_arn" {
  type = string
}

variable "vpce_ids" {
  type = map(list(string))
}

variable "ssm_env_arns" {
  type = map(string)
}

variable "secret_arns" {
  type = map(string)
}

variable "ssm_kms_ids" {
  type = list(string)
}

variable "secret_kms_ids" {
  type = list(string)
}

variable "analytics_ssm_env_arns" {
  type = map(string)
}

variable "analytics_secret_arns" {
  type = map(string)
}

variable "analytics_secret_kms_id" {
  type = string
}

variable "analytics_ssm_kms_id" {
  type = string
}

variable "ecs_kms_arns" {
  type = list(string)
}

///

variable "proxy_ssm_env_arns" {
  type = map(string)
}

variable "proxy_secret_arns" {
  type = map(string)
}

variable "proxy_secret_kms_ids" {
  type = list(string)
}

variable "proxy_ssm_kms_ids" {
  type = list(string)
}

  
  
  