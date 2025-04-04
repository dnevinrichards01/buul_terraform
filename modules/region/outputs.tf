output "analytics_sg_id" {
    value = module.vpc.sg_analytics_id
}

output "app_subnet_ids" {
    value = module.vpc.app_subnet_ids
}
