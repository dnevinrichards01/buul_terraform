variable "domain" {
  type = string
}

variable "regions" {
  type = list(string)
}

variable "domain_validation_options" {
  type = list(any)
}