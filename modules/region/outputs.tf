//output "analytics_sg_id" {
//    value = module.vpc.sg_analytics_id
//}

output "app_subnet_ids" {
    value = module.vpc.app_subnet_ids
}

output "data_subnet_ids" {
    value = module.vpc.data_subnet_ids
}

output "alb_dns_name" {
  value = module.ecs.alb_dns_name
}

output "alb_zone_id" {
  value = module.ecs.alb_zone_id
} 

output "domain_validation_options" {
    value = module.acm_cert.domain_validation_options
}

output "vpce_ids" {
    value = module.vpc.vpce_ids
}

output "ssm_env_arns" {
    value = module.env_vars.ssm_env_arns
}

output "secret_arns" {
    value = module.env_vars.secret_arns
}

output "ssm_kms_id" {
    value = module.env_vars.ssm_kms_id
}

output "secret_kms_id" {
    value = module.env_vars.secret_kms_id
}

//output "sg_analyticsdb_id" {
//    value = module.vpc.sg_analyticsdb_id
//}

//output "sg_analytics_id" {
//    value = module.vpc.sg_analytics_id
//}

output "db_name_port_host" {
    value = module.database.db_name_port_host
}

//output "analytics_ssm_env_arns" {
//    value = data.aws_region.region.name == "us-west-1" ? module.env_vars.analytics_ssm_env_arns : null
//}

//output "analytics_secret_arns" {
//    value = data.aws_region.region.name == "us-west-1" ? module.env_vars.analytics_secret_arns : null
//}

//output "analytics_secret_kms_id" {
//    value = data.aws_region.region.name == "us-west-1" ? module.env_vars.analytics_secret_kms_id : null
//}

//output "analytics_ssm_kms_id" {
//    value = data.aws_region.region.name == "us-west-1" ? module.env_vars.analytics_ssm_kms_id : null
//}

output "ecs_kms_arns" {
    value = module.ecs.kms_arns
}