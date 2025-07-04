module "region_us_west_1" {
  source = "../region"
  count  = contains(var.regions, "us-west-1") ? 1 : 0
  providers = {
    aws = aws.us_west_1
  }
  environment               = var.environment
  domain                    = var.domain
  hosted_zone_id            = var.hosted_zone_id
  desired_counts_by_service = var.desired_counts_by_service

  ecs_task_role_arns         = module.iam.ecs_task_role_arns
  db_username                = var.db_username
  db_password                = var.db_password
  plaid_secret               = var.plaid_secret
  plaid_host                 = var.plaid_host
  fmp_key                    = var.fmp_key
  anonymize_user_hmac_key    = var.anonymize_user_hmac_key
  email_host_password        = var.email_host_password
  email_host_user            = var.email_host_user
  notifications_email        = var.notifications_email
  sendgrid_api_key           = var.sendgrid_api_key
  plaid_client_id            = var.plaid_client_id
  validation_record_fqdns    = var.validation_record_fqdns
  flow_logs_role_arn         = module.iam.flow_logs_role_arn
  firehose_delivery_role_arn = module.iam.firehose_delivery_role_arn

  //  analytics_ec2_role_arn = module.iam.analytics_ec2_role_arn
  //  analytics_db_user_password = var.analytics_db_user_password
  //  analytics_db_user_username = var.analytics_db_user_username
  //  analytics_db_name_port_host = module.analytics.analytics_db_name_port_host

  docker_password = var.docker_password
  docker_username = var.docker_username
  codebuild_role_arn = module.iam.codebuild_role_arn
}

//module "region_us_west_2" {
//  source = "../region"
//  count = contains(var.regions, "us-west-2") ? 1 : 0
//  providers = {
//    aws = aws.us_west_2
//  }
//  environment = var.environment
//  domain = var.domain
//  hosted_zone_id = var.hosted_zone_id
//  desired_counts_by_service = var.desired_counts_by_service
//
//  ecs_task_role_arns = module.iam.ecs_task_role_arns
//  db_username = var.db_username
//  db_password = var.db_password
//  plaid_secret = var.plaid_secret
//  plaid_host = var.plaid_host
//  fmp_key = var.fmp_key
//  anonymize_user_hmac_key = var.anonymize_user_hmac_key
//  email_host_password = var.email_host_password
//  email_host_user = var.email_host_user
//  notifications_email = var.notifications_email
//  sendgrid_api_key = var.sendgrid_api_key
//  plaid_client_id = var.plaid_client_id
//  validation_record_fqdns = var.validation_record_fqdns
//  flow_logs_role_arn = module.iam.flow_logs_role_arn
//  firehose_delivery_role = module.iam.firehose_delivery_role_arn

//  analytics_ec2_role_arn = module.iam.analytics_ec2_role_arn
//  analytics_db_user_password = var.analytics_db_user_password
//  analytics_db_user_username = var.analytics_db_user_username
//  analytics_db_name_port_host = module.analytics.analytics_db_name_port_host

//  docker_password = var.docker_password
//  docker_username = var.docker_username
//  codebuild_role_arn = module.iam.codebuild_role_arn
//}

module "latency_routing" {
  source = "../latency_routing"
  providers = {
    aws = aws
  }
  regions        = var.regions
  environment    = var.environment
  alb_dns_names  = local.alb_dns_names
  alb_zone_ids   = local.alb_zone_ids
  hosted_zone_id = var.hosted_zone_id
  domain         = var.domain
}

module "codebuild" {
  source = "../codebuild"
  providers = {
    aws = aws.us_west_1
  }
  region      = "us-west-1"
  environment = var.environment
  role_arn    = module.iam.codebuild_role_arn
}


//module "analytics" {
//  source = "../analytics"
//  providers = {
//    aws = aws.us_west_1
//  }
//  environment = var.environment
//  app_subnet_id = module.region_us_west_1[0].app_subnet_ids[0]
//  data_subnet_ids = module.region_us_west_1[0].data_subnet_ids
//  analytics_db_master_password = var.analytics_db_master_password
//  analytics_db_master_username = var.analytics_db_master_username
//  analytics_db_user_password = var.analytics_db_user_password
//  analytics_db_user_username = var.analytics_db_user_username
//  sg_analytics_id = module.region_us_west_1[0].sg_analytics_id
//  sg_analyticsdb_id = module.region_us_west_1[0].sg_analyticsdb_id
//  db_name_port_host = module.region_us_west_1[0].db_name_port_host
//  ec2_analytics_role_name = module.iam.ec2_analytics_role_name
//}


module "iam" {
  source             = "../iam"
  environment        = var.environment
  regions            = var.regions
  codeconnection_arn = module.codebuild.codeconnection_arn
  vpce_ids           = local.vpce_ids
  ssm_env_arns       = module.region_us_west_1[0].ssm_env_arns
  secret_arns        = module.region_us_west_1[0].secret_arns
  secret_kms_ids     = local.secret_kms_ids
  ssm_kms_ids        = local.ssm_kms_ids
  //  analytics_ssm_env_arns = module.region_us_west_1[0].analytics_ssm_env_arns
  //  analytics_secret_arns = module.region_us_west_1[0].analytics_secret_arns
  //  analytics_secret_kms_id = module.region_us_west_1[0].analytics_secret_kms_id
  //  analytics_ssm_kms_id = module.region_us_west_1[0].analytics_ssm_kms_id
  ecs_kms_arns                = local.ecs_kms_arns
  monitoring_logs_bucket_arns = local.monitoring_logs_bucket_arns
  cloudtrail_bucket_arn       = local.cloudtrail_bucket_arn
  
  codebuild_kms_arns = local.codebuild_kms_arns
  codebuild_ssm_arns = values(module.region_us_west_1[0].codebuild_env_var_arns)
  codebuild_secrets_arns = values(module.region_us_west_1[0].codebuild_secret_arns)
}


