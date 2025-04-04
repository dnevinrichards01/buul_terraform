module "prod" {
  source = "./modules/environment"
  providers = {
    aws.us_west_1 = aws.us_west_1
    aws.us_west_2 = aws.us_west_2
  }
  regions = ["us-west-1"]
  environment = "abprod"
  desired_counts_by_service = var.desired_counts_by_service
  domain_name = var.domain_name
  db_username = var.db_username
  plaid_secret = var.plaid_secret
  plaid_host = var.plaid_host
  plaid_client_id = var.plaid_client_id
  email_host_password = var.email_host_password
  fmp_key = var.fmp_key
}