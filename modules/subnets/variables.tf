variable "environment" {
  type = string
}

variable "az" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_ipv6_cidr_block" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "igw_id" { // creates a dependency in place of using depends_on in nat gateway
  type = string
}

variable "rt_public_id" {
  type = string
}

variable "rt_private_id" {
  type = string
}

variable "az_index" {
  type = string
}