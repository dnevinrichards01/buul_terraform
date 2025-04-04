variable "environment" {
  type = string
  default = "prod"
}

variable "region" {
  type = string
  default = "us-west-1"
}

variable "sqs_access_policy_doc_json" { 
    type = map(string)
}
