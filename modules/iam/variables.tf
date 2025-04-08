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