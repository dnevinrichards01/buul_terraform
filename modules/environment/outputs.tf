output "domain_validation_options" {
    value = module.region_us_west_1[0].domain_validation_options
}

output "alb_dns_names" {
    value = local.alb_dns_names
}

output "alb_zone_ids" {
    value = local.alb_zone_ids
}