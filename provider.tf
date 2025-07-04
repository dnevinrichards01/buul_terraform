terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

// add more as we add more regions..
provider "aws" {
  profile = "ab-nevin"
  region  = "us-west-1"
  alias   = "us_west_1"
}

provider "aws" {
  profile = "ab-nevin"
  region  = "us-west-2"
  alias   = "us_west_2"
}

