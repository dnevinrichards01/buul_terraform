module "region_us_west_1" {
  source = "../region"
  count = contains(var.regions, "us-west-1") ? 1 : 0
  providers = {
    aws = aws.us_west_1
  }
  environment = var.environment
  domain = var.domain
  hosted_zone_id = var.hosted_zone_id
  desired_counts_by_service = var.desired_counts_by_service

  secret_policy_doc_json = module.iam.secret_policy_doc_json
  ecs_task_role_arns = module.iam.ecs_task_role_arns
  sqs_access_policy_doc_json = module.iam.sqs_access_policy_doc_json
  db_username = var.db_username
  db_password = var.db_password
  plaid_secret = var.plaid_secret
  plaid_host = var.plaid_host
  fmp_key = var.fmp_key
  email_host_password = var.email_host_password
  email_host_user = var.email_host_user
  plaid_client_id = var.plaid_client_id
  validation_record_fqdns = var.validation_record_fqdns
}

module "region_us_west_2" {
  source = "../region"
  count = contains(var.regions, "us-west-2") ? 1 : 0
  providers = {
    aws = aws.us_west_2
  }
  environment = var.environment
  domain = var.domain
  hosted_zone_id = var.hosted_zone_id
  desired_counts_by_service = var.desired_counts_by_service

  secret_policy_doc_json = module.iam.secret_policy_doc_json
  ecs_task_role_arns = module.iam.ecs_task_role_arns
  sqs_access_policy_doc_json = module.iam.sqs_access_policy_doc_json
  db_username = var.db_username
  db_password = var.db_password
  plaid_secret = var.plaid_secret
  plaid_host = var.plaid_host
  fmp_key = var.fmp_key
  email_host_password = var.email_host_password
  email_host_user = var.email_host_user
  plaid_client_id = var.plaid_client_id
  validation_record_fqdns = var.validation_record_fqdns
}

module "latency_routing" {
  source = "../latency_routing"
  providers = {
    aws = aws
  }
  regions = var.regions
  environment = var.environment
  alb_dns_names = local.alb_dns_names
  alb_zone_ids = local.alb_zone_ids
  hosted_zone_id = var.hosted_zone_id
  domain = var.domain
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
  vpce_ids = local.vpce_ids
  ssm_env_arns = module.region_us_west_1[0].ssm_env_arns
  secret_arns = module.region_us_west_1[0].secret_arns
  secret_kms_ids = local.secret_kms_ids
  ssm_kms_ids = local.ssm_kms_ids
}