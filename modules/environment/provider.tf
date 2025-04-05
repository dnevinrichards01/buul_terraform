terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
        configuration_aliases = [
            aws.us_west_1,
            aws.us_west_2
        ]
    }
  }
}