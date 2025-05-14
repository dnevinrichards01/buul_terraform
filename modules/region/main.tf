module "vpc" {
  source = "../vpc"
  providers = {
    aws = aws
  }
  region = data.aws_region.region.name
  environment = var.environment
  azs      = data.aws_availability_zones.available.names
}
data "aws_availability_zones" "available" {
  state = "available"
}


module "ecr" {
  source = "../ecr"
  providers = {
    aws = aws
  }
  region = data.aws_region.region.name
  environment = var.environment
  ecs_task_role_arns = var.ecs_task_role_arns
  proxy_role_arn = var.proxy_role_arn
}


module "ecs" {
  source = "../ecs"
  providers = {
    aws = aws
  }
  region = data.aws_region.region.name
  environment = var.environment
  desired_counts_by_service = var.desired_counts_by_service

  vpc_id = module.vpc.vpc_id
  alb_subnet_ids = module.vpc.alb_subnet_ids
  app_subnet_ids = module.vpc.app_subnet_ids
  data_subnet_ids = module.vpc.data_subnet_ids
  alb_security_group_id = module.vpc.sg_alb_id
  app_security_group_id = module.vpc.sg_app_id
  data_security_group_id = module.vpc.sg_data_id
  ssm_env_arns = module.env_vars.ssm_env_arns
  secrets_arns = module.env_vars.secret_arns
  ecr_repo_names = module.ecr.repo_names 
  ecs_task_role_arns = var.ecs_task_role_arns
  acm_cert_arn = module.acm_cert.acm_cert_arn
  vpce_ids = module.vpc.vpce_ids

  proxy_secret_arns = module.env_vars.proxy_secret_arns
  proxy_ssm_env_arns = module.env_vars.proxy_ssm_env_arns
  proxy_task_role_arn = var.proxy_role_arn
}


module "acm_cert" {
  source = "../acm_cert"
  providers = {
    aws = aws
  }
  environment = var.environment
  region = data.aws_region.region.name
  hosted_zone_id = var.hosted_zone_id
  domain = var.domain
  validation_record_fqdns = var.validation_record_fqdns
}

module "env_vars" {
  source = "../env_vars"
  providers = {
    aws = aws
  }
  region = data.aws_region.region.name
  environment = var.environment
  sqs_urls = module.sqs.sqs_urls
  redis_no_cluster_host_port_url = module.cache.redis_no_cluster_host_port_url
  db_username = var.db_username
  db_password = var.db_password
  plaid_secret = var.plaid_secret
  plaid_host = var.plaid_host
  plaid_client_id = var.plaid_client_id
  db_name_port_host = module.database.db_name_port_host
  email_host_password = var.email_host_password
  email_host_user = var.email_host_user
  notifications_email = var.notifications_email
  sendgrid_api_key = var.sendgrid_api_key
  fmp_key = var.fmp_key
  ecs_task_role_arns = var.ecs_task_role_arns
  vpce_ids = module.vpc.vpce_ids
  kms_aliases = module.ecs.kms_aliases
  analytics_db_user_password = var.analytics_db_user_password
  analytics_db_user_username = var.analytics_db_user_username
  analytics_db_name_port_host = var.analytics_db_name_port_host
  analytics_ec2_role_arn = var.analytics_ec2_role_arn
  anonymize_user_hmac_key = var.anonymize_user_hmac_key
  domain = var.domain

  proxy_master_key = var.proxy_master_key
  proxy_role_arn = var.proxy_role_arn
  proxy_db_user_username = var.proxy_db_user_username
  proxy_db_user_password = var.proxy_db_user_password
  proxy_db_name_port_host = module.database.proxy_db_name_port_host
}


module "sqs" {
  source = "../sqs"
  providers = {
    aws = aws
  }
  region = data.aws_region.region.name
  environment = var.environment
  ecs_task_role_arns = var.ecs_task_role_arns
  vpce_ids = module.vpc.vpce_ids
}


module "cache" {
  source = "../cache"
  providers = {
    aws = aws
  }
  region = data.aws_region.region.name
  environment = var.environment

  data_subnet_ids = module.vpc.data_subnet_ids
  data_security_group_id = module.vpc.sg_data_id
}


module "database" {
  source = "../database"
  providers = {
    aws = aws
  }
  region = data.aws_region.region.name
  environment = var.environment

  data_subnet_ids = module.vpc.data_subnet_ids
  data_security_group_id = module.vpc.sg_data_id
  db_username_final = module.env_vars.db_username_final
  db_password_final = module.env_vars.db_password_final

  proxy_db_user_username = var.proxy_db_user_username
  proxy_db_user_password = var.proxy_db_user_password
}


data "aws_region" "region" {
  provider = aws
}