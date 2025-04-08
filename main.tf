module "prod" {
  source = "./modules/environment"
  providers = {
    aws.us_west_1 = aws.us_west_1
    aws.us_west_2 = aws.us_west_2
    aws = aws
  }
  regions = var.regions
  environment = "prod"
  desired_counts_by_service = var.desired_counts_by_service
  domain = var.domain
  db_username = var.db_username
  db_password = var.db_password
  plaid_secret = var.plaid_secret
  plaid_host = var.plaid_host
  plaid_client_id = var.plaid_client_id
  email_host_password = var.email_host_password
  email_host_user = var.email_host_user
  fmp_key = var.fmp_key
  hosted_zone_id = module.domain_records.hosted_zone_id
  validation_record_fqdns = module.domain_records.validation_record_fqdns
}

module "domain_records" {
  source = "./modules/domain_records"
  providers = {
    aws = aws.us_west_1
  }
  regions = var.regions
  domain = var.domain
  domain_validation_options = module.prod.domain_validation_options
}

