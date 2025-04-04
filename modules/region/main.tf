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
  secrets_arns = module.env_vars.secrets_arns
  ecr_repo_names = module.ecr.repo_names 
  ecs_task_role_arns = var.ecs_task_role_arns
  acm_cert_arn = module.acm.acm_cert_arn
}


module "acm" {
  source = "../acm"
  providers = {
    aws = aws
  }
  region = data.aws_region.region.name
  environment = var.environment
  domain_name = var.domain_name
  alb_dns_name = module.ecs.alb_dns_name
  alb_zone_id = module.ecs.alb_zone_id
}


module "env_vars" {
  source = "../env_vars"
  providers = {
    aws = aws
  }
  region = data.aws_region.region.name
  environment = var.environment
  secret_policy_doc_json = var.secret_policy_doc_json
  sqs_urls = module.sqs.sqs_urls
  redis_no_cluster_host_port_url = module.cache.redis_no_cluster_host_port_url
  db_username = var.db_username
  plaid_secret = var.plaid_secret
  plaid_host = var.plaid_host
  plaid_client_id = var.plaid_client_id
  db_name_port_host = module.database.db_name_port_host
  email_host_password = var.email_host_password
  fmp_key = var.fmp_key
}



module "sqs" {
  source = "../sqs"
  providers = {
    aws = aws
  }
  region = data.aws_region.region.name
  environment = var.environment
  sqs_access_policy_doc_json = var.sqs_access_policy_doc_json
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
}


data "aws_region" "region" {
  provider = aws
}