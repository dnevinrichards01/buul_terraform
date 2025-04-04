module "region_us_west_1" {
  source = "../region"
  count = contains(var.regions, "us-west-1") ? 1 : 0
  providers = {
    aws = aws.us_west_1
  }
  environment = var.environment
  desired_counts_by_service = var.desired_counts_by_service

  secret_policy_doc_json = module.iam.secret_policy_doc_json
  ecs_task_role_arns = module.iam.ecs_task_role_arns
  domain_name = var.domain_name
  sqs_access_policy_doc_json = module.iam.sqs_access_policy_doc_json
  db_username = var.db_username
  plaid_secret = var.plaid_secret
  plaid_host = var.plaid_host
  fmp_key = var.fmp_key
  email_host_password = var.email_host_password
  plaid_client_id = var.plaid_client_id
}

module "region_us_west_2" {
  source = "../region"
  count = contains(var.regions, "us-west-2") ? 1 : 0
  providers = {
    aws = aws.us_west_2
  }
  environment = var.environment
  desired_counts_by_service = var.desired_counts_by_service

  secret_policy_doc_json = module.iam.secret_policy_doc_json
  ecs_task_role_arns = module.iam.ecs_task_role_arns
  domain_name = var.domain_name
  sqs_access_policy_doc_json = module.iam.sqs_access_policy_doc_json
  db_username = var.db_username
  plaid_secret = var.plaid_secret
  plaid_host = var.plaid_host
  fmp_key = var.fmp_key
  email_host_password = var.email_host_password
  plaid_client_id = var.plaid_client_id
}



module "codebuild" {
  source = "../codebuild"
  providers = {
    aws = aws.us_west_1
  }
  region = "us-west-1"
  environment = var.environment
  role_arn =  module.iam.codebuild_role_arn
}

module "analytics_ec2" {
  source = "../analytics_ec2"
  providers = {
    aws = aws.us_west_1
  }
  environment = var.environment
  analytics_sg_id = module.region_us_west_1[0].analytics_sg_id
  app_subnet_id = module.region_us_west_1[0].app_subnet_ids[0]
}


module "iam" {
  source = "../iam"
  environment = var.environment
  regions = var.regions
  codeconnection_arn = module.codebuild.codeconnection_arn
}