output "analytics_sg_id" {
    value = module.vpc.sg_analytics_id
}

output "app_subnet_ids" {
    value = module.vpc.app_subnet_ids
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